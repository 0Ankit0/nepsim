'use client';

import Link from 'next/link';
import { useMemo } from 'react';
import { Award, BookOpen, Brain, CheckCircle2, Clock, GraduationCap, Hammer, Star } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui';
import { useLessons } from '@/hooks';

const sectionStyles: Record<string, { icon: typeof BookOpen; color: string; bg: string; border: string }> = {
  Foundations: { icon: BookOpen, color: 'text-blue-700', bg: 'bg-blue-50', border: 'border-blue-100' },
  Chartcraft: { icon: GraduationCap, color: 'text-indigo-700', bg: 'bg-indigo-50', border: 'border-indigo-100' },
  Indicators: { icon: Brain, color: 'text-emerald-700', bg: 'bg-emerald-50', border: 'border-emerald-100' },
  Practice: { icon: Hammer, color: 'text-amber-700', bg: 'bg-amber-50', border: 'border-amber-100' },
};

const levelTone: Record<string, string> = {
  beginner: 'bg-emerald-50 text-emerald-700',
  intermediate: 'bg-amber-50 text-amber-700',
  advanced: 'bg-rose-50 text-rose-700',
};

export default function LearnPage() {
  const { data: sections, isLoading } = useLessons();

  const stats = useMemo(() => {
    const lessons = sections?.flatMap((section) => section.lessons) ?? [];
    const beginnerCount = lessons.filter((lesson) => lesson.difficulty_level === 'beginner').length;
    return {
      totalSections: sections?.length ?? 0,
      totalLessons: lessons.length,
      beginnerCount,
    };
  }, [sections]);

  return (
    <div className="mx-auto max-w-6xl space-y-8 pb-12">
      <section className="rounded-3xl bg-slate-950 px-8 py-10 text-white shadow-xl">
        <div className="grid gap-8 lg:grid-cols-[1.4fr_0.9fr]">
          <div className="space-y-4">
            <span className="inline-flex rounded-full bg-white/10 px-3 py-1 text-xs font-semibold uppercase tracking-[0.2em] text-slate-200">
              Learn From Zero
            </span>
            <h1 className="text-3xl font-bold sm:text-4xl">A step-by-step technical analysis path for first-time learners.</h1>
            <p className="max-w-2xl text-sm leading-6 text-slate-300 sm:text-base">
              Start with the basics, read real examples, and practice by hand before you rely on indicators.
              Each lesson is built to help you understand what the chart is saying and why it matters in a live simulation.
            </p>
          </div>
          <div className="grid grid-cols-3 gap-3">
            <StatCard label="Sections" value={stats.totalSections} />
            <StatCard label="Lessons" value={stats.totalLessons} />
            <StatCard label="Beginner" value={stats.beginnerCount} />
          </div>
        </div>
      </section>

      <section className="grid gap-4 md:grid-cols-3">
        <FeatureCard
          icon={BookOpen}
          title="Start simple"
          body="The first lessons explain markets, candles, support, resistance, and trend without assuming prior knowledge."
        />
        <FeatureCard
          icon={Star}
          title="Study real examples"
          body="Each module connects the idea to realistic price behavior so learners can see what the concept looks like on a chart."
        />
        <FeatureCard
          icon={Hammer}
          title="Practice by hand"
          body="Lessons include notebook-style exercises so learners can pause, label candles, mark levels, and form their own read."
        />
      </section>

      {isLoading ? (
        <div className="space-y-6">
          {Array.from({ length: 3 }).map((_, index) => (
            <Skeleton key={index} className="h-64 w-full rounded-3xl" />
          ))}
        </div>
      ) : (
        <div className="space-y-8">
          {(sections ?? []).map((section) => {
            const style = sectionStyles[section.section] ?? sectionStyles.Foundations;
            return (
              <section key={section.section} className={`rounded-3xl border ${style.border} bg-white p-6 shadow-sm`}>
                <div className="mb-6 flex items-center gap-3">
                  <div className={`flex h-12 w-12 items-center justify-center rounded-2xl ${style.bg}`}>
                    <style.icon className={`h-6 w-6 ${style.color}`} />
                  </div>
                  <div>
                    <h2 className="text-xl font-bold text-gray-900">{section.section}</h2>
                    <p className="text-sm text-gray-500">{section.lessons.length} lesson{section.lessons.length === 1 ? '' : 's'} in this track</p>
                  </div>
                </div>

                <div className="grid gap-4 md:grid-cols-2">
                  {section.lessons.map((lesson, index) => (
                    <Card key={lesson.id} className="border-gray-100 shadow-sm">
                      <CardContent className="space-y-4 p-5">
                        <div className="flex items-start justify-between gap-4">
                          <div>
                            <span className="text-xs font-semibold uppercase tracking-[0.2em] text-gray-400">
                              Lesson {index + 1}
                            </span>
                            <h3 className="mt-2 text-lg font-bold text-gray-900">{lesson.title}</h3>
                          </div>
                          {lesson.has_quiz ? (
                            <CheckCircle2 className="h-5 w-5 text-emerald-500" />
                          ) : (
                            <Award className="h-5 w-5 text-gray-300" />
                          )}
                        </div>

                        <div className="flex flex-wrap gap-2 text-xs font-medium">
                          <span className={`rounded-full px-2.5 py-1 ${levelTone[lesson.difficulty_level] ?? 'bg-gray-100 text-gray-700'}`}>
                            {lesson.difficulty_level}
                          </span>
                          <span className="inline-flex items-center gap-1 rounded-full bg-gray-50 px-2.5 py-1 text-gray-600">
                            <Clock className="h-3.5 w-3.5" />
                            {lesson.read_time_minutes} min
                          </span>
                          {lesson.has_quiz && (
                            <span className="rounded-full bg-indigo-50 px-2.5 py-1 text-indigo-700">
                              Quiz included
                            </span>
                          )}
                        </div>

                        <Link href={`/learn/${lesson.id}`}>
                          <Button variant="outline" className="w-full justify-between">
                            Open Lesson
                            <GraduationCap className="h-4 w-4" />
                          </Button>
                        </Link>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </section>
            );
          })}
        </div>
      )}
    </div>
  );
}

function FeatureCard({
  icon: Icon,
  title,
  body,
}: {
  icon: typeof BookOpen;
  title: string;
  body: string;
}) {
  return (
    <Card className="border-gray-100 shadow-sm">
      <CardContent className="space-y-3 p-5">
        <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-slate-100">
          <Icon className="h-5 w-5 text-slate-700" />
        </div>
        <h2 className="text-lg font-bold text-gray-900">{title}</h2>
        <p className="text-sm leading-6 text-gray-600">{body}</p>
      </CardContent>
    </Card>
  );
}

function StatCard({ label, value }: { label: string; value: number }) {
  return (
    <div className="rounded-2xl border border-white/10 bg-white/5 p-4">
      <p className="text-xs uppercase tracking-[0.18em] text-slate-400">{label}</p>
      <p className="mt-2 text-3xl font-black">{value}</p>
    </div>
  );
}
