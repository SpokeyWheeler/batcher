package main

import (
	"bytes"
	"database/sql"
	"flag"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	_ "github.com/lib/pq"
	"log"
	"os"
	"sync"
)

type jobConfig struct {
	command     string
	table       string
	set         string
	where       string
	concurrency int
	execute     bool
	verbose     bool
	user        string
	password    string
	database    string
	host        string
	dbtype      string
	portnum     string
	opts        string
}

type primaryKey struct {
	colname string
	coltype string
}

var (
	version = "undefined"
)

func parseArgs() *jobConfig {

	fs := flag.NewFlagSet("update or delete", flag.ExitOnError)

	tablePtr := fs.String("table", "", "table name")
	setPtr := fs.String("set", "", "e.g. 'column_name=value, column_name=value ...' (ignored if provided with delete subcommand)")
	wherePtr := fs.String("where", "", "e.g. 'column=value AND column IS NOT NULL ...'")
	concurrencyPtr := fs.Int("concurrency", 20, "concurrency")
	executePtr := fs.Bool("execute", false, "execute the operation ('dry-run' only by default)")
	verbosePtr := fs.Bool("verbose", false, "provide detailed output (will output all statements to the screen)")
	userPtr := fs.String("user", "", "user name")
	passwordPtr := fs.String("password", "", "password")
	databasePtr := fs.String("database", "", "database name")
	hostPtr := fs.String("host", "localhost", "host name or IP")
	dbtypePtr := fs.String("dbtype", "postgres", "database type, e.g. postgres, informix, oracle, mysql")
	portnumPtr := fs.String("portnum", "26257", "port number")
	optsPtr := fs.String("opts", "sslmode=require", "JDBC URL options (e.g. sslmode=disable)")

	jc := jobConfig{command: ""}

	if len(os.Args) > 1 {
		jc.command = os.Args[1]

		fs.Parse(os.Args[2:])

		jc.table = *tablePtr
		jc.where = *wherePtr
		jc.concurrency = *concurrencyPtr
		jc.execute = *executePtr
		jc.verbose = *verbosePtr
		jc.user = *userPtr
		jc.password = *passwordPtr
		jc.database = *databasePtr
		jc.host = *hostPtr
		jc.dbtype = *dbtypePtr
		jc.portnum = *portnumPtr
		jc.opts = *optsPtr

		if jc.dbtype == "postgresql" {
			jc.dbtype = "postgres"
		}
	}

	switch jc.command {
	case "update":
		jc.set = *setPtr
	case "delete":
		jc.set = ""
	case "version":
		fmt.Printf("%s Version: %s\n", os.Args[0], version)
		os.Exit(0)
	default:
		fmt.Println("'update', 'delete', 'version' or 'help' subcommand is required")
		fmt.Println("flags:")
		fs.PrintDefaults()
		os.Exit(0)
	}
	return &jc
}

func buildConnectionString(dbtype string, database string, user string, password string, host string, portnum string, opts string) string {
	var builtStr string
	switch dbtype {
	case "postgres":
		builtStr = fmt.Sprintf("postgresql://%s:%s@%s:%s/%s?%s", user, password, host, portnum, database, opts)
	case "mysql":
		builtStr = fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?%s", user, password, host, portnum, database, opts)
	default:
		fmt.Printf("Unknown database type (or not implemented yet) - %s\n", dbtype)
		os.Exit(1)
	}
	return builtStr
}

func getConnection(dbtype string, database string, user string, password string, host string, portnum string, opts string) (*sql.DB, error) {
	connStr := buildConnectionString(dbtype, database, user, password, host, portnum, opts)
	db, err := sql.Open(dbtype, connStr)
	if err != nil {
		log.Fatal("error connecting to the database: ", err)
	}
	return db, err
}

func countRows(db *sql.DB, database string, table string, where string) (rowcount int) {
	sqlStr := fmt.Sprintf("SELECT COUNT(1) FROM %s WHERE %s;\n", table, where)
	crow := db.QueryRow(sqlStr)
	switch err := crow.Scan(&rowcount); err {
	case sql.ErrNoRows:
		fmt.Println("No rows were returned!")
	case nil:
	default:
		panic(err)
	}
	return rowcount
}

func myGetPrimaryKey(db *sql.DB, database string, table string) (mk []primaryKey) {
	var rowcount int
	var currentKey primaryKey

	cntStr := fmt.Sprintf("WITH a AS (SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = '%s' AND table_name = '%s'), b AS (SELECT column_name, constraint_name FROM information_schema.key_column_usage WHERE table_schema = '%s' AND table_name = '%s'), c AS (SELECT constraint_name FROM information_schema.table_constraints WHERE constraint_type = 'PRIMARY KEY' AND table_schema = '%s' AND table_name = '%s') SELECT COUNT(1) FROM b JOIN c ON b.constraint_name = c.constraint_name JOIN a ON a.column_name = b.column_name;", database, table, database, table, database, table)

	_, seterr := db.Exec("SET NAMES 'utf8mb4';")
	if seterr != nil {
		log.Fatal("error setting character set: ", seterr)
	}

	crow := db.QueryRow(cntStr)
	switch err := crow.Scan(&rowcount); err {
	case sql.ErrNoRows:
		log.Println("No rows were returned!")
	case nil:
	default:
		panic(err)
	}
	if rowcount < 1 {
		fmt.Println("No primary key found")
		os.Exit(2)
	}

	sqlStr := fmt.Sprintf("WITH a AS (SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = '%s' AND table_name = '%s'), b AS (SELECT column_name, constraint_name FROM information_schema.key_column_usage WHERE table_schema = '%s' AND table_name = '%s'), c AS (SELECT constraint_name FROM information_schema.table_constraints WHERE constraint_type = 'PRIMARY KEY' AND table_schema = '%s' AND table_name = '%s') SELECT b.column_name, a.data_type FROM b JOIN c ON b.constraint_name = c.constraint_name JOIN a ON a.column_name = b.column_name;", database, table, database, table, database, table)

	rows, err := db.Query(sqlStr)
	if err != nil {
		log.Fatal("error getting key: ", err)
	}
	defer rows.Close()
	for rows.Next() {
		if err := rows.Scan(&currentKey.colname, &currentKey.coltype); err != nil {
			log.Println("Bazinga")
			log.Fatal(err)
		}
		mk = append(mk, currentKey)
	}
	return mk
}

func pgGetPrimaryKey(db *sql.DB, database string, table string) (pk []primaryKey) {
	var rowcount int
	var currentKey primaryKey

	cntStr := fmt.Sprintf("WITH a AS (SELECT column_name, udt_name FROM information_schema.columns WHERE table_catalog = '%s' AND table_schema = 'public' AND table_name = '%s'), b AS (SELECT column_name, constraint_name FROM information_schema.key_column_usage WHERE table_catalog = '%s' AND table_schema = 'public' AND table_name = '%s'), c AS (SELECT constraint_name FROM information_schema.table_constraints WHERE constraint_type = 'PRIMARY KEY' AND table_catalog = '%s' AND table_schema = 'public' AND table_name = '%s') SELECT COUNT(1) FROM b JOIN c ON b.constraint_name = c.constraint_name JOIN a ON a.column_name = b.column_name;", database, table, database, table, database, table)

	crow := db.QueryRow(cntStr)
	switch err := crow.Scan(&rowcount); err {
	case sql.ErrNoRows:
		log.Println("No rows were returned!")
	case nil:
	default:
		panic(err)
	}
	if rowcount < 1 {
		fmt.Println("No primary key found")
		os.Exit(2)
	}

	sqlStr := fmt.Sprintf("WITH a AS (SELECT column_name, udt_name FROM information_schema.columns WHERE table_catalog = '%s' AND table_schema = 'public' AND table_name = '%s'), b AS (SELECT column_name, constraint_name FROM information_schema.key_column_usage WHERE table_catalog = '%s' AND table_schema = 'public' AND table_name = '%s'), c AS (SELECT constraint_name FROM information_schema.table_constraints WHERE constraint_type = 'PRIMARY KEY' AND table_catalog = '%s' AND table_schema = 'public' AND table_name = '%s') SELECT b.column_name, a.udt_name FROM b JOIN c ON b.constraint_name = c.constraint_name JOIN a ON a.column_name = b.column_name;", database, table, database, table, database, table)

	rows, err := db.Query(sqlStr)
	if err != nil {
		log.Fatal("error getting key: ", err)
	}
	defer rows.Close()
	for rows.Next() {
		if err := rows.Scan(&currentKey.colname, &currentKey.coltype); err != nil {
			log.Fatal(err)
		}
		pk = append(pk, currentKey)
	}
	return pk
}

func doCmd(db *sql.DB, pk []primaryKey, jc jobConfig) {
	var wg sync.WaitGroup
	var sqlStr bytes.Buffer
	var prepStr bytes.Buffer

	getKeys := func() chan string {
		sqlStr.WriteString("SELECT ")

		switch jc.command {
		case "update":
			prepStr.WriteString("UPDATE ")
			prepStr.WriteString(jc.table)
			prepStr.WriteString(" SET ")
			prepStr.WriteString(jc.set)
		case "delete":
			prepStr.WriteString("DELETE FROM ")
			prepStr.WriteString(jc.table)
		}
		prepStr.WriteString(" WHERE ")

		for key, value := range pk {
			sqlStr.WriteString(value.colname)
			prepStr.WriteString(value.colname)
			prepStr.WriteString(" = ?")
			if key+1 < len(pk) {
				sqlStr.WriteString(",")
				prepStr.WriteString(" AND ")
			} else {
				sqlStr.WriteString(" FROM ")
				sqlStr.WriteString(jc.table)
				sqlStr.WriteString(" WHERE ")
				sqlStr.WriteString(jc.where)
				sqlStr.WriteString(";")
				prepStr.WriteString(";")
			}
		}

		out := make(chan string)

		rows, err := db.Query(sqlStr.String())
		if err != nil {
			log.Fatal("error fetching key: ", err)
		}
		wg.Add(1)

		go func() {
			defer close(out)
			defer rows.Close()
			defer wg.Done()

			for rows.Next() {
				var retStr bytes.Buffer
				cols, err := rows.Columns()
				if err != nil {
					log.Fatal(err)
				}

				colvals := make([]interface{}, len(cols))
				colassoc := make(map[string]interface{}, len(cols))
				for i := range colvals {
					colvals[i] = new(interface{})
				}
				if err := rows.Scan(colvals...); err != nil {
					log.Fatal(err)
				}
				switch jc.command {
				case "update":
					retStr.WriteString("UPDATE ")
					retStr.WriteString(jc.table)
					retStr.WriteString(" SET ")
					retStr.WriteString(jc.set)
				case "delete":
					retStr.WriteString("DELETE FROM ")
					retStr.WriteString(jc.table)
				}
				retStr.WriteString(" WHERE ")
				for i, col := range cols {
					var t string
					colassoc[col] = *colvals[i].(*interface{})
					switch colassoc[col].(type) {
					case int, int64:
						t = fmt.Sprintf("%d", colassoc[col])
					default:
						t = fmt.Sprintf("%s", colassoc[col])
					}
					retStr.WriteString(col)
					switch jc.dbtype {
					case "mysql":
						retStr.WriteString(" = CAST('")
						retStr.WriteString(t)
						retStr.WriteString("' AS ")
						switch pk[i].coltype {
						case "bigint":
							retStr.WriteString("UNSIGNED INTEGER")
						case "int":
							retStr.WriteString("SIGNED INTEGER")
						default:
							retStr.WriteString("CHAR")
						}
						retStr.WriteString(")")
					default:
						retStr.WriteString(" = '")
						retStr.WriteString(t)
						retStr.WriteString("'::")
						retStr.WriteString(pk[i].coltype)
					}
					if i+1 < len(cols) {
						retStr.WriteString(" AND ")
					}
				}
				retStr.WriteString(";")
				if jc.verbose {
					fmt.Println(retStr.String())
				}
				out <- retStr.String()
			}
		}()
		return out
	}

	cmd := getKeys()

	for i := 0; i < jc.concurrency; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for execution := range cmd {
				if jc.execute {
					_, err := db.Exec(execution)
					if err != nil {
						log.Fatal(err)
					}
				}
			}
		}()
	}

	wg.Wait()
}

func doMain() int {
	var pk []primaryKey
	jc := parseArgs()

	switch jc.command {
	case "update":
		if !jc.execute || jc.verbose {
			fmt.Printf("UPDATE %s SET %s WHERE %s;\n", jc.table, jc.set, jc.where)
		}
	case "delete":
		if !jc.execute || jc.verbose {
			fmt.Printf("DELETE FROM %s WHERE %s;\n", jc.table, jc.where)
		}
	default:
		fmt.Printf("Invalid command '%s'\n", jc.command)
		os.Exit(3)
	}

	db, err := getConnection(jc.dbtype, jc.database, jc.user, jc.password, jc.host, jc.portnum, jc.opts)
	if err != nil {
		log.Fatal("error connecting to the database: ", err)
	}

	switch jc.dbtype {
	case "postgres":
		pk = pgGetPrimaryKey(db, jc.database, jc.table)
	case "mysql":
		pk = myGetPrimaryKey(db, jc.database, jc.table)
	default:
		fmt.Printf("Unknown database type (or not implemented yet) - %s\n", jc.dbtype)
		os.Exit(1)
	}

	rowsleft := countRows(db, jc.database, jc.table, jc.where)
	if !jc.execute || jc.verbose {
		fmt.Printf("Will %s %d row(s)\n", jc.command, rowsleft)
	}

	doCmd(db, pk, *jc)

	return 0
}

func main() {
	ok := doMain()
	if ok != 0 {
		fmt.Println("Something went wrong")
	}

}
