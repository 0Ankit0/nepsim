'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/api-client';
import type { CurriculumSection, LessonDetail, QuizResult, QuizSubmissionPayload } from '@/types';

export function useLessons() {
  return useQuery({
    queryKey: ['lessons'],
    queryFn: async () => {
      const response = await apiClient.get<CurriculumSection[]>('/learn/lessons');
      return response.data;
    },
  });
}

export function useLessonDetail(id: number) {
  return useQuery({
    queryKey: ['lessons', id],
    queryFn: async () => {
      const response = await apiClient.get<LessonDetail>(`/learn/lessons/${id}`);
      return response.data;
    },
    enabled: !!id,
  });
}

export function useCreateLesson() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (data: Partial<LessonDetail>) => {
      const response = await apiClient.post<LessonDetail>('/learn/lessons/', data);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['lessons'] });
    },
  });
}

export function useUpdateLesson() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, data }: { id: number; data: Partial<LessonDetail> }) => {
      const response = await apiClient.patch<LessonDetail>(`/learn/lessons/${id}`, data);
      return response.data;
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['lessons', variables.id] });
      queryClient.invalidateQueries({ queryKey: ['lessons'] });
    },
  });
}

export function useDeleteLesson() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (id: number) => {
      await apiClient.delete(`/learn/lessons/${id}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['lessons'] });
    },
  });
}

export function useSubmitQuiz() {
  return useMutation({
    mutationFn: async ({ quizId, payload }: { quizId: number; payload: QuizSubmissionPayload }) => {
      const response = await apiClient.post<QuizResult>(`/learn/quizzes/${quizId}/submit`, payload);
      return response.data;
    },
  });
}
