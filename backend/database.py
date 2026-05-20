"""SQLite database setup and management for Pulse backend."""

import aiosqlite
import os
import json
from datetime import datetime

DB_PATH = os.environ.get("DB_PATH", "/tmp/pulse.db")


async def init_db():
    """Initialize database tables."""
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("""
            CREATE TABLE IF NOT EXISTS analyses (
                id TEXT PRIMARY KEY,
                run_id TEXT NOT NULL,
                input_text TEXT NOT NULL,
                domain TEXT DEFAULT 'Business',
                created_at TEXT NOT NULL,
                ingestion_data TEXT,
                insights_data TEXT,
                impact_data TEXT,
                actions_data TEXT,
                execution_data TEXT,
                severity TEXT DEFAULT 'Medium',
                confidence_avg REAL DEFAULT 0.0,
                bookmarked INTEGER DEFAULT 0
            )
        """)
        await db.execute("""
            CREATE TABLE IF NOT EXISTS pipeline_logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                run_id TEXT NOT NULL,
                step TEXT NOT NULL,
                status TEXT NOT NULL,
                data TEXT,
                timestamp TEXT NOT NULL
            )
        """)
        await db.execute("""
            CREATE TABLE IF NOT EXISTS feedback (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                run_id TEXT NOT NULL,
                insight_index INTEGER,
                rating TEXT NOT NULL,
                comment TEXT,
                created_at TEXT NOT NULL
            )
        """)
        await db.execute("""
            CREATE TABLE IF NOT EXISTS bookmarks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                run_id TEXT NOT NULL,
                insight_index INTEGER,
                bookmark_type TEXT NOT NULL,
                created_at TEXT NOT NULL
            )
        """)
        await db.commit()


async def get_db():
    """Get database connection."""
    db = await aiosqlite.connect(DB_PATH)
    db.row_factory = aiosqlite.Row
    return db


async def save_analysis(run_id: str, input_text: str, domain: str, step: str, data: dict):
    """Save or update analysis data."""
    async with aiosqlite.connect(DB_PATH) as db:
        cursor = await db.execute("SELECT id FROM analyses WHERE run_id = ?", (run_id,))
        row = await cursor.fetchone()
        
        now = datetime.utcnow().isoformat()
        data_json = json.dumps(data)
        
        column_map = {
            "ingest": "ingestion_data",
            "insights": "insights_data",
            "impact": "impact_data",
            "actions": "actions_data",
            "execute": "execution_data",
        }
        
        if row is None:
            await db.execute(
                """INSERT INTO analyses (id, run_id, input_text, domain, created_at, {col})
                   VALUES (?, ?, ?, ?, ?, ?)""".format(col=column_map.get(step, "ingestion_data")),
                (run_id, run_id, input_text, domain, now, data_json)
            )
        else:
            col = column_map.get(step, "ingestion_data")
            await db.execute(
                f"UPDATE analyses SET {col} = ? WHERE run_id = ?",
                (data_json, run_id)
            )
        
        if step == "insights" and isinstance(data, dict):
            insights = data.get("insights", [])
            if insights:
                scores = [i.get("confidence", 0) for i in insights]
                avg_conf = sum(scores) / len(scores) if scores else 0
                severities = [i.get("severity", "Medium") for i in insights]
                severity_order = {"Low": 0, "Medium": 1, "High": 2, "Critical": 3}
                max_sev = max(severities, key=lambda s: severity_order.get(s, 1))
                await db.execute(
                    "UPDATE analyses SET confidence_avg = ?, severity = ? WHERE run_id = ?",
                    (avg_conf, max_sev, run_id)
                )
        
        await db.commit()


async def log_step(run_id: str, step: str, status: str, data: dict = None):
    """Log a pipeline step safely."""
    try:
        async with aiosqlite.connect(DB_PATH) as db:
            await db.execute(
                "INSERT INTO pipeline_logs (run_id, step, status, data, timestamp) VALUES (?, ?, ?, ?, ?)",
                (run_id, step, status, json.dumps(data) if data else None, datetime.utcnow().isoformat())
            )
            await db.commit()
    except Exception as e:
        print(f"Failed to log step {step}: {e}")


async def get_logs(run_id: str):
    """Get all logs for a run."""
    async with aiosqlite.connect(DB_PATH) as db:
        db.row_factory = aiosqlite.Row
        cursor = await db.execute(
            "SELECT * FROM pipeline_logs WHERE run_id = ? ORDER BY timestamp ASC", (run_id,)
        )
        rows = await cursor.fetchall()
        return [dict(row) for row in rows]


async def get_all_analyses():
    """Get all analyses ordered by date."""
    async with aiosqlite.connect(DB_PATH) as db:
        db.row_factory = aiosqlite.Row
        cursor = await db.execute(
            "SELECT run_id, input_text, domain, created_at, severity, confidence_avg, bookmarked FROM analyses ORDER BY created_at DESC"
        )
        rows = await cursor.fetchall()
        return [dict(row) for row in rows]


async def get_analysis(run_id: str):
    """Get full analysis by run_id."""
    async with aiosqlite.connect(DB_PATH) as db:
        db.row_factory = aiosqlite.Row
        cursor = await db.execute("SELECT * FROM analyses WHERE run_id = ?", (run_id,))
        row = await cursor.fetchone()
        if row:
            result = dict(row)
            for key in ["ingestion_data", "insights_data", "impact_data", "actions_data", "execution_data"]:
                if result.get(key):
                    result[key] = json.loads(result[key])
            return result
        return None


async def get_cached_step(input_text: str, domain: str, step: str) -> dict | None:
    """Retrieve previously generated data for the same input text to bypass rate limits."""
    try:
        column_map = {
            "ingest": "ingestion_data",
            "insights": "insights_data",
            "impact": "impact_data",
            "actions": "actions_data",
            "execute": "execution_data",
        }
        col = column_map.get(step)
        if not col:
            return None
            
        async with aiosqlite.connect(DB_PATH) as db:
            db.row_factory = aiosqlite.Row
            cursor = await db.execute(
                f"SELECT {col} FROM analyses WHERE LOWER(TRIM(input_text)) = LOWER(TRIM(?)) AND domain = ? AND {col} IS NOT NULL AND {col} != '' LIMIT 1",
                (input_text, domain)
            )
            row = await cursor.fetchone()
            if row and row[col]:
                return json.loads(row[col])
    except Exception as e:
        print(f"Cache lookup failed: {e}")
    return None


async def save_feedback(run_id: str, insight_index: int, rating: str, comment: str = None):
    """Save user feedback on an insight."""
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute(
            "INSERT INTO feedback (run_id, insight_index, rating, comment, created_at) VALUES (?, ?, ?, ?, ?)",
            (run_id, insight_index, rating, comment, datetime.utcnow().isoformat())
        )
        await db.commit()


async def toggle_bookmark(run_id: str, insight_index: int = None):
    """Toggle bookmark for an analysis or insight."""
    async with aiosqlite.connect(DB_PATH) as db:
        if insight_index is None:
            cursor = await db.execute("SELECT bookmarked FROM analyses WHERE run_id = ?", (run_id,))
            row = await cursor.fetchone()
            if row:
                new_val = 0 if row[0] else 1
                await db.execute("UPDATE analyses SET bookmarked = ? WHERE run_id = ?", (new_val, run_id))
        else:
            cursor = await db.execute(
                "SELECT id FROM bookmarks WHERE run_id = ? AND insight_index = ?",
                (run_id, insight_index)
            )
            row = await cursor.fetchone()
            if row:
                await db.execute("DELETE FROM bookmarks WHERE run_id = ? AND insight_index = ?", (run_id, insight_index))
            else:
                await db.execute(
                    "INSERT INTO bookmarks (run_id, insight_index, bookmark_type, created_at) VALUES (?, ?, 'insight', ?)",
                    (run_id, insight_index, datetime.utcnow().isoformat())
                )
        await db.commit()


async def delete_analysis(run_id: str):
    """Delete an analysis and its logs."""
    async with aiosqlite.connect(DB_PATH) as db:
        await db.execute("DELETE FROM analyses WHERE run_id = ?", (run_id,))
        await db.execute("DELETE FROM pipeline_logs WHERE run_id = ?", (run_id,))
        await db.execute("DELETE FROM feedback WHERE run_id = ?", (run_id,))
        await db.execute("DELETE FROM bookmarks WHERE run_id = ?", (run_id,))
        await db.commit()