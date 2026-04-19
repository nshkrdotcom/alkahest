package gateway

import "testing"

func TestNormalizeError(t *testing.T) {
	err := normalizeError(assertionError("boom"))
	if err.GetCode() != "temporal_error" {
		t.Fatalf("expected temporal_error, got %s", err.GetCode())
	}
	if !err.GetRetryable() {
		t.Fatal("expected retryable error")
	}
}

type assertionError string

func (err assertionError) Error() string {
	return string(err)
}
