-- Database init for PostgreSQL (High Performance / 50k+ users)
-- Optimizations: Native UUIDs, TIMESTAMPTZ, Triggers for updated_at

-- Drop and Recreate Database (Run this separately or ensuring no active connections)
-- DROP DATABASE IF EXISTS hms_db;
-- CREATE DATABASE hms_db;
-- \c hms_db;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Function for automatic updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Hospitals Table (Multi-Tenancy Root)
CREATE TABLE IF NOT EXISTS hospitals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    setup_key VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hospital_id UUID NOT NULL,
    username VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'staff',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE
);

CREATE TRIGGER update_users_modtime
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

-- Patients Table
CREATE TABLE IF NOT EXISTS patients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hospital_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL,
    age INT,
    gender VARCHAR(10),
    contact_number VARCHAR(20),
    address TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    sync_status VARCHAR(20) DEFAULT 'synced',
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE
);

CREATE TRIGGER update_patients_modtime
    BEFORE UPDATE ON patients
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

-- Visits Table
CREATE TABLE IF NOT EXISTS visits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hospital_id UUID NOT NULL,
    patient_id UUID NOT NULL,
    doctor_id UUID,
    visit_date TIMESTAMPTZ DEFAULT NOW(),
    symptoms TEXT,
    diagnosis TEXT,
    prescription TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    sync_status VARCHAR(20) DEFAULT 'synced',
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE
    -- PARTITION BY RANGE (visit_date) -- Example for future partitioning
);

CREATE TRIGGER update_visits_modtime
    BEFORE UPDATE ON visits
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

-- Bills Table
CREATE TABLE IF NOT EXISTS bills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hospital_id UUID NOT NULL,
    visit_id UUID NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'unpaid',
    payment_method VARCHAR(50),
    generated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    sync_status VARCHAR(20) DEFAULT 'synced',
    FOREIGN KEY (visit_id) REFERENCES visits(id) ON DELETE CASCADE,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE
);

CREATE TRIGGER update_bills_modtime
    BEFORE UPDATE ON bills
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

-- Medical Files
CREATE TABLE IF NOT EXISTS medical_files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hospital_id UUID NOT NULL,
    visit_id UUID,
    patient_id UUID,
    file_path VARCHAR(255) NOT NULL, 
    file_type VARCHAR(50),
    uploaded_at TIMESTAMPTZ DEFAULT NOW(),
    FOREIGN KEY (visit_id) REFERENCES visits(id) ON DELETE SET NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
);

-- Audit Logs
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hospital_id UUID,
    user_id UUID,
    action VARCHAR(50) NOT NULL,
    entity_id UUID,
    details TEXT,
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_hospital ON users(hospital_id);
CREATE INDEX IF NOT EXISTS idx_patients_hospital ON patients(hospital_id);
CREATE INDEX IF NOT EXISTS idx_visits_hospital ON visits(hospital_id);
CREATE INDEX IF NOT EXISTS idx_visits_patient ON visits(patient_id);
CREATE INDEX IF NOT EXISTS idx_bills_visit ON bills(visit_id);

CREATE INDEX IF NOT EXISTS idx_patient_name ON patients(name);
CREATE INDEX IF NOT EXISTS idx_visit_date ON visits(visit_date);
CREATE INDEX IF NOT EXISTS idx_bill_status ON bills(status);
