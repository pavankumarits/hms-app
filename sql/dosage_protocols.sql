-- Create Dosage Protocols Table
CREATE TABLE IF NOT EXISTS dosage_protocols (
    id SERIAL PRIMARY KEY,
    drug_name VARCHAR NOT NULL,
    min_age_months INTEGER DEFAULT 0,
    max_age_months INTEGER DEFAULT 1200,
    min_weight_kg FLOAT DEFAULT 0,
    max_weight_kg FLOAT DEFAULT 200,
    dosage_per_kg_mg FLOAT NOT NULL,
    max_daily_dose_mg FLOAT,
    frequency_hours INTEGER,
    form VARCHAR DEFAULT 'Syrup',
    concentration_mg_per_ml FLOAT, -- e.g. 120mg/5ml = 24 mg/ml
    instructions TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed Data for Pediatric Dosage
-- Paracetamol Syrup (15mg/kg) - Standard 120mg/5ml (24mg/ml)
INSERT INTO dosage_protocols (drug_name, dosage_per_kg_mg, max_daily_dose_mg, frequency_hours, form, concentration_mg_per_ml, instructions) 
VALUES 
('Paracetamol', 15.0, 2000.0, 6, 'Syrup', 24.0, 'Take after food. Max 4 doses in 24 hours.'),
('Ibuprofen', 10.0, 1200.0, 8, 'Syrup', 20.0, 'Take with food. Do not give if dehydrated.'),
('Amoxicillin', 25.0, 1500.0, 8, 'Syrup', 25.0, 'Finish the full course.'), -- 125mg/5ml
('Azithromycin', 10.0, 500.0, 24, 'Syrup', 40.0, 'Once daily for 3-5 days.'); -- 200mg/5ml

-- Adult Tablets (just basic mapping for demo, usually per tablet)
-- Storing 'per kg' for adults is tricky, usually it's fixed dose. 
-- But for this demo we focus on pediatric/weight-based.
INSERT INTO dosage_protocols (drug_name, min_weight_kg, dosage_per_kg_mg, max_daily_dose_mg, frequency_hours, form, concentration_mg_per_ml, instructions) 
VALUES 
('Paracetamol', 40.0, 10.0, 4000.0, 6, 'Tablet', NULL, 'Max 4g per day. Do not take with alcohol.');
