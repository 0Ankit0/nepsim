import factory 
from factory.faker import Faker
from factory.base import Factory
from datetime import datetime, timezone, timedelta
from factory.declarations import LazyAttribute
from src.apps.iam.models.user import User, UserProfile
from src.apps.iam.models.login_attempt import LoginAttempt
from src.apps.iam.models.token_tracking import TokenTracking
from src.apps.core import security
from src.apps.core.security import TokenType
from src.apps.market.models import StockMetadata, MarketDataOHLCV
from src.apps.simulator.models import Simulation, Trade, TradeSide, TradeStatus
from src.apps.learn.models import Lesson, Quiz, QuizQuestion
from src.apps.gamification.models import Achievement, UserAchievement, UserProgress


class UserFactory(Factory):
    """Factory for creating User instances."""
    
    class Meta(): # type: ignore
        model = User
    
    username = Faker("user_name")
    email = Faker("email")
    hashed_password = LazyAttribute(lambda obj: security.get_password_hash("TestPass123"))
    is_active = True
    is_superuser = False
    is_confirmed = False
    otp_enabled = False
    otp_verified = False
    otp_base32 = ""
    otp_auth_url = ""
    created_at = LazyAttribute(lambda _: datetime.now(timezone.utc))


class UserProfileFactory(Factory):
    """Factory for creating UserProfile instances."""
    
    class Meta(): # type: ignore
        model = UserProfile
    
    first_name = Faker("first_name")
    last_name = Faker("last_name")
    phone = Faker("phone_number")
    image_url = Faker("image_url")
    bio = Faker("text", max_nb_chars=200)


class LoginAttemptFactory(Factory):
    """Factory for creating LoginAttempt instances."""
    
    class Meta(): # type: ignore
        model = LoginAttempt
    
    user_id = Faker("random_int", min=1, max=1000)
    ip_address = Faker("ipv4")
    user_agent = "Mozilla/5.0 Test Browser"
    success = True
    failure_reason = ""
    timestamp = LazyAttribute(lambda _: datetime.now(timezone.utc))


class TokenTrackingFactory(Factory):
    """Factory for creating TokenTracking instances."""
    
    class Meta(): # type: ignore
        model = TokenTracking
    
    user_id = Faker("random_int", min=1, max=1000)
    token_jti = Faker("uuid4")
    token_type = TokenType.ACCESS
    ip_address = Faker("ipv4")
    user_agent = "Mozilla/5.0 Test Browser"
    is_active = True
    created_at = LazyAttribute(lambda _: datetime.now(timezone.utc))
    expires_at = LazyAttribute(lambda _: datetime.now(timezone.utc))


class StockMetadataFactory(Factory):
    """Factory for creating StockMetadata instances."""
    
    class Meta(): # type: ignore
        model = StockMetadata
    
    symbol = Faker("lexify", text="????", letters="ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    company_name = Faker("company")
    sector = Faker("word")
    is_active = True


class MarketDataOHLCVFactory(Factory):
    """Factory for creating MarketDataOHLCV instances."""
    
    class Meta(): # type: ignore
        model = MarketDataOHLCV
    
    symbol = Faker("lexify", text="????", letters="ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    trade_date = Faker("date_object")
    open = Faker("pyfloat", left_digits=4, right_digits=2, min_value=100, max_value=9999)
    high = LazyAttribute(lambda obj: obj.open + 10)
    low = LazyAttribute(lambda obj: obj.open - 10)
    close = LazyAttribute(lambda obj: obj.open + 2)
    volume = Faker("random_int", min=1000, max=1000000)


class SimulationFactory(Factory):
    """Factory for creating Simulation instances."""
    
    class Meta(): # type: ignore
        model = Simulation
    
    user_id = Faker("random_int", min=1, max=1000)
    initial_capital = 100000.0
    cash_balance = 100000.0
    current_balance = 100000.0
    status = "active"
    start_date = LazyAttribute(lambda _: datetime.now(timezone.utc))
    period_start = LazyAttribute(lambda _: datetime.now(timezone.utc) - timedelta(days=60))
    period_end = LazyAttribute(lambda _: datetime.now(timezone.utc))
    current_sim_date = LazyAttribute(lambda obj: obj.period_start)


class TradeFactory(Factory):
    """Factory for creating Trade instances."""
    
    class Meta(): # type: ignore
        model = Trade
        
    simulation_id = Faker("random_int", min=1, max=1000)
    user_id = Faker("random_int", min=1, max=1000)
    symbol = "NABIL"
    side = TradeSide.BUY
    quantity = 100
    requested_price = 500.0
    executed_price = 501.0
    sebon_commission = 0.075
    broker_commission = 2.0
    dp_charge = 25.0
    total_cost = 50127.075
    sim_date = LazyAttribute(lambda _: datetime.now(timezone.utc))
    status = TradeStatus.EXECUTED


class LessonFactory(Factory):
    """Factory for creating Lesson instances."""
    
    class Meta(): # type: ignore
        model = Lesson
        
    title = Faker("sentence")
    section = "Introduction"
    content_html = "<h2>Test</h2><p>Content</p>"
    difficulty_level = "beginner"
    read_time_minutes = 5
    order_index = 1


class QuizFactory(Factory):
    """Factory for creating Quiz instances."""
    
    class Meta(): # type: ignore
        model = Quiz
        
    lesson_id = Faker("random_int", min=1, max=1000)
    title = Faker("sentence")
    passing_score = 70


class AchievementFactory(Factory):
    """Factory for creating Achievement instances."""
    
    class Meta(): # type: ignore
        model = Achievement
        
    title = Faker("sentence")
    slug = Faker("slug")
    description = Faker("text")
    icon_name = "award"
    is_active = True


class UserProgressFactory(Factory):
    """Factory for creating UserProgress instances."""
    
    class Meta(): # type: ignore
        model = UserProgress
        
    user_id = Faker("random_int", min=1, max=1000)
    total_simulations = 0
    total_trades = 0
    best_pnl_pct = 0.0
