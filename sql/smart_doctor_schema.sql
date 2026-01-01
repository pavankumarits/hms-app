-- Knowledge Base for Disease-Drug Rules
CREATE TABLE IF NOT EXISTS disease_protocols (
    id SERIAL PRIMARY KEY,
    disease_name VARCHAR(100) NOT NULL,
    drug_name VARCHAR(100) NOT NULL,
    line_of_treatment INT, -- 1 = First Line, 2 = Second Line
    min_age INT DEFAULT 0,
    max_age INT DEFAULT 120,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Drug Interactions Table
CREATE TABLE IF NOT EXISTS drug_interactions (
    id SERIAL PRIMARY KEY,
    drug_a VARCHAR(100) NOT NULL,
    drug_b VARCHAR(100) NOT NULL,
    severity VARCHAR(20), -- 'Mild', 'Moderate', 'Severe'
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Seed Data for Testing (Hypertension)
INSERT INTO disease_protocols (disease_name, drug_name, line_of_treatment, min_age, max_age)
VALUES 
    ('Hypertension', 'Amlodipine 5mg', 1, 18, 120),
    ('Hypertension', 'Telmisartan 40mg', 1, 18, 120),
    ('Hypertension', 'Atenolol 50mg', 2, 18, 120)
ON CONFLICT DO NOTHING; -- (Note: ID conflict handling might need reset if run multiple times, but this is simple insert)

-- Seed Data for Interactions
INSERT INTO drug_interactions (drug_a, drug_b, severity, description)
VALUES 
    ('Aspirin', 'Warfarin', 'Severe', 'Increased risk of bleeding due to anticoagulant effect.'),
    ('Amlodipine', 'Simvastatin', 'Moderate', 'May increase serum concentration of simvastatin.')
ON CONFLICT DO NOTHING;
