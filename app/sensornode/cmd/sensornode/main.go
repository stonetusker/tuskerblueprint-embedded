package main

import (
	"context"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"log/slog"
	"math"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"strconv"
	"strings"
	"sync/atomic"
	"syscall"
	"time"
)

var (
	version   = "development"
	gitCommit = "unknown"
	buildTime = "unknown"
)

type configuration struct {
	ListenAddress    string
	DeviceID         string
	ImageVersionFile string
	FailureMode      string
	ShutdownTimeout  time.Duration
}

type application struct {
	cfg          configuration
	logger       *slog.Logger
	imageVersion string
	startedAt    time.Time
	sequence     atomic.Uint64
}

type healthResponse struct {
	Status             string `json:"status"`
	ApplicationVersion string `json:"application_version"`
	ImageVersion       string `json:"image_version"`
	DeviceID           string `json:"device_id"`
	UptimeSeconds      int64  `json:"uptime_seconds"`
}

type versionResponse struct {
	ApplicationVersion string `json:"application_version"`
	ImageVersion       string `json:"image_version"`
	GitCommit          string `json:"git_commit"`
	BuildTime          string `json:"build_time"`
	DeviceID           string `json:"device_id"`
}

type sensorResponse struct {
	DeviceID string  `json:"device_id"`
	Sequence uint64  `json:"sequence"`
	Value    float64 `json:"value"`
	Unit     string  `json:"unit"`
	Time     string  `json:"timestamp"`
}

func main() {
	cfg, err := loadConfiguration()
	if err != nil {
		fmt.Fprintf(os.Stderr, "configuration error: %v\n", err)
		os.Exit(2)
	}

	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))
	imageVersion := readTextFile(cfg.ImageVersionFile, "unknown")
	app := &application{cfg: cfg, logger: logger, imageVersion: imageVersion, startedAt: time.Now().UTC()}

	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", app.health)
	mux.HandleFunc("GET /version", app.version)
	mux.HandleFunc("GET /sensor", app.sensor)
	mux.HandleFunc("GET /ready", app.ready)

	server := &http.Server{
		Addr:              cfg.ListenAddress,
		Handler:           requestLogger(logger, mux),
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       10 * time.Second,
		WriteTimeout:      10 * time.Second,
		IdleTimeout:       60 * time.Second,
	}

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		logger.Info("sensornode starting",
			"listen", cfg.ListenAddress,
			"device_id", cfg.DeviceID,
			"application_version", version,
			"image_version", imageVersion,
			"git_commit", gitCommit,
			"build_time", buildTime,
			"failure_mode", cfg.FailureMode,
		)
		if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			logger.Error("http server failed", "error", err)
			os.Exit(1)
		}
	}()

	<-stop
	logger.Info("shutdown requested")
	ctx, cancel := context.WithTimeout(context.Background(), cfg.ShutdownTimeout)
	defer cancel()
	if err := server.Shutdown(ctx); err != nil {
		logger.Error("graceful shutdown failed", "error", err)
		os.Exit(1)
	}
	logger.Info("sensornode stopped")
}

func loadConfiguration() (configuration, error) {
	listen := flag.String("listen", envOrDefault("SENSORNODE_LISTEN", ":8080"), "HTTP listen address")
	deviceID := flag.String("device-id", defaultDeviceID(), "device identifier")
	imageVersionFile := flag.String("image-version-file", envOrDefault("SENSORNODE_IMAGE_VERSION_FILE", "/etc/sensornode/image-version"), "image version file")
	failureMode := flag.String("failure-mode", envOrDefault("SENSORNODE_FAILURE_MODE", "none"), "controlled failure mode")
	shutdownTimeout := flag.Duration("shutdown-timeout", 10*time.Second, "graceful shutdown timeout")
	flag.Parse()

	allowed := map[string]bool{"none": true, "health": true, "ready": true, "exit": true}
	if !allowed[*failureMode] {
		return configuration{}, fmt.Errorf("unsupported failure mode %q", *failureMode)
	}
	if *failureMode == "exit" {
		return configuration{}, errors.New("controlled startup failure requested")
	}
	return configuration{
		ListenAddress: *listen, DeviceID: *deviceID, ImageVersionFile: *imageVersionFile,
		FailureMode: *failureMode, ShutdownTimeout: *shutdownTimeout,
	}, nil
}

func (a *application) health(w http.ResponseWriter, _ *http.Request) {
	if a.cfg.FailureMode == "health" {
		writeJSON(w, http.StatusServiceUnavailable, map[string]string{"status": "unhealthy", "reason": "controlled failure"})
		return
	}
	writeJSON(w, http.StatusOK, healthResponse{
		Status: "healthy", ApplicationVersion: version, ImageVersion: a.imageVersion,
		DeviceID: a.cfg.DeviceID, UptimeSeconds: int64(time.Since(a.startedAt).Seconds()),
	})
}

func (a *application) ready(w http.ResponseWriter, _ *http.Request) {
	if a.cfg.FailureMode == "ready" {
		writeJSON(w, http.StatusServiceUnavailable, map[string]string{"status": "not_ready"})
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"status": "ready"})
}

func (a *application) version(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, versionResponse{
		ApplicationVersion: version, ImageVersion: a.imageVersion, GitCommit: gitCommit,
		BuildTime: buildTime, DeviceID: a.cfg.DeviceID,
	})
}

func (a *application) sensor(w http.ResponseWriter, _ *http.Request) {
	seq := a.sequence.Add(1)
	value := 22.0 + math.Sin(float64(seq)/10.0)*2.5
	writeJSON(w, http.StatusOK, sensorResponse{
		DeviceID: a.cfg.DeviceID, Sequence: seq, Value: math.Round(value*100) / 100,
		Unit: "celsius", Time: time.Now().UTC().Format(time.RFC3339Nano),
	})
}

func requestLogger(logger *slog.Logger, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		logger.Info("request", "method", r.Method, "path", r.URL.Path, "duration_ms", time.Since(start).Milliseconds())
	})
}

func writeJSON(w http.ResponseWriter, status int, value any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(value); err != nil {
		slog.Error("response encoding failed", "error", err)
	}
}

func readTextFile(path, fallback string) string {
	data, err := os.ReadFile(filepath.Clean(path))
	if err != nil {
		return fallback
	}
	value := strings.TrimSpace(string(data))
	if value == "" {
		return fallback
	}
	return value
}

func envOrDefault(name, fallback string) string {
	if value := strings.TrimSpace(os.Getenv(name)); value != "" {
		return value
	}
	return fallback
}

func defaultDeviceID() string {
	if value := strings.TrimSpace(os.Getenv("SENSORNODE_DEVICE_ID")); value != "" {
		return value
	}
	if data, err := os.ReadFile("/proc/cmdline"); err == nil {
		for _, field := range strings.Fields(string(data)) {
			if value, found := strings.CutPrefix(field, "sensornode.device_id="); found && strings.TrimSpace(value) != "" {
				return value
			}
		}
	}
	return hostname()
}

func hostname() string {
	name, err := os.Hostname()
	if err != nil || strings.TrimSpace(name) == "" {
		return "sensornode-unknown"
	}
	return name
}

func parsePort(address string) int {
	parts := strings.Split(address, ":")
	value, _ := strconv.Atoi(parts[len(parts)-1])
	return value
}
