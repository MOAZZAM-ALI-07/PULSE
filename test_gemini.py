import asyncio
from backend.gemini_service import extract_signals

async def main():
    print("Testing gemini...")
    res = await extract_signals("Our revenue dropped 20% in Q3 due to supply chain issues.", "Business")
    print(res)

if __name__ == "__main__":
    asyncio.run(main())
