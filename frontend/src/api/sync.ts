import { apiClient } from '@/lib/api-client';

export interface UserSyncSettingsResponse {
  backup_gemini_key_to_cloud: boolean;
  cloud_gemini_key_stored: boolean;
  last_synced_at: string | null;
}

export interface UpdateUserSyncSettingsPayload {
  backup_gemini_key_to_cloud: boolean;
  gemini_api_key?: string | null;
}

export const syncApi = {
  getSettings: async (): Promise<UserSyncSettingsResponse> => {
    const { data } = await apiClient.get('/users/me/sync-settings');
    return data;
  },
  updateSettings: async (
    payload: UpdateUserSyncSettingsPayload
  ): Promise<UserSyncSettingsResponse> => {
    const { data } = await apiClient.put('/users/me/sync-settings', payload);
    return data;
  },
  removeGeminiKeyBackup: async (): Promise<UserSyncSettingsResponse> => {
    const { data } = await apiClient.delete('/users/me/sync-settings/gemini-key');
    return data;
  },
};
