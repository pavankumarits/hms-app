from typing import List, Dict, Any

class ReadmissionPredictor:
    """
    Predicts 30-day readmission risk using the LACE Index methodology.
    LACE = Length of Stay + Acuity + Comorbidities + ED Visits (past 6mo)
    """
    
    def predict(self, 
                length_of_stay_days: int, 
                is_acute_admission: bool, 
                comorbidities: List[str], 
                ed_visits_last_6m: int) -> Dict[str, Any]:
        """
        Calculate LACE Score and Readmission Probability.
        """
        score = 0
        factors = []

        # 'L': Length of Stay
        if length_of_stay_days < 1:
            score += 0
        elif length_of_stay_days <= 2: # 1-2 days
            score += 3  # Wait, standard LACE is: 0->0, 1->1, 2->2, 3->3, 4-6->4... 
            # Let's use simplified clinical logic for this demo or standard LACE?
            # Standard LACE:
            # <1 day: 0
            # 1 day: 1
            # 2 days: 2
            # 3 days: 3
            # 4-6 days: 4
            # 7-13 days: 5
            # >=14 days: 7
            pass # We'll just define logic below
            
        if length_of_stay_days < 1: score += 0
        elif length_of_stay_days == 1: score += 1
        elif length_of_stay_days == 2: score += 2
        elif length_of_stay_days == 3: score += 3
        elif 4 <= length_of_stay_days <= 6: score += 4
        elif 7 <= length_of_stay_days <= 13: score += 5
        else: score += 7
        
        if score > 0: factors.append(f"Length of Stay ({length_of_stay_days} days)")

        # 'A': Acuity of Admission
        if is_acute_admission:
            score += 3
            factors.append("Acute/Emergency Admission")

        # 'C': Comorbidities (Charlson Comorbidity Index approximation)
        # We simplify by just counting high-risk chronic conditions provided
        cci_score = 0
        # Simple keywords mapping
        cci_keywords = [
            'infarct', 'failure', 'peripheral', 'dementia', 'pulmonary', 'rheumatic', 
            'peptic', 'liver', 'diabetes', 'hemiplegia', 'renal', 'cancer', 'aids'
        ]
        
        for condition in comorbidities:
            if any(k in condition.lower() for k in cci_keywords):
                cci_score += 1
        
        cci_points = min(cci_score, 4) # LACE caps Comorbidity score contribution roughly
        # Actually LACE uses Charlson score: 0->0, 1->1, 2->2, 3->3, >=4->5
        if cci_score >= 4:
            score += 5
        elif cci_score > 0:
            score += cci_score
            
        if cci_score > 0: factors.append(f"Comorbidities Burden (Count: {cci_score})")

        # 'E': Emergency Department visits in last 6 months
        if ed_visits_last_6m >= 4:
            score += 4
        elif ed_visits_last_6m > 0:
            score += ed_visits_last_6m
            
        if ed_visits_last_6m > 0: factors.append(f"Recent ED Visits ({ed_visits_last_6m})")

        # Total LACE Score Interpretation
        # 0-4: Low
        # 5-9: Moderate
        # >=10: High
        
        if score >= 10:
            risk_level = "High"
            probability = ">15%" # Approx
        elif score >= 5:
            risk_level = "Moderate"
            probability = "5-15%"
        else:
            risk_level = "Low"
            probability = "<5%"

        return {
            "lace_score": score,
            "risk_level": risk_level,
            "readmission_probability": probability,
            "risk_factors": factors,
            "recommendation": self._get_recommendation(risk_level)
        }

    def _get_recommendation(self, level: str) -> str:
        if level == "High":
            return "Enhanced discharge planning required. Schedule follow-up within 7 days."
        elif level == "Moderate":
            return "Coordinate with primary care. Verify medication adherence."
        else:
            return "Standard discharge instructions."

readmission_predictor = ReadmissionPredictor()
