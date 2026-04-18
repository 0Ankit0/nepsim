'use client';

import { useEffect, useMemo, useRef, useState } from 'react';
import Link from 'next/link';
import { Activity, Bell, CheckCheck, ChevronRight, LogOut, Pause, Play, Settings, StopCircle, User } from 'lucide-react';
import { useAuth } from '@/hooks/use-auth';
import { useAuthSession } from '@/hooks/use-auth-session';
import { Button } from '@/components/ui/button';
import { ConfirmDialog } from '@/components/ui/confirm-dialog';
import { useNotifications, useMarkAllNotificationsRead, useMarkNotificationRead } from '@/hooks/use-notifications';
import { useEndSimulation, usePauseSimulation, useResumeSimulation, useSimulations } from '@/hooks/useSimulator';
import { LanguageSwitcher } from './language-switcher';

function useClickOutside(ref: React.RefObject<HTMLElement | null>, handler: () => void) {
  useEffect(() => {
    const listener = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) handler();
    };
    document.addEventListener('mousedown', listener);
    return () => document.removeEventListener('mousedown', listener);
  }, [ref, handler]);
}

export function Header() {
  const { logout } = useAuth();
  const { user } = useAuthSession();

  const [showLogoutDialog, setShowLogoutDialog] = useState(false);
  const [showEndSimulationDialog, setShowEndSimulationDialog] = useState(false);
  const [isLoggingOut, setIsLoggingOut] = useState(false);
  const [notifOpen, setNotifOpen] = useState(false);
  const [userOpen, setUserOpen] = useState(false);

  const notifRef = useRef<HTMLDivElement>(null);
  const userRef = useRef<HTMLDivElement>(null);

  useClickOutside(notifRef, () => setNotifOpen(false));
  useClickOutside(userRef, () => setUserOpen(false));

  const { data: notifData } = useNotifications({ limit: 6 });
  const { data: simulations } = useSimulations();
  const activeSimulation = useMemo(
    () => (simulations ?? []).find((simulation) => simulation.status === 'active' || simulation.status === 'paused') ?? null,
    [simulations]
  );
  const activeSimulationId = activeSimulation?.id ?? 0;
  const pauseSimulation = usePauseSimulation(activeSimulationId);
  const resumeSimulation = useResumeSimulation(activeSimulationId);
  const endSimulation = useEndSimulation(activeSimulationId);

  const markAll = useMarkAllNotificationsRead();
  const markOne = useMarkNotificationRead();

  const notifications = notifData?.items ?? [];
  const unreadCount = notifData?.unread_count ?? 0;
  const isPaused = activeSimulation?.status === 'paused';

  const handleLogoutConfirm = async () => {
    setIsLoggingOut(true);
    await logout();
    setIsLoggingOut(false);
    setShowLogoutDialog(false);
  };

  const handleEndSimulationConfirm = () => {
    endSimulation.mutate(undefined, {
      onSettled: () => setShowEndSimulationDialog(false),
    });
  };

  return (
    <header className="fixed top-0 left-64 right-0 z-10 h-16 border-b border-gray-200 bg-white">
      <div className="flex h-full items-center justify-between gap-4 px-6">
        <div className="min-w-0 flex-1">
          {activeSimulation ? (
            <div className="flex items-center gap-3 rounded-2xl border border-indigo-200 bg-indigo-50/80 px-4 py-2">
              <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-indigo-600 text-white">
                <Activity className="h-4 w-4" />
              </div>
              <div className="min-w-0">
                <p className="text-[10px] font-semibold uppercase tracking-[0.24em] text-indigo-500">Live simulation</p>
                <p className="truncate text-sm font-semibold text-slate-900">
                  {activeSimulation.name || `Simulation #${activeSimulation.id}`} · {new Date(activeSimulation.current_sim_date).toLocaleDateString()}
                </p>
              </div>
              <div className="ml-auto hidden items-center gap-2 lg:flex">
                <Button
                  type="button"
                  size="sm"
                  variant="outline"
                  onClick={() => (isPaused ? resumeSimulation.mutate() : pauseSimulation.mutate())}
                  disabled={pauseSimulation.isPending || resumeSimulation.isPending}
                >
                  {isPaused ? <Play className="mr-1 h-3.5 w-3.5" /> : <Pause className="mr-1 h-3.5 w-3.5" />}
                  {isPaused ? 'Resume' : 'Pause'}
                </Button>
                <Button
                  type="button"
                  size="sm"
                  className="bg-rose-600 text-white hover:bg-rose-700"
                  onClick={() => setShowEndSimulationDialog(true)}
                  disabled={endSimulation.isPending}
                >
                  <StopCircle className="mr-1 h-3.5 w-3.5" />
                  Stop
                </Button>
                <Link href={`/simulator/${activeSimulation.id}`}>
                  <Button type="button" size="sm" className="bg-slate-900 text-white hover:bg-black">
                    Open
                  </Button>
                </Link>
              </div>
            </div>
          ) : (
            <div />
          )}
        </div>

        <div className="flex items-center gap-3">
          <LanguageSwitcher />

          <div ref={notifRef} className="relative">
            <button
              onClick={() => {
                setNotifOpen((open) => !open);
                setUserOpen(false);
              }}
              className="relative rounded-lg p-2 text-gray-500 hover:bg-gray-100 hover:text-gray-700"
              aria-label="Notifications"
            >
              <Bell className="h-5 w-5" />
              {unreadCount > 0 && (
                <span className="absolute top-1 right-1 flex h-4 w-4 items-center justify-center rounded-full bg-red-500 text-[10px] font-bold leading-none text-white">
                  {unreadCount > 9 ? '9+' : unreadCount}
                </span>
              )}
            </button>

            {notifOpen && (
              <div className="absolute right-0 z-50 mt-2 w-80 overflow-hidden rounded-xl border border-gray-200 bg-white shadow-lg">
                <div className="flex items-center justify-between border-b border-gray-100 px-4 py-3">
                  <span className="text-sm font-semibold text-gray-900">Notifications</span>
                  {unreadCount > 0 && (
                    <button onClick={() => markAll.mutate()} className="flex items-center gap-1 text-xs text-blue-600 hover:text-blue-800">
                      <CheckCheck className="h-3.5 w-3.5" />
                      Mark all read
                    </button>
                  )}
                </div>

                <div className="max-h-72 divide-y divide-gray-50 overflow-y-auto">
                  {notifications.length === 0 ? (
                    <div className="py-8 text-center">
                      <Bell className="mx-auto mb-2 h-7 w-7 text-gray-300" />
                      <p className="text-sm text-gray-400">No notifications</p>
                    </div>
                  ) : (
                    notifications.map((notification) => (
                      <div
                        key={notification.id}
                        className={`flex items-start gap-3 px-4 py-3 transition-colors hover:bg-gray-50 ${!notification.is_read ? 'bg-blue-50/60' : ''}`}
                      >
                        <span className={`mt-1.5 h-2 w-2 flex-shrink-0 rounded-full ${notification.is_read ? 'bg-gray-300' : 'bg-blue-500'}`} />
                        <div className="min-w-0 flex-1">
                          <p className="truncate text-sm font-medium text-gray-900">{notification.title}</p>
                          <p className="mt-0.5 truncate text-xs text-gray-500">{notification.body}</p>
                          <p className="mt-1 text-[10px] text-gray-400">{new Date(notification.created_at).toLocaleDateString()}</p>
                        </div>
                        {!notification.is_read && (
                          <button onClick={() => markOne.mutate(notification.id)} className="mt-1 flex-shrink-0 text-[10px] text-blue-500 hover:text-blue-700">
                            Mark read
                          </button>
                        )}
                      </div>
                    ))
                  )}
                </div>

                <Link
                  href="/notifications"
                  onClick={() => setNotifOpen(false)}
                  className="flex items-center justify-center gap-1 border-t border-gray-100 px-4 py-2.5 text-xs font-medium text-blue-600 transition-colors hover:bg-blue-50"
                >
                  View all notifications <ChevronRight className="h-3.5 w-3.5" />
                </Link>
              </div>
            )}
          </div>

          <div ref={userRef} className="relative">
            <button
              onClick={() => {
                setUserOpen((open) => !open);
                setNotifOpen(false);
              }}
              className="flex items-center gap-2 rounded-lg px-2 py-1.5 transition-colors hover:bg-gray-100"
              aria-label="User menu"
            >
              <div className="flex h-8 w-8 items-center justify-center rounded-full bg-blue-100">
                <User className="h-4 w-4 text-blue-600" />
              </div>
              <span className="max-w-[120px] truncate text-sm font-medium text-gray-700">
                {user?.first_name || user?.username || user?.email || 'User'}
              </span>
            </button>

            {userOpen && (
              <div className="absolute right-0 z-50 mt-2 w-56 overflow-hidden rounded-xl border border-gray-200 bg-white shadow-lg">
                <div className="border-b border-gray-100 px-4 py-3">
                  <p className="truncate text-sm font-semibold text-gray-900">
                    {user?.first_name && user?.last_name
                      ? `${user.first_name} ${user.last_name}`
                      : user?.username || 'User'}
                  </p>
                  <p className="mt-0.5 truncate text-xs text-gray-500">{user?.email}</p>
                </div>

                <div className="py-1">
                  <Link
                    href="/profile"
                    onClick={() => setUserOpen(false)}
                    className="flex items-center gap-3 px-4 py-2 text-sm text-gray-700 transition-colors hover:bg-gray-50"
                  >
                    <User className="h-4 w-4 text-gray-400" />
                    Profile
                  </Link>
                  <Link
                    href="/settings"
                    onClick={() => setUserOpen(false)}
                    className="flex items-center gap-3 px-4 py-2 text-sm text-gray-700 transition-colors hover:bg-gray-50"
                  >
                    <Settings className="h-4 w-4 text-gray-400" />
                    Settings
                  </Link>
                </div>

                <div className="border-t border-gray-100 py-1">
                  <button
                    onClick={() => {
                      setUserOpen(false);
                      setShowLogoutDialog(true);
                    }}
                    className="flex w-full items-center gap-3 px-4 py-2 text-sm text-red-600 transition-colors hover:bg-red-50"
                  >
                    <LogOut className="h-4 w-4" />
                    Sign out
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      <ConfirmDialog
        open={showLogoutDialog}
        title="Sign out?"
        description="You will be signed out of your account and redirected to the login page."
        confirmLabel="Sign out"
        cancelLabel="Cancel"
        onConfirm={handleLogoutConfirm}
        onCancel={() => setShowLogoutDialog(false)}
        isLoading={isLoggingOut}
      />

      <ConfirmDialog
        open={showEndSimulationDialog}
        title="Stop active simulation?"
        description="This will end the running simulation and begin analysis generation."
        confirmLabel="Stop simulation"
        cancelLabel="Keep running"
        onConfirm={handleEndSimulationConfirm}
        onCancel={() => setShowEndSimulationDialog(false)}
        isLoading={endSimulation.isPending}
      />
    </header>
  );
}
