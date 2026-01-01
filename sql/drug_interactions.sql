-- Create Drug Interactions Table
DROP TABLE IF EXISTS drug_interactions;
CREATE TABLE IF NOT EXISTS drug_interactions (
    id SERIAL PRIMARY KEY,
    drug_a VARCHAR NOT NULL,
    drug_b VARCHAR NOT NULL,
    severity VARCHAR DEFAULT 'Major',
    description TEXT NOT NULL,
    management VARCHAR,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed Data for Common Dangerous Drug Interactions
INSERT INTO drug_interactions (drug_a, drug_b, severity, description, management) VALUES
-- Warfarin Interactions
('Warfarin', 'Aspirin', 'Major', 'Significantly increased risk of bleeding.', 'Avoid combination unless benefit outweighs risk.'),
('Warfarin', 'Ibuprofen', 'Major', 'Increased risk of GI bleeding.', 'Avoid NSAIDs while on Warfarin.'),
('Warfarin', 'Amiodarone', 'Major', 'Increases Warfarin effect (INR spike).', 'Reduce Warfarin dose by 30-50%.'),

-- Statin Interactions
('Simvastatin', 'Erythromycin', 'Major', 'Increased risk of myopathy/rhabdomyolysis.', 'Avoid combination.'),
('Simvastatin', 'Amlodipine', 'Moderate', 'Increased Simvastatin exposure.', 'Limit Simvastatin to 20mg daily.'),

-- ACE Inhibitor Interactions
('Lisinopril', 'Potassium', 'Major', 'Risk of Hyperkalemia.', 'Monitor serum potassium.'),
('Lisinopril', 'Spironolactone', 'Major', 'Risk of severe Hyperkalemia.', 'Frequent monitoring required.'),

-- PDE5 Inhibitors (Viagra etc) + Nitrates
('Sildenafil', 'Nitroglycerin', 'Major', 'Risk of severe hypotension (fatal).', 'Contraindicated.'),
('Tadalafil', 'Isosorbide', 'Major', 'Risk of severe hypotension.', 'Contraindicated.');
