from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_
from app.api import deps
from app.models.lab import LabProtocol
from app.schemas.lab import LabRecommendationInput, LabRecommendation

router = APIRouter()

@router.post("/recommend", response_model=List[LabRecommendation])
async def recommend_labs(
    input_data: LabRecommendationInput,
    db: AsyncSession = Depends(deps.get_db)
):
    """
    Recommend lab tests based on diagnosis.
    Returns a list of tests sorted by priority (Essential > Recommended > Optional).
    """
    diagnosis_lower = input_data.diagnosis.lower()
    
    # Simple keyword matching strategy
    # "Viral Fever" -> matches "viral", "fever"
    
    # 1. Exact or partial match on diagnosis keyword
    result = await db.execute(
        select(LabProtocol).where(
            or_(
                LabProtocol.diagnosis_keyword.ilike(f"%{diagnosis_lower}%"),
                # Check if the keyword functions as a substring of input
                # e.g. input "Acute Viral Fever" matches keyword "Fever"
                # We can do this in python or simple query. 
                # For now, let's reverse match: find protocols where keyword is in input string
            )
        )
    )
    all_protocols = result.scalars().all()
    
    # 2. Filter in Python for robust matching (e.g. input "Dengue Fever" should match "Dengue")
    matched_labs = []
    
    # To avoid duplicates if multiple keywords match same test
    seen_tests = set()
    
    # We fetch ALL protocols to do smarter python-side filtering (better for small datasets)
    # Ideally for production we optimize the SQL query
    # Re-querying to get all for in-memory filtering (since dataset is small <1000 rows)
    all_rows_result = await db.execute(select(LabProtocol))
    all_rows = all_rows_result.scalars().all()

    for p in all_rows:
        if p.diagnosis_keyword.lower() in diagnosis_lower:
            key = f"{p.test_name}-{p.priority}"
            if key not in seen_tests:
                matched_labs.append(p)
                seen_tests.add(key)
    
    # Sort order: Essential > Recommended > Optional
    priority_map = {"Essential": 1, "Recommended": 2, "Optional": 3}
    matched_labs.sort(key=lambda x: priority_map.get(x.priority, 4))
    
    return [
        LabRecommendation(
            test_name=lab.test_name,
            priority=lab.priority,
            reasoning=lab.reasoning
        ) for lab in matched_labs
    ]
