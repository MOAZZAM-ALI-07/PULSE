"""Pipeline router — core analysis endpoints for Pulse."""

import uuid
from fastapi import APIRouter, HTTPException
from models import (
    AnalysisRequest, IngestionResponse, InsightsResponse,
    ImpactResponse, ActionsResponse, ExecutionResponse
)
from gemini_service import (
    extract_signals, generate_insights, assess_impact,
    generate_actions, simulate_execution
)
from database import save_analysis, log_step, get_analysis

router = APIRouter(prefix="/api", tags=["pipeline"])


@router.post("/ingest", response_model=IngestionResponse)
async def ingest(request: AnalysisRequest):
    """Extract all facts, entities, numbers, dates, percentages from input."""
    run_id = request.run_id or str(uuid.uuid4())
    
    try:
        await log_step(run_id, "ingest", "started")
        
        result = await extract_signals(request.text, request.domain)
        
        await save_analysis(run_id, request.text, request.domain, "ingest", result)
        await log_step(run_id, "ingest", "completed", result)
        
        return IngestionResponse(
            run_id=run_id,
            signals=result.get("signals", []),
            signal_count=result.get("signal_count", len(result.get("signals", []))),
            domain_detected=result.get("domain_detected", request.domain)
        )
    except Exception as e:
        await log_step(run_id, "ingest", "failed", {"error": str(e)})
        raise HTTPException(status_code=500, detail=f"Ingestion failed: {str(e)}")


@router.post("/insights", response_model=InsightsResponse)
async def insights(request: AnalysisRequest):
    """Generate 3-5 non-obvious insights with confidence scores."""
    run_id = request.run_id or str(uuid.uuid4())
    
    try:
        await log_step(run_id, "insights", "started")
        
        # Get existing ingestion data
        analysis = await get_analysis(run_id)
        signals = []
        if analysis and analysis.get("ingestion_data"):
            signals = analysis["ingestion_data"].get("signals", [])
        
        result = await generate_insights(request.text, signals, request.domain)
        
        await save_analysis(run_id, request.text, request.domain, "insights", result)
        await log_step(run_id, "insights", "completed", result)
        
        return InsightsResponse(
            run_id=run_id,
            insights=result.get("insights", [])
        )
    except Exception as e:
        await log_step(run_id, "insights", "failed", {"error": str(e)})
        raise HTTPException(status_code=500, detail=f"Insights generation failed: {str(e)}")


@router.post("/impact", response_model=ImpactResponse)
async def impact(request: AnalysisRequest):
    """Map insights to real business consequences."""
    run_id = request.run_id or str(uuid.uuid4())
    
    try:
        await log_step(run_id, "impact", "started")
        
        # Get existing insights data
        analysis = await get_analysis(run_id)
        insights_data = []
        if analysis and analysis.get("insights_data"):
            insights_data = analysis["insights_data"].get("insights", [])
        
        result = await assess_impact(request.text, insights_data, request.domain)
        
        await save_analysis(run_id, request.text, request.domain, "impact", result)
        await log_step(run_id, "impact", "completed", result)
        
        return ImpactResponse(
            run_id=run_id,
            impacts=result.get("impacts", []),
            overall_severity=result.get("overall_severity", "Medium"),
            summary=result.get("summary", "")
        )
    except Exception as e:
        await log_step(run_id, "impact", "failed", {"error": str(e)})
        raise HTTPException(status_code=500, detail=f"Impact assessment failed: {str(e)}")


@router.post("/actions", response_model=ActionsResponse)
async def actions(request: AnalysisRequest):
    """Generate exactly 3 ranked recommended actions."""
    run_id = request.run_id or str(uuid.uuid4())
    
    try:
        await log_step(run_id, "actions", "started")
        
        # Get existing impact data
        analysis = await get_analysis(run_id)
        impacts = []
        if analysis and analysis.get("impact_data"):
            impacts = analysis["impact_data"].get("impacts", [])
        
        result = await generate_actions(request.text, impacts, request.domain)
        
        await save_analysis(run_id, request.text, request.domain, "actions", result)
        await log_step(run_id, "actions", "completed", result)
        
        return ActionsResponse(
            run_id=run_id,
            actions=result.get("actions", [])
        )
    except Exception as e:
        await log_step(run_id, "actions", "failed", {"error": str(e)})
        raise HTTPException(status_code=500, detail=f"Actions generation failed: {str(e)}")


@router.post("/execute", response_model=ExecutionResponse)
async def execute(request: AnalysisRequest):
    """Simulate 3 execution actions: email, CRM update, dashboard update."""
    run_id = request.run_id or str(uuid.uuid4())
    
    try:
        await log_step(run_id, "execute", "started")
        
        # Get existing actions data
        analysis = await get_analysis(run_id)
        actions_data = []
        if analysis and analysis.get("actions_data"):
            actions_data = analysis["actions_data"].get("actions", [])
        
        result = await simulate_execution(request.text, actions_data, request.domain)
        
        await save_analysis(run_id, request.text, request.domain, "execute", result)
        await log_step(run_id, "execute", "completed", result)
        
        return ExecutionResponse(
            run_id=run_id,
            email=result.get("email", {}),
            crm_update=result.get("crm_update", {}),
            dashboard_update=result.get("dashboard_update", {})
        )
    except Exception as e:
        await log_step(run_id, "execute", "failed", {"error": str(e)})
        raise HTTPException(status_code=500, detail=f"Execution simulation failed: {str(e)}")
