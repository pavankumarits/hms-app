from sqlalchemy.ext.asyncio import AsyncSession
from app.models.audit import AuditLog

import uuid

async def create_audit_log(
    db: AsyncSession,
    user_id: str,
    action: str,
    resource: str,
    details: str = None
):
    log = AuditLog(
        id=str(uuid.uuid4()),
        user_id=user_id,
        action=action,
        resource=resource,
        details=details
    )
    db.add(log)
    await db.commit()
