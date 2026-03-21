// @ts-nocheck

'use client';

import { useAuthStore } from '@/store/auth-store';
import { useNotifications } from '@/hooks/use-notifications';
import { useTokens } from '@/hooks/use-tokens';
import { useSimulations, useStocks } from '@/hooks';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { 
  Bell, Shield, Key, CheckCircle, Clock, AlertTriangle, 
  TrendingUp, TrendingDown, Activity, Play, GraduationCap,
  ArrowRight
} from 'lucide-react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';

export default function DashboardPage() {
  const { user } = useAuthStore();
  const { data: notifData, isLoading: loadingNotifs } = useNotifications({ limit: 5 });
  const { data: tokenData } = useTokens({ limit: 1 });
  const { data: simulations } = useSimulations({ limit: 1 });
  const { data: stocks, isLoading: loadingStocks } = useStocks({ limit: 4 });

  const recentNotifs = notifData?.items ?? [];
  const unreadCount = notifData?.unread_count ?? 0;
  const activeSessions = tokenData?.total ?? 0;

  const stats = [
    {
      name: 'Unread Notifications',
      value: String(unreadCount),
      icon: Bell,
      href: '/notifications',
      color: 'text-blue-600 bg-blue-50',
    },
    {
      name: 'Active Sessions',
      value: String(activeSessions),
      icon: Key,
      href: '/tokens',
      color: 'text-purple-600 bg-purple-50',
    },
    {
      name: '2FA Status',
      value: user?.otp_enabled ? 'Enabled' : 'Disabled',
      icon: Shield,
      href: '/profile',
      color: user?.otp_enabled ? 'text-green-600 bg-green-50' : 'text-yellow-600 bg-yellow-50',
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-500">
          Welcome back{user?.first_name ? `, ${user.first_name}` : user?.username ? `, ${user.username}` : ''}!
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {stats.map((stat) => (
          <Link key={stat.name} href={stat.href}>
            <Card className="hover:shadow-md transition-shadow cursor-pointer">
              <CardContent className="pt-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm text-gray-500">{stat.name}</p>
                    <p className="text-2xl font-bold text-gray-900 mt-1">{stat.value}</p>
                  </div>
                  <div className={`h-12 w-12 rounded-lg flex items-center justify-center ${stat.color}`}>
                    <stat.icon className="h-6 w-6" />
                  </div>
                </div>
              </CardContent>
            </Card>
          </Link>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Simulation Overview Card */}
        <Card className="lg:col-span-2 overflow-hidden border-indigo-500/20 shadow-lg shadow-indigo-500/5">
          <CardHeader className="bg-slate-900/50 border-b border-slate-100 flex flex-row items-center justify-between">
            <CardTitle className="flex items-center gap-2 text-indigo-900">
              <Activity className="h-5 w-5" />
              Active Simulation
            </CardTitle>
            <Link href="/simulator" className="text-sm font-medium text-indigo-600 hover:text-indigo-800 flex items-center gap-1">
              Go to Simulator <ArrowRight className="h-3.5 w-3.5" />
            </Link>
          </CardHeader>
          <CardContent className="pt-6">
            {(simulations ?? []).length > 0 ? (
              <div className="flex flex-col md:flex-row items-center gap-8">
                <div className="flex-1 space-y-4">
                  <div>
                    <p className="text-sm text-gray-500">Current Balance</p>
                    <p className="text-3xl font-bold text-gray-900">Rs. {simulations![0].current_balance.toLocaleString()}</p>
                  </div>
                  <div className="flex gap-4">
                    <div className="px-3 py-1 bg-emerald-50 text-emerald-700 rounded-full text-sm font-medium border border-emerald-100 flex items-center gap-1.5">
                      <TrendingUp className="h-3.5 w-3.5" />
                      +{simulations![0].total_pnl_pct.toFixed(2)}%
                    </div>
                    <div className="px-3 py-1 bg-indigo-50 text-indigo-700 rounded-full text-sm font-medium border border-indigo-100 flex items-center gap-1.5">
                      <Clock className="h-3.5 w-3.5" />
                      Day 14
                    </div>
                  </div>
                </div>
                <div className="w-full md:w-48 space-y-2">
                  <Button className="w-full bg-indigo-600 hover:bg-indigo-700">
                    Advance Day
                  </Button>
                  <Button variant="outline" className="w-full">
                    View Portfolio
                  </Button>
                </div>
              </div>
            ) : (
              <div className="text-center py-10 space-y-4">
                <div className="h-16 w-16 bg-indigo-50 rounded-full flex items-center justify-center mx-auto">
                    <Play className="h-8 w-8 text-indigo-600 ml-1" />
                </div>
                <div>
                  <h3 className="text-lg font-bold text-gray-900">No Active Simulation</h3>
                  <p className="text-gray-500 text-sm max-w-xs mx-auto">
                    Start a new simulation to practice your trading skills and get AI feedback.
                  </p>
                </div>
                <Link href="/simulator">
                  <Button className="bg-indigo-600 hover:bg-indigo-700 mt-2">
                    Start Simulation
                  </Button>
                </Link>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Learning Progress Card */}
        <Card className="border-emerald-500/20 shadow-lg shadow-emerald-500/5">
          <CardHeader className="bg-slate-900/50 border-b border-slate-100">
            <CardTitle className="flex items-center gap-2 text-emerald-900">
              <GraduationCap className="h-5 w-5" />
              Learning Path
            </CardTitle>
          </CardHeader>
          <CardContent className="pt-6 space-y-4">
            <div className="p-4 bg-emerald-50 rounded-xl border border-emerald-100 flex gap-4">
              <div className="h-10 w-10 bg-white rounded-lg border border-emerald-200 flex items-center justify-center flex-shrink-0">
                <TrendingUp className="h-5 w-5 text-emerald-600" />
              </div>
              <div>
                <p className="text-xs font-bold text-emerald-700 uppercase tracking-wider">Next Lesson</p>
                <h4 className="text-sm font-bold text-gray-900">Understanding RSI</h4>
                <p className="text-xs text-gray-500 mt-1">Learn to spot overbought and oversold market conditions.</p>
              </div>
            </div>
            <Link href="/learn">
              <Button variant="outline" className="w-full border-emerald-200 text-emerald-700 hover:bg-emerald-50">
                Continue Learning
              </Button>
            </Link>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle className="flex items-center gap-2">
              <Bell className="h-5 w-5" />
              Recent Notifications
            </CardTitle>
            <Link href="/notifications" className="text-sm text-blue-600 hover:underline">
              View all
            </Link>
          </CardHeader>
          <CardContent>
            {loadingNotifs ? (
              <div className="space-y-3">
                {[1, 2, 3].map((i) => (
                  <div key={i} className="h-12 bg-gray-100 rounded animate-pulse" />
                ))}
              </div>
            ) : recentNotifs.length === 0 ? (
              <div className="text-center py-8">
                <Bell className="h-8 w-8 text-gray-300 mx-auto mb-2" />
                <p className="text-sm text-gray-500">No notifications yet</p>
              </div>
            ) : (
              <div className="space-y-3">
                {recentNotifs.map((n) => (
                  <div
                    key={n.id}
                    className={`flex items-start gap-3 p-3 rounded-lg ${n.is_read ? '' : 'bg-blue-50'}`}
                  >
                    <div
                      className={`mt-0.5 h-2 w-2 rounded-full flex-shrink-0 ${
                        n.is_read ? 'bg-gray-300' : 'bg-blue-500'
                      }`}
                    />
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900 truncate">{n.title}</p>
                      <p className="text-xs text-gray-500 truncate">{n.body}</p>
                    </div>
                    <span className="text-xs text-gray-400 flex-shrink-0">
                      {new Date(n.created_at).toLocaleDateString()}
                    </span>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Market Summary</CardTitle>
          </CardHeader>
          <CardContent>
             <div className="space-y-4">
                {loadingStocks ? (
                   <div className="space-y-2">
                      {[1, 2, 3].map(i => <div key={i} className="h-10 bg-gray-100 rounded animate-pulse" />)}
                   </div>
                ) : (stocks?.items ?? []).slice(0, 4).map(stock => (
                   <div key={stock.symbol} className="flex items-center justify-between p-2 hover:bg-gray-50 rounded-lg transition-colors">
                      <div className="flex items-center gap-3">
                         <div className="h-8 w-8 rounded bg-slate-100 flex items-center justify-center font-bold text-slate-600 text-[10px]">
                            {stock.symbol.substring(0, 3)}
                         </div>
                         <div className="min-w-0">
                            <p className="text-sm font-bold text-gray-900 truncate">{stock.symbol}</p>
                            <p className="text-[10px] text-gray-500">{stock.sector}</p>
                         </div>
                      </div>
                      <div className="text-right">
                         <p className="text-sm font-bold text-gray-900">Rs. {stock.last_price}</p>
                         <p className={`text-[10px] font-medium flex items-center justify-end gap-1 ${stock.change_pct >= 0 ? 'text-emerald-600' : 'text-rose-600'}`}>
                            {stock.change_pct >= 0 ? <TrendingUp className="h-2.5 w-2.5" /> : <TrendingDown className="h-2.5 w-2.5" />}
                            {stock.change_pct.toFixed(2)}%
                         </p>
                      </div>
                   </div>
                ))}
                <Link href="/market">
                   <Button variant="ghost" size="sm" className="w-full text-indigo-600 hover:text-indigo-700 hover:bg-indigo-50">
                      View All Markets
                   </Button>
                </Link>
             </div>
          </CardContent>
        </Card>
      </div>


      {!user?.is_confirmed && (
        <Card className="border-yellow-200 bg-yellow-50">
          <CardContent className="pt-6">
            <div className="flex items-start gap-3">
              <AlertTriangle className="h-5 w-5 text-yellow-600 flex-shrink-0 mt-0.5" />
              <div>
                <p className="text-sm font-medium text-yellow-800">Email not verified</p>
                <p className="text-xs text-yellow-700 mt-1">
                  Please verify your email address to unlock all features.
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      {!user?.otp_enabled && (
        <Card className="border-orange-200 bg-orange-50">
          <CardContent className="pt-6">
            <div className="flex items-center justify-between">
              <div className="flex items-start gap-3">
                <Shield className="h-5 w-5 text-orange-600 flex-shrink-0 mt-0.5" />
                <div>
                  <p className="text-sm font-medium text-orange-800">Two-factor authentication is disabled</p>
                  <p className="text-xs text-orange-700 mt-1">
                    Enable 2FA to add an extra layer of security to your account.
                  </p>
                </div>
              </div>
              <Link
                href="/profile"
                className="text-sm font-medium text-orange-700 hover:text-orange-900 underline flex-shrink-0"
              >
                Enable 2FA
              </Link>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
