import random
from typing import List, Dict, Any, Tuple

class RiskPredictor:
    """
    Predicts patient deterioration risk based on clinical data.
    Currently uses a heuristic-based hybrid model (Rule-based + Simulation).
    Designed to be replaced by a trained scikit-learn/XGBoost model.
    """
    
    def __init__(self):
        # In a real scenario, we would load a pickle file here
        # self.model = joblib.load('risk_model.pkl')
        pass

    def predict(self, 
                age: int, 
                gender: str, 
                vitals: Dict[str, float], 
                comorbidities: List[str], 
                lab_results: Dict[str, float]) -> Dict[str, Any]:
        """
        Predict risk of deterioration.
        
        Args:
            age: Patient age
            gender: 'Male' or 'Female'
            vitals: Dict, e.g., {'systolic_bp': 140, 'heart_rate': 90, 'spo2': 98, 'temp': 37.5}
            comorbidities: List of chronic conditions, e.g., ['Diabetes', 'Hypertension']
            lab_results: Dict of recent key labs, e.g., {'creatinine': 1.2, 'wbc': 11000}
            
        Returns:
            Dict containing risk_score (0-100), risk_level, and risk_factors.
        """
        
        # 1. Feature Engineering (Simplified)
        risk_score = 0.0
        risk_factors = []

        # Age factor
        if age > 65:
            risk_score += 15
            risk_factors.append("Advanced Age (>65)")
        elif age > 50:
            risk_score += 5

        # Comorbidities impact
        high_risk_conditions = ['Heart Failure', 'COPD', 'CKD', 'Cancer', 'Liver Disease']
        moderate_risk_conditions = ['Diabetes', 'Hypertension', 'Asthma']

        for condition in commodities:
            if any(c.lower() in condition.lower() for c in high_risk_conditions):
                risk_score += 20
                risk_factors.append(f"High risk condition: {condition}")
            elif any(c.lower() in condition.lower() for c in moderate_risk_conditions):
                risk_score += 10
                risk_factors.append(f"Moderate risk condition: {condition}")

        # Vitals Analysis (NEWS-2 check variant)
        sbp = vitals.get('systolic_bp', 120)
        hr = vitals.get('heart_rate', 72)
        spo2 = vitals.get('spo2', 98)
        resp_rate = vitals.get('resp_rate', 16) # Default if missing
        temp = vitals.get('temp', 37.0)

        # Systolic BP
        if sbp < 90:
            risk_score += 25
            risk_factors.append("Hypotension (SBP < 90)")
        elif sbp > 180:
            risk_score += 15
            risk_factors.append("Hypertensive Crisis (SBP > 180)")

        # Heart Rate
        if hr > 130:
            risk_score += 20
            risk_factors.append("Severe Tachycardia (HR > 130)")
        elif hr > 110:
            risk_score += 10
        elif hr < 40:
            risk_score += 20
            risk_factors.append("Severe Bradycardia (HR < 40)")

        # SpO2
        if spo2 < 90:
            risk_score += 30
            risk_factors.append("Critical Hypoxia (SpO2 < 90%)")
        elif spo2 < 94:
            risk_score += 15
            risk_factors.append("Hypoxia (SpO2 < 94%)")

        # Labs Analysis (if available)
        creatinine = lab_results.get('creatinine')
        if creatinine and creatinine > 1.5:
            risk_score += 15
            risk_factors.append("Elevated Creatinine (Kidney Strain)")
            
        wbc = lab_results.get('wbc')
        if wbc and (wbc > 12000 or wbc < 4000):
            risk_score += 10
            risk_factors.append("Abnormal WBC Count")

        # Cap score at 99
        risk_score = min(risk_score, 99.0)
        
        # Determine Level
        if risk_score >= 70:
            risk_level = "High"
        elif risk_score >= 40:
            risk_level = "Medium"
        else:
            risk_level = "Low"

        return {
            "risk_score": float(risk_score),
            "risk_level": risk_level,
            "risk_factors": risk_factors,
            "recommendation": self._get_recommendation(risk_level, risk_factors)
        }

    def _get_recommendation(self, level: str, factors: List[str]) -> str:
        if level == "High":
            return "Immediate clinical review required. Consider admission/ICU if unstable."
        elif level == "Medium":
            return "Increase monitoring frequency. Review medications and management plan."
        else:
            return "Routine monitoring. Continue current management plan."

risk_predictor = RiskPredictor()
