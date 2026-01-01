from typing import List, Dict, Any

class TreatmentEffectivePredictor:
    """
    Predicts the effectiveness of a treatment for a specific patient.
    Uses historical data (mocked for now) to recommend personalized treatments.
    """
    
    def __init__(self):
        # Mock database of treatment effectiveness
        # In reality, this would be a trained ML model (e.g., Collaborative Filtering)
        self.effectiveness_db = {
            "Hypertension": [
                {"drug": "Amlodipine", "success_rate": 0.85, "side_effect_risk": "Low"},
                {"drug": "Lisinopril", "success_rate": 0.80, "side_effect_risk": "Medium (Cough)"},
                {"drug": "Losartan", "success_rate": 0.82, "side_effect_risk": "Low"}
            ],
            "Diabetes Type 2": [
                {"drug": "Metformin", "success_rate": 0.90, "side_effect_risk": "Medium (GI)"},
                {"drug": "Glimepiride", "success_rate": 0.75, "side_effect_risk": "Medium"},
                {"drug": "Sitagliptin", "success_rate": 0.70, "side_effect_risk": "Low"}
            ],
             "Migraine": [
                {"drug": "Sumatriptan", "success_rate": 0.88, "side_effect_risk": "Medium"},
                {"drug": "Naproxen", "success_rate": 0.60, "side_effect_risk": "Low"},
                {"drug": "Propranolol", "success_rate": 0.70, "side_effect_risk": "Low (Preventive)"}
            ]
        }

    def predict(self, 
                diagnosis: str, 
                patient_profile: Dict[str, Any]) -> List[Dict[str, Any]]:
        """
        Rank treatments by predicted effectiveness for this patient.
        
        Args:
            diagnosis: Diagnosed condition
            patient_profile: Dict with age, gender, comorbidities
            
        Returns:
            List of treatments sorted by score.
        """
        
        base_treatments = self.effectiveness_db.get(diagnosis, [])
        if not base_treatments:
            return []

        # Personalize scores based on profile
        ranked_treatments = []
        
        for t in base_treatments:
            score = t['success_rate'] * 100
            drug = t['drug']
            reasoning = ["Standard protocol"]

            # Adjust based on Age
            age = patient_profile.get('age', 40)
            if age > 65 and drug in ["Glimepiride", "Naproxen"]: # Mock interaction
                score -= 15
                reasoning.append("Reduced efficacy/safety in elderly")
            elif age < 18 and drug in ["Lisinopril"]:
                score -= 20
                reasoning.append("Not recommended for pediatric use")

            # Adjust based on Comorbidities
            comorbidities = patient_profile.get('comorbidities', [])
            if "Kidney Disease" in comorbidities and drug in ["Metformin", "Naproxen"]:
                score -= 30
                reasoning.append("Contraindicated in Kidney Disease")
            
            # Simple ML-like adjustment (mocking learned preference)
            # e.g., "Patients like this responded 10% better to Amlodipine"
            if patient_profile.get('gender') == 'Female' and drug == 'Losartan':
                score += 5
                reasoning.append("Higher observed success in demographic")

            ranked_treatments.append({
                "drug_name": drug,
                "predicted_efficacy": f"{min(score, 99):.1f}%",
                "side_effect_risk": t['side_effect_risk'],
                "match_score": float(score),
                "reasoning": "; ".join(reasoning)
            })

        # Sort by score desc
        ranked_treatments.sort(key=lambda x: x['match_score'], reverse=True)
        return ranked_treatments

treatment_predictor = TreatmentEffectivePredictor()
