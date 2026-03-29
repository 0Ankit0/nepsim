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
    lessons_data = [
        {
            "title": "Introduction to NEPSE",
            "section": "Foundations",
            "order_index": 1,
            "difficulty_level": "beginner",
            "read_time_minutes": 12,
            "content_html": """<h2>What is NEPSE and why do prices move?</h2>
<p>The Nepal Stock Exchange (NEPSE) is the market where listed Nepali companies are bought and sold. Every chart in NEPSIM is a history of agreements between buyers and sellers.</p>
<h3>Start with the big picture</h3>
<ul>
  <li><strong>Price rises</strong> when buyers are willing to pay more than sellers asked before.</li>
  <li><strong>Price falls</strong> when sellers accept lower prices to exit.</li>
  <li><strong>Volume matters</strong> because it tells you whether many people agreed with the move.</li>
  <li><strong>Time matters</strong> because a stock can look strong this month and weak on a longer chart.</li>
</ul>
<h3>What a beginner should learn first</h3>
<ol>
  <li>How to read one candle.</li>
  <li>How to spot trend: up, down, or sideways.</li>
  <li>How to mark support and resistance.</li>
  <li>How to decide entry, target, and stop before trading.</li>
</ol>
<h3>Simple example</h3>
<p>Imagine ADBL trades around Rs. 240 for several days and then closes at Rs. 248 with stronger-than-usual volume. That move matters because buyers pushed the stock above its recent range with participation.</p>
<h3>Practice by hand</h3>
<ul>
  <li>Open any simulator chart and write down the last three closes.</li>
  <li>Ask whether price is moving up, down, or sideways.</li>
  <li>Mark one place where price repeatedly stopped falling.</li>
  <li>Mark one place where price repeatedly stopped rising.</li>
</ul>""",
        },
        {
            "title": "Trading Costs in NEPSE",
            "section": "Foundations",
            "order_index": 2,
            "difficulty_level": "beginner",
            "read_time_minutes": 8,
            "content_html": """<h2>Trading costs change the quality of a setup</h2>
<p>A chart may look attractive, but a small move is not enough if fees eat the reward. Beginners should learn this early.</p>
<h3>Main costs</h3>
<ul>
  <li><strong>SEBON Fee</strong>: 0.015% of turnover</li>
  <li><strong>Broker Commission</strong>: typically around 0.40%</li>
  <li><strong>DP Charge</strong>: NPR 25 per transaction</li>
</ul>
<h3>Worked example</h3>
<p>Buying 10 shares at NPR 1,200 means turnover is NPR 12,000. Add fees and your break-even point moves higher than the raw chart price suggests.</p>
<h3>Why it matters</h3>
<p>A weak trade with tiny upside often looks acceptable before costs and poor after costs. Strong ideas need enough room to justify risk and friction.</p>
<h3>Practice by hand</h3>
<ul>
  <li>Pick one old trade from your simulation.</li>
  <li>Write the approximate percentage move.</li>
  <li>Ask whether that move was large enough to justify fees and risk.</li>
</ul>""",
        },
        {
            "title": "Reading Candlestick Charts",
            "section": "Chartcraft",
            "order_index": 1,
            "difficulty_level": "beginner",
            "read_time_minutes": 14,
            "content_html": """<h2>How to read one candle at a time</h2>
<p>A candlestick records four prices: open, high, low, and close. Before learning patterns, learn to read the message inside one candle.</p>
<h3>Anatomy</h3>
<ul>
  <li><strong>Open</strong>: where the session began</li>
  <li><strong>Close</strong>: where the session finished</li>
  <li><strong>High</strong>: the highest traded price</li>
  <li><strong>Low</strong>: the lowest traded price</li>
</ul>
<h3>What candle shape tells you</h3>
<ul>
  <li><strong>Large green body</strong>: buyers controlled the session.</li>
  <li><strong>Large red body</strong>: sellers controlled the session.</li>
  <li><strong>Long lower wick</strong>: buyers defended lower prices.</li>
  <li><strong>Long upper wick</strong>: sellers pushed price back down.</li>
  <li><strong>Small body</strong>: indecision.</li>
</ul>
<h3>Worked example</h3>
<p>If a stock opens at Rs. 500, drops to Rs. 488, rallies to Rs. 507, and closes at Rs. 505, that candle shows recovery from weakness. It becomes more meaningful if it forms near support.</p>
<h3>Hand-based learning</h3>
<ul>
  <li>Pick five candles from any chart.</li>
  <li>Label each one: buyer control, seller control, or indecision.</li>
  <li>Then check the next two candles and see whether your reading added useful context.</li>
</ul>""",
        },
        {
            "title": "Support, Resistance, and Trendlines",
            "section": "Chartcraft",
            "order_index": 2,
            "difficulty_level": "beginner",
            "read_time_minutes": 13,
            "content_html": """<h2>Mark the levels before you trust indicators</h2>
<p>Support is an area where price repeatedly finds buyers. Resistance is an area where price repeatedly finds sellers. These are zones, not magic exact numbers.</p>
<h3>What to look for</h3>
<ul>
  <li>Multiple touches near the same area</li>
  <li>Strong rejection candles from the zone</li>
  <li>Volume expansion when price finally breaks out</li>
</ul>
<h3>Trendlines</h3>
<p>A rising trendline connects higher lows. A falling trendline connects lower highs. They help you organize price action and judge whether structure is improving or weakening.</p>
<h3>Practice by hand</h3>
<ol>
  <li>Pick one chart and mark two support areas and two resistance areas.</li>
  <li>Write whether the current price is near a useful level or in the middle of nowhere.</li>
  <li>Only then reveal indicators.</li>
</ol>""",
        },
        {
            "title": "Reading Volume and Breakouts",
            "section": "Chartcraft",
            "order_index": 3,
            "difficulty_level": "beginner",
            "read_time_minutes": 10,
            "content_html": """<h2>Volume shows whether a move has support</h2>
<p>Breakouts are stronger when many participants join the move. Volume helps you judge whether price is moving with conviction or just drifting.</p>
<h3>Healthy breakout checklist</h3>
<ul>
  <li>Price closes above resistance, not just intraday.</li>
  <li>Volume is stronger than recent sessions.</li>
  <li>The next candle does not immediately erase the breakout.</li>
</ul>
<h3>Hand-based learning</h3>
<ul>
  <li>Find one successful breakout and one failed breakout in old chart data.</li>
  <li>Compare candle shape and volume on both days.</li>
  <li>Write which setup you would trust more and why.</li>
</ul>""",
        },
        {
            "title": "Moving Averages and Trend Confirmation",
            "section": "Indicators",
            "order_index": 1,
            "difficulty_level": "beginner",
            "read_time_minutes": 11,
            "content_html": """<h2>Use moving averages to simplify trend</h2>
<p>Moving averages smooth noisy candles so you can judge trend faster. Short averages react quickly; long averages move slowly and show the bigger picture.</p>
<h3>Common uses</h3>
<ul>
  <li><strong>SMA20</strong>: short-term direction</li>
  <li><strong>SMA50</strong>: medium-term structure</li>
  <li><strong>SMA200</strong>: long-term trend context</li>
</ul>
<h3>Practical reading</h3>
<ul>
  <li>Price above rising averages often supports a bullish trend.</li>
  <li>Price below falling averages often supports a bearish trend.</li>
  <li>Crossovers matter more when price structure agrees.</li>
</ul>
<h3>Practice by hand</h3>
<ul>
  <li>Choose a trending stock.</li>
  <li>Write whether price is above or below SMA20 and SMA50.</li>
  <li>Finish the sentence: "Trend looks healthy because..."</li>
</ul>""",
        },
        {
            "title": "Understanding RSI",
            "section": "Indicators",
            "order_index": 2,
            "difficulty_level": "beginner",
            "read_time_minutes": 10,
            "content_html": """<h2>RSI is momentum, not prophecy</h2>
<p>The Relative Strength Index (RSI) moves between 0 and 100 and summarizes recent momentum. It is useful when combined with structure, not when used blindly.</p>
<h3>Quick guide</h3>
<ul>
  <li><strong>Above 70</strong>: momentum is stretched upward</li>
  <li><strong>Below 30</strong>: momentum is stretched downward</li>
  <li><strong>Near 50</strong>: neutral</li>
</ul>
<h3>What beginners get wrong</h3>
<p>RSI above 70 does not automatically mean "sell now." Strong trends can stay strong. Context matters.</p>
<h3>Better use</h3>
<ul>
  <li>Watch oversold RSI near support.</li>
  <li>Watch overbought RSI during breakouts for strength, not just risk.</li>
  <li>Compare RSI with price structure and volume.</li>
</ul>
<h3>Practice by hand</h3>
<ul>
  <li>Mark the last three times RSI dropped below 35.</li>
  <li>Write what price was doing at those moments.</li>
  <li>Compare which one produced the best recovery and why.</li>
</ul>""",
        },
        {
            "title": "Building a Trade Plan",
            "section": "Practice",
            "order_index": 1,
            "difficulty_level": "beginner",
            "read_time_minutes": 12,
            "content_html": """<h2>A trade plan protects you from impulsive decisions</h2>
<p>A chart setup is only useful if you can define how you will act on it. A trade plan forces you to think before you click.</p>
<h3>Your minimum checklist</h3>
<ol>
  <li><strong>Reason</strong>: why this stock?</li>
  <li><strong>Entry</strong>: where will you enter?</li>
  <li><strong>Stop</strong>: where is the idea clearly wrong?</li>
  <li><strong>Target</strong>: where does reward justify risk?</li>
</ol>
<h3>Practice by hand</h3>
<ul>
  <li>Pause your simulation.</li>
  <li>Choose one stock.</li>
  <li>Write one sentence each for entry, stop, target, and reason.</li>
  <li>Then decide whether the setup still feels attractive.</li>
</ul>""",
        },
        {
            "title": "Hand-Based Chart Practice",
            "section": "Practice",
            "order_index": 2,
            "difficulty_level": "beginner",
            "read_time_minutes": 15,
            "content_html": """<h2>Train your eyes before you trust automation</h2>
<p>The quickest way to improve is to annotate charts by hand. This lesson turns chart reading into a repeatable habit.</p>
<h3>A 10-minute drill</h3>
<ol>
  <li>Hide indicators.</li>
  <li>Mark trend.</li>
  <li>Mark one support and one resistance zone.</li>
  <li>Read the last three candles.</li>
  <li>Write a trade plan.</li>
  <li>Only then reveal indicators and compare.</li>
</ol>
<h3>Reflection prompts</h3>
<ul>
  <li>Was the chart trending or noisy?</li>
  <li>Did volume support the move?</li>
  <li>Was your stop placed where the idea truly breaks?</li>
  <li>Would you still take the trade with larger size?</li>
</ul>""",
        },
    ]

    quiz_data = [
        {
            "lesson_idx": 0,
            "questions": [
                {
                    "question_text": "What should a beginner usually mark before checking indicators?",
                    "options": ["Broker fees only", "Support and resistance zones", "Rumors on social media", "Only the latest candle color"],
                    "correct_option_index": 1,
                    "explanation": "Support and resistance give price context. Indicators become more useful after you understand where price sits on the chart.",
                },
                {
                    "question_text": "Why does volume matter during analysis?",
                    "options": ["It replaces every other tool", "It shows participation and conviction", "It guarantees profit", "It tells you tomorrow's exact close"],
                    "correct_option_index": 1,
                    "explanation": "Volume helps you judge whether many market participants supported a move or whether price moved weakly.",
                },
            ],
        },
        {
            "lesson_idx": 1,
            "questions": [
                {
                    "question_text": "Why should trading costs matter to a beginner?",
                    "options": ["They only matter to institutions", "They affect whether a small move is truly profitable", "They replace stop losses", "They are not relevant in NEPSE"],
                    "correct_option_index": 1,
                    "explanation": "Fees reduce net profit, so weak small moves often fail after trading costs are included.",
                },
            ],
        },
        {
            "lesson_idx": 2,
            "questions": [
                {
                    "question_text": "What does a long lower wick often suggest?",
                    "options": ["No buyers showed up", "Buyers stepped in after a sell-off", "Volume was zero", "The candle has no meaning"],
                    "correct_option_index": 1,
                    "explanation": "A long lower wick shows price traded lower but buyers pushed it back up before the close.",
                },
                {
                    "question_text": "What do candle wicks represent?",
                    "options": ["Average broker fee", "High and low extremes", "Only the opening price", "Only the closing price"],
                    "correct_option_index": 1,
                    "explanation": "Wicks mark the highest and lowest traded prices during that candle's session.",
                },
            ],
        },
        {
            "lesson_idx": 3,
            "questions": [
                {
                    "question_text": "Support and resistance are best treated as:",
                    "options": ["Exact magic prices", "Flexible zones where price reacts", "Guaranteed reversal signals", "News announcements"],
                    "correct_option_index": 1,
                    "explanation": "Price often reacts within zones rather than at one exact rupee value.",
                },
            ],
        },
        {
            "lesson_idx": 4,
            "questions": [
                {
                    "question_text": "A healthier breakout usually includes:",
                    "options": ["A close above resistance with stronger volume", "An immediate reversal into the range", "Very weak participation", "No defined resistance"],
                    "correct_option_index": 0,
                    "explanation": "Breakouts are more trustworthy when price closes above resistance and volume supports the move.",
                },
            ],
        },
        {
            "lesson_idx": 5,
            "questions": [
                {
                    "question_text": "If price is above rising SMA20 and SMA50, it often suggests:",
                    "options": ["Improving trend structure", "Guaranteed reversal", "Zero risk", "Only random movement"],
                    "correct_option_index": 0,
                    "explanation": "Price above rising moving averages often supports a bullish trend read, though it is never a guarantee.",
                },
            ],
        },
        {
            "lesson_idx": 6,
            "questions": [
                {
                    "question_text": "What does RSI above 70 usually mean?",
                    "options": ["Momentum is stretched upward", "The stock must be sold instantly", "The trend is over", "There is no trend"],
                    "correct_option_index": 0,
                    "explanation": "RSI above 70 suggests strong recent upside momentum, but chart context still matters.",
                },
                {
                    "question_text": "Which RSI setup is stronger for a beginner?",
                    "options": ["RSI alone with no structure", "Oversold RSI near support with price stabilizing", "Any RSI reading above 50", "Ignoring price structure completely"],
                    "correct_option_index": 1,
                    "explanation": "RSI is more useful when it aligns with price structure like support or a recovering trend.",
                },
            ],
        },
        {
            "lesson_idx": 7,
            "questions": [
                {
                    "question_text": "A complete trade plan should include:",
                    "options": ["Entry, stop, target, and the setup reason", "Only entry price", "Only a guess that price will rise", "Only one indicator reading"],
                    "correct_option_index": 0,
                    "explanation": "A real trade plan defines the setup, risk, and expected reward before the trade is placed.",
                },
            ],
        },
        {
            "lesson_idx": 8,
            "questions": [
                {
                    "question_text": "What is the goal of hand-based chart practice?",
                    "options": ["To avoid ever using indicators again", "To train your eyes to read structure before relying on tools", "To memorize random candle names", "To make trading automatic"],
                    "correct_option_index": 1,
                    "explanation": "Manual chart work helps you build context and judgment before you lean on automated signals.",
                },
            ],
        },
    ]

    created_lessons = []
    for lesson_data in lessons_data:
        result = await session.execute(select(Lesson).where(Lesson.title == lesson_data["title"]))
        lesson = result.scalar_one_or_none()
        if lesson:
            for key, value in lesson_data.items():
                setattr(lesson, key, value)
        else:
            lesson = Lesson(**lesson_data)
            session.add(lesson)
            await session.flush()
        created_lessons.append(lesson)

    await session.commit()
    for lesson in created_lessons:
        await session.refresh(lesson)

    for quiz_info in quiz_data:
        lesson = created_lessons[quiz_info["lesson_idx"]]
        result = await session.execute(select(Quiz).where(Quiz.lesson_id == lesson.id))
        quiz = result.scalar_one_or_none()
        if quiz:
            quiz.title = f"Quiz: {lesson.title}"
            quiz.passing_score = 70
            questions_result = await session.execute(select(QuizQuestion).where(QuizQuestion.quiz_id == quiz.id))
            for existing_question in questions_result.scalars().all():
                await session.delete(existing_question)
            await session.flush()
        else:
            quiz = Quiz(lesson_id=lesson.id, title=f"Quiz: {lesson.title}", passing_score=70)
            session.add(quiz)
            await session.flush()

        for order, q in enumerate(quiz_info["questions"]):
            session.add(QuizQuestion(
                quiz_id=quiz.id,
                order_index=order,
                question_text=q["question_text"],
                options=json.dumps(q["options"]),
                correct_option_index=q["correct_option_index"],
                explanation=q["explanation"],
            ))

    await session.commit()
    print(f"✅ Upserted {len(lessons_data)} lessons with quizzes.")


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
