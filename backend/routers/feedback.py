"""Feedback router — user feedback and bookmarks for Pulse."""

from fastapi import APIRouter
from models import FeedbackRequest, BookmarkRequest
from database import save_feedback, toggle_bookmark, get_all_analyses, get_analysis, delete_analysis

router = APIRouter(prefix="/api", tags=["feedback"])


@router.post("/feedback")
async def submit_feedback(request: FeedbackRequest):
    """Store user thumbs up/down on insights."""
    await save_feedback(
        run_id=request.run_id,
        insight_index=request.insight_index,
        rating=request.rating,
        comment=request.comment
    )
    return {"status": "success", "message": "Feedback recorded"}


@router.post("/bookmark")
async def bookmark(request: BookmarkRequest):
    """Toggle bookmark on analysis or insight."""
    await toggle_bookmark(
        run_id=request.run_id,
        insight_index=request.insight_index
    )
    return {"status": "success", "message": "Bookmark toggled"}


@router.get("/analyses")
async def list_analyses():
    """Get all past analyses."""
    analyses = await get_all_analyses()
    return {"analyses": analyses}


@router.get("/analyses/{run_id}")
async def get_single_analysis(run_id: str):
    """Get full analysis by run_id."""
    analysis = await get_analysis(run_id)
    if not analysis:
        return {"error": "Analysis not found"}
    return analysis


@router.delete("/analyses/{run_id}")
async def remove_analysis(run_id: str):
    """Delete an analysis."""
    await delete_analysis(run_id)
    return {"status": "success", "message": "Analysis deleted"}
