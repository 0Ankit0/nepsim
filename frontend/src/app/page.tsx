'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useAuthStore } from '@/store/auth-store';
import { Button } from '@/components/ui/button';
import { ShoppingCart, Shield, Zap, Users, Cloud, HardDrive } from 'lucide-react';

const features = [
  {
    icon: ShoppingCart,
    title: 'Fastapi Template Ready',
    description: 'Complete Fastapi Template solution with payments, subscriptions, and billing.',
  },
  {
    icon: Shield,
    title: 'Secure by Default',
    description: 'Built-in authentication, authorization, and secure API endpoints.',
  },
  {
    icon: Zap,
    title: 'Fast & Modern',
    description: 'Built with Next.js and Fastapi REST for optimal performance.',
  },
  {
    icon: Users,
    title: 'Multi-Tenant',
    description: 'Support for organizations and teams with role-based access.',
  },
  {
    icon: HardDrive,
    title: 'Offline First',
    description: 'Use the simulator, portfolio, watchlist, and Gemini key locally before you ever sign in.',
  },
  {
    icon: Cloud,
    title: 'Sync When Ready',
    description: 'Sign in later to sync your device data and optionally save an encrypted Gemini key backup.',
  },
];

export default function Home() {
  const router = useRouter();
  const { isAuthenticated } = useAuthStore();

  useEffect(() => {
    if (isAuthenticated) {
      router.push('/dashboard');
    }
  }, [isAuthenticated, router]);

  return (
    <div className="min-h-screen bg-gradient-to-b from-white to-gray-50">
      <header className="fixed top-0 left-0 right-0 z-50 bg-white/80 backdrop-blur-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="text-xl font-bold text-blue-600">NEPSIM</div>
            <div className="flex items-center gap-4">
              <Link href="/dashboard">
                <Button variant="ghost">Continue offline</Button>
              </Link>
              <Link href="/login">
                <Button variant="ghost">Sync</Button>
              </Link>
              <Link href="/signup">
                <Button>Sign up to sync</Button>
              </Link>
            </div>
          </div>
        </div>
      </header>

      <main className="pt-16">
        <section className="py-20 px-4 sm:px-6 lg:px-8">
          <div className="max-w-4xl mx-auto text-center">
            <h1 className="text-4xl sm:text-5xl font-bold text-gray-900 mb-6">
              NEPSIM works offline first
            </h1>
            <p className="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
              Use the simulator, portfolio, watchlist, and Gemini features without logging in.
              Sign in only when you want to sync your device data across devices.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link href="/dashboard">
                <Button size="lg" className="w-full sm:w-auto">
                  Continue Offline
                </Button>
              </Link>
              <Link href="/signup">
                <Button variant="outline" size="lg" className="w-full sm:w-auto">
                  Create Sync Account
                </Button>
              </Link>
            </div>
          </div>
        </section>

        <section className="py-20 px-4 sm:px-6 lg:px-8 bg-white">
          <div className="max-w-7xl mx-auto">
              <h2 className="text-3xl font-bold text-center text-gray-900 mb-12">
                Everything You Need
              </h2>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {features.map((feature) => (
                <div
                  key={feature.title}
                  className="p-6 rounded-xl border border-gray-200 hover:border-blue-500 hover:shadow-lg transition-all"
                >
                  <div className="h-12 w-12 rounded-lg bg-blue-50 flex items-center justify-center mb-4">
                    <feature.icon className="h-6 w-6 text-blue-600" />
                  </div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-2">{feature.title}</h3>
                  <p className="text-gray-600">{feature.description}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        <section className="py-20 px-4 sm:px-6 lg:px-8">
          <div className="max-w-3xl mx-auto text-center">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">Ready to Get Started?</h2>
            <p className="text-lg text-gray-600 mb-8">
              Start locally now, then sign in later whenever you want to sync securely.
            </p>
            <Link href="/signup">
              <Button size="lg">Create Sync Account</Button>
            </Link>
          </div>
        </section>
      </main>

      <footer className="py-8 px-4 border-t border-gray-200">
        <div className="max-w-7xl mx-auto text-center text-gray-500 text-sm">
          © {new Date().getFullYear()} Fastapi Template Platform. All rights reserved.
        </div>
      </footer>
    </div>
  );
}
