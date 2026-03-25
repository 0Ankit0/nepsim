from datetime import datetime
from typing import Optional

from pydantic import BaseModel, field_validator


class UserSyncSettingsRead(BaseModel):
    backup_gemini_key_to_cloud: bool
    cloud_gemini_key_stored: bool
    last_synced_at: Optional[datetime] = None


class UserSyncSettingsUpdate(BaseModel):
    backup_gemini_key_to_cloud: bool
    gemini_api_key: Optional[str] = None

    @field_validator("gemini_api_key")
    @classmethod
    def normalize_key(cls, value: Optional[str]) -> Optional[str]:
        if value is None:
            return None
        stripped = value.strip()
        return stripped or None
