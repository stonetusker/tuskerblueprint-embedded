package main

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
	"time"
)

func testApp(mode string) *application {
	return &application{
		cfg:          configuration{DeviceID: "test-device", FailureMode: mode},
		logger:       slog.New(slog.NewTextHandler(os.Stdout, nil)),
		imageVersion: "test-image", startedAt: time.Now().UTC(),
	}
}

func TestHealth(t *testing.T) {
	app := testApp("none")
	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	rec := httptest.NewRecorder()
	app.health(rec, req)
	if rec.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", rec.Code)
	}
	var response healthResponse
	if err := json.Unmarshal(rec.Body.Bytes(), &response); err != nil {
		t.Fatal(err)
	}
	if response.Status != "healthy" || response.DeviceID != "test-device" {
		t.Fatalf("unexpected response: %+v", response)
	}
}

func TestControlledHealthFailure(t *testing.T) {
	app := testApp("health")
	rec := httptest.NewRecorder()
	app.health(rec, httptest.NewRequest(http.MethodGet, "/health", nil))
	if rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("expected 503, got %d", rec.Code)
	}
}

func TestVersion(t *testing.T) {
	app := testApp("none")
	rec := httptest.NewRecorder()
	app.version(rec, httptest.NewRequest(http.MethodGet, "/version", nil))
	if rec.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", rec.Code)
	}
}

func TestSensorSequence(t *testing.T) {
	app := testApp("none")
	first := httptest.NewRecorder()
	app.sensor(first, httptest.NewRequest(http.MethodGet, "/sensor", nil))
	second := httptest.NewRecorder()
	app.sensor(second, httptest.NewRequest(http.MethodGet, "/sensor", nil))
	var a, b sensorResponse
	_ = json.Unmarshal(first.Body.Bytes(), &a)
	_ = json.Unmarshal(second.Body.Bytes(), &b)
	if b.Sequence != a.Sequence+1 {
		t.Fatalf("expected incrementing sequence, got %d then %d", a.Sequence, b.Sequence)
	}
}

func TestDefaultDeviceIDFromEnvironment(t *testing.T) {
	t.Setenv("SENSORNODE_DEVICE_ID", "device-from-environment")
	if got := defaultDeviceID(); got != "device-from-environment" {
		t.Fatalf("expected environment device ID, got %q", got)
	}
}
