'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/api-client';
import { hasStoredAuthTokens } from '@/lib/api-client';
import {
  getOfflineNotifications,
  getOfflineNotificationPreferences,
  markAllOfflineNotificationsRead,
  markOfflineNotificationRead,
  updateOfflineNotificationPreferences,
} from '@/lib/offline-data';
import type {
  Notification,
  NotificationList,
  NotificationPreference,
  NotificationPreferenceUpdate,
} from '@/types';

export function useNotifications(params?: { unread_only?: boolean; skip?: number; limit?: number }) {
  const isAuthenticated = hasStoredAuthTokens();
  return useQuery({
    queryKey: ['notifications', params],
    queryFn: async () => {
      if (!isAuthenticated) {
        return getOfflineNotifications(params);
      }

      const response = await apiClient.get<NotificationList>('/notifications/', { params });
      return response.data;
    },
  });
}

export function useGetNotification(id: number) {
  return useQuery({
    queryKey: ['notifications', id],
    queryFn: async () => {
      const response = await apiClient.get<Notification>(`/notifications/${id}/`);
      return response.data;
    },
    enabled: !!id,
  });
}

export function useMarkNotificationRead() {
  const queryClient = useQueryClient();
  const isAuthenticated = hasStoredAuthTokens();
  return useMutation({
    mutationFn: async (id: number) => {
      if (!isAuthenticated) {
        return markOfflineNotificationRead(id);
      }

      const response = await apiClient.patch<Notification>(`/notifications/${id}/read/`);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notifications'] });
    },
  });
}

export function useMarkAllNotificationsRead() {
  const queryClient = useQueryClient();
  const isAuthenticated = hasStoredAuthTokens();
  return useMutation({
    mutationFn: async () => {
      if (!isAuthenticated) {
        return markAllOfflineNotificationsRead();
      }

      const response = await apiClient.patch('/notifications/read-all/');
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notifications'] });
    },
  });
}

export function useDeleteNotification() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: number) => {
      await apiClient.delete(`/notifications/${id}/`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notifications'] });
    },
  });
}

/** Create a notification (superuser only). */
export function useCreateNotification() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (data: {
      user_id: number;
      title: string;
      body: string;
      type?: string;
    }) => {
      const response = await apiClient.post('/notifications/', data);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notifications'] });
    },
  });
}

// ── Notification Preferences ────────────────────────────────────────────────

export function useNotificationPreferences() {
  const isAuthenticated = hasStoredAuthTokens();
  return useQuery({
    queryKey: ['notification-preferences'],
    queryFn: async () => {
      if (!isAuthenticated) {
        return getOfflineNotificationPreferences();
      }

      const response = await apiClient.get<NotificationPreference>(
        '/notifications/preferences/'
      );
      return response.data;
    },
  });
}

export function useUpdateNotificationPreferences() {
  const queryClient = useQueryClient();
  const isAuthenticated = hasStoredAuthTokens();
  return useMutation({
    mutationFn: async (data: NotificationPreferenceUpdate) => {
      if (!isAuthenticated) {
        return updateOfflineNotificationPreferences(data);
      }

      const response = await apiClient.patch<NotificationPreference>(
        '/notifications/preferences/',
        data
      );
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notification-preferences'] });
    },
  });
}

export function useRegisterPushSubscription() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (data: { endpoint: string; p256dh: string; auth: string }) => {
      const response = await apiClient.put<NotificationPreference>(
        '/notifications/preferences/push-subscription/',
        data
      );
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notification-preferences'] });
    },
  });
}

export function useRemovePushSubscription() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async () => {
      await apiClient.delete('/notifications/preferences/push-subscription/');
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notification-preferences'] });
    },
  });
}
