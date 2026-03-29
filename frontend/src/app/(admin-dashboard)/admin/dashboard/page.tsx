// @ts-nocheck

'use client';

import { useListUsers } from '@/hooks/use-users';
import { useTokens } from '@/hooks/use-tokens';
import { useStocks, useSimulations, useLessons } from '@/hooks';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { 
  Users, Key, Activity, UserCheck, UserX,
  TrendingUp, PlayCircle, BookOpen, GraduationCap 
} from 'lucide-react';
import Link from 'next/link';
import { Skeleton } from '@/components/ui';

export default function AdminDashboardPage() {
  const { data: usersData } = useListUsers({ limit: 1 });
  const { data: tokenData } = useTokens({ limit: 1 });
  const { data: stocks, isLoading: loadingStocks } = useStocks({ active_only: false });
  const { data: sims, isLoading: loadingSims } = useSimulations({ limit: 1 });
  const { data: curriculum, isLoading: loadingLearn } = useLessons();

  const totalUsers = usersData?.total ?? 0;
  const activeSessions = tokenData?.total ?? 0;
  const totalStocks = stocks?.length ?? 0;
  const activeSims = (sims ?? []).filter(s => s.status === 'active').length;
  const totalLessons = (curriculum ?? []).reduce((acc, section) => acc + section.lessons.length, 0);

  const stats = [
    {
      name: 'Total Users',
      value: String(totalUsers),
      icon: Users,
      href: '/admin/users',
      color: 'text-indigo-400 bg-indigo-900/40',
    },
    {
      name: 'Total Stocks',
      value: String(totalStocks),
      href: '/admin/market',
      icon: TrendingUp,
      color: 'text-emerald-400 bg-emerald-900/40',
    },
    {
      name: 'Active Simulations',
      value: String(activeSims),
      href: '/admin/simulator',
      icon: PlayCircle,
      color: 'text-rose-400 bg-rose-900/40',
    },
    {
      name: 'Learning Lessons',
      value: String(totalLessons),
      href: '/admin/learn',
      icon: BookOpen,
      color: 'text-amber-400 bg-amber-900/40',
    },
  ];

  const quickActions = [
    { href: '/admin/market', icon: TrendingUp, label: 'Market Data', desc: 'Manage stocks & CSV prices', color: 'text-emerald-400' },
    { href: '/admin/simulator', icon: Activity, label: 'Simulations', desc: 'Monitor user trading', color: 'text-rose-400' },
    { href: '/admin/learn', icon: GraduationCap, label: 'Learn CMS', desc: 'Edit lessons & quizzes', color: 'text-amber-400' },
    { href: '/admin/users', icon: Users, label: 'Manage Users', desc: 'View, edit, delete users', color: 'text-indigo-400' },
    { href: '/tokens', icon: Key, label: 'Active Sessions', desc: 'Monitor & revoke tokens', color: 'text-purple-400' },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-white">Admin Dashboard</h1>
        <p className="text-indigo-300 mt-1">Platform overview &amp; management</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {stats.map((stat) => (
          <Link key={stat.name} href={stat.href}>
            <Card className="bg-slate-900 border-slate-700 hover:border-indigo-600 transition-all hover:scale-[1.02] cursor-pointer shadow-lg shadow-black/20">
              <CardContent className="pt-6">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-xs font-bold uppercase tracking-wider text-slate-500">{stat.name}</p>
                    <p className="text-3xl font-black text-white mt-1">{stat.value}</p>
                  </div>
                  <div className={`h-12 w-12 rounded-xl flex items-center justify-center border border-white/5 ${stat.color}`}>
                    <stat.icon className="h-6 w-6" />
                  </div>
                </div>
              </CardContent>
            </Card>
          </Link>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card className="bg-slate-900 border-slate-700">
          <CardHeader>
            <CardTitle className="text-white flex items-center gap-2">
              <Activity className="h-5 w-5 text-indigo-400" />
              Quick Actions
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 lg:grid-cols-3 gap-3">
              {quickActions.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className="flex flex-col gap-2 p-4 rounded-xl border border-slate-800 bg-slate-900/50 hover:border-indigo-500 hover:bg-slate-800 transition-all"
                >
                  <item.icon className={`h-5 w-5 ${item.color}`} />
                  <div>
                    <p className="text-sm font-bold text-white">{item.label}</p>
                    <p className="text-[10px] text-slate-500 uppercase tracking-tighter">{item.desc}</p>
                  </div>
                </Link>
              ))}
            </div>
          </CardContent>
        </Card>

        <Card className="bg-slate-900 border-slate-700">
          <CardHeader>
            <CardTitle className="text-white flex items-center gap-2">
              <Users className="h-5 w-5 text-indigo-400" />
              User Management
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <Link
              href="/admin/users"
              className="flex items-center justify-between p-3 rounded-lg border border-slate-700 hover:border-indigo-500 hover:bg-slate-800 transition-colors"
            >
              <div className="flex items-center gap-3">
                <UserCheck className="h-5 w-5 text-green-400" />
                <span className="text-sm text-slate-200">View All Users</span>
              </div>
              <span className="text-xs text-slate-400">{totalUsers} total</span>
            </Link>
            <Link
              href="/admin/users"
              className="flex items-center justify-between p-3 rounded-lg border border-slate-700 hover:border-indigo-500 hover:bg-slate-800 transition-colors"
            >
              <div className="flex items-center gap-3">
                <UserX className="h-5 w-5 text-red-400" />
                <span className="text-sm text-slate-200">Manage Admin Access</span>
              </div>
              <span className="text-xs text-slate-400">Edit users</span>
            </Link>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
