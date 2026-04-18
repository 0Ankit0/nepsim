'use client';

import { hasStoredAuthTokens } from '@/lib/api-client';
import { useAuthStore } from '@/store/auth-store';

export function useAuthSession() {
  const { user, isAuthenticated: hasAuthenticatedUser, _hasHydrated } = useAuthStore();

  return {
    user,
    isHydrated: _hasHydrated,
    isAuthenticated: _hasHydrated && (hasAuthenticatedUser || hasStoredAuthTokens()),
  };
}
