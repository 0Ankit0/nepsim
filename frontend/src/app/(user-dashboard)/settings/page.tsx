'use client';

import { useEffect, useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useAuthStore } from '@/store/auth-store';
import { hasStoredAuthTokens } from '@/lib/api-client';
import {
  getLocalGeminiApiKey,
  getOfflineGuestUser,
  getOfflineSyncSettings,
  setLocalGeminiApiKey,
  updateOfflineSyncSettings,
} from '@/lib/offline-data';
import { syncApi } from '@/api/sync';
import {
  useNotificationPreferences,
  useUpdateNotificationPreferences,
} from '@/hooks/use-notifications';
import { useResendVerification } from '@/hooks/use-auth';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button, Skeleton } from '@/components/ui';
import {
  Bell,
  Mail,
  ShieldAlert,
  CheckCircle2,
  XCircle,
  Key,
  RefreshCw,
  ExternalLink,
  DatabaseZap,
  Cloud,
  Lock,
  Sparkles,
} from 'lucide-react';
import Link from 'next/link';

const TABS = [
  { id: 'account',       label: 'Account',       icon: Mail },
  { id: 'notifications', label: 'Notifications',  icon: Bell },
  { id: 'ai-sync',       label: 'AI & Sync',      icon: Sparkles },
  { id: 'privacy',       label: 'Privacy',        icon: ShieldAlert },
] as const;

type TabId = (typeof TABS)[number]['id'];

// ── Toggle component ────────────────────────────────────────────────────────
function Toggle({
  checked,
  onChange,
  disabled,
}: {
  checked: boolean;
  onChange: (v: boolean) => void;
  disabled?: boolean;
}) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      disabled={disabled}
      onClick={() => onChange(!checked)}
      className={`relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed ${
        checked ? 'bg-blue-600' : 'bg-gray-200'
      }`}
    >
      <span
        className={`inline-block h-5 w-5 rounded-full bg-white shadow transform transition-transform duration-200 ${
          checked ? 'translate-x-5' : 'translate-x-0'
        }`}
      />
    </button>
  );
}

export default function SettingsPage() {
  const { user } = useAuthStore();
  const isAuthenticated = hasStoredAuthTokens();
  const effectiveUser = user ?? getOfflineGuestUser();
  const [activeTab, setActiveTab] = useState<TabId>('account');
  const [geminiKey, setGeminiKey] = useState('');
  const [backupGeminiKey, setBackupGeminiKey] = useState(false);
  const [savedLocally, setSavedLocally] = useState(false);
  const queryClient = useQueryClient();

  // ── Notifications ──────────────────────────────────────────────────────
  const { data: prefs, isLoading: prefsLoading } = useNotificationPreferences();
  const updatePref = useUpdateNotificationPreferences();

  // ── Email verification ─────────────────────────────────────────────────
  const resend = useResendVerification();
  const [resentOk, setResentOk] = useState(false);
  const handleResend = () => {
    resend.mutate(undefined, {
      onSuccess: () => setResentOk(true),
    });
  };

  useEffect(() => {
    setGeminiKey(getLocalGeminiApiKey());
    setBackupGeminiKey(getOfflineSyncSettings().backupGeminiKeyToCloud);
  }, []);

  const { data: cloudSyncSettings } = useQuery({
    queryKey: ['sync-settings'],
    queryFn: () => syncApi.getSettings(),
    enabled: isAuthenticated,
  });

  const saveCloudSyncSettings = useMutation({
    mutationFn: async () => {
      const localKey = geminiKey.trim();
      return syncApi.updateSettings({
        backup_gemini_key_to_cloud: backupGeminiKey,
        gemini_api_key: backupGeminiKey && localKey ? localKey : null,
      });
    },
    onSuccess: (data) => {
      updateOfflineSyncSettings({
        backupGeminiKeyToCloud: data.backup_gemini_key_to_cloud,
        cloudGeminiKeyStored: data.cloud_gemini_key_stored,
        lastSyncAt: data.last_synced_at,
      });
      queryClient.invalidateQueries({ queryKey: ['sync-settings'] });
    },
  });

  const removeCloudBackup = useMutation({
    mutationFn: () => syncApi.removeGeminiKeyBackup(),
    onSuccess: (data) => {
      updateOfflineSyncSettings({
        backupGeminiKeyToCloud: data.backup_gemini_key_to_cloud,
        cloudGeminiKeyStored: data.cloud_gemini_key_stored,
        lastSyncAt: data.last_synced_at,
      });
      setBackupGeminiKey(false);
      queryClient.invalidateQueries({ queryKey: ['sync-settings'] });
    },
  });

  const handleSaveKeyLocally = () => {
    setLocalGeminiApiKey(geminiKey);
    updateOfflineSyncSettings({ backupGeminiKeyToCloud: backupGeminiKey });
    setSavedLocally(true);
    window.setTimeout(() => setSavedLocally(false), 2500);
  };

  const effectiveCloudSync = cloudSyncSettings ?? {
    backup_gemini_key_to_cloud: getOfflineSyncSettings().backupGeminiKeyToCloud,
    cloud_gemini_key_stored: getOfflineSyncSettings().cloudGeminiKeyStored,
    last_synced_at: getOfflineSyncSettings().lastSyncAt,
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Settings</h1>
        <p className="text-gray-500">App preferences and account management</p>
      </div>

      <div className="flex gap-6">
        {/* Sidebar nav */}
        <nav className="w-48 flex-shrink-0 space-y-1">
          {TABS.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`w-full flex items-center gap-3 px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                activeTab === tab.id
                  ? 'bg-blue-50 text-blue-600'
                  : 'text-gray-700 hover:bg-gray-100'
              }`}
            >
              <tab.icon className="h-4 w-4" />
              {tab.label}
            </button>
          ))}
        </nav>

        <div className="flex-1 space-y-5">

          {/* ── Account tab ─────────────────────────────────────────────── */}
          {activeTab === 'account' && (
            <>
              {/* Email address + verification */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Mail className="h-5 w-5" />
                    Email Address
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="flex items-center justify-between rounded-lg border border-gray-200 px-4 py-3">
                    <div>
                      <p className="text-sm font-medium text-gray-900">{effectiveUser?.email}</p>
                      <p className="text-xs text-gray-500 mt-0.5">
                        {isAuthenticated ? 'Your sync account email' : 'Local-only guest profile'}
                      </p>
                    </div>
                    {isAuthenticated && effectiveUser?.is_confirmed ? (
                      <span className="flex items-center gap-1.5 text-xs font-medium text-emerald-600 bg-emerald-50 px-2.5 py-1 rounded-full">
                        <CheckCircle2 className="h-3.5 w-3.5" />
                        Verified
                      </span>
                    ) : (
                      <span className="flex items-center gap-1.5 text-xs font-medium text-amber-600 bg-amber-50 px-2.5 py-1 rounded-full">
                        <XCircle className="h-3.5 w-3.5" />
                        Unverified
                      </span>
                    )}
                  </div>

                  {isAuthenticated && !effectiveUser?.is_confirmed && (
                    <div className="rounded-lg border border-amber-200 bg-amber-50 p-4 space-y-3">
                      <p className="text-sm text-amber-800">
                        Your email address hasn't been verified yet. Check your inbox for the
                        verification link, or request a new one below.
                      </p>
                      {resentOk ? (
                        <p className="flex items-center gap-2 text-sm font-medium text-emerald-700">
                          <CheckCircle2 className="h-4 w-4" />
                          Verification email sent — check your inbox.
                        </p>
                      ) : (
                        <Button
                          size="sm"
                          variant="outline"
                          onClick={handleResend}
                          isLoading={resend.isPending}
                        >
                          <RefreshCw className="h-3.5 w-3.5 mr-1.5" />
                          Resend verification email
                        </Button>
                      )}
                    </div>
                  )}

                  {!isAuthenticated && (
                    <p className="text-xs text-gray-400">
                      You can use every local feature without logging in. Sign in only when you want to sync across devices.
                    </p>
                  )}

                  {isAuthenticated && effectiveUser?.is_confirmed && (
                    <p className="text-xs text-gray-400">
                      To change your email address, contact support.
                    </p>
                  )}
                </CardContent>
              </Card>

              {/* Username / display info (read-only, edit via Profile) */}
              <Card>
                <CardHeader>
                  <CardTitle>Account Details</CardTitle>
                </CardHeader>
                <CardContent className="space-y-3">
                  {[
                    { label: 'Username', value: effectiveUser?.username },
                    { label: 'Member since', value: isAuthenticated && (effectiveUser as any)?.created_at ? new Date((effectiveUser as any).created_at).toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' }) : 'This device' },
                    { label: 'Account type', value: isAuthenticated ? (effectiveUser?.is_superuser ? 'Superuser' : 'Standard') : 'Offline local profile' },
                  ].map(({ label, value }) => (
                    <div key={label} className="flex items-center justify-between py-2 border-b border-gray-100 last:border-0">
                      <span className="text-sm text-gray-500">{label}</span>
                      <span className="text-sm font-medium text-gray-900">{value || '—'}</span>
                    </div>
                  ))}
                  {isAuthenticated ? (
                    <p className="pt-1 text-xs text-gray-400">
                      Update your name and avatar on the{' '}
                      <Link href="/profile" className="text-blue-600 hover:underline">
                        Profile page
                      </Link>
                      .
                    </p>
                  ) : (
                    <p className="pt-1 text-xs text-gray-400">
                      Local profile information is device-only until you sign in and sync.
                    </p>
                  )}
                </CardContent>
              </Card>
            </>
          )}

          {/* ── Notifications tab ────────────────────────────────────────── */}
          {activeTab === 'notifications' && (
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Bell className="h-5 w-5" />
                  Notification Channels
                </CardTitle>
              </CardHeader>
              <CardContent>
                {prefsLoading ? (
                  <div className="space-y-4">
                    {[1, 2, 3, 4].map((i) => (
                      <Skeleton key={i} className="h-10 w-full" />
                    ))}
                  </div>
                ) : prefs ? (
                  <div className="divide-y divide-gray-100">
                    {(
                      [
                        {
                          key: 'websocket_enabled',
                          label: 'In-App notifications',
                          desc: 'Real-time alerts inside the dashboard',
                        },
                        {
                          key: 'email_enabled',
                          label: 'Email notifications',
                          desc: 'Receive updates to your email address',
                        },
                        {
                          key: 'push_enabled',
                          label: 'Browser push notifications',
                          desc: 'Desktop or mobile push alerts',
                        },
                        {
                          key: 'sms_enabled',
                          label: 'SMS notifications',
                          desc: 'Text messages to your phone number',
                        },
                      ] as const
                    ).map(({ key, label, desc }) => (
                      <div key={key} className="flex items-center justify-between py-3 first:pt-0 last:pb-0">
                        <div>
                          <p className="text-sm font-medium text-gray-900">{label}</p>
                          <p className="text-xs text-gray-500 mt-0.5">{desc}</p>
                        </div>
                        <Toggle
                          checked={!!prefs[key]}
                          onChange={(v) => updatePref.mutate({ [key]: v })}
                          disabled={updatePref.isPending}
                        />
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-sm text-gray-500">Unable to load preferences.</p>
                )}
              </CardContent>
            </Card>
          )}

          {activeTab === 'ai-sync' && (
            <div className="grid grid-cols-1 xl:grid-cols-[minmax(0,1fr)_340px] gap-6">
              <div className="space-y-5">
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <Key className="h-5 w-5" />
                      Gemini API key
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="rounded-lg border border-blue-200 bg-blue-50 p-4 text-sm text-blue-900">
                      Your Gemini key is stored on this device by default. It is not uploaded anywhere unless you explicitly enable encrypted backup below.
                    </div>
                    <div className="space-y-2">
                      <label className="text-sm font-medium text-gray-700" htmlFor="gemini-key">
                        Gemini API key
                      </label>
                      <input
                        id="gemini-key"
                        type="password"
                        value={geminiKey}
                        onChange={(event) => setGeminiKey(event.target.value)}
                        placeholder="Paste your Gemini API key"
                        className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-100"
                      />
                      <p className="text-xs text-gray-500">
                        Current status: {geminiKey.trim() ? 'stored locally on this device' : 'no key saved locally'}.
                      </p>
                    </div>
                    <div className="flex flex-wrap gap-2">
                      <Button onClick={handleSaveKeyLocally}>
                        Save locally
                      </Button>
                      <Button variant="outline" onClick={() => { setGeminiKey(''); setLocalGeminiApiKey(''); }}>
                        Remove local key
                      </Button>
                    </div>
                    {savedLocally && (
                      <p className="text-sm font-medium text-emerald-600">Saved locally on this device.</p>
                    )}
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <Cloud className="h-5 w-5" />
                      Sync and encrypted backup
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="flex items-start justify-between gap-4 rounded-lg border border-gray-200 p-4">
                      <div className="space-y-1">
                        <p className="text-sm font-medium text-gray-900">Back up Gemini key to the backend</p>
                        <p className="text-xs text-gray-500">
                          Turn this on only if you want an encrypted copy of the key stored for syncing to another device.
                        </p>
                      </div>
                      <Toggle checked={backupGeminiKey} onChange={setBackupGeminiKey} disabled={!isAuthenticated} />
                    </div>

                    {!isAuthenticated && (
                      <div className="rounded-lg border border-amber-200 bg-amber-50 p-4 text-sm text-amber-900">
                        You are currently local-only. Sign in only when you want to sync your device data and optionally store an encrypted backup of the Gemini key.
                      </div>
                    )}

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                      <div className="rounded-lg border border-gray-200 p-4">
                        <p className="text-xs uppercase tracking-wider text-gray-500">Device key</p>
                        <p className="mt-2 text-sm font-semibold text-gray-900">
                          {geminiKey.trim() ? 'Stored locally' : 'Not saved'}
                        </p>
                      </div>
                      <div className="rounded-lg border border-gray-200 p-4">
                        <p className="text-xs uppercase tracking-wider text-gray-500">Cloud backup</p>
                        <p className="mt-2 text-sm font-semibold text-gray-900">
                          {effectiveCloudSync.cloud_gemini_key_stored ? 'Encrypted backup saved' : 'No cloud backup'}
                        </p>
                      </div>
                      <div className="rounded-lg border border-gray-200 p-4">
                        <p className="text-xs uppercase tracking-wider text-gray-500">Last sync</p>
                        <p className="mt-2 text-sm font-semibold text-gray-900">
                          {effectiveCloudSync.last_synced_at ? new Date(effectiveCloudSync.last_synced_at).toLocaleString() : 'Never'}
                        </p>
                      </div>
                    </div>

                    {isAuthenticated && (
                      <div className="flex flex-wrap gap-2">
                        <Button
                          onClick={() => saveCloudSyncSettings.mutate()}
                          disabled={saveCloudSyncSettings.isPending}
                        >
                          {saveCloudSyncSettings.isPending ? 'Saving…' : 'Save sync preference'}
                        </Button>
                        <Button
                          variant="outline"
                          onClick={() => removeCloudBackup.mutate()}
                          disabled={removeCloudBackup.isPending || !effectiveCloudSync.cloud_gemini_key_stored}
                        >
                          Remove cloud backup
                        </Button>
                      </div>
                    )}
                  </CardContent>
                </Card>
              </div>

              <Card className="h-fit">
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <DatabaseZap className="h-5 w-5" />
                    How to get a free Gemini key
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4 text-sm text-gray-600">
                  <div className="rounded-lg border border-gray-200 p-4 space-y-2">
                    <p className="font-medium text-gray-900">1. Open Google AI Studio</p>
                    <p>Go to Google AI Studio and sign in with your Google account.</p>
                  </div>
                  <div className="rounded-lg border border-gray-200 p-4 space-y-2">
                    <p className="font-medium text-gray-900">2. Generate an API key</p>
                    <p>Create a new key for Gemini and copy it into the local key field on the left.</p>
                  </div>
                  <div className="rounded-lg border border-gray-200 p-4 space-y-2">
                    <p className="font-medium text-gray-900">3. Keep it local or sync it</p>
                    <p>Leave sync disabled for device-only storage, or enable encrypted cloud backup if you want it available after signing in on another device.</p>
                  </div>
                  <div className="rounded-lg border border-indigo-200 bg-indigo-50 p-4">
                    <p className="flex items-center gap-2 font-medium text-indigo-900">
                      <Lock className="h-4 w-4" />
                      Privacy note
                    </p>
                    <p className="mt-2 text-indigo-900/80">
                      The app stores your Gemini key locally by default and only sends it to the backend when you explicitly opt in.
                    </p>
                  </div>
                  <div className="space-y-2">
                    <Link
                      href="https://aistudio.google.com/app/apikey"
                      target="_blank"
                      className="inline-flex items-center gap-2 text-blue-600 hover:underline"
                    >
                      Open Google AI Studio <ExternalLink className="h-3.5 w-3.5" />
                    </Link>
                    <Link
                      href="https://ai.google.dev/gemini-api/docs/api-key"
                      target="_blank"
                      className="inline-flex items-center gap-2 text-blue-600 hover:underline"
                    >
                      Read the official Gemini API key guide <ExternalLink className="h-3.5 w-3.5" />
                    </Link>
                  </div>
                </CardContent>
              </Card>
            </div>
          )}

          {/* ── Privacy tab ─────────────────────────────────────────────── */}
          {activeTab === 'privacy' && (
            <div className="space-y-5">
              {isAuthenticated ? (
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Key className="h-5 w-5" />
                    Active Sessions
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-3">
                  <p className="text-sm text-gray-600">
                    View all devices and locations where your account is currently signed in. Revoke
                    any session you don't recognise.
                  </p>
                  <Link href="/tokens">
                    <Button variant="outline" size="sm">
                      <ExternalLink className="h-3.5 w-3.5 mr-1.5" />
                      Manage sessions
                    </Button>
                  </Link>
                </CardContent>
              </Card>
              ) : (
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <Lock className="h-5 w-5" />
                      Privacy in offline mode
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-3 text-sm text-gray-600">
                    <p>Your watchlist, portfolio, simulator sessions, notification preferences, and Gemini key stay on this device until you choose to sync.</p>
                    <p>When you sign in later, the app asks whether your Gemini key should remain local-only or be backed up to the backend in encrypted form.</p>
                  </CardContent>
                </Card>
              )}

              {isAuthenticated && (
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-red-600">
                    <ShieldAlert className="h-5 w-5" />
                    Danger Zone
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="rounded-lg border border-red-200 bg-red-50 p-4 space-y-3">
                    <div>
                      <p className="text-sm font-medium text-red-800">Deactivate account</p>
                      <p className="text-xs text-red-700 mt-0.5">
                        Signing out from all devices and disabling your account. You can reactivate
                        by contacting support.
                      </p>
                    </div>
                    <Link href="/tokens">
                      <Button variant="destructive" size="sm">
                        Revoke all sessions
                      </Button>
                    </Link>
                  </div>
                </CardContent>
              </Card>
              )}
            </div>
          )}

        </div>
      </div>
    </div>
  );
}
