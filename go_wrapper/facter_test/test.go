package main

import (
	"fmt"
	"facter"
)

func main() {
	fmt.Println("### We're here!")
	facts, err := facter.GetFacts()
	if err != nil {
		fmt.Printf("Error throw calling libral.GetFacts: %v", err)
		return
	}
	fmt.Printf("Successfully called libral.GetFacts\n")
	fmt.Printf("### Facts: %v\n", facts)
}
