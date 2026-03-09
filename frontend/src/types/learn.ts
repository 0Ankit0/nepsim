export interface LessonListItem {
  id: number;
  title: string;
  section: string;
  difficulty_level: string;
  order_index: number;
  read_time_minutes: number;
  has_quiz: boolean;
}

export interface QuizQuestion {
  id: number;
  question_text: string;
  options: string[];
  order_index: number;
  explanation?: string;
}

export interface Quiz {
  id: number;
  lesson_id: number;
  title: string;
  passing_score: number;
  time_limit_seconds?: number;
  questions: QuizQuestion[];
}

export interface LessonDetail extends LessonListItem {
  content_html: string;
  image_urls: string[];
  created_at: string;
  updated_at: string;
  quiz?: Quiz;
}

export interface QuizSubmission {
  question_id: number;
  selected_option_index: number;
}

export interface QuizResult {
  score: number;
  passed: boolean;
  total_questions: number;
  correct_answers: number;
}
