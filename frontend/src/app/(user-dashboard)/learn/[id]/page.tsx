// @ts-nocheck

'use client';

import { useState } from 'react';
import { useLessonDetail, useSubmitQuiz } from '@/hooks';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui';
import { 
  ArrowLeft, BookOpen, GraduationCap, PlayCircle, 
  CheckCircle2, AlertCircle, ArrowRight, Save, 
  Check, X, Trophy
} from 'lucide-react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';

export default function LessonDetailPage({ params }: { params: { id: string } }) {
  const id = parseInt(params.id);
  const router = useRouter();
  const { data: lesson, isLoading } = useLessonDetail(id);
  const submitQuiz = useSubmitQuiz();
  
  const [mode, setMode] = useState<'reading' | 'quiz' | 'result'>('reading');
  const [answers, setAnswers] = useState<Record<number, number>>({});
  const [quizResult, setQuizResult] = useState<any>(null);

  if (isLoading) return <Skeleton className="h-[80vh] w-full" />;
  if (!lesson) return <div className="text-center py-20 text-gray-500">Lesson not found.</div>;

  const handleOptionSelect = (questionId: number, optionIndex: number) => {
    setAnswers(prev => ({ ...prev, [questionId]: optionIndex }));
  };

  const handleSubmit = async () => {
    if (!lesson.quiz) return;
    
    // Format submissions for the API
    const submissions = Object.entries(answers).map(([qId, oIdx]) => ({
      question_id: parseInt(qId),
      selected_option: oIdx
    }));

    try {
        const result = await submitQuiz.mutateAsync({ 
            quizId: lesson.quiz.id, 
            submissions 
        } as any);
        setQuizResult(result);
        setMode('result');
    } catch (error) {
        console.error('Failed to submit quiz', error);
    }
  };

  const isReading = mode === 'reading';
  const isQuiz = mode === 'quiz';
  const isResult = mode === 'result';

  return (
    <div className="max-w-4xl mx-auto space-y-8 pb-20">
      <Link href="/learn" className="inline-flex items-center text-sm font-medium text-gray-500 hover:text-indigo-600 transition-colors gap-1">
        <ArrowLeft className="h-4 w-4" />
        Back to Curriculum
      </Link>

      <div className="space-y-4">
        <div className="flex items-center gap-3">
             <div className="h-10 w-10 rounded-lg bg-indigo-50 flex items-center justify-center text-indigo-600">
                <BookOpen className="h-6 w-6" />
             </div>
             <div>
                <span className="text-[10px] font-bold uppercase tracking-wider text-gray-400">Lesson Module</span>
                <h1 className="text-3xl font-bold text-gray-900">{lesson.title}</h1>
             </div>
        </div>
      </div>

      {isReading && (
        <Card className="border-none shadow-sm overflow-hidden bg-white">
            <CardContent className="p-8 prose prose-indigo max-w-none">
                <div className="mb-8 p-4 bg-indigo-50 border-l-4 border-indigo-500 rounded-r-lg text-indigo-900 text-sm">
                    <strong>Learning Objective:</strong> By the end of this lesson, you will understand the core concepts of {lesson.title} and how to apply them in your NEPSE simulations.
                </div>
                <div dangerouslySetInnerHTML={{ __html: lesson.content }} className="text-gray-700 leading-relaxed" />
                
                <div className="mt-12 pt-8 border-t border-gray-100 flex justify-between items-center">
                    <div className="text-sm text-gray-500 italic">
                        Ready to test your knowledge?
                    </div>
                    <Button 
                        onClick={() => setMode('quiz')}
                        className="bg-indigo-600 hover:bg-indigo-700 text-white gap-2 px-8 py-6 rounded-xl font-bold"
                    >
                        Take the Quiz <ArrowRight className="h-5 w-5" />
                    </Button>
                </div>
            </CardContent>
        </Card>
      )}

      {isQuiz && (
        <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <div className="bg-indigo-600 text-white p-6 rounded-2xl shadow-lg shadow-indigo-200">
                <h2 className="text-xl font-bold flex items-center gap-2">
                    <GraduationCap className="h-6 w-6" />
                    Lesson Quiz
                </h2>
                <p className="text-indigo-100/70 text-sm mt-1">Answer all questions correctly to complete this module.</p>
            </div>

            <div className="space-y-6">
                {(lesson.quiz?.questions ?? []).map((q: any, idx: number) => (
                    <Card key={q.id} className="border-gray-100 shadow-sm overflow-hidden">
                        <CardHeader className="bg-gray-50 py-4 px-6">
                            <CardTitle className="text-base font-bold text-gray-900">
                                {idx + 1}. {q.question_text || q.text}
                            </CardTitle>
                        </CardHeader>
                        <CardContent className="p-6 space-y-3">
                            {(q.options || []).map((option: string, oIdx: number) => {
                                const isSelected = answers[q.id] === oIdx;
                                return (
                                    <div 
                                        key={oIdx}
                                        onClick={() => handleOptionSelect(q.id, oIdx)}
                                        className={`p-4 rounded-xl border-2 transition-all cursor-pointer flex items-center gap-4 ${
                                            isSelected 
                                            ? 'border-indigo-600 bg-indigo-50 text-indigo-900' 
                                            : 'border-gray-50 bg-white text-gray-700 hover:border-gray-200 hover:bg-gray-50'
                                        }`}
                                    >
                                        <div className={`h-5 w-5 rounded-full border-2 flex items-center justify-center flex-shrink-0 ${
                                            isSelected ? 'border-indigo-600 bg-indigo-600 text-white' : 'border-gray-300 bg-white'
                                        }`}>
                                            {isSelected && <Check className="h-3 w-3" />}
                                        </div>
                                        <span className="text-sm font-medium">{option}</span>
                                    </div>
                                );
                            })}
                        </CardContent>
                    </Card>
                ))}
            </div>

            <div className="flex justify-between items-center pt-8 border-t border-gray-100">
                <Button variant="ghost" onClick={() => setMode('reading')} className="text-gray-500 font-medium font-bold">
                    Back to Content
                </Button>
                <Button 
                    onClick={handleSubmit}
                    disabled={Object.keys(answers).length < (lesson.quiz?.questions?.length || 0) || submitQuiz.isPending}
                    className="bg-indigo-600 hover:bg-indigo-700 text-white px-10 py-6 rounded-xl font-bold shadow-lg shadow-indigo-100 disabled:opacity-50"
                >
                    {submitQuiz.isPending ? 'Submitting...' : 'Submit Answers'}
                </Button>
            </div>
        </div>
      )}

      {isResult && quizResult && (
        <div className="text-center py-12 space-y-8 animate-in zoom-in-95 duration-500">
            <div className={`h-32 w-32 rounded-full flex items-center justify-center mx-auto shadow-2xl ${quizResult.passed ? 'bg-emerald-50 text-emerald-600 shadow-emerald-100' : 'bg-rose-50 text-rose-600 shadow-rose-100'}`}>
                {quizResult.passed ? <Trophy className="h-16 w-16" /> : <X className="h-16 w-16" />}
            </div>
            
            <div className="space-y-2">
                <h2 className="text-3xl font-bold text-gray-900">
                    {quizResult.passed ? 'Great Job!' : 'Better Luck Next Time'}
                </h2>
                <p className="text-gray-500 max-w-sm mx-auto">
                    {quizResult.passed 
                        ? 'You have successfully completed this module. You are one step closer to mastering the market!' 
                        : 'Review the content once more and try again. Practice makes perfect!'}
                </p>
            </div>

            <div className="flex justify-center gap-10 py-6">
                <div>
                    <p className="text-[10px] font-bold uppercase text-gray-400 mb-1">Your Score</p>
                    <p className={`text-4xl font-black ${quizResult.passed ? 'text-emerald-600' : 'text-rose-600'}`}>
                        {quizResult.score}%
                    </p>
                </div>
                <div className="w-px bg-gray-100" />
                <div>
                    <p className="text-[10px] font-bold uppercase text-gray-400 mb-1">Status</p>
                    <p className={`text-sm font-bold mt-2 uppercase px-3 py-1 rounded-full ${quizResult.passed ? 'bg-emerald-100 text-emerald-700' : 'bg-rose-100 text-rose-700'}`}>
                        {quizResult.passed ? 'Passed' : 'Failed'}
                    </p>
                </div>
            </div>

            <div className="flex flex-col md:flex-row justify-center gap-4 pt-4">
                <Button 
                    variant="outline" 
                    onClick={() => {
                        setAnswers({});
                        setMode('reading');
                    }}
                    className="font-bold py-6 px-10 border-gray-200"
                >
                    Review Content
                </Button>
                <Link href="/learn">
                    <Button className="font-bold py-6 px-10 bg-indigo-600 hover:bg-indigo-700 text-white">
                        Back to Academy
                    </Button>
                </Link>
            </div>
        </div>
      )}
    </div>
  );
}
