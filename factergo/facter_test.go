package facter

import (
	"encoding/json"
	"testing"
)

func Test_GetFacts(t *testing.T) {
	facts, fErr := GetFacts()

	if fErr != nil {
		t.Fatalf("Error thrown while retrieving facts: %v", fErr)
	}

	var decodedJSON map[string]interface{}
	jErr := json.Unmarshal([]byte(facts), &decodedJSON)

	if jErr != nil {
		t.Fatal("Facts are not in a valid JSON format")
	}

	if len(decodedJSON) == 0 {
		t.Fatal("Failed to gather any fact")
	}
}
