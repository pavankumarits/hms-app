package main

import (
	"log"
	"os"
	"strings"

	"hms-service/db"
	"hms-service/handlers"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/joho/godotenv"
)

func main() {
	// 1. Load Environment Variables (from the parent backend folder if possible, or local)
	// Try loading from ../.env (shared with Python)
	if err := godotenv.Load("../.env"); err != nil {
		log.Println("Warning: Could not load ../.env file, trying .env")
		if err := godotenv.Load(); err != nil {
			log.Println("Warning: No .env file found. Relying on System ENV")
		}
	}

	// 2. Initialize Database Connection
	dbUrl := os.Getenv("DATABASE_URL")
	if dbUrl == "" {
		log.Fatal("DATABASE_URL is not set")
	}
	// Remove python driver prefix if present
	dbUrl = strings.Replace(dbUrl, "+asyncpg", "", 1)

	dbPool, err := db.Connect(dbUrl)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v\n", err)
	}
	defer dbPool.Close()

	log.Println("✅ Connected to Neon PostgreSQL (Go Service)")

	// 3. Setup Web Server (Fiber)
	app := fiber.New(fiber.Config{
		AppName:     "HMS High Scale Service",
		JSONEncoder: nil, // Use default for now, can swap to sonic/goccy later
		JSONDecoder: nil,
	})

	// Middleware
	app.Use(logger.New())
	app.Use(cors.New())

	// 4. Routes
	api := app.Group("/api/v1")

	// Health Check
	api.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok", "service": "Go/Fiber"})
	})

	// High Scale Sync Endpoint
	// Pass the DB pool to the handler
	syncHandler := handlers.NewSyncHandler(dbPool)
	api.Post("/sync", syncHandler.HandleSync)

	// 5. Start Server
	// Run on Port 8001 (leaving 8000 for Python)
	port := os.Getenv("GO_PORT")
	if port == "" {
		port = "8001"
	}

	log.Printf("🚀 Go Service listening on port %s", port)
	log.Fatal(app.Listen(":" + port))
}
