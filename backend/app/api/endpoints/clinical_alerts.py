from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.api import deps
from app.models.alerts import ClinicalAlertRule
from app.schemas.alerts import AlertInput, AlertOutput, AlertCheckResponse

router = APIRouter()

@router.post("/check", response_model=AlertCheckResponse)
async def check_alerts(
    input_data: AlertInput,
    db: AsyncSession = Depends(deps.get_db)
):
    """
    Check for preventive care gaps and clinical alerts.
    """
    generated_alerts = []
    
    # Fetch all rules (optimize later if needed)
    result = await db.execute(select(ClinicalAlertRule))
    rules = result.scalars().all()
    
    for rule in rules:
        # 1. Check Age Constraint
        if not (rule.min_age <= input_data.age <= rule.max_age):
            continue
            
        # 2. Check Gender Constraint
        if rule.target_gender != "All" and rule.target_gender.lower() != input_data.gender.lower():
            continue
            
        # 3. Check Condition Constraint (if rule has one)
        if rule.condition_keyword:
            # Check if patient HAS the condition required for this alert
            # e.g. Rule "HbA1c" requires "Diabetes"
            has_condition = False
            for cond in input_data.conditions:
                if rule.condition_keyword.lower() in cond.lower():
                    has_condition = True
                    break
            
            if not has_condition:
                continue

        # If all passed, add alert
        generated_alerts.append(AlertOutput(
            alert_name=rule.alert_name,
            message=rule.alert_message,
            priority=rule.priority,
            reference=rule.reference_guideline
        ))
        
    return AlertCheckResponse(
        alerts=generated_alerts,
        total_alerts=len(generated_alerts)
    )
