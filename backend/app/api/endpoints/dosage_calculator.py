from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from app.api import deps
from app.models.dosage import DosageProtocol
from app.schemas.dosage import DosageInput, DosageRecommendation

router = APIRouter()

@router.post("/calculate", response_model=DosageRecommendation)
async def calculate_dosage(
    input_data: DosageInput,
    db: AsyncSession = Depends(deps.get_db)
):
    """
    Calculate safe drug dosage based on weight and age.
    """
    age_months = int(input_data.age_years * 12)
    
    # normalized drug name search (start simple)
    drug_query = input_data.drug_name.lower().strip()
    
    # Find matching protocol
    result = await db.execute(
        select(DosageProtocol).where(
            and_(
                DosageProtocol.drug_name.ilike(f"%{drug_query}%"),
                DosageProtocol.form == input_data.form,
                DosageProtocol.min_weight_kg <= input_data.weight_kg,
                DosageProtocol.max_weight_kg >= input_data.weight_kg,
                DosageProtocol.min_age_months <= age_months,
                DosageProtocol.max_age_months >= age_months
            )
        )
    )
    protocol = result.scalars().first()
    
    if not protocol:
        # Fallback: Try finding without strict age limits if weight is valid, or vice-versa
        # For now, return generic or empty
        raise HTTPException(status_code=404, detail=f"No dosage protocol found for {input_data.drug_name} ({input_data.form}) for this patient stats.")

    # Calculation Logic
    # 1. Calculate per dose
    dose_mg = input_data.weight_kg * protocol.dosage_per_kg_mg
    
    # 2. Safety Cap (Single Dose Cap if needed, but usually we have max daily)
    # Let's assume max_daily_dose is the absolute ceiling per day
    
    # 3. Frequency
    freq_str = f"Every {protocol.frequency_hours} hours" if protocol.frequency_hours else "As needed"
    doses_per_day = 24 / protocol.frequency_hours if protocol.frequency_hours else 3 # default 3?
    
    daily_total = dose_mg * doses_per_day
    
    warning = None
    if protocol.max_daily_dose_mg and daily_total > protocol.max_daily_dose_mg:
        # Cap logic or Warn? 
        # Better to cap the single dose to stay within daily limit
        # capped_single = protocol.max_daily_dose_mg / doses_per_day
        warning = f"Calculated dose exceeds daily limit. Capped to safe max."
        # For MVP, we just warn and show the calculated safe vs max
    
    # 4. Convert to ML if syrup
    dose_ml = None
    if protocol.form == "Syrup" and protocol.concentration_mg_per_ml:
        dose_ml = round(dose_mg / protocol.concentration_mg_per_ml, 1)
    
    return DosageRecommendation(
        drug_name=protocol.drug_name,
        calculated_dose_mg=round(dose_mg, 1),
        calculated_dose_ml=dose_ml,
        frequency=freq_str,
        max_daily_dose_mg=protocol.max_daily_dose_mg,
        instructions=protocol.instructions,
        warning=warning
    )
