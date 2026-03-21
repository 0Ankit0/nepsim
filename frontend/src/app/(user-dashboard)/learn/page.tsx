// @ts-nocheck

'use client';

import { useLessons } from '@/hooks';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui';
import { 
  GraduationCap, BookOpen, CheckCircle2, PlayCircle, 
  ArrowRight, Award, Star, Clock, Lock
} from 'lucide-react';
import Link from 'next/link';

export default function LearnPage() {
  const { data: lessons, isLoading } = useLessons();

  // Mock categories if lessons don't have them
  const categories = [
    { id: 'basics', name: 'Trading Basics', description: 'Foundation of stock market and trading', icon: BookOpen, color: 'text-blue-600', bg: 'bg-blue-50' },
    { id: 'technical', name: 'Technical Analysis', description: 'Charts, patterns, and indicators', icon: GraduationCap, color: 'text-indigo-600', bg: 'bg-indigo-50' },
    { id: 'advanced', name: 'Advanced Strategies', description: 'Risk management and psychology', icon: Award, color: 'text-emerald-600', bg: 'bg-emerald-50' },
  ];

  return (
    <div className="max-w-5xl mx-auto space-y-10 pb-10">
      <div className="text-center space-y-2">
        <h1 className="text-3xl font-bold text-gray-900">Learning Center</h1>
        <p className="text-gray-500 max-w-2xl mx-auto">
          Master the art of NEPSE trading through our structured curriculum. 
          Complete lessons, take quizzes, and earn skill ratings.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {categories.map((cat) => (
          <Card key={cat.id} className="border-none shadow-sm hover:shadow-md transition-shadow">
            <CardContent className="p-6">
                <div className={`h-12 w-12 rounded-xl ${cat.bg} flex items-center justify-center mb-4`}>
                    <cat.icon className={`h-6 w-6 ${cat.color}`} />
                </div>
                <h3 className="text-lg font-bold text-gray-900 mb-1">{cat.name}</h3>
                <p className="text-xs text-gray-500">{cat.description}</p>
            </CardContent>
          </Card>
        ))}
      </div>

      <section className="space-y-6">
        <div className="flex items-center justify-between">
            <h2 className="text-xl font-bold text-gray-900 flex items-center gap-2">
                <Star className="h-5 w-5 text-amber-500 fill-amber-500" />
                Lessons for You
            </h2>
            <div className="text-sm font-medium text-gray-500">
                Found {lessons?.length ?? 0} modules
            </div>
        </div>

        {isLoading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {[1, 2, 3, 4].map(i => <Skeleton key={i} className="h-40 w-full rounded-xl" />)}
            </div>
        ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {(lessons ?? []).map((lesson, index) => (
                    <Card key={lesson.id} className="border-gray-100 hover:border-indigo-200 group transition-colors overflow-hidden flex flex-col">
                        <div className="h-3 bg-indigo-50" />
                        <CardContent className="p-6 flex-1 flex flex-col">
                            <div className="flex justify-between items-start mb-4">
                                <div>
                                    <span className="text-[10px] font-bold uppercase tracking-wider text-indigo-500 bg-indigo-50 px-2 py-0.5 rounded">
                                        Module {index + 1}
                                    </span>
                                    <h3 className="text-lg font-bold text-gray-900 mt-2">{lesson.title}</h3>
                                </div>
                                {lesson.is_completed ? (
                                    <CheckCircle2 className="h-5 w-5 text-emerald-500" />
                                ) : (
                                    <PlayCircle className="h-5 w-5 text-gray-300 group-hover:text-indigo-500 transition-colors" />
                                )}
                            </div>
                            <p className="text-sm text-gray-500 mb-6 flex-1 line-clamp-2">
                                {lesson.content?.substring(0, 100)}...
                            </p>
                            <div className="flex items-center justify-between mt-auto pt-4 border-t border-gray-50">
                                <div className="flex items-center gap-4">
                                    <div className="flex items-center gap-1.5 text-xs text-gray-500 font-medium">
                                        <Clock className="h-3.5 w-3.5" />
                                        15 min
                                    </div>
                                    <div className="flex items-center gap-1.5 text-xs text-gray-500 font-medium">
                                        <Award className="h-3.5 w-3.5" />
                                        Quiz
                                    </div>
                                </div>
                                <Link href={`/learn/${lesson.id}`}>
                                    <Button size="sm" variant="ghost" className="text-indigo-600 hover:text-indigo-700 hover:bg-indigo-50 gap-2">
                                        {lesson.is_completed ? 'Review' : 'Start'} <ArrowRight className="h-4 w-4" />
                                    </Button>
                                </Link>
                            </div>
                        </CardContent>
                    </Card>
                ))}
            </div>
        )}
      </section>

      <Card className="bg-slate-900 border-none rounded-2xl overflow-hidden relative shadow-xl shadow-indigo-500/10">
        <div className="absolute top-0 right-0 p-8 opacity-10">
            <GraduationCap className="h-32 w-32 text-white" />
        </div>
        <CardContent className="p-10 relative z-10 flex flex-col md:flex-row items-center justify-between gap-8">
            <div className="space-y-3">
                <h3 className="text-2xl font-bold text-white">Advanced Trading Course</h3>
                <p className="text-indigo-200/70 text-sm max-w-sm">
                    Unlock professional tools and strategies once you complete the basic technical analysis track.
                </p>
            </div>
            <Button className="bg-indigo-500 hover:bg-indigo-600 text-white border-none py-6 px-10 rounded-xl flex gap-2">
                <Lock className="h-5 w-5" />
                Coming Soon
            </Button>
        </CardContent>
      </Card>
    </div>
  );
}
