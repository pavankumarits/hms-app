-- Create Risk Rules Table
CREATE TABLE IF NOT EXISTS risk_rules (
    id SERIAL PRIMARY KEY,
    condition_keyword VARCHAR NOT NULL,
    risk_points INTEGER NOT NULL,
    category VARCHAR DEFAULT 'Chronic',
    description VARCHAR,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed Data for Common Risk Factors
INSERT INTO risk_rules (condition_keyword, risk_points, category, description) VALUES
('Diabetes', 10, 'Chronic', 'Increases risk of CVS, Kidney issues'),
('Hypertension', 10, 'Chronic', 'Silent killer, CVS risk'),
('Asthma', 5, 'Chronic', 'Respiratory risk'),
('COPD', 15, 'Chronic', 'High respiratory failure risk'),
('Heart Disease', 20, 'Chronic', 'Critical CVS risk'),
('Kidney Disease', 15, 'Chronic', 'Renal failure risk'),

('Smoker', 15, 'Lifestyle', 'Major cause of cancer/CVS'),
('Alcohol', 5, 'Lifestyle', 'Liver risk'),
('Obesity', 10, 'Lifestyle', 'Metabolic syndrome risk');
