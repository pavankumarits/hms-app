-- Create Drug Side Effects Table
CREATE TABLE IF NOT EXISTS drug_side_effects (
    id SERIAL PRIMARY KEY,
    drug_name VARCHAR NOT NULL,
    side_effect VARCHAR NOT NULL,
    frequency VARCHAR DEFAULT 'Common',
    severity VARCHAR DEFAULT 'Mild',
    description VARCHAR,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed Data for Common Adverse Drug Reactions (Prescribing Cascades)
INSERT INTO drug_side_effects (drug_name, side_effect, frequency, severity, description) VALUES
-- ACE Inhibitors
('Lisinopril', 'Cough', 'Common', 'Mild', 'Dry, persistent non-productive cough'),
('Enalapril', 'Cough', 'Common', 'Mild', 'Dry cough'),
('Captopril', 'Cough', 'Common', 'Mild', 'Dry cough'),

-- Calcium Channel Blockers
('Amlodipine', 'Edema', 'Common', 'Mild', 'Swelling of ankles/feet'),
('Amlodipine', 'Swelling', 'Common', 'Mild', 'Peripheral edema'),
('Nifedipine', 'Edema', 'Common', 'Mild', 'Peripheral edema'),

-- Statins
('Atorvastatin', 'Muscle Pain', 'Common', 'Moderate', 'Myalgia, muscle aches'),
('Atorvastatin', 'Myalgia', 'Common', 'Moderate', 'Muscle pain'),
('Simvastatin', 'Muscle Pain', 'Common', 'Moderate', 'Myalgia'),
('Rosuvastatin', 'Muscle Pain', 'Common', 'Moderate', 'Myalgia'),

-- Metformin
('Metformin', 'Diarrhea', 'Very Common', 'Mild', 'GI upset'),
('Metformin', 'Nausea', 'Common', 'Mild', 'GI upset'),

-- Antibiotics
('Amoxicillin', 'Rash', 'Common', 'Mild', 'Skin rash'),
('Azithromycin', 'Diarrhea', 'Common', 'Mild', 'Loose stools'),

-- NSAIDs (Ibuprofen etc are usually short term but good to have)
('Ibuprofen', 'Stomach Pain', 'Common', 'Mild', 'Gastric irritation'),
('Naproxen', 'Stomach Pain', 'Common', 'Mild', 'Gastric irritation');
