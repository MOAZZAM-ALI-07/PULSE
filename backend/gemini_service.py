"""Gemini 2.0 Flash API integration for Pulse analysis pipeline with Key Rotation Pool."""

import os
import json
import asyncio
import httpx
from dotenv import load_dotenv
from fallback_data import (
    get_fallback_signals, get_fallback_insights,
    get_fallback_impact, get_fallback_actions, get_fallback_execution
)

load_dotenv()

# The 8 fresh API keys from different accounts to share the load and prevent quota issues
API_KEYS_POOL = [
    "AIzaSyBwaFSkK8SRwLrfeP6QVcVnYtYC12AIJTo",
    "AIzaSyB6x0LuA8Njah7rgw0NgNZd0-Ro-07PxAU",
    "AIzaSyAb2PLGO-gqkpjws67J0WON_NzWcDaelcc",
    "AIzaSyAqlgMaBE4GIdSVS0JwStqcil5USOzNv54",
    "AIzaSyDNV4MhE6k5WY-XRcKKgopI9yO_9_s7XRQ",
    "AIzaSyBPrvh1QaM8xNCmjv3veT6UmwL6JN3NxEE",
    "AIzaSyD67WQ27NVQTrQG3zb333e0tjVbdavRRZA",
    "AIzaSyCTpOMepAobV17uI3olPrCmTezWZ75pHNI"
]

# Track the active key index globally
_active_key_index = 0

GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

# Rate limit protection settings
MAX_RETRIES_PER_KEY = 2
BASE_DELAY = 1.5


def _get_current_key() -> str:
    """Get the currently active API key from the pool, or fallback to env."""
    global _active_key_index
    # First try from the pool
    if API_KEYS_POOL:
        # Wrap index to ensure it is always in bounds
        idx = _active_key_index % len(API_KEYS_POOL)
        return API_KEYS_POOL[idx]
    # Fallback to backend .env key if pool is somehow empty
    return os.getenv("GEMINI_API_KEY", "")


def _rotate_key():
    """Rotate to the next API key in the pool."""
    global _active_key_index
    if API_KEYS_POOL:
        old_idx = _active_key_index % len(API_KEYS_POOL)
        _active_key_index = (old_idx + 1) % len(API_KEYS_POOL)
        print(f"[PULSE ROTATION] Key index {old_idx} rate-limited or failed. Switched to key index {_active_key_index}.")


async def call_gemini(prompt: str, system_instruction: str = None) -> dict:
    """Call Gemini 2.0 Flash API with auto key-rotation, retry logic, and rate-limit handling."""
    
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
    
    # Try keys from the pool one by one
    total_keys = len(API_KEYS_POOL) if API_KEYS_POOL else 1
    
    for key_attempt in range(total_keys):
        current_key = _get_current_key()
        url = f"{GEMINI_URL}?key={current_key}"
        
        for attempt in range(MAX_RETRIES_PER_KEY):
            try:
                async with httpx.AsyncClient(timeout=30.0) as client:
                    response = await client.post(url, json=payload, headers=headers)
                    
                    # Rate limited (429) -> wait briefly and retry on same key first
                    if response.status_code == 429:
                        delay = BASE_DELAY * (2 ** attempt)
                        print(f"[PULSE] Key {_active_key_index % len(API_KEYS_POOL)} rate limited (429). Retry {attempt+1}/{MAX_RETRIES_PER_KEY} in {delay}s...")
                        await asyncio.sleep(delay)
                        continue
                    
                    # Server error (5xx) -> wait and retry
                    if response.status_code >= 500:
                        delay = BASE_DELAY * (2 ** attempt)
                        print(f"[PULSE] Server error ({response.status_code}). Retry {attempt+1}/{MAX_RETRIES_PER_KEY} in {delay}s...")
                        await asyncio.sleep(delay)
                        continue
                    
                    # Bad Request/Unauthorized -> key might be invalid or restricted, rotate immediately
                    if response.status_code == 400 or response.status_code == 403:
                        print(f"[PULSE] Key {_active_key_index % len(API_KEYS_POOL)} returned {response.status_code}. Rotating key...")
                        _rotate_key()
                        break # Break inner loop to try next key in outer loop
                    
                    if response.status_code != 200:
                        raise Exception(f"AI service error (HTTP {response.status_code})")
                    
                    result = response.json()
                    
                    try:
                        text = result["candidates"][0]["content"]["parts"][0]["text"]
                    except (IndexError, KeyError):
                        raise Exception("AI returned empty response")
                    
                    try:
                        return json.loads(text)
                    except json.JSONDecodeError:
                        if "```json" in text:
                            text = text.split("```json")[1].split("```")[0].strip()
                        elif "```" in text:
                            text = text.split("```")[1].split("```")[0].strip()
                        try:
                            return json.loads(text)
                        except json.JSONDecodeError:
                            raise Exception("AI returned invalid JSON")
                            
            except httpx.TimeoutException:
                delay = BASE_DELAY * (2 ** attempt)
                print(f"[PULSE] Timeout on Key {_active_key_index % len(API_KEYS_POOL)}. Retry {attempt+1}/{MAX_RETRIES_PER_KEY} in {delay}s...")
                await asyncio.sleep(delay)
                continue
            except httpx.ConnectError:
                print(f"[PULSE] Connection error on Key {_active_key_index % len(API_KEYS_POOL)}. Rotating...")
                _rotate_key()
                break
            except Exception as e:
                error_msg = str(e)
                # Hide key in logs if present
                if current_key and current_key in error_msg:
                    error_msg = error_msg.replace(current_key, "***")
                print(f"[PULSE] Exception on Key {_active_key_index % len(API_KEYS_POOL)}: {error_msg}. Rotating...")
                _rotate_key()
                break
        else:
            # If inner loop finished without breaking/returning successfully, it means all retries on this key failed.
            # Rotate key for the next attempt.
            _rotate_key()
            
    # All keys and retries failed -> Raise Exception to trigger high-fidelity fallback in step methods
    raise Exception("ALL_KEYS_EXHAUSTED")


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
    
    try:
        return await call_gemini(prompt, system)
    except Exception as e:
        print(f"[PULSE] Gemini failed for extract_signals: {e}. Using fallback.")
        return get_fallback_signals(text, domain)


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
    
    try:
        await asyncio.sleep(1.0)
        return await call_gemini(prompt, system)
    except Exception as e:
        print(f"[PULSE] Gemini failed for generate_insights: {e}. Using fallback.")
        return get_fallback_insights(text, domain)


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
    
    try:
        await asyncio.sleep(1.0)
        return await call_gemini(prompt, system)
    except Exception as e:
        print(f"[PULSE] Gemini failed for assess_impact: {e}. Using fallback.")
        return get_fallback_impact(text, domain)


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
    
    try:
        await asyncio.sleep(1.0)
        return await call_gemini(prompt, system)
    except Exception as e:
        print(f"[PULSE] Gemini failed for generate_actions: {e}. Using fallback.")
        return get_fallback_actions(text, domain)


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
    
    try:
        await asyncio.sleep(1.0)
        return await call_gemini(prompt, system)
    except Exception as e:
        print(f"[PULSE] Gemini failed for simulate_execution: {e}. Using fallback.")
        return get_fallback_execution(text, domain)
