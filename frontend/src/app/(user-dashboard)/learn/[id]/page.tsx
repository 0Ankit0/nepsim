'use client';

import Link from 'next/link';
import { useMemo, useState } from 'react';
import { ArrowLeft, ArrowRight, Check, Trophy, X } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui';
import { useLessonDetail, useSubmitQuiz } from '@/hooks';

const parseOptions = (options: string[] | string): string[] => {
  if (Array.isArray(options)) {
    return options;
  }

  try {
    const parsed = JSON.parse(options);
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
};

export default function LessonDetailPage({ params }: { params: { id: string } }) {
  const lessonId = Number.parseInt(params.id, 10);
  const { data: lesson, isLoading } = useLessonDetail(lessonId);
  const submitQuiz = useSubmitQuiz();
  const [mode, setMode] = useState<'reading' | 'quiz' | 'result'>('reading');
  const [answers, setAnswers] = useState<Record<number, number>>({});
  const [quizStartedAt, setQuizStartedAt] = useState<number | null>(null);
  const [quizResult, setQuizResult] = useState<Awaited<ReturnType<typeof submitQuiz.mutateAsync>> | null>(null);

  const normalizedQuestions = useMemo(
    () =>
      (lesson?.quiz?.questions ?? []).map((question) => ({
        ...question,
        normalizedOptions: parseOptions(question.options),
      })),
    [lesson?.quiz?.questions],
  );

  if (isLoading) {
    return <Skeleton className="h-[80vh] w-full rounded-3xl" />;
  }

  if (!lesson) {
    return <div className="py-20 text-center text-gray-500">Lesson not found.</div>;
  }

  const questionCount = normalizedQuestions.length;

  const openQuiz = () => {
    setQuizStartedAt(Date.now());
    setMode('quiz');
  };

  const submit = async () => {
    if (!lesson.quiz) {
      return;
    }

    const timeTakenSeconds = quizStartedAt ? Math.max(1, Math.round((Date.now() - quizStartedAt) / 1000)) : undefined;
    const result = await submitQuiz.mutateAsync({
      quizId: lesson.quiz.id,
      payload: {
        answers,
        time_taken_seconds: timeTakenSeconds,
      },
    });

    setQuizResult(result);
    setMode('result');
  };

  return (
    <div className="mx-auto max-w-4xl space-y-8 pb-16">
      <Link href="/learn" className="inline-flex items-center gap-1 text-sm font-medium text-gray-500 hover:text-indigo-600">
        <ArrowLeft className="h-4 w-4" />
        Back to curriculum
      </Link>

      <section className="rounded-3xl border border-gray-100 bg-white p-8 shadow-sm">
        <div className="flex flex-wrap items-center gap-3 text-xs font-medium">
          <span className="rounded-full bg-indigo-50 px-3 py-1 text-indigo-700">{lesson.section}</span>
          <span className="rounded-full bg-gray-50 px-3 py-1 text-gray-600">{lesson.difficulty_level}</span>
          <span className="rounded-full bg-gray-50 px-3 py-1 text-gray-600">{lesson.read_time_minutes} min read</span>
        </div>
        <h1 className="mt-4 text-3xl font-bold text-gray-900">{lesson.title}</h1>
        <p className="mt-3 max-w-2xl text-sm leading-6 text-gray-600">
          Work through the lesson slowly, then test yourself. The goal is to understand what you see on a chart before you act on it.
        </p>
      </section>

      {mode === 'reading' && (
        <Card className="border-gray-100 shadow-sm">
          <CardContent className="p-8">
            <div className="mb-8 rounded-2xl bg-indigo-50 p-4 text-sm text-indigo-900">
              Focus on the examples and practice prompts in this lesson. If you can explain the setup in your own words, you are ready for the quiz.
            </div>
            <article
              className="prose prose-slate max-w-none prose-headings:text-gray-900 prose-p:text-gray-700 prose-li:text-gray-700"
              dangerouslySetInnerHTML={{ __html: lesson.content_html }}
            />

            {lesson.quiz && (
              <div className="mt-10 flex items-center justify-between rounded-2xl border border-indigo-100 bg-indigo-50 px-5 py-4">
                <div>
                  <p className="text-sm font-semibold text-indigo-900">Ready to check your understanding?</p>
                  <p className="text-xs text-indigo-700">{questionCount} questions with instant feedback.</p>
                </div>
                <Button className="gap-2" onClick={openQuiz}>
                  Take Quiz
                  <ArrowRight className="h-4 w-4" />
                </Button>
              </div>
            )}
          </CardContent>
        </Card>
      )}

      {mode === 'quiz' && (
        <div className="space-y-6">
          <Card className="border-indigo-100 bg-indigo-50 shadow-sm">
            <CardContent className="flex items-center justify-between p-5">
              <div>
                <h2 className="text-lg font-bold text-indigo-950">Lesson Quiz</h2>
                <p className="text-sm text-indigo-700">Answer every question, then submit for feedback and explanations.</p>
              </div>
              <span className="rounded-full bg-white px-3 py-1 text-xs font-semibold text-indigo-700">
                {Object.keys(answers).length}/{questionCount} answered
              </span>
            </CardContent>
          </Card>

          {normalizedQuestions.map((question, index) => (
            <Card key={question.id} className="border-gray-100 shadow-sm">
              <CardHeader>
                <CardTitle className="text-base">
                  {index + 1}. {question.question_text}
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {question.normalizedOptions.map((option, optionIndex) => {
                  const selected = answers[question.id] === optionIndex;
                  return (
                    <button
                      key={optionIndex}
                      type="button"
                      className={`flex w-full items-center gap-3 rounded-2xl border px-4 py-3 text-left transition-colors ${
                        selected ? 'border-indigo-600 bg-indigo-50 text-indigo-900' : 'border-gray-200 bg-white text-gray-700 hover:border-indigo-200 hover:bg-gray-50'
                      }`}
                      onClick={() => setAnswers((current) => ({ ...current, [question.id]: optionIndex }))}
                    >
                      <span
                        className={`flex h-5 w-5 items-center justify-center rounded-full border ${
                          selected ? 'border-indigo-600 bg-indigo-600 text-white' : 'border-gray-300'
                        }`}
                      >
                        {selected && <Check className="h-3 w-3" />}
                      </span>
                      <span className="text-sm font-medium">{option}</span>
                    </button>
                  );
                })}
              </CardContent>
            </Card>
          ))}

          <div className="flex items-center justify-between">
            <Button variant="ghost" onClick={() => setMode('reading')}>
              Back to lesson
            </Button>
            <Button disabled={Object.keys(answers).length < questionCount || submitQuiz.isPending} onClick={submit}>
              {submitQuiz.isPending ? 'Submitting...' : 'Submit quiz'}
            </Button>
          </div>
        </div>
      )}

      {mode === 'result' && quizResult && (
        <div className="space-y-6">
          <Card className="border-gray-100 shadow-sm">
            <CardContent className="space-y-5 p-8 text-center">
              <div className={`mx-auto flex h-20 w-20 items-center justify-center rounded-full ${quizResult.passed ? 'bg-emerald-50 text-emerald-600' : 'bg-rose-50 text-rose-600'}`}>
                {quizResult.passed ? <Trophy className="h-10 w-10" /> : <X className="h-10 w-10" />}
              </div>
              <div>
                <h2 className="text-2xl font-bold text-gray-900">{quizResult.passed ? 'You passed' : 'Keep practicing'}</h2>
                <p className="mt-2 text-sm text-gray-600">
                  Score: {quizResult.score}% · {quizResult.correct_count}/{quizResult.total_questions} correct · Passing score {quizResult.passing_score}%
                </p>
              </div>
            </CardContent>
          </Card>

          <div className="space-y-4">
            {quizResult.question_results.map((question) => (
              <Card key={question.question_id} className="border-gray-100 shadow-sm">
                <CardContent className="space-y-3 p-5">
                  <div className="flex items-start justify-between gap-4">
                    <div>
                      <h3 className="font-semibold text-gray-900">{question.question_text}</h3>
                      <p className={`mt-1 text-sm font-medium ${question.is_correct ? 'text-emerald-600' : 'text-rose-600'}`}>
                        {question.is_correct ? 'Correct answer' : 'Review this concept'}
                      </p>
                    </div>
                  </div>
                  <p className="text-sm leading-6 text-gray-600">{question.explanation}</p>
                </CardContent>
              </Card>
            ))}
          </div>

          <div className="flex gap-3">
            <Button
              variant="outline"
              onClick={() => {
                setAnswers({});
                setQuizStartedAt(null);
                setQuizResult(null);
                setMode('reading');
              }}
            >
              Review lesson
            </Button>
            <Link href="/learn">
              <Button>Back to academy</Button>
            </Link>
          </div>
        </div>
      )}
    </div>
  );
}
