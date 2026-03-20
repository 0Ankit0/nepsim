"""
Supabase async client singleton.

Usage:
    from src.db.supabase import get_supabase_client
    client = await get_supabase_client()
    if client:
        data = await client.table("historicdata").select("*").execute()
"""
from __future__ import annotations

import logging
from typing import Optional

from src.apps.core.config import settings

logger = logging.getLogger(__name__)

_client = None


async def get_supabase_client():
    """
    Return a shared AsyncClient for Supabase.
    Returns None (with a warning) if the env-vars are not configured.
    """
    global _client

    if _client is not None:
        return _client

    url = getattr(settings, "SUPABASE_URL", "")
    key = getattr(settings, "SUPABASE_KEY", "")

    if not url or not key:
        logger.warning(
            "SUPABASE_URL or SUPABASE_KEY is not configured. "
            "Supabase-backed endpoints will return empty results."
        )
        return None

    try:
        from supabase import create_async_client  # type: ignore

        _client = await create_async_client(url, key)
        logger.info("Supabase async client initialised.")
        return _client
    except Exception as exc:
        logger.error("Failed to create Supabase client: %s", exc)
        return None


def reset_supabase_client() -> None:
    """Reset the singleton (useful in tests)."""
    global _client
    _client = None
