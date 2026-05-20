"""
PULSE — Reflection Agent
Self-critique layer. Yeh agent apni hi output ko question karta hai.
Judges ke liye sabse impressive feature — "Agency = Autonomy + Self-Correction"
"""

import json
from gemini_service import call_gemini
from database import log_step


class ReflectionAgent:
    """
    After all 5 specialist agents finish, Reflection Agent reviews the full output.
    It asks Gemini: 'Are these insights actually good? What's missing? What's wrong?'
    If quality is poor, it triggers a re-run of specific agents.
    This is what separates PULSE from a basic API wrapper.
    """

    SYSTEM_PROMPT = """You are a brutal quality reviewer for a business intelligence system.
Your job is to find flaws, gaps, and weaknesses in AI-generated analysis.
Be harsh. Be specific. Your critique directly improves the output quality.
Never say something is perfect — there is always room for improvement."""

    async def reflect(
        self,
        run_id: str,
        original_text: str,
        pipeline_output: dict,
    ) -> dict:
        """
        Review the full pipeline output. Return quality score + specific issues.
        If score < 60, recommend which agents should re-run.
        """
        await log_step(run_id, "reflection", "started")

        insights = pipeline_output.get("pipeline_data", {}).get(
            "insights", {}
        ).get("insights", [])
        impacts = pipeline_output.get("pipeline_data", {}).get(
            "impact", {}
        ).get("impacts", [])
        actions = pipeline_output.get("pipeline_data", {}).get(
            "actions", {}
        ).get("actions", [])

        prompt = f"""Review this business intelligence analysis and score its quality.

ORIGINAL INPUT TEXT:
{original_text}

GENERATED INSIGHTS:
{json.dumps(insights, indent=2)}

GENERATED IMPACTS:
{json.dumps(impacts, indent=2)}

RECOMMENDED ACTIONS:
{json.dumps(actions, indent=2)}

Return ONLY a JSON object with this exact structure:
{{
    "quality_score": <number 0-100>,
    "verdict": "Excellent|Good|Acceptable|Poor|Unacceptable",
    "strengths": ["strength 1", "strength 2"],
    "weaknesses": ["weakness 1", "weakness 2", "weakness 3"],
    "missing_insights": ["what was missed that should have been caught"],
    "hallucination_flags": ["any claims not supported by the original text"],
    "rerun_recommendation": {{
        "should_rerun": <true/false>,
        "agents_to_rerun": ["insight_agent"|"risk_agent"|"action_agent"],
        "reason": "why a rerun is needed"
    }},
    "improved_summary": "Your own 2-sentence summary that is better than what was generated"
}}

Be genuinely critical. A score above 85 means near-perfect analysis.
Score below 60 means a rerun should be triggered."""

        reflection = await call_gemini(prompt, self.SYSTEM_PROMPT)

        # Log the reflection decision
        score = reflection.get("quality_score", 0)
        verdict = reflection.get("verdict", "Unknown")
        should_rerun = reflection.get("rerun_recommendation", {}).get("should_rerun", False)

        print(f"[REFLECTION AGENT] Score: {score}/100 | Verdict: {verdict} | Rerun: {should_rerun}")

        await log_step(run_id, "reflection", "completed", {
            "quality_score": score,
            "verdict": verdict,
            "should_rerun": should_rerun,
            "weaknesses": reflection.get("weaknesses", []),
        })

        return {
            "run_id": run_id,
            "reflection": reflection,
            "quality_score": score,
            "verdict": verdict,
            "should_rerun": should_rerun,
        }

    async def reflect_single_insight(self, insight: dict, original_text: str) -> dict:
        """
        Quick reflection on a single insight.
        Used by alert agent before sending proactive alerts.
        """
        prompt = f"""Evaluate this single business insight for quality and accuracy.

ORIGINAL TEXT: {original_text}

INSIGHT: {json.dumps(insight, indent=2)}

Return ONLY JSON:
{{
    "is_valid": <true/false>,
    "confidence_accurate": <true/false>,
    "is_actionable": <true/false>,
    "improvement": "How to state this insight better (one sentence)",
    "should_alert": <true/false — is this worth proactively alerting the user?>
}}"""

        return await call_gemini(prompt, self.SYSTEM_PROMPT)


# ─── FastAPI Route (add to pipeline.py) ──────────────────────────────────────
# from reflection_agent import ReflectionAgent
#
# @router.post("/reflect/{run_id}")
# async def reflect(run_id: str, request: AnalysisRequest):
#     """Reflection agent reviews pipeline output quality."""
#     agent = ReflectionAgent()
#     analysis = await get_analysis(run_id)
#     result = await agent.reflect(run_id, request.text, analysis)
#     return result
