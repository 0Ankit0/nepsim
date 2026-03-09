"""
NEPSE Data Seeder — loads historical OHLCV CSV files into the database.

Usage:
    uv run python backend/scripts/seed_market_data.py

CSV format expected (one file per symbol, filename = SYMBOL.csv):
    date,open,high,low,close,volume
    2020-01-02,1200.0,1250.0,1190.0,1230.0,45000
    ...

Place CSV files in: backend/data/nepse_ohlcv/
"""
import asyncio
import csv
import os
import sys
from datetime import datetime, date
from pathlib import Path

# Add backend/src to path when run directly
sys.path.insert(0, str(Path(__file__).parent.parent))

from src.apps.core.config import settings
from src.apps.market.models import StockMetadata, MarketDataOHLCV
from src.db.session import async_session_factory, engine, init_db

# ── Sample stocks metadata (add more as needed) ────────────────────────────
SAMPLE_STOCKS = [
    {"symbol": "NABIL", "company_name": "Nabil Bank Limited", "sector": "Banking", "lot_size": 10, "face_value": 100.0},
    {"symbol": "SCB", "company_name": "Standard Chartered Bank Nepal", "sector": "Banking", "lot_size": 10, "face_value": 100.0},
    {"symbol": "NICA", "company_name": "NIC Asia Bank Limited", "sector": "Banking", "lot_size": 10, "face_value": 100.0},
    {"symbol": "EBL", "company_name": "Everest Bank Limited", "sector": "Banking", "lot_size": 10, "face_value": 100.0},
    {"symbol": "GBIME", "company_name": "Global IME Bank", "sector": "Banking", "lot_size": 10, "face_value": 100.0},
    {"symbol": "KBL", "company_name": "Kumari Bank Limited", "sector": "Banking", "lot_size": 10, "face_value": 100.0},
    {"symbol": "UPPER", "company_name": "Upper Tamakoshi Hydropower", "sector": "Hydropower", "lot_size": 10, "face_value": 100.0},
    {"symbol": "NHPC", "company_name": "National Hydropower Company", "sector": "Hydropower", "lot_size": 10, "face_value": 100.0},
    {"symbol": "NRIC", "company_name": "Nepal Reinsurance Company", "sector": "Insurance", "lot_size": 10, "face_value": 100.0},
    {"symbol": "LICN", "company_name": "Life Insurance Corporation Nepal", "sector": "Insurance", "lot_size": 10, "face_value": 100.0},
    {"symbol": "NTC", "company_name": "Nepal Telecom", "sector": "Telecom", "lot_size": 10, "face_value": 100.0},
    {"symbol": "CIT", "company_name": "Citizen Investment Trust", "sector": "Finance", "lot_size": 10, "face_value": 100.0},
    {"symbol": "SHPC", "company_name": "Sanima Hydro & Engineering", "sector": "Hydropower", "lot_size": 10, "face_value": 100.0},
    {"symbol": "PRVU", "company_name": "Prabhu Bank Limited", "sector": "Banking", "lot_size": 10, "face_value": 100.0},
    {"symbol": "ADBL", "company_name": "Agricultural Development Bank", "sector": "Banking", "lot_size": 10, "face_value": 100.0},
]


async def seed_stocks(session):
    """Insert sample stock metadata if not already present."""
    from sqlmodel import select
    for stock_data in SAMPLE_STOCKS:
        result = await session.execute(
            select(StockMetadata).where(StockMetadata.symbol == stock_data["symbol"])
        )
        if not result.scalar_one_or_none():
            stock = StockMetadata(**stock_data)
            session.add(stock)
    await session.commit()
    print(f"✅ Seeded {len(SAMPLE_STOCKS)} stocks.")


async def seed_ohlcv_from_csv(session, data_dir: str):
    """Load OHLCV data from CSV files in the data directory."""
    data_path = Path(data_dir)
    if not data_path.exists():
        print(f"⚠️  Data directory not found: {data_path}")
        print("   Create it and add CSV files named SYMBOL.csv")
        return

    csv_files = list(data_path.glob("*.csv"))
    if not csv_files:
        print(f"⚠️  No CSV files found in {data_path}")
        return

    total_rows = 0
    for csv_file in csv_files:
        symbol = csv_file.stem.upper()
        rows_inserted = 0
        with open(csv_file, newline="") as f:
            reader = csv.DictReader(f)
            batch = []
            for row in reader:
                try:
                    trade_date = date.fromisoformat(row["date"].strip())
                    record = MarketDataOHLCV(
                        symbol=symbol,
                        trade_date=trade_date,
                        open=float(row["open"]),
                        high=float(row["high"]),
                        low=float(row["low"]),
                        close=float(row["close"]),
                        volume=int(float(row.get("volume", 0))),
                    )
                    batch.append(record)
                    rows_inserted += 1
                except (ValueError, KeyError) as e:
                    print(f"   ⚠️  Skipped row in {csv_file.name}: {e}")

            if batch:
                session.add_all(batch)
                await session.commit()

        print(f"   ✅ {symbol}: {rows_inserted} OHLCV records loaded.")
        total_rows += rows_inserted

    print(f"\n✅ Total: {total_rows} OHLCV records imported.")


async def seed_achievements(session):
    """Seed the default achievement definitions."""
    from src.apps.gamification.models import Achievement
    from src.apps.gamification.services import ACHIEVEMENT_SLUGS
    from sqlmodel import select

    ACHIEVEMENT_DETAILS = {
        "first_simulation": ("First Steps", "Complete your first simulation", "🎯", "bronze"),
        "first_trades": ("First Trade", "Place your first trade", "💼", "bronze"),
        "five_simulations": ("Committed Trader", "Complete 5 simulations", "🔄", "silver"),
        "ten_percent_profit": ("Double Digits", "Achieve 10% profit in one simulation", "📈", "silver"),
        "fifty_percent_profit": ("Market Wizard", "Achieve 50% profit in one simulation", "⭐", "gold"),
        "no_loss_simulation": ("Flawless", "Complete a simulation with only winning trades", "🏆", "gold"),
        "diversified": ("Diversified", "Hold 5+ different stocks simultaneously", "🎨", "silver"),
        "high_volume": ("Active Trader", "Execute 20+ trades in one simulation", "⚡", "silver"),
        "patient_investor": ("Diamond Hands", "Hold a position for 30+ simulated days", "💎", "gold"),
        "first_learn": ("Eager Learner", "Complete your first lesson", "📚", "bronze"),
        "quiz_master": ("Quiz Master", "Pass 10 quizzes", "🧠", "gold"),
        "perfect_score": ("Perfect Score", "Score 100% on a quiz", "💯", "silver"),
    }

    count = 0
    for slug, (title, desc, icon, tier) in ACHIEVEMENT_DETAILS.items():
        result = await session.execute(select(Achievement).where(Achievement.slug == slug))
        if not result.scalar_one_or_none():
            session.add(Achievement(slug=slug, title=title, description=desc, icon_name=icon, tier=tier))
            count += 1
    await session.commit()
    print(f"✅ Seeded {count} achievement definitions.")


async def seed_lessons(session):
    """Seed starter educational lessons and quizzes."""
    from src.apps.learn.models import Lesson, Quiz, QuizQuestion
    from sqlmodel import select
    import json

    # Check if any lessons already exist
    result = await session.execute(select(Lesson).limit(1))
    if result.scalar_one_or_none():
        print("ℹ️  Lessons already seeded. Skipping.")
        return

    lessons_data = [
        {
            "title": "Introduction to NEPSE",
            "section": "Introduction",
            "order_index": 1,
            "difficulty_level": "beginner",
            "read_time_minutes": 5,
            "content_html": """<h2>What is NEPSE?</h2>
<p>The Nepal Stock Exchange (NEPSE) is Nepal's only stock exchange, established in 1993. It provides a platform for trading shares of publicly listed companies in Nepal.</p>
<h3>Key Facts</h3>
<ul>
  <li>Located in Kathmandu, Nepal</li>
  <li>Over 200 listed companies</li>
  <li>Sectors: Banking, Insurance, Hydropower, Finance, Manufacturing</li>
  <li>Trading hours: 11:00 AM – 3:00 PM (Sunday to Thursday)</li>
</ul>
<h3>How Trading Works</h3>
<p>Stock prices fluctuate based on supply and demand. When more people want to buy a stock than sell it, the price rises. When more want to sell, the price falls.</p>
<p>In NEPSE, the minimum trade unit is called a <strong>lot</strong>, typically consisting of 10 shares.</p>""",
        },
        {
            "title": "Reading Candlestick Charts",
            "section": "Chart Patterns",
            "order_index": 1,
            "difficulty_level": "beginner",
            "read_time_minutes": 8,
            "content_html": """<h2>Candlestick Charts</h2>
<p>Candlestick charts are the most popular chart type among traders. Each candlestick represents one time period (e.g., one day) of price action.</p>
<h3>Anatomy of a Candlestick</h3>
<ul>
  <li><strong>Open</strong>: Price at the start of the period</li>
  <li><strong>Close</strong>: Price at the end of the period</li>
  <li><strong>High</strong>: Highest price during the period</li>
  <li><strong>Low</strong>: Lowest price during the period</li>
</ul>
<h3>Green vs Red Candles</h3>
<p>A <strong>green candle</strong> means the close was higher than the open (price went up). A <strong>red candle</strong> means the close was lower than the open (price went down).</p>
<p>The thin lines above and below the body are called <strong>wicks</strong> or <strong>shadows</strong>, showing the high and low extremes.</p>""",
        },
        {
            "title": "Understanding RSI",
            "section": "Indicators",
            "order_index": 1,
            "difficulty_level": "intermediate",
            "read_time_minutes": 7,
            "content_html": """<h2>Relative Strength Index (RSI)</h2>
<p>The RSI is a momentum oscillator that measures the speed and change of price movements. It oscillates between 0 and 100.</p>
<h3>Key Levels</h3>
<ul>
  <li><strong>Above 70</strong>: Overbought — the stock may be overvalued, potential selling opportunity</li>
  <li><strong>Below 30</strong>: Oversold — the stock may be undervalued, potential buying opportunity</li>
  <li><strong>50</strong>: Neutral zone</li>
</ul>
<h3>How to Use RSI on NEPSE</h3>
<p>In NEPSE, stocks often spend longer in overbought territory during bull markets. Use RSI as one signal among many, not as a standalone buy/sell signal.</p>
<p>A common strategy: buy when RSI drops below 30 and then rises back above 35 (confirming recovery).</p>""",
        },
        {
            "title": "Trading Costs in NEPSE",
            "section": "Introduction",
            "order_index": 2,
            "difficulty_level": "beginner",
            "read_time_minutes": 4,
            "content_html": """<h2>NEPSE Trading Costs</h2>
<p>Every trade in NEPSE incurs fees. Understanding these costs is essential for profitable trading.</p>
<h3>Fee Structure</h3>
<ul>
  <li><strong>SEBON Fee</strong>: 0.015% of turnover (paid to the regulator)</li>
  <li><strong>Broker Commission</strong>: Typically 0.40% of turnover</li>
  <li><strong>DP Charge</strong>: NPR 25 per transaction (CDSC demat fee)</li>
</ul>
<h3>Example Calculation</h3>
<p>Buying 10 shares of NABIL at NPR 1,200:</p>
<ul>
  <li>Turnover: NPR 12,000</li>
  <li>SEBON fee: NPR 1.80</li>
  <li>Broker fee: NPR 48.00</li>
  <li>DP Charge: NPR 25.00</li>
  <li><strong>Total cost: NPR 12,074.80</strong></li>
</ul>
<p>This means you need the price to rise more than 0.62% just to break even on a round-trip trade!</p>""",
        },
    ]

    quiz_data = [
        {
            "lesson_idx": 0,  # NEPSE intro
            "questions": [
                {
                    "question_text": "What is the minimum trade unit in NEPSE called?",
                    "options": ["Share", "Lot", "Bundle", "Unit"],
                    "correct_option_index": 1,
                    "explanation": "In NEPSE, the minimum tradeable unit is called a 'lot', which typically consists of 10 shares.",
                },
                {
                    "question_text": "What are NEPSE's trading days?",
                    "options": ["Monday to Friday", "Saturday to Wednesday", "Sunday to Thursday", "All 7 days"],
                    "correct_option_index": 2,
                    "explanation": "NEPSE trades Sunday through Thursday, following Nepal's work week (Friday is a holiday in Nepal).",
                },
            ],
        },
        {
            "lesson_idx": 1,  # Candlesticks
            "questions": [
                {
                    "question_text": "What does a green candlestick indicate?",
                    "options": ["Price went down", "Price went up", "No price change", "High volatility"],
                    "correct_option_index": 1,
                    "explanation": "A green candle means the closing price was higher than the opening price — the price increased during that period.",
                },
                {
                    "question_text": "What do the wicks (shadows) of a candlestick represent?",
                    "options": ["Open and close prices", "High and low extremes", "Volume of trades", "Moving averages"],
                    "correct_option_index": 1,
                    "explanation": "The wicks (thin lines above and below the body) show the highest and lowest prices reached during the candlestick's period.",
                },
            ],
        },
        {
            "lesson_idx": 2,  # RSI
            "questions": [
                {
                    "question_text": "An RSI reading above 70 typically indicates what?",
                    "options": ["Oversold", "Overbought", "Neutral", "High volume"],
                    "correct_option_index": 1,
                    "explanation": "An RSI above 70 suggests the stock is overbought — it may have risen too fast and could face a reversal.",
                },
            ],
        },
        {
            "lesson_idx": 3,  # Trading costs
            "questions": [
                {
                    "question_text": "What is the SEBON regulatory fee rate on NEPSE trades?",
                    "options": ["0.015%", "0.40%", "0.10%", "0.025%"],
                    "correct_option_index": 0,
                    "explanation": "SEBON charges 0.015% of the total turnover value as a regulatory fee on each NEPSE transaction.",
                },
            ],
        },
    ]

    created_lessons = []
    for lesson_data in lessons_data:
        lesson = Lesson(**lesson_data)
        session.add(lesson)
        await session.flush()
        created_lessons.append(lesson)

    await session.commit()
    await session.refresh(created_lessons[0])  # Refresh to get IDs

    # Add quizzes
    for quiz_info in quiz_data:
        lesson_idx = quiz_info["lesson_idx"]
        if lesson_idx < len(created_lessons):
            lesson = created_lessons[lesson_idx]
            quiz = Quiz(lesson_id=lesson.id, title=f"Quiz: {lesson.title}", passing_score=70)
            session.add(quiz)
            await session.flush()
            for order, q in enumerate(quiz_info["questions"]):
                question = QuizQuestion(
                    quiz_id=quiz.id,
                    order_index=order,
                    question_text=q["question_text"],
                    options=json.dumps(q["options"]),
                    correct_option_index=q["correct_option_index"],
                    explanation=q["explanation"],
                )
                session.add(question)

    await session.commit()
    print(f"✅ Seeded {len(lessons_data)} lessons with quizzes.")


async def main():
    print("🌱 Starting NEPSIM database seed...")
    await init_db()
    async with async_session_factory() as session:
        await seed_stocks(session)
        await seed_achievements(session)
        await seed_lessons(session)
        await seed_ohlcv_from_csv(session, settings.NEPSE_DATA_PATH)
    print("\n✅ Seed complete!")


if __name__ == "__main__":
    asyncio.run(main())
