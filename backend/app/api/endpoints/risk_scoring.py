from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.api import deps
from app.models.risk import RiskRule
from app.schemas.risk import RiskInput, RiskAssessmentOutput, RiskFactorContributor

router = APIRouter()

@router.post("/assess", response_model=RiskAssessmentOutput)
async def assess_risk(
    input_data: RiskInput,
    db: AsyncSession = Depends(deps.get_db)
):
    """
    Calculate patient health risk score based on history and vitals.
    """
    contributors = []
    total_score = 0
    
    # 1. Age Factor (Hardcoded logic for demographics)
    if input_data.age > 65:
        points = 15
        total_score += points
        contributors.append(RiskFactorContributor(factor="Age > 65", points=points, category="Demographics"))
    elif input_data.age > 50:
        points = 10
        total_score += points
        contributors.append(RiskFactorContributor(factor="Age > 50", points=points, category="Demographics"))

    # 2. Vitals Logic (Hardcoded)
    if input_data.systolic_bp and input_data.systolic_bp >= 140:
        points = 15
        total_score += points
        contributors.append(RiskFactorContributor(factor="Systolic BP >= 140", points=points, category="Vitals"))
    elif input_data.systolic_bp and input_data.systolic_bp >= 130:
        points = 5
        total_score += points
        contributors.append(RiskFactorContributor(factor="Systolic BP >= 130", points=points, category="Vitals"))

    # 3. Fetch Dynamic Rules for Conditions & Lifestyle
    # Combine inputs to search against DB rules
    search_terms = input_data.conditions + input_data.lifestyle_factors
    
    # Fetch all rules (small table) - optimization: filter by keywords if list is huge, 
    # but usually < 100 rules, so fetching all and matching in python is fine, 
    # OR iteratively query. Let's fetch all active rules for simplicity and speed (cache candidate).
    all_rules_result = await db.execute(select(RiskRule))
    all_rules = all_rules_result.scalars().all()
    
    for term in search_terms:
        term_lower = term.lower()
        for rule in all_rules:
            # Check if rule keyword is in patient's reported term (e.g. "Diabetes Type 2" matches "Diabetes")
            if rule.condition_keyword.lower() in term_lower:
                # Avoid double counting if multiple terms match same rule? 
                # Simple logic for now: just add.
                 total_score += rule.risk_points
                 contributors.append(RiskFactorContributor(
                     factor=term, 
                     points=rule.risk_points, 
                     category=rule.category
                 ))
                 break # Match first rule per term

    # 4. Determine Level
    if total_score < 30:
        level = "Low"
        rec = "Routine checkups recommended."
    elif total_score < 60:
        level = "Medium"
        rec = "Preventive care and lifestyle changes advised."
    else:
        level = "High"
        rec = "Immediate medical attention or specialist consult required."

    return RiskAssessmentOutput(
        total_score=total_score,
        risk_level=level,
        contributors=contributors,
        recommendation=rec
    )
