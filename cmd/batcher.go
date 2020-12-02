package main

import (
	"database/sql"
	"flag"
	"fmt"
	_ "github.com/lib/pq"
	"log"
	"os"
)

type jobConfig struct {
	command  string
	table    string
	set      string
	where    string
	batch    int
	execute  bool
	user     string
	password string
	database string
	host     string
	portnum  string
}

var (
	VERSION = "0.1.0"
)

func parseArgs() *jobConfig {

	fs := flag.NewFlagSet("update or delete", flag.ExitOnError)

	tablePtr := fs.String("table", "", "table name")
	setPtr := fs.String("set", "", "e.g. 'column_name=value, column_name=value ...' (ignored if provided with delete subcommand)")
	wherePtr := fs.String("where", "", "e.g. 'column=value AND column IS NOT NULL ...'")
	batchPtr := fs.Int("batch", 100, "batch size")
	executePtr := fs.Bool("execute", false, "execute the operation ('dry-run' only by default)")
	userPtr := fs.String("user", "", "user name")
	passwordPtr := fs.String("password", "", "password")
	databasePtr := fs.String("database", "", "database name")
	hostPtr := fs.String("host", "localhost", "host name or IP")
	portnumPtr := fs.String("portnum", "", "port number")

	jc := jobConfig{command: ""}

	if len(os.Args) > 1 {
		jc.command = os.Args[1]
	}

	fs.Parse(os.Args[2:])

	jc.table = *tablePtr
	jc.where = *wherePtr
	jc.batch = *batchPtr
	jc.execute = *executePtr
	jc.user = *userPtr
	jc.password = *passwordPtr
	jc.database = *databasePtr
	jc.host = *hostPtr
	jc.portnum = *portnumPtr

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

func getConnection(database string, user string, password string) (*sql.DB, error) {
	// connStr := fmt.Sprintf("postgresql://%s:%s@localhost:26257/%s?sslmode=disable", user, password, database)
	connStr := fmt.Sprintf("postgresql://%s@localhost:26257/%s?sslmode=disable", user, database)
	fmt.Println(connStr)
	// db, err := sql.Open("postgres", "postgresql://root@localhost:26257/default?sslmode=disable")
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("error connecting to the database: ", err)
	}
	return db, err
}

func countRows(db *sql.DB, database string, table string, where string) (rowcount int) {
	sqlstr := fmt.Sprintf("SELECT COUNT(1) FROM %s.%s WHERE %s;\n", database, table, where)
	rows, err := db.Query(sqlstr)
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

func do_main() {
	jobConfig := parseArgs()
	fmt.Println(jobConfig.command, jobConfig.database, jobConfig.table, jobConfig.set, jobConfig.where, jobConfig.batch, jobConfig.execute, jobConfig.user, jobConfig.password)
	conn, err := getConnection(jobConfig.database, jobConfig.user, jobConfig.password)
	if err != nil {
		log.Fatal("error connecting to the database: ", err)
	}
	// rowsleft := countRows(conn, jobConfig.database, jobConfig.table, jobConfig.where)
	// fmt.Println("Rows left: ", rowsleft)

	while countRows(conn, jobConfig.database, jobConfig.table, jobConfig.where) > 0 {
	}
}

func main() {
	do_main()
}

