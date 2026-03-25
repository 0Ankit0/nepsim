'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  Home,
  Bell,
  Settings,
  Building2,
  User,
  CreditCard,
  Shield,
  Key,
  TrendingUp,
  Activity,
  GraduationCap,
  Briefcase,
  Bookmark,
  BarChart3,
  ScanSearch,
} from 'lucide-react';
import { OrgSwitcher } from './org-switcher';
import { hasStoredAuthTokens } from '@/lib/api-client';

const coreNavigation = [
  { name: 'Dashboard', href: '/dashboard', icon: Home },
  { name: 'Market', href: '/market', icon: TrendingUp },
  { name: 'Portfolio', href: '/portfolio', icon: Briefcase },
  { name: 'Watchlist', href: '/watchlist', icon: Bookmark },
  { name: 'Analysis', href: '/analysis', icon: BarChart3 },
  { name: '360° View', href: '/stock360', icon: ScanSearch },
  { name: 'Simulator', href: '/simulator', icon: Activity },
  { name: 'Learn', href: '/learn', icon: GraduationCap },
  { name: 'Settings', href: '/settings', icon: Settings },
];

const accountNavigation = [
  { name: 'Profile', href: '/profile', icon: User },
  { name: 'Tenants', href: '/tenants', icon: Building2 },
  { name: 'Payments', href: '/finances', icon: CreditCard },
  { name: 'Notifications', href: '/notifications', icon: Bell },
  { name: 'Roles & Permissions', href: '/rbac', icon: Shield },
  { name: 'Active Sessions', href: '/tokens', icon: Key },
];


export function Sidebar() {
  const pathname = usePathname();
  const isAuthenticated = hasStoredAuthTokens();
  const navigation = isAuthenticated ? [...coreNavigation, ...accountNavigation] : coreNavigation;

  return (
    <aside className="fixed inset-y-0 left-0 z-10 w-64 bg-white border-r border-gray-200">
      <div className="flex h-16 items-center justify-center border-b border-gray-200">
        <Link href="/dashboard" className="text-xl font-bold text-blue-600">
          NEPSIM
        </Link>
      </div>
      {isAuthenticated ? <OrgSwitcher /> : (
        <div className="px-4 py-3 border-b border-gray-100 bg-blue-50/60">
          <p className="text-xs font-semibold uppercase tracking-wider text-blue-700">Offline mode</p>
          <p className="mt-1 text-xs text-blue-800">Local data stays on this device until you choose to sync.</p>
        </div>
      )}
      <nav className="flex flex-col gap-1 p-4 pt-0">
        {navigation.map((item) => {
          const isActive =
            pathname === item.href || pathname.startsWith(`${item.href}/`);
          return (
            <Link
              key={item.name}
              href={item.href}
              className={`flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                isActive
                  ? 'bg-blue-50 text-blue-600'
                  : 'text-gray-700 hover:bg-gray-100'
              }`}
            >
              <item.icon className="h-5 w-5" />
              {item.name}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
