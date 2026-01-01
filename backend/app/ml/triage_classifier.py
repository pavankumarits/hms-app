from typing import List, Dict, Any, Optional

class TriageClassifier:
    """
    Auto-classifies patient urgency using a simplified ESI (Emergency Severity Index) model.
    Levels:
    1 - Resuscitation (Immediate life-saving intervention required)
    2 - Emergent (High risk, confusion, severe pain, unstable vitals)
    3 - Urgent (Stable vitals but requires multiple resources)
    4 - Less Urgent (Stable, requires one resource)
    5 - Non-Urgent (No resources needed, just review/meds)
    """
    
    def predict(self, 
                symptoms: str, 
                vitals: Dict[str, float], 
                pain_score: int, # 0-10
                consciousness: str) -> Dict[str, Any]: # 'Alert', 'Confused', 'Unresponsive'
        
        symptoms_lower = symptoms.lower()
        level = 5
        reasoning = []
        wait_time = "2-4 hours" # Default
        
        # Level 1: Resuscitation (Dead or Dying)
        # Unresponsive, critical vitals (SpO2 < 90, HR < 40 or > 130)
        spo2 = vitals.get('spo2', 98)
        hr = vitals.get('heart_rate', 72)
        sbp = vitals.get('systolic_bp', 120)
        
        if consciousness == 'Unresponsive' or spo2 < 90 or hr > 150 or sbp < 80:
            level = 1
            reasoning.append("Critical Vitals/Unresponsive")
            wait_time = "Immediate"
            return self._format_result(level, wait_time, reasoning)

        # Level 2: Emergent (High Risk)
        # Chest pain, Stroke signs, Severe Pain (7+), Confused, Suicidal
        high_risk_keywords = ["chest pain", "stroke", "paralysis", "breathing difficulty", "severe bleeding"]
        
        if consciousness == 'Confused':
            level = 2
            reasoning.append("Altered Mental Status")
        elif pain_score >= 7:
            level = 2
            reasoning.append(f"Severe Pain (Score: {pain_score})")
        elif any(k in symptoms_lower for k in high_risk_keywords):
            level = 2
            reasoning.append("High Risk Symptom Detected")
        elif hr > 110 or spo2 < 94: # Danger zone vitals
            level = 2
            reasoning.append("Unstable Vitals")
            
        if level == 2:
            wait_time = "< 15 mins"
            return self._format_result(level, wait_time, reasoning)

        # Level 3: Urgent (Needs resources -> Labs, X-Ray, etc.)
        # Abdominal pain, high fever, fracture?
        urgent_keywords = ["abdominal pain", "fracture", "broken", "fever", "vomiting"]
        
        if any(k in symptoms_lower for k in urgent_keywords) or pain_score >= 4:
            level = 3
            reasoning.append("Resource intensive likely (Labs/Imaging)")
        elif sbp > 160: # High BP but asymptomatic?
            level = 3
            reasoning.append("Marked Hypertension")
            
        if level == 3:
            wait_time = "30-60 mins"
            return self._format_result(level, wait_time, reasoning)

        # Level 4: Less Urgent (One resource -> just stitches or x-ray)
        # Minor cuts, sore throat, ear ache, UTI
        less_urgent_keywords = ["sore throat", "cough", "ear pain", "uti", "burning urine", "rash"]
        
        if any(k in symptoms_lower for k in less_urgent_keywords):
            level = 4
            reasoning.append("Minor illness, single resource likely")
            
        if level == 4:
            wait_time = "1-2 hours"
            return self._format_result(level, wait_time, reasoning)

        # Level 5: Non-Urgent (Refill, Check-up)
        reasoning.append("Routine compliant / Prescription Refill")
        return self._format_result(level, wait_time, reasoning)

    def _format_result(self, level: int, wait: str, reasoning: List[str]) -> Dict[str, Any]:
        return {
            "triage_level": level,
            "category": self._get_category_name(level),
            "estimated_wait_time": wait,
            "reasoning": "; ".join(reasoning)
        }

    def _get_category_name(self, level: int) -> str:
        names = {
            1: "Resuscitation (Immediate)",
            2: "Emergent (Very Urgent)",
            3: "Urgent",
            4: "Less Urgent",
            5: "Non-Urgent"
        }
        return names.get(level, "Unknown")

triage_classifier = TriageClassifier()
