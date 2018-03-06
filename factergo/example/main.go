package main

import (
	"fmt"
	"log"

	"github.com/puppetlabs/facter/factergo"
)

func main() {
	log.Println("Gathering Facts...")
	facts, err := factergo.GetFacts()
	if err != nil {
		log.Fatalf("Error gathering Facts: %v", err)
	}
	fmt.Println(facts)
}
