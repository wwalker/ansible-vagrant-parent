package main

import (
	"flag"
	"log"
	"net/http"
)

var (
	addr    = flag.String("http", ":8080", "addr:port to serve on")
	datadir = flag.String("d", ".", "the directory of static file to host")
)

func main() {
	flag.Parse()

	http.Handle("/", http.FileServer(http.Dir(*datadir)))

	log.Printf("Serving '%s' over HTTP on: %s", *datadir, *addr)

	log.Fatal(http.ListenAndServe(*addr, nil))
}
