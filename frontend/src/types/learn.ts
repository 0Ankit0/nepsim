export interface LessonSummary {
  id: number;
  title: string;
  section: string;
  difficulty_level: string;
  order_index: number;
  read_time_minutes: number;
  has_quiz: boolean;
}

export interface CurriculumSection {
  section: string;
  lessons: LessonSummary[];
}

export interface QuizQuestion {
  id: number;
  question_text: string;
  options: string | string[];
  order_index: number;
  explanation?: string;
}

export interface Quiz {
  id: number;
  lesson_id: number;
  title: string;
  passing_score: number;
  time_limit_seconds?: number | null;
  questions: QuizQuestion[];
}

export interface LessonDetail {
  id: number;
  title: string;
  section: string;
  content_html: string;
  image_urls?: string | string[] | null;
  difficulty_level: string;
  read_time_minutes: number;
  quiz?: Quiz | null;
  created_at: string;
  updated_at: string;
}

export interface QuizSubmissionPayload {
  answers: Record<number, number>;
  time_taken_seconds?: number;
}

export interface QuizQuestionResult {
  question_id: number;
  question_text: string;
  selected_option?: number;
  correct_option: number;
  is_correct: boolean;
  explanation: string;
}

export interface QuizResult {
  quiz_id: number;
  lesson_id: number;
  score: number;
  passed: boolean;
  passing_score: number;
  correct_count: number;
  total_questions: number;
  question_results: QuizQuestionResult[];
}
