"""Gemini 2.0 Flash API integration for Pulse analysis pipeline."""

import os
import json
import httpx
from dotenv import load_dotenv

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"


async def call_gemini(prompt: str, system_instruction: str = None) -> dict:
    """Call Gemini 2.0 Flash API with a prompt and return parsed JSON response."""
    
    headers = {"Content-Type": "application/json"}
    
    contents = [{"parts": [{"text": prompt}]}]
    
    payload = {
        "contents": contents,
        "generationConfig": {
            "temperature": 0.3,
            "topP": 0.95,
            "topK": 40,
            "maxOutputTokens": 4096,
            "responseMimeType": "application/json"
        }
    }
    
    if system_instruction:
        payload["systemInstruction"] = {
            "parts": [{"text": system_instruction}]
        }
    
    async with httpx.AsyncClient(timeout=60.0) as client:
        response = await client.post(
            f"{GEMINI_URL}?key={GEMINI_API_KEY}",
            json=payload,
            headers=headers
        )
        response.raise_for_status()
        result = response.json()
    
    # Extract text from Gemini response
    text = result["candidates"][0]["content"]["parts"][0]["text"]
    
    # Parse JSON from response
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        # Try to extract JSON from markdown code blocks
        if "```json" in text:
            text = text.split("```json")[1].split("```")[0].strip()
        elif "```" in text:
            text = text.split("```")[1].split("```")[0].strip()
        return json.loads(text)


async def extract_signals(text: str, domain: str) -> dict:
    """Extract facts, entities, numbers, dates, percentages from input text."""
    
    prompt = f"""Analyze this {domain} text and extract ALL signals.

INPUT TEXT:
{text}

Return a JSON object with this exact structure:
{{
    "signals": [
        {{
            "text": "exact quote or extracted info",
            "signal_type": "fact|entity|number|date|percentage",
            "value": "the numeric or date value if applicable",
            "context": "brief context of what this signal means"
        }}
    ],
    "domain_detected": "{domain}",
    "signal_count": <number>
}}

Extract EVERY factual claim, named entity, number, date, and percentage. Be thorough."""

    system = "You are a precision data extraction engine for business intelligence. Extract every signal with zero hallucination. Only extract what is explicitly stated in the input."
    
    return await call_gemini(prompt, system)


async def generate_insights(text: str, signals: list, domain: str) -> dict:
    """Generate 3-5 non-obvious insights from extracted signals."""
    
    signals_text = json.dumps(signals, indent=2)
    
    prompt = f"""Based on these extracted signals from a {domain} report, generate 3-5 NON-OBVIOUS insights.

ORIGINAL TEXT:
{text}

EXTRACTED SIGNALS:
{signals_text}

Return a JSON object with this exact structure:
{{
    "insights": [
        {{
            "text": "The insight statement - must be non-obvious and actionable",
            "confidence": <number 0-100>,
            "tag": "Financial|Operational|Risk|Opportunity",
            "severity": "Low|Medium|High|Critical",
            "explanation": "Why this insight matters and how it was derived"
        }}
    ]
}}

Rules:
- Generate exactly 3-5 insights
- Each must be NON-OBVIOUS (not just restating the data)
- Confidence score must reflect how well-supported the insight is
- Tag must be one of: Financial, Operational, Risk, Opportunity
- Severity must be one of: Low, Medium, High, Critical
- Explanation should show reasoning"""

    system = "You are a senior business analyst at a top consulting firm. Generate insights that a CEO would find valuable. Focus on hidden patterns, correlations, and implications."
    
    return await call_gemini(prompt, system)


async def assess_impact(text: str, insights: list, domain: str) -> dict:
    """Map insights to real business consequences."""
    
    insights_text = json.dumps(insights, indent=2)
    
    prompt = f"""Map these {domain} insights to concrete business consequences.

ORIGINAL TEXT:
{text}

INSIGHTS:
{insights_text}

Return a JSON object with this exact structure:
{{
    "impacts": [
        {{
            "insight": "the original insight text",
            "consequence": "specific business consequence",
            "severity": "Low|Medium|High|Critical",
            "severity_explanation": "why this severity level was assigned",
            "estimated_impact": "quantified impact if possible (e.g., PKR 3.6M revenue loss)"
        }}
    ],
    "overall_severity": "Low|Medium|High|Critical",
    "summary": "2-3 sentence executive summary of all impacts"
}}"""

    system = "You are a risk assessment specialist. Map each insight to its most likely business consequence with quantified impact where possible."
    
    return await call_gemini(prompt, system)


async def generate_actions(text: str, impacts: list, domain: str) -> dict:
    """Generate exactly 3 ranked recommended actions."""
    
    impacts_text = json.dumps(impacts, indent=2)
    
    prompt = f"""Based on these {domain} impact assessments, generate exactly 3 ranked recommended actions.

ORIGINAL TEXT:
{text}

IMPACT ASSESSMENTS:
{impacts_text}

Return a JSON object with this exact structure:
{{
    "actions": [
        {{
            "rank": 1,
            "title": "Action title",
            "description": "Detailed description of what to do",
            "priority": "P1|P2|P3",
            "expected_outcome": "What this action will achieve"
        }},
        {{
            "rank": 2,
            "title": "Action title",
            "description": "Detailed description of what to do",
            "priority": "P1|P2|P3",
            "expected_outcome": "What this action will achieve"
        }},
        {{
            "rank": 3,
            "title": "Action title",
            "description": "Detailed description of what to do",
            "priority": "P1|P2|P3",
            "expected_outcome": "What this action will achieve"
        }}
    ]
}}

Rules:
- Exactly 3 actions, ranked by impact
- P1 = immediate action needed, P2 = this week, P3 = this month
- Expected outcome must be specific and measurable"""

    system = "You are a management consultant. Provide exactly 3 actionable, specific recommendations ranked by urgency and impact."
    
    return await call_gemini(prompt, system)


async def simulate_execution(text: str, actions: list, domain: str) -> dict:
    """Simulate 3 execution actions: email, CRM update, dashboard update."""
    
    actions_text = json.dumps(actions, indent=2)
    
    prompt = f"""Simulate executing these {domain} actions. Generate realistic outputs for all 3 simulations.

ORIGINAL TEXT:
{text}

RECOMMENDED ACTIONS:
{actions_text}

Return a JSON object with this exact structure:
{{
    "email": {{
        "subject": "Professional email subject",
        "to": "relevant-stakeholders@company.com",
        "body": "Full professional email body with greeting, context, findings, recommended actions, and professional closing. Use proper formatting."
    }},
    "crm_update": {{
        "record_type": "Account|Lead|Opportunity",
        "before": {{
            "status": "previous status",
            "risk_level": "previous risk",
            "notes": "previous notes",
            "last_activity": "previous date",
            "revenue_forecast": "previous forecast"
        }},
        "after": {{
            "status": "updated status",
            "risk_level": "updated risk",
            "notes": "updated notes with analysis findings",
            "last_activity": "current date",
            "revenue_forecast": "updated forecast"
        }}
    }},
    "dashboard_update": {{
        "metric_name": "Key metric that changed",
        "before_value": "previous value with units",
        "after_value": "new value with units",
        "change_percent": "percentage change with sign",
        "direction": "up|down"
    }}
}}

Make all simulations realistic and specific to the input data."""

    system = "You are simulating business system updates. Generate realistic, professional outputs that match the analysis data exactly."
    
    return await call_gemini(prompt, system)
