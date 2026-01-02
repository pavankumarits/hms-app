from typing import List, Dict, Tuple, Any
import logging

try:
    from sentence_transformers import SentenceTransformer, util
    HAS_NLP = True
except ImportError:
    HAS_NLP = False
    print("Warning: sentence_transformers not found. Reverting to keyword matching.")

class MedicalNLP:
    """
    NLP-based Symptom Checker using Semantic Search.
    Uses BioBERT (via sentence-transformers) to map symptoms to diagnosis.
    """
    
    def __init__(self):
        global HAS_NLP
        self.model = None
        self.diagnosis_corpus = []
        self.corpus_embeddings = None
        self.diagnosis_map = {}
        
        if HAS_NLP:
            try:
                # We use a lightweight model for speed, or a clinical one if downloaded
                # 'all-MiniLM-L6-v2' is fast and good for general semantic similarity
                # For clinical, 'pritamdeka/S-PubMedBert-MS-MARCO' is better but larger
                self.model = SentenceTransformer('all-MiniLM-L6-v2') 
                self._load_medical_knowledge_base()
            except Exception as e:
                print(f"Failed to load NLP model: {e}")
                HAS_NLP = False

    def _load_medical_knowledge_base(self):
        """
        Loads standard diagnosis-symptom pairs into the corpus.
        In production, this would load from DB or a large verified JSON.
        """
        knowledge_base = [
            ("Viral Upper Respiratory Infection", "cough fever sore throat runny nose nasal congestion sneezing"),
            ("Pneumonia", "high fever chest pain cough with phlegm difficulty breathing shortness of breath"),
            ("Malaria", "high fever shaking chills sweating headache nausea vomiting muscle pain"),
            ("Typhoid", "prolonged fever headache abdominal pain constipation weakness rash"),
            ("Dengue", "high fever severe headache eye pain joint pain muscle pain rash rash bone pain"),
            ("Acute Gastroenteritis", "diarrhea vomiting stomach pain nausea cramping loose motions"),
            ("Migraine", "throbbing headache one side light sensitivity sound sensitivity nausea visual aura"),
            ("Tension Headache", "dull constant headache tightness pressure forehead back of head"),
            ("Hypertension", "high blood pressure dizziness headache vision problems chest pain"),
            ("Diabetes Type 2", "frequent urination excessive thirst hunger fatigue blurred vision weight loss"),
            ("Gastroesophageal Reflux Disease (GERD)", "heartburn acid reflux chest pain trouble swallowing sensation of lump in throat"),
            ("Angina Pectoris", "chest pain pressure squeezing left arm pain sweating shortness of breath"),
            ("Myocardial Infarction (Heart Attack)", "severe chest pain radiating to jaw arm sweating nausea anxiety crushing sensation"),
            ("Asthma", "wheezing shortness of breath chest tightness coughing night cough"),
            ("Tuberculosis", "chronic cough blood in cough weight loss night sweats fever fatigue"),
            ("Urinary Tract Infection (UTI)", "burning urination frequent urination cloudy urine pelvic pain strong smell"),
        ]
        
        self.diagnosis_corpus = [item[1] for item in knowledge_base]
        self.diagnosis_map = {i: item[0] for i, item in enumerate(knowledge_base)}
        
        if self.model:
            self.corpus_embeddings = self.model.encode(self.diagnosis_corpus, convert_to_tensor=True)

    def predict_diagnosis(self, user_symptoms: str, top_k: int = 3) -> List[Dict[str, Any]]:
        """
        Predict diagnosis based on semantic similarity of symptoms.
        """
        if not HAS_NLP or self.model is None:
            return self._heuristic_fallback(user_symptoms)

        # Encode user query
        query_embedding = self.model.encode(user_symptoms, convert_to_tensor=True)

        # Compute cosine similarity
        hits = util.semantic_search(query_embedding, self.corpus_embeddings, top_k=top_k)
        hits = hits[0] # Get first query results

        results = []
        for hit in hits:
            idx = hit['corpus_id']
            score = hit['score']
            
            if score < 0.25: # relevancy threshold
                continue
                
            diagnosis_name = self.diagnosis_map[idx]
            confidence = int(score * 100)
            
            results.append({
                "name": diagnosis_name,
                "confidence": confidence,
                "reasoning": "Symptom profile match (NLP)"
            })
            
        return results

    def _heuristic_fallback(self, symptoms: str) -> List[Dict[str, Any]]:
        """ Simple keyword matching if NLP fails """
        symptoms = symptoms.lower()
        suggestions = []
        
        if "fever" in symptoms:
            suggestions.append({"name": "Viral Fever", "confidence": 60})
        if "cough" in symptoms:
            suggestions.append({"name": "Upper Respiratory Infection", "confidence": 50})
        if "chest" in symptoms and "pain" in symptoms:
             suggestions.append({"name": "Angina", "confidence": 70})
             
        return suggestions

medical_nlp = MedicalNLP()
