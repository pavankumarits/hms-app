# High Scale Go Service

This service handles high-throughput data ingestion for the HMS App.

## Prerequisites
- **Go 1.21+**: [Install Go](https://go.dev/dl/)
- **PostgreSQL**: (Configuration is in `../.env` via `DATABASE_URL`)

## Setup
1. Open this directory in terminal:
   ```powershell
   cd backend/go-service
   ```
2. Install dependencies:
   ```powershell
   go mod tidy
   ```

## Running
```powershell
go run main.go
```
The service will listen on Port **8001**.
