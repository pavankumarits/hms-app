-- Create Clinical Alert Rules Table
CREATE TABLE IF NOT EXISTS clinical_alert_rules (
    id SERIAL PRIMARY KEY,
    alert_name VARCHAR NOT NULL,
    target_gender VARCHAR DEFAULT 'All',
    min_age INTEGER DEFAULT 0,
    max_age INTEGER DEFAULT 120,
    condition_keyword VARCHAR,
    alert_message TEXT NOT NULL,
    priority VARCHAR DEFAULT 'Medium',
    reference_guideline VARCHAR,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed Data for Logic-Based Alerts
INSERT INTO clinical_alert_rules (alert_name, target_gender, min_age, max_age, condition_keyword, alert_message, priority, reference_guideline) VALUES
-- General Screenings
('Hypertension Screening', 'All', 18, 120, NULL, 'Check BP annually for adults > 18.', 'Medium', 'JNC 8'),
('Colon Cancer Screening', 'All', 45, 75, NULL, 'Colonoscopy recommended every 10 years.', 'High', 'USPSTF'),

-- Gender Specific
('Mammography', 'Female', 45, 74, NULL, 'Annual or biennial mammogram recommended.', 'High', 'ACS'),
('Cervical Cancer Screening', 'Female', 21, 65, NULL, 'Pap smear recommended every 3 years.', 'High', 'USPSTF'),

-- Condition Specific
('HbA1c Monitoring', 'All', 0, 120, 'Diabetes', 'Monitor HbA1c every 3-6 months.', 'High', 'ADA'),
('Diabetic Eye Exam', 'All', 0, 120, 'Diabetes', 'Annual dilated eye exam required.', 'Medium', 'ADA'),
('Foot Exam', 'All', 0, 120, 'Diabetes', 'Annual comprehensive foot exam required.', 'Medium', 'ADA'),
('Lipid Panel', 'All', 20, 120, 'Hypertension', 'Check lipid profile to manage CVS risk.', 'Medium', 'AHA');
