from typing import List, Dict, Any, Optional
import math

class MedicalAnomalyDetector:
    """
    Detects anomalies in clinical data using statistical methods and reference ranges.
    Uses Z-score analysis and standard medical reference ranges.
    """
    
    def __init__(self):
        # Standard Reference Ranges (Adults)
        self.reference_ranges = {
            "systolic_bp": {"min": 90, "max": 140, "unit": "mmHg"},
            "diastolic_bp": {"min": 60, "max": 90, "unit": "mmHg"},
            "heart_rate": {"min": 60, "max": 100, "unit": "bpm"},
            "spo2": {"min": 95, "max": 100, "unit": "%"},
            "temp": {"min": 36.1, "max": 37.2, "unit": "C"},
            "resp_rate": {"min": 12, "max": 20, "unit": "bpm"},
            "creatinine": {"min": 0.7, "max": 1.3, "unit": "mg/dL"},
            "wbc": {"min": 4000, "max": 11000, "unit": "/uL"},
            "hemoglobin": {"min": 13.5, "max": 17.5, "unit": "g/dL", "gender": "Male"}, # Simplified
            "glucose_random": {"min": 70, "max": 140, "unit": "mg/dL"}
        }

    def detect_anomalies(self, 
                         patient_id: str, 
                         vitals: Dict[str, float], 
                         labs: Dict[str, float],
                         history: List[Dict[str, float]] = []) -> Dict[str, Any]:
        """
        Check for values outside reference ranges AND deviation from patient's history.
        """
        anomalies = []
        
        # 1. Check Vitals against Global Reference
        for name, value in vitals.items():
            ref = self.reference_ranges.get(name)
            if ref and value is not None:
                if value < ref['min'] or value > ref['max']:
                    severity = "Critical" if (value < ref['min']*0.8 or value > ref['max']*1.2) else "Warning"
                    anomalies.append({
                        "parameter": name,
                        "value": value,
                        "issue": "Outside Reference Range",
                        "reference": f"{ref['min']}-{ref['max']} {ref['unit']}",
                        "severity": severity
                    })

        # 2. Check Labs against Global Reference
        for name, value in labs.items():
            ref = self.reference_ranges.get(name)
            if ref and value is not None:
                if value < ref['min'] or value > ref['max']:
                    anomalies.append({
                        "parameter": name,
                        "value": value,
                        "issue": "Abnormal Lab Result",
                        "reference": f"{ref['min']}-{ref['max']} {ref['unit']}",
                        "severity": "High"
                    })

        # 3. Check against Personal History (Statistical Drift)
        # If we have historical data points, check if current value is a spike
        # Simple Logic: If value deviates > 20% from average of last 3 readings -> Anomaly
        if history:
            full_data = {**vitals, **labs}
            
            # Group history by parameter
            hist_map = {}
            for h in history:
                for k, v in h.items():
                    if k not in hist_map: hist_map[k] = []
                    hist_map[k].append(v)
            
            for param, current_val in full_data.items():
                past_vals = hist_map.get(param, [])
                if len(past_vals) >= 3 and current_val is not None:
                    avg = sum(past_vals) / len(past_vals)
                    deviation = abs(current_val - avg)
                    percent_change = (deviation / avg) * 100 if avg > 0 else 0
                    
                    if percent_change > 25: # 25% sudden change
                        anomalies.append({
                            "parameter": param,
                            "value": current_val,
                            "issue": f"Sudden Change (+{percent_change:.1f}%)",
                            "reference": f"Avg: {avg:.1f}",
                            "severity": "Medium"
                        })

        return {
            "is_anomalous": len(anomalies) > 0,
            "anomaly_count": len(anomalies),
            "anomalies": anomalies,
            "recommendation": "Review flagged parameters." if anomalies else "No significant anomalies."
        }

anomaly_detector = MedicalAnomalyDetector()
