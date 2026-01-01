from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_
from app.api import deps
from app.models.adverse_events import DrugSideEffect
from app.schemas.adverse_events import AdverseCheckInput, AdverseCheckOutput, AdverseMatch

router = APIRouter()

@router.post("/check", response_model=AdverseCheckOutput)
async def check_adverse_events(
    input_data: AdverseCheckInput,
    db: AsyncSession = Depends(deps.get_db)
):
    """
    Check if reported symptoms are potential side effects of current medications.
    """
    matches = []
    
    if not input_data.symptoms or not input_data.current_meds:
         return AdverseCheckOutput(matches=[], total_matches=0)

    # Simple logic: Search for side effects matching current meds AND reported symptoms
    # Optimization: Loading all side effects for the current meds first, then matching in memory
    # to handle partial string matching better (e.g. "Dry Cough" matches "Cough")
    
    # Clean drug names (basic) - remove dosage if present e.g. "Lisinopril 10mg" -> "Lisinopril"
    # This is a naive implementation; in a real system, use RxNorm or normalized IDs.
    cleaned_meds = []
    for med in input_data.current_meds:
        # Take first word as simple heuristic for now, or match substring
        cleaned_meds.append(med.split()[0]) 

    stmt = select(DrugSideEffect).where(
        or_(*[DrugSideEffect.drug_name.ilike(f"%{med}%") for med in cleaned_meds])
    )
    
    result = await db.execute(stmt)
    potential_effects = result.scalars().all()
    
    for symptom in input_data.symptoms:
        symptom_lower = symptom.lower()
        for effect in potential_effects:
            # Check if symptom matches side effect keyword
            # e.g. User says "coughing", DB has "Cough" -> Match?
            # Or User says "Cough", DB has "Dry Cough" -> Match?
            
            effect_lower = effect.side_effect.lower()
            
            # Bidirectional containment check for robust matching on small strings
            if symptom_lower in effect_lower or effect_lower in symptom_lower:
                matches.append(AdverseMatch(
                    drug_name=effect.drug_name,
                    side_effect=effect.side_effect,
                    likelihood=effect.frequency,
                    description=effect.description
                ))

    return AdverseCheckOutput(
        matches=matches,
        total_matches=len(matches)
    )
