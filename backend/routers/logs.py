"""Logs router — pipeline log retrieval for Pulse."""

from fastapi import APIRouter, HTTPException
from models import LogsResponse
from database import get_logs

router = APIRouter(prefix="/api", tags=["logs"])


@router.get("/logs/{run_id}", response_model=LogsResponse)
async def get_pipeline_logs(run_id: str):
    """Get full pipeline logs for a run, exportable as JSON."""
    logs = await get_logs(run_id)
    
    if not logs:
        raise HTTPException(status_code=404, detail=f"No logs found for run_id: {run_id}")
    
    return LogsResponse(
        run_id=run_id,
        logs=logs,
        total_steps=len(logs)
    )
