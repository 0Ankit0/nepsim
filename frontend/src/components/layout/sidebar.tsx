'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  Home,
  Bell,
  Settings,
  User,
  CreditCard,
  Key,
  TrendingUp,
  Activity,
  GraduationCap,
  Briefcase,
  Bookmark,
  BarChart3,
  ScanSearch,
} from 'lucide-react';

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: Home },
  { name: 'Market', href: '/market', icon: TrendingUp },
  { name: 'Portfolio', href: '/portfolio', icon: Briefcase },
  { name: 'Watchlist', href: '/watchlist', icon: Bookmark },
  { name: 'Analysis', href: '/analysis', icon: BarChart3 },
  { name: '360° View', href: '/stock360', icon: ScanSearch },
  { name: 'Simulator', href: '/simulator', icon: Activity },
  { name: 'Learn', href: '/learn', icon: GraduationCap },
  { name: 'Profile', href: '/profile', icon: User },
  { name: 'Payments', href: '/finances', icon: CreditCard },
  { name: 'Notifications', href: '/notifications', icon: Bell },
  { name: 'Active Sessions', href: '/tokens', icon: Key },
  { name: 'Settings', href: '/settings', icon: Settings },
];


export function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="fixed inset-y-0 left-0 z-10 w-64 bg-white border-r border-gray-200">
      <div className="flex h-16 items-center justify-center border-b border-gray-200">
        <Link href="/dashboard" className="text-xl font-bold text-blue-600">
          FastAPI Template
        </Link>
      </div>
      <nav className="flex flex-col gap-1 p-4">
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
