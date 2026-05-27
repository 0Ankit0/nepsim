import { Navigate, Route, Routes } from 'react-router-dom';
import { Providers } from '@/components/providers';
import AuthLayout from '@/app/(auth)/layout';
import UserDashboardLayout from '@/app/(user-dashboard)/layout';
import AdminDashboardLayout from '@/app/(admin-dashboard)/layout';
import HomePage from '@/app/page';
import LoginPage from '@/app/(auth)/login/page';
import SignupPage from '@/app/(auth)/signup/page';
import ForgotPasswordPage from '@/app/(auth)/forgot-password/page';
import ResetPasswordPage from '@/app/(auth)/reset-password/page';
import OtpVerifyPage from '@/app/(auth)/otp-verify/page';
import VerifyEmailPage from '@/app/(auth)/verify-email/page';
import AuthCallbackPage from '@/app/(auth)/auth-callback/page';
import PaymentCallbackPage from '@/app/(auth)/payment-callback/page';
import DashboardPage from '@/app/(user-dashboard)/dashboard/page';
import WatchlistPage from '@/app/(user-dashboard)/watchlist/page';
import TokensPage from '@/app/(user-dashboard)/tokens/page';
import Stock360Page from '@/app/(user-dashboard)/stock360/page';
import MarketPage from '@/app/(user-dashboard)/market/page';
import MarketSymbolPage from '@/app/(user-dashboard)/market/[symbol]/page';
import FinancesPage from '@/app/(user-dashboard)/finances/page';
import NotificationsPage from '@/app/(user-dashboard)/notifications/page';
import SimulatorPage from '@/app/(user-dashboard)/simulator/page';
import SimulatorDetailPage from '@/app/(user-dashboard)/simulator/[id]/page';
import SimulatorAnalysisPage from '@/app/(user-dashboard)/simulator/[id]/analysis/page';
import SettingsPage from '@/app/(user-dashboard)/settings/page';
import AnalysisPage from '@/app/(user-dashboard)/analysis/page';
import LearnPage from '@/app/(user-dashboard)/learn/page';
import LearnDetailPage from '@/app/(user-dashboard)/learn/[id]/page';
import ProfilePage from '@/app/(user-dashboard)/profile/page';
import PortfolioPage from '@/app/(user-dashboard)/portfolio/page';
import AdminDashboardPage from '@/app/(admin-dashboard)/admin/dashboard/page';
import AdminUsersPage from '@/app/(admin-dashboard)/admin/users/page';
import AdminMarketPage from '@/app/(admin-dashboard)/admin/market/page';
import AdminSimulatorPage from '@/app/(admin-dashboard)/admin/simulator/page';
import AdminLearnPage from '@/app/(admin-dashboard)/admin/learn/page';

const AuthShell = ({ children }: { children: React.ReactNode }) => <AuthLayout>{children}</AuthLayout>;
const UserShell = ({ children }: { children: React.ReactNode }) => <UserDashboardLayout>{children}</UserDashboardLayout>;
const AdminShell = ({ children }: { children: React.ReactNode }) => <AdminDashboardLayout>{children}</AdminDashboardLayout>;

export function AppRoutes() {
  return (
    <Providers>
      <Routes>
        <Route path="/" element={<HomePage />} />

        <Route path="/login" element={<AuthShell><LoginPage /></AuthShell>} />
        <Route path="/signup" element={<AuthShell><SignupPage /></AuthShell>} />
        <Route path="/forgot-password" element={<AuthShell><ForgotPasswordPage /></AuthShell>} />
        <Route path="/reset-password" element={<AuthShell><ResetPasswordPage /></AuthShell>} />
        <Route path="/otp-verify" element={<AuthShell><OtpVerifyPage /></AuthShell>} />
        <Route path="/verify-email" element={<AuthShell><VerifyEmailPage /></AuthShell>} />
        <Route path="/auth-callback" element={<AuthCallbackPage />} />
        <Route path="/payment-callback" element={<PaymentCallbackPage />} />

        <Route path="/dashboard" element={<UserShell><DashboardPage /></UserShell>} />
        <Route path="/watchlist" element={<UserShell><WatchlistPage /></UserShell>} />
        <Route path="/tokens" element={<UserShell><TokensPage /></UserShell>} />
        <Route path="/stock360" element={<UserShell><Stock360Page /></UserShell>} />
        <Route path="/market" element={<UserShell><MarketPage /></UserShell>} />
        <Route path="/market/:symbol" element={<UserShell><MarketSymbolPage /></UserShell>} />
        <Route path="/finances" element={<UserShell><FinancesPage /></UserShell>} />
        <Route path="/notifications" element={<UserShell><NotificationsPage /></UserShell>} />
        <Route path="/simulator" element={<UserShell><SimulatorPage /></UserShell>} />
        <Route path="/simulator/:id" element={<UserShell><SimulatorDetailPage /></UserShell>} />
        <Route path="/simulator/:id/analysis" element={<UserShell><SimulatorAnalysisPage /></UserShell>} />
        <Route path="/settings" element={<UserShell><SettingsPage /></UserShell>} />
        <Route path="/analysis" element={<UserShell><AnalysisPage /></UserShell>} />
        <Route path="/learn" element={<UserShell><LearnPage /></UserShell>} />
        <Route path="/learn/:id" element={<UserShell><LearnDetailPage /></UserShell>} />
        <Route path="/profile" element={<UserShell><ProfilePage /></UserShell>} />
        <Route path="/portfolio" element={<UserShell><PortfolioPage /></UserShell>} />

        <Route path="/admin/dashboard" element={<AdminShell><AdminDashboardPage /></AdminShell>} />
        <Route path="/admin/users" element={<AdminShell><AdminUsersPage /></AdminShell>} />
        <Route path="/admin/market" element={<AdminShell><AdminMarketPage /></AdminShell>} />
        <Route path="/admin/simulator" element={<AdminShell><AdminSimulatorPage /></AdminShell>} />
        <Route path="/admin/learn" element={<AdminShell><AdminLearnPage /></AdminShell>} />

        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Providers>
  );
}