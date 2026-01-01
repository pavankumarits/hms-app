from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_, and_
from app.api import deps
from app.models.interactions import DrugInteraction
from app.schemas.interactions import AuditInput, AuditOutput, InteractionAlert

router = APIRouter()

@router.post("/audit", response_model=AuditOutput)
async def audit_prescription(
    input_data: AuditInput,
    db: AsyncSession = Depends(deps.get_db)
):
    """
    Check for Drug-Drug Interactions between new drug and current meds.
    """
    alerts = []
    
    if not input_data.current_meds:
        return AuditOutput(interactions=[], is_safe=True)

    new_drug_clean = input_data.new_drug.split()[0] # Simple heuristic
    
    # Check against each current med
    for current_med in input_data.current_meds:
        current_med_clean = current_med.split()[0]
        
        # Check bidirectional: (A=New, B=Current) OR (A=Current, B=New)
        # Using ILIKE for case-insensitive partial matching
        stmt = select(DrugInteraction).where(
            or_(
                and_(
                    DrugInteraction.drug_a.ilike(f"%{new_drug_clean}%"),
                    DrugInteraction.drug_b.ilike(f"%{current_med_clean}%")
                ),
                and_(
                    DrugInteraction.drug_a.ilike(f"%{current_med_clean}%"),
                    DrugInteraction.drug_b.ilike(f"%{new_drug_clean}%")
                )
            )
        )
        
        result = await db.execute(stmt)
        interactions = result.scalars().all()
        
        for interaction in interactions:
            alerts.append(InteractionAlert(
                interacting_drug=current_med, # The drug causing conflict
                severity=interaction.severity,
                description=interaction.description,
                management=interaction.management
            ))

    return AuditOutput(
        interactions=alerts,
        is_safe=len(alerts) == 0
    )
