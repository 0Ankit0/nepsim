"""
Seed reusable QA data for NEPSIM.

Usage:
    source backend/.venv/bin/activate
    python3 backend/scripts/seed_qa_data.py
"""

import asyncio
import json
from datetime import datetime, timedelta
from pathlib import Path
import sys

from sqlmodel import delete, select

# Add backend root to Python path when run directly.
sys.path.insert(0, str(Path(__file__).parent.parent))

from src.apps.core import security
from src.apps.iam.models.role import Role, UserRole
from src.apps.iam.models.user import User, UserProfile
from src.apps.portfolio.models import PortfolioAlert, PortfolioItem
from src.apps.simulator.models import (
    Simulation,
    SimulationPortfolio,
    SimulationStatus,
    Trade,
    TradeSide,
    TradeStatus,
)
from src.apps.watchlist.models import WatchlistAlert, WatchlistItem
from src.db.session import async_session_factory, init_db

QA_PASSWORD = "QaPass123!"

QA_USERS = [
    {
        "username": "qa_admin",
        "email": "qa.admin@nepsimqa.com",
        "is_superuser": True,
        "first_name": "QA",
        "last_name": "Admin",
        "phone": "+9779800000001",
        "roles": ["admin"],
    },
    {
        "username": "qa_trader",
        "email": "qa.trader@nepsimqa.com",
        "is_superuser": False,
        "first_name": "QA",
        "last_name": "Trader",
        "phone": "+9779800000002",
        "roles": ["trader"],
    },
    {
        "username": "qa_analyst",
        "email": "qa.analyst@nepsimqa.com",
        "is_superuser": False,
        "first_name": "QA",
        "last_name": "Analyst",
        "phone": "+9779800000003",
        "roles": ["analyst"],
    },
]


async def upsert_roles(session):
    role_map: dict[str, Role] = {}
    for role_name in ["admin", "trader", "analyst"]:
        result = await session.execute(select(Role).where(Role.name == role_name))
        role = result.scalar_one_or_none()
        if not role:
            role = Role(name=role_name, description=f"QA role: {role_name}")
            session.add(role)
            await session.flush()
        role_map[role_name] = role
    return role_map


async def upsert_users(session, role_map: dict[str, Role]):
    users_by_username: dict[str, User] = {}

    for user_data in QA_USERS:
        result = await session.execute(select(User).where(User.username == user_data["username"]))
        user = result.scalar_one_or_none()

        if not user:
            user = User(
                username=user_data["username"],
                email=user_data["email"],
                is_superuser=user_data["is_superuser"],
                is_active=True,
                is_confirmed=True,
                hashed_password=security.get_password_hash(QA_PASSWORD),
            )
            session.add(user)
            await session.flush()
        else:
            user.email = user_data["email"]
            user.is_superuser = user_data["is_superuser"]
            user.is_active = True
            user.is_confirmed = True

        profile_result = await session.execute(select(UserProfile).where(UserProfile.user_id == user.id))
        profile = profile_result.scalar_one_or_none()
        if not profile:
            profile = UserProfile(
                user_id=user.id,
                first_name=user_data["first_name"],
                last_name=user_data["last_name"],
                phone=user_data["phone"],
            )
            session.add(profile)
        else:
            profile.first_name = user_data["first_name"]
            profile.last_name = user_data["last_name"]
            profile.phone = user_data["phone"]

        existing_links = await session.execute(select(UserRole).where(UserRole.user_id == user.id))
        for link in existing_links.scalars().all():
            await session.delete(link)

        for role_name in user_data["roles"]:
            session.add(UserRole(user_id=user.id, role_id=role_map[role_name].id))

        users_by_username[user.username] = user

    return users_by_username


async def reseed_trader_data(session, trader_user: User):
    await session.execute(delete(WatchlistAlert).where(WatchlistAlert.user_id == trader_user.id))
    await session.execute(delete(WatchlistItem).where(WatchlistItem.user_id == trader_user.id))
    await session.execute(delete(PortfolioAlert).where(PortfolioAlert.user_id == trader_user.id))
    await session.execute(delete(PortfolioItem).where(PortfolioItem.user_id == trader_user.id))

    trader_sim_ids_result = await session.execute(
        select(Simulation.id).where(Simulation.user_id == trader_user.id)
    )
    trader_sim_ids = [row for row in trader_sim_ids_result.scalars().all()]
    if trader_sim_ids:
        await session.execute(delete(Trade).where(Trade.simulation_id.in_(trader_sim_ids)))
        await session.execute(
            delete(SimulationPortfolio).where(SimulationPortfolio.simulation_id.in_(trader_sim_ids))
        )
        await session.execute(delete(Simulation).where(Simulation.id.in_(trader_sim_ids)))

    watch_items = [
        WatchlistItem(user_id=trader_user.id, symbol="NABIL", notes="Breakout watch", target_price=840.0),
        WatchlistItem(user_id=trader_user.id, symbol="UPPER", notes="Support retest", stop_loss=265.0),
    ]
    session.add_all(watch_items)
    await session.flush()

    session.add(
        WatchlistAlert(
            user_id=trader_user.id,
            watchlist_item_id=watch_items[0].id,
            symbol="NABIL",
            alert_type="BUY_CONSIDER",
            signal_score=72.5,
            analysis_summary="Momentum building above recent resistance.",
            key_signals=json.dumps(["Breakout", "Higher volume", "RSI recovery"]),
            entry_price=812.5,
            target_price=840.0,
            stop_loss_price=790.0,
        )
    )

    portfolio_item = PortfolioItem(
        user_id=trader_user.id,
        symbol="SCB",
        quantity=120,
        avg_buy_price=640.0,
        buy_date=datetime.utcnow().strftime("%Y-%m-%d"),
        notes="Swing position",
    )
    session.add(portfolio_item)
    await session.flush()

    session.add(
        PortfolioAlert(
            user_id=trader_user.id,
            portfolio_item_id=portfolio_item.id,
            symbol="SCB",
            alert_type="SELL_CONSIDER",
            signal_score=68.0,
            analysis_summary="Price near resistance; risk-reward tightening.",
            key_signals=json.dumps(["Resistance", "Overextended move"]),
            recommended_action="Scale out partial position",
            current_price=675.0,
        )
    )

    period_start = datetime.utcnow() - timedelta(days=120)
    period_end = datetime.utcnow() - timedelta(days=1)
    current_date = datetime.utcnow() - timedelta(days=5)

    sim = Simulation(
        user_id=trader_user.id,
        name="QA Swing Simulation",
        initial_capital=500_000.0,
        cash_balance=362_450.0,
        status=SimulationStatus.ACTIVE,
        period_start=period_start,
        period_end=period_end,
        current_sim_date=current_date,
        seconds_per_day=45,
    )
    session.add(sim)
    await session.flush()

    session.add_all(
        [
            SimulationPortfolio(
                simulation_id=sim.id,
                symbol="NABIL",
                quantity=150,
                average_buy_price=805.0,
            ),
            SimulationPortfolio(
                simulation_id=sim.id,
                symbol="UPPER",
                quantity=80,
                average_buy_price=278.0,
            ),
        ]
    )

    session.add_all(
        [
            Trade(
                simulation_id=sim.id,
                user_id=trader_user.id,
                symbol="NABIL",
                side=TradeSide.BUY,
                quantity=100,
                requested_price=798.0,
                executed_price=800.0,
                sebon_commission=11.97,
                broker_commission=319.2,
                dp_charge=25.0,
                total_cost=80356.17,
                sim_date=current_date - timedelta(days=12),
                status=TradeStatus.EXECUTED,
            ),
            Trade(
                simulation_id=sim.id,
                user_id=trader_user.id,
                symbol="UPPER",
                side=TradeSide.BUY,
                quantity=80,
                requested_price=276.0,
                executed_price=277.0,
                sebon_commission=3.32,
                broker_commission=88.64,
                dp_charge=25.0,
                total_cost=22277.0,
                sim_date=current_date - timedelta(days=8),
                status=TradeStatus.EXECUTED,
            ),
        ]
    )


async def main():
    print("🌱 Seeding QA users, roles, and workflow data...")
    await init_db()

    async with async_session_factory() as session:
        role_map = await upsert_roles(session)
        users = await upsert_users(session, role_map)
        await reseed_trader_data(session, users["qa_trader"])
        await session.commit()

    print("✅ QA data seeding complete.")
    print("\nTest users:")
    print("  - qa_admin / QaPass123!  (superuser)")
    print("  - qa_trader / QaPass123! (standard user)")
    print("  - qa_analyst / QaPass123! (standard user)")


if __name__ == "__main__":
    asyncio.run(main())
