-- Create Lab Protocols Table
CREATE TABLE IF NOT EXISTS lab_protocols (
    id SERIAL PRIMARY KEY,
    diagnosis_keyword VARCHAR NOT NULL,
    test_name VARCHAR NOT NULL,
    priority VARCHAR DEFAULT 'Recommended',
    reasoning TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed Data for Common Diagnoses
INSERT INTO lab_protocols (diagnosis_keyword, test_name, priority, reasoning) VALUES
('Fever', 'CBC (Complete Blood Count)', 'Essential', 'To rule out infection or anemia.'),
('Fever', 'Malaria Antigen', 'Recommended', 'Common cause of acute fever.'),
('Fever', 'Dengue NS1 Antigen', 'Recommended', 'If platelets are low or in endemic areas.'),
('Fever', 'Urinalysis', 'Optional', 'To rule out UTI.'),

('Viral', 'CBC (Complete Blood Count)', 'Essential', 'Check lymphocyte count.'),
('Viral', 'CRP (C-Reactive Protein)', 'Recommended', 'Inflammatory marker.'),

('Typhoid', 'Widal Test', 'Essential', 'Diagnostic for enteric fever.'),
('Typhoid', 'Blood Culture', 'Recommended', 'Gold standard for confirmation.'),

('Hypertension', 'Lipid Profile', 'Essential', 'Assess cardiovascular risk.'),
('Hypertension', 'Serum Creatinine', 'Essential', 'Check kidney function.'),
('Hypertension', 'ECG', 'Recommended', 'Check for cardiac strain.'),
('Hypertension', 'Fasting Blood Glucose', 'Recommended', 'Screen for comorbid diabetes.'),

('Diabetes', 'HbA1c', 'Essential', '3-month average glucose control.'),
('Diabetes', 'Fasting Blood Glucose', 'Essential', 'Current glucose status.'),
('Diabetes', 'Lipid Profile', 'Essential', 'High risk of dyslipidemia in diabetics.'),
('Diabetes', 'Urine Microalbumin', 'Recommended', 'Early detection of nephropathy.'),

('Anemia', 'CBC', 'Essential', 'Check Hemoglobin, MCV, MCH.'),
('Anemia', 'Peripheral Smear', 'Recommended', 'Morphology of RBCs.'),
('Anemia', 'Serum Ferritin', 'Recommended', 'Iron stores check.'),

('Chest Pain', 'ECG', 'Essential', 'Rule out ischemia/infarction.'),
('Chest Pain', 'Troponin I', 'Essential', 'Cardiac marker for MI.'),
('Chest Pain', 'Chest X-Ray', 'Recommended', 'Rule out lung causes.'),

('Abdominal Pain', 'Ultrasound Abdomen', 'Recommended', 'Check liver, gallbladder, appendix.'),
('Abdominal Pain', 'Liver Function Test', 'Optional', 'Check hepatic causes.'),
('Abdominal Pain', 'Serum Amylase/Lipase', 'Optional', 'Rule out pancreatitis.');
