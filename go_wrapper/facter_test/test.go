package main

import (
	"facter"
	"fmt"
)

func main() {
	fmt.Println("\n\n### Testing GetFacts()\n")
	facts, err := facter.GetFacts()
	if err != nil {
		fmt.Printf("Error throw calling facter.GetFacts: %v", err)
		return
	}
	fmt.Printf("Successfully called facter.GetFacts\n")
	fmt.Printf("### Facts:\n%v\n", facts)
}
