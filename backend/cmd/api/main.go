package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
)

func main() {
	// Setup logger
	logger := log.New(os.Stdout, "", log.Ldate|log.Ltime)

	// Database connection
	db, err := setupDatabase()
	if err != nil {
		logger.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	// Set up router
	router := setupRouter()

	// Set up HTTP server
	server := &http.Server{
		Addr:    ":8080",
		Handler: router,
	}

	// Start server in a goroutine
	go func() {
		logger.Printf("Starting server on port 8080...")
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Fatalf("Server error: %v", err)
		}
	}()

	// Wait for interrupt signal to gracefully shut down the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logger.Println("Shutting down server...")

	// Create a deadline for server shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		logger.Fatalf("Server forced to shutdown: %v", err)
	}

	logger.Println("Server exiting")
}

func setupDatabase() (*sql.DB, error) {
	// Get database connection details from environment variables
	host := getEnv("DB_HOST", "db")
	port := getEnv("DB_PORT", "5432")
	user := getEnv("DB_USER", "postgres")
	password := getEnv("DB_PASSWORD", "postgres")
	dbname := getEnv("DB_NAME", "lottery")

	// Connection string
	connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		host, port, user, password, dbname)

	// Open connection
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		return nil, err
	}

	// Check connection
	err = db.Ping()
	if err != nil {
		return nil, err
	}

	return db, nil
}

func setupRouter() *gin.Engine {
	router := gin.Default()

	// CORS configuration
	config := cors.DefaultConfig()
	config.AllowOrigins = []string{"http://localhost:3000"}
	config.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
	router.Use(cors.New(config))

	// Routes
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status": "UP",
		})
	})

	// API routes - version 1
	v1 := router.Group("/api/v1")
	{
		// Mega 6/45 routes
		mega := v1.Group("/mega")
		{
			mega.GET("/draw", func(c *gin.Context) {
				c.JSON(http.StatusOK, gin.H{
					"message": "Mega 6/45 draw endpoint",
				})
			})
			mega.POST("/ticket", func(c *gin.Context) {
				c.JSON(http.StatusOK, gin.H{
					"message": "Mega 6/45 ticket creation endpoint",
				})
			})
		}

		// Power 6/55 routes
		power := v1.Group("/power")
		{
			power.GET("/draw", func(c *gin.Context) {
				c.JSON(http.StatusOK, gin.H{
					"message": "Power 6/55 draw endpoint",
				})
			})
			power.POST("/ticket", func(c *gin.Context) {
				c.JSON(http.StatusOK, gin.H{
					"message": "Power 6/55 ticket creation endpoint",
				})
			})
		}
	}

	return router
}

// Helper function to get environment variables with fallback
func getEnv(key, fallback string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return fallback
}
