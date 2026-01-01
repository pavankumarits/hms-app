-- ML Predictions History Table
CREATE TABLE IF NOT EXISTS ml_risk_predictions (
    id SERIAL PRIMARY KEY,
    patient_id VARCHAR(36) NOT NULL,
    visit_id VARCHAR(36),
    risk_score FLOAT NOT NULL,
    risk_level VARCHAR(20) NOT NULL,
    risk_factors TEXT, -- JSON or comma-separated string
    prediction_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Metadata
    model_version VARCHAR(20) DEFAULT 'v1.0-heuristic',
    is_accurate BOOLEAN DEFAULT NULL, -- For feedback loop (True/False confirmed by doctor)
    doctor_notes TEXT
);

CREATE INDEX idx_risk_patient ON ml_risk_predictions(patient_id);
