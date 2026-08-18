from pydantic import BaseModel, ConfigDict
from uuid import UUID
from datetime import datetime
from typing import Optional

class SecurityAnalysisBase(BaseModel):
    scanned_url: Optional[str] = None
    threat_level: Optional[str] = None
    phishing_score: Optional[float] = None
    ai_model_version: Optional[str] = None

class SecurityAnalysisCreate(SecurityAnalysisBase):
    scan_history_id: UUID

class SecurityAnalysisResponse(SecurityAnalysisBase):
    id: UUID
    scan_history_id: UUID
    analyzed_at: datetime

    model_config = ConfigDict(from_attributes=True)

class URLAnalyzeRequest(BaseModel):
    url: str

class URLAnalyzeResponse(SecurityAnalysisBase):
    is_safe: bool
    risk_factors: list[str]