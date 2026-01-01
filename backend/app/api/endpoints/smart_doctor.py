from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_, and_, func
from app.api import deps
from app.models.smart_doctor import DiseaseProtocol, DrugInteraction
from app.schemas.smart_doctor import (
    DiagnosisInput, DrugSuggestion, SafetyCheckInput, SafetyCheckResult,
    SymptomInput, DiagnosisSuggestion
)

router = APIRouter()

@router.post("/predict-diagnosis", response_model=List[DiagnosisSuggestion])
async def predict_diagnosis(input_data: SymptomInput):
    """
    AI Symptom Checker: Map symptoms to likely diagnosis.
    (Heuristic Demo Version)
    """
    symptoms = input_data.symptoms.lower()
    suggestions = []

    # Logic: Simple keyword mapping (In a real app, uses embeddings/BERT)
    if "fever" in symptoms or "chills" in symptoms:
        if "cough" in symptoms:
            suggestions.append(DiagnosisSuggestion(name="Viral Upper Respiratory Infection", confidence=85))
            suggestions.append(DiagnosisSuggestion(name="Pneumonia", confidence=40))
        elif "headache" in symptoms:
            suggestions.append(DiagnosisSuggestion(name="Viral Fever", confidence=70))
            suggestions.append(DiagnosisSuggestion(name="Malaria", confidence=30))
    
    if "headache" in symptoms:
        if "vision" in symptoms or "blur" in symptoms:
             suggestions.append(DiagnosisSuggestion(name="Migraine", confidence=80))
        else:
             suggestions.append(DiagnosisSuggestion(name="Tension Headache", confidence=60))

    if "chest pain" in symptoms:
        suggestions.append(DiagnosisSuggestion(name="Angina Pectoris", confidence=90))
        suggestions.append(DiagnosisSuggestion(name="GERD", confidence=50))
        
    if "bp" in symptoms or "pressure" in symptoms:
        suggestions.append(DiagnosisSuggestion(name="Hypertension", confidence=95))

    # De-duplicate and sort
    seen = set()
    unique = []
    for s in suggestions:
        if s.name not in seen:
            seen.add(s.name)
            unique.append(s)
            
    unique.sort(key=lambda x: x.confidence, reverse=True)
    return unique[:3] # Top 3

@router.post("/predict-drugs", response_model=List[DrugSuggestion])
async def predict_drugs(
    input_data: DiagnosisInput,
    db: AsyncSession = Depends(deps.get_db)
):
    """
    Predict drugs based on diagnosis and patient details.
    """
    # 1. Fetch standard protocols
    result = await db.execute(
        select(DiseaseProtocol).where(
            func.lower(DiseaseProtocol.disease_name) == input_data.diagnosis.lower(),
            DiseaseProtocol.min_age <= input_data.age,
            DiseaseProtocol.max_age >= input_data.age
        )
    )
    protocols = result.scalars().all()

    if not protocols:
        return []

    suggestions = []
    for p in protocols:
        # Simple scoring logic
        score = 98 if p.line_of_treatment == 1 else 90
        
        suggestions.append(DrugSuggestion(
            drug_name=p.drug_name,
            match_score=score,
            line_of_treatment=p.line_of_treatment
        ))
    
    # Sort by score desc, then line of treatment asc
    suggestions.sort(key=lambda x: (x.match_score, -x.line_of_treatment), reverse=True)
    return suggestions

@router.post("/check-safety", response_model=SafetyCheckResult)
async def check_safety(
    input_data: SafetyCheckInput,
    db: AsyncSession = Depends(deps.get_db)
):
    """
    Check for drug-drug interactions.
    """
    warnings = []
    proposed = input_data.proposed_drug.split(" ")[0] # Basic cleanup to match drug name root
    
    for med in input_data.current_meds:
        current = med.split(" ")[0]
        
        # Check interaction in both directions (A-B or B-A)
        result = await db.execute(
            select(DrugInteraction).where(
                or_(
                    and_(DrugInteraction.drug_a.ilike(f"%{proposed}%"), DrugInteraction.drug_b.ilike(f"%{current}%")),
                    and_(DrugInteraction.drug_b.ilike(f"%{proposed}"), DrugInteraction.drug_a.ilike(f"%{current}%"))
                )
            )
        )
        interaction = result.scalars().first()
        
        if interaction:
            warnings.append(
                f"Interaction with {med}: {interaction.description} ({interaction.severity} Risk)"
            )

    return SafetyCheckResult(
        is_safe=len(warnings) == 0,
        warnings=warnings
    )
