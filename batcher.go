package main

import (
	"bytes"
	"database/sql"
	"flag"
	"fmt"
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
	VERSION = "0.1.1"
)

func parseArgs() *jobConfig {

	fs := flag.NewFlagSet("update or delete", flag.ExitOnError)

	tablePtr := fs.String("table", "", "table name")
	setPtr := fs.String("set", "", "e.g. 'column_name=value, column_name=value ...' (ignored if provided with delete subcommand)")
	wherePtr := fs.String("where", "", "e.g. 'column=value AND column IS NOT NULL ...'")
	concurrencyPtr := fs.Int("concurrency", 20, "concurrency")
	executePtr := fs.Bool("execute", false, "execute the operation ('dry-run' only by default)")
	verbosePtr := fs.Bool("verbose", false, "provide detailed output")
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
	}

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

	switch jc.command {
	case "update":
		jc.set = *setPtr
	case "delete":
		jc.set = ""
	case "version":
		fmt.Printf("%s Version: %s\n", os.Args[0], VERSION)
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
	sqlStr := fmt.Sprintf("SELECT COUNT(1) FROM %s.%s WHERE %s;\n", database, table, where)
	rows, err := db.Query(sqlStr)
	if err != nil {
		log.Fatal("error counting rows: ", err)
	}
	defer rows.Close()
	for rows.Next() {
		if err := rows.Scan(&rowcount); err != nil {
			log.Fatal(err)
		}
	}
	return rowcount
}

func getPrimaryKey(db *sql.DB, database string, table string) (pk []primaryKey) {
	var rowcount int
	var currentKey primaryKey

	cntStr := fmt.Sprintf("with a as (select column_name, udt_name from information_schema.columns where table_catalog = '%s' and table_schema = 'public' and table_name = '%s'), b as (select column_name, constraint_name from information_schema.constraint_column_usage where table_catalog = '%s' and table_schema = 'public' and table_name = '%s'), c as (select constraint_name from information_schema.table_constraints where constraint_type = 'PRIMARY KEY' and table_catalog = '%s' and table_schema = 'public' and table_name = '%s') select count(1) from b join c on b.constraint_name = c.constraint_name join a on a.column_name = b.column_name;", database, table, database, table, database, table)

	crows, err := db.Query(cntStr)
	if err != nil {
		log.Fatal("error counting primary key elements: ", err)
	}
	defer crows.Close()
	for crows.Next() {
		if err := crows.Scan(&rowcount); err != nil {
			log.Fatal(err)
		}
	}

	if rowcount < 1 {
		fmt.Println(cntStr)
		fmt.Println("No primary key found")
		os.Exit(2)
	}

	sqlStr := fmt.Sprintf("with a as (select column_name, udt_name from information_schema.columns where table_catalog = '%s' and table_schema = 'public' and table_name = '%s'), b as (select column_name, constraint_name from information_schema.constraint_column_usage where table_catalog = '%s' and table_schema = 'public' and table_name = '%s'), c as (select constraint_name from information_schema.table_constraints where constraint_type = 'PRIMARY KEY' and table_catalog = '%s' and table_schema = 'public' and table_name = '%s') select b.column_name, a.udt_name from b join c on b.constraint_name = c.constraint_name join a on a.column_name = b.column_name;", database, table, database, table, database, table)

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
				sqlStr.WriteString(";\n")
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
				for i, _ := range colvals {
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
					retStr.WriteString(" = '")
					retStr.WriteString(t)
					retStr.WriteString("'::")
					retStr.WriteString(pk[i].coltype)
					if i+1 < len(cols) {
						retStr.WriteString(" AND ")
					}
				}
				retStr.WriteString(";")
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
				if jc.verbose {
					fmt.Println(execution)
				}
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
	jc := parseArgs()

	switch jc.command {
	case "update":
		if jc.verbose {
			fmt.Printf("UPDATE %s SET %s WHERE %s;\n", jc.table, jc.set, jc.where)
		}
	case "delete":
		if jc.verbose {
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

	pk := getPrimaryKey(db, jc.database, jc.table)

	rowsleft := countRows(db, jc.database, jc.table, jc.where)
	if jc.verbose {
		fmt.Println("Starting row count: ", rowsleft)
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
