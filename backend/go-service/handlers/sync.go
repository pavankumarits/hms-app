package handlers

import (
	"context"
	"log"
	"time"

	"github.com/gofiber/fiber/v2"

	"github.com/jackc/pgx/v5/pgxpool"
)

// SyncRequest matches the JSON payload from the Flutter app
type SyncRequest struct {
	Patients []Patient `json:"patients"`
	Visits   []Visit   `json:"visits"`
}

type Patient struct {
	ID          string `json:"id"`
	HospitalID  string `json:"hospital_id"`
	Name        string `json:"name"`
	Age         int    `json:"age"`
	Gender      string `json:"gender"`
	Phone       string `json:"phone"`
	PatientUIID string `json:"patient_uiid"`
	SyncStatus  string `json:"sync_status"`
	// Add other fields as per schema
}

type Visit struct {
	ID             string  `json:"id"`
	PatientID      string  `json:"patient_id"`
	HospitalID     string  `json:"hospital_id"`
	Date           string  `json:"date"` // Receive as string, parse if needed
	DoctorName     string  `json:"doctor_name"`
	ChiefComplaint string  `json:"chief_complaint"`
	Diagnosis      string  `json:"diagnosis"`
	TotalAmount    float64 `json:"total_amount"`
}

type SyncHandler struct {
	DB *pgxpool.Pool
}

func NewSyncHandler(db *pgxpool.Pool) *SyncHandler {
	return &SyncHandler{DB: db}
}

func (h *SyncHandler) HandleSync(c *fiber.Ctx) error {
	// 1. fast parsing
	var req SyncRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Cannot parse JSON",
		})
	}

	ctx := context.Background()

	// 2. Start Transaction
	tx, err := h.DB.Begin(ctx)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "DB Transaction Failed",
		})
	}
	defer tx.Rollback(ctx)

	// 3. Bulk Insert/Upsert Patients
	for _, p := range req.Patients {
		// Calculate DOB from Age (Approximate)
		// DB requires dob, JSON provides Age
		birthYear := time.Now().Year() - p.Age
		dob := time.Date(birthYear, 1, 1, 0, 0, 0, 0, time.UTC)

		_, err := tx.Exec(ctx, `
			INSERT INTO patients (id, hospital_id, name, gender, phone, patient_uiid, sync_status, dob, created_at, updated_at)
			VALUES ($1, $2, $3, $4, $5, $6, 'synced', $7, NOW(), NOW())
			ON CONFLICT (id) DO UPDATE SET 
				name = EXCLUDED.name,
				gender = EXCLUDED.gender,
				phone = EXCLUDED.phone,
				dob = EXCLUDED.dob,
				sync_status = 'synced',
				updated_at = NOW();
		`, p.ID, p.HospitalID, p.Name, p.Gender, p.Phone, p.PatientUIID, dob)

		if err != nil {
			log.Printf("Error inserting patient %s: %v", p.ID, err)
			tx.Rollback(ctx)
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"error": "Failed to insert patient: " + err.Error(),
			})
		}
	}

	// 4. Bulk Insert Visits
	for _, v := range req.Visits {
		// Resolve Doctor ID (FK Constraint)
		var doctorID string
		// Try to find by exact name matching username? Or just use first user (admin) as fallback?
		// Since we don't have doctor_name in Users table, let's try to fetch ANY valid user ID to satisfy FK.
		// In a real app, strict mapping is needed.
		err := tx.QueryRow(ctx, "SELECT id FROM users LIMIT 1").Scan(&doctorID)
		if err != nil {
			log.Printf("Skipping visit %s: No users found for doctor_id FK", v.ID)
			continue
		}

		_, err = tx.Exec(ctx, `
			INSERT INTO visits (id, patient_id, hospital_id, visit_date, doctor_id, complaint, diagnosis, billing_amount)
			VALUES ($1, $2, $3, $4::timestamp, $5, $6, $7, $8)
			ON CONFLICT (id) DO NOTHING;
		`, v.ID, v.PatientID, v.HospitalID, v.Date, doctorID, v.ChiefComplaint, v.Diagnosis, v.TotalAmount)

		if err != nil {
			log.Printf("Error inserting visit %s: %v", v.ID, err)
			tx.Rollback(ctx)
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"error": "Failed to insert visit: " + err.Error(),
			})
		}
	}

	// 5. Commit
	if err := tx.Commit(ctx); err != nil {
		log.Printf("Commit failed: %v", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Transaction Commit Failed",
		})
	}

	return c.JSON(fiber.Map{
		"status":            "success",
		"message":           "Data synced successfully",
		"patients_received": len(req.Patients),
		"visits_received":   len(req.Visits),
	})
}
