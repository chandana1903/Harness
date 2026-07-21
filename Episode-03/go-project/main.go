package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"runtime"
)

type Response struct {
	Message        string `json:"message"`
	Episode        int    `json:"episode"`
	Project        string `json:"project"`
	Language       string `json:"language"`
	GoVersion      string `json:"go_version"`
	Infrastructure string `json:"infrastructure"`
	Status         string `json:"status"`
}

type HealthResponse struct {
	Status string `json:"status"`
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	resp := Response{
		Message:        "Hello from Harness CI/CD Course!",
		Episode:        3,
		Project:        "Go App with Docker Delegate on AWS EC2",
		Language:       "Go",
		GoVersion:      runtime.Version(),
		Infrastructure: "Docker Delegate on AWS EC2",
		Status:         "running",
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	resp := HealthResponse{Status: "healthy"}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/health", healthHandler)

	fmt.Printf("Server starting on port %s\n", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
