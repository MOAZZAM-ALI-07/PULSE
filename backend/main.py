"""Pulse Backend — FastAPI main application."""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from database import init_db
from routers import pipeline, logs, feedback


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initialize database on startup."""
    await init_db()
    yield


app = FastAPI(
    title="Pulse API",
    description="Business Intelligence Analysis Pipeline",
    version="1.0.0",
    lifespan=lifespan
)

# CORS for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(pipeline.router)
app.include_router(logs.router)
app.include_router(feedback.router)


@app.get("/")
async def root():
    return {"name": "Pulse API", "version": "1.0.0", "status": "running"}


@app.get("/health")
async def health():
    return {"status": "healthy"}
