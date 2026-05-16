"""Pydantic models for Pulse API request/response schemas."""

from pydantic import BaseModel, Field
from typing import List, Optional
from enum import Enum


class DomainType(str, Enum):
    BUSINESS = "Business"
    FINANCE = "Finance"
    SUPPLY_CHAIN = "Supply Chain"
    POLICY = "Policy"
    HEALTHCARE = "Healthcare"


class SeverityLevel(str, Enum):
    LOW = "Low"
    MEDIUM = "Medium"
    HIGH = "High"
    CRITICAL = "Critical"


class InsightTag(str, Enum):
    FINANCIAL = "Financial"
    OPERATIONAL = "Operational"
    RISK = "Risk"
    OPPORTUNITY = "Opportunity"


# ─── Request Models ───

class AnalysisRequest(BaseModel):
    text: str = Field(..., min_length=10, description="Input text to analyze")
    domain: Optional[str] = Field(default="Business", description="Analysis domain")
    run_id: Optional[str] = Field(default=None, description="Run ID for pipeline tracking")


class FeedbackRequest(BaseModel):
    run_id: str
    insight_index: int
    rating: str = Field(..., pattern="^(up|down)$")
    comment: Optional[str] = None


class BookmarkRequest(BaseModel):
    run_id: str
    insight_index: Optional[int] = None


# ─── Response Models ───

class ExtractedSignal(BaseModel):
    text: str
    signal_type: str  # fact, entity, number, date, percentage
    value: Optional[str] = None
    context: Optional[str] = None


class IngestionResponse(BaseModel):
    run_id: str
    signals: List[ExtractedSignal]
    signal_count: int
    domain_detected: str


class Insight(BaseModel):
    text: str
    confidence: float = Field(..., ge=0, le=100)
    tag: str
    severity: str
    explanation: str


class InsightsResponse(BaseModel):
    run_id: str
    insights: List[Insight]


class ImpactItem(BaseModel):
    insight: str
    consequence: str
    severity: str
    severity_explanation: str
    estimated_impact: Optional[str] = None


class ImpactResponse(BaseModel):
    run_id: str
    impacts: List[ImpactItem]
    overall_severity: str
    summary: str


class Action(BaseModel):
    rank: int
    title: str
    description: str
    priority: str
    expected_outcome: str


class ActionsResponse(BaseModel):
    run_id: str
    actions: List[Action]


class EmailDraft(BaseModel):
    subject: str
    to: str
    body: str


class CRMUpdate(BaseModel):
    record_type: str
    before: dict
    after: dict


class DashboardMetric(BaseModel):
    metric_name: str
    before_value: str
    after_value: str
    change_percent: str
    direction: str  # up or down


class ExecutionResponse(BaseModel):
    run_id: str
    email: EmailDraft
    crm_update: CRMUpdate
    dashboard_update: DashboardMetric


class LogEntry(BaseModel):
    step: str
    status: str
    data: Optional[dict] = None
    timestamp: str


class LogsResponse(BaseModel):
    run_id: str
    logs: List[LogEntry]
    total_steps: int
