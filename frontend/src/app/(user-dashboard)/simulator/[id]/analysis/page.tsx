'use client';

import { useSimulationAnalysis, useSimulation } from '@/hooks/useSimulator';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui';
import { 
  Brain, CheckCircle2, AlertTriangle, Target, 
  ArrowLeft, Star, TrendingUp, TrendingDown,
  Info, BarChart3, Clock, Zap, MessageSquare
} from 'lucide-react';
import Link from 'next/link';
import { useState, useEffect } from 'react';

export default function AIAnalysisPage({ params }: { params: { id: string } }) {
  const id = parseInt(params.id);
  const { data: analysis, isLoading, error } = useSimulationAnalysis(id);
  const { data: sim } = useSimulation(id);
  
  const [loadingMsgIdx, setLoadingMsgIdx] = useState(0);
  const loadingMessages = [
    "Synthesizing your trading patterns...",
    "Comparing your moves with market optimality...",
    "Calculating counterfactual possibilities...",
    "Generating personalized feedback...",
    "Almost there! Just polishing the insights..."
  ];

  useEffect(() => {
    if (isLoading) {
      const interval = setInterval(() => {
        setLoadingMsgIdx(prev => (prev + 1) % loadingMessages.length);
      }, 3000);
      return () => clearInterval(interval);
    }
  }, [isLoading]);

  if (isLoading) return (
    <div className="flex flex-col items-center justify-center min-h-[60vh] space-y-8">
        <div className="relative">
            <div className="h-24 w-24 rounded-full border-4 border-indigo-100 border-t-indigo-600 animate-spin" />
            <Brain className="h-10 w-10 text-indigo-600 absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2" />
        </div>
        <div className="text-center space-y-2">
            <h2 className="text-xl font-bold text-gray-900">AI is Analyzing Your Performance</h2>
            <p className="text-gray-500 animate-pulse">{loadingMessages[loadingMsgIdx]}</p>
        </div>
    </div>
  );

  if (error || !analysis) return (
    <div className="text-center py-20 space-y-4">
        <AlertTriangle className="h-12 w-12 text-amber-500 mx-auto" />
        <h2 className="text-xl font-bold">Analysis not ready yet or an error occurred</h2>
        <p className="text-gray-500">Please try again in a few moments.</p>
        <Link href={`/simulator/${id}`}>
            <Button variant="outline">Back to Dashboard</Button>
        </Link>
    </div>
  );

  const scores = [analysis.timing_score, analysis.selection_score, analysis.risk_score, analysis.patience_score].filter(s => s != null) as number[];
  const rating = scores.length > 0 ? Math.round(scores.reduce((a, b) => a + b, 0) / scores.length) : 0;
  const ratingColor = rating >= 80 ? 'text-emerald-500' : rating >= 50 ? 'text-amber-500' : 'text-rose-500';

  return (
    <div className="max-w-6xl mx-auto space-y-8 pb-20 mt-4">
      <Link href={`/simulator/${id}`} className="inline-flex items-center text-sm font-medium text-gray-500 hover:text-indigo-600 transition-colors gap-1">
        <ArrowLeft className="h-4 w-4" />
        Back to Simulation {id}
      </Link>

      <div className="flex flex-col md:flex-row gap-8 items-start">
        {/* Left Column: Summary & Rating */}
        <div className="md:w-1/3 space-y-8">
            <Card className="border-none shadow-lg bg-indigo-600 text-white overflow-hidden relative">
                <div className="absolute -right-4 -bottom-4 opacity-10">
                    <Brain className="h-40 w-40" />
                </div>
                <CardContent className="p-8 relative z-10 space-y-6">
                    <div>
                        <span className="text-[10px] font-bold uppercase tracking-widest text-indigo-200">AI Performance Score</span>
                        <div className="flex items-baseline gap-2 mt-2">
                            <span className="text-6xl font-black">{rating}</span>
                            <span className="text-xl text-indigo-200">/ 100</span>
                        </div>
                    </div>
                    <div className="h-2 w-full bg-indigo-900/30 rounded-full overflow-hidden">
                        <div className="h-full bg-white rounded-full transition-all duration-1000" style={{ width: `${rating}%` }} />
                    </div>
                    <p className="text-sm text-indigo-100 italic">
                        "Your trading shows strong {rating >= 70 ? 'strategic depth' : 'potential'}, specifically in your {rating >= 50 ? 'timing' : 'sector selection'}."
                    </p>
                </CardContent>
            </Card>

            <Card className="border-gray-100 shadow-sm">
                <CardHeader>
                    <CardTitle className="text-sm flex items-center gap-2">
                        <Zap className="h-4 w-4 text-amber-500" />
                        Executive Summary
                    </CardTitle>
                </CardHeader>
                <CardContent className="text-sm text-gray-600 leading-relaxed">
                    {analysis.summary_narrative || "No summary available."}
                </CardContent>
            </Card>
        </div>

        {/* Right Column: Detailed Insights */}
        <div className="flex-1 space-y-8">
            <section className="space-y-4">
                <h2 className="text-lg font-bold text-gray-900 flex items-center gap-2">
                    <CheckCircle2 className="h-5 w-5 text-emerald-500" />
                    What You Did Right
                </h2>
                <div className="grid grid-cols-1 gap-4">
                    {analysis.what_you_did_right?.map((section, idx) => (
                        <Card key={idx} className="border-l-4 border-l-emerald-500 border-gray-100 hover:shadow-md transition-shadow">
                            <CardContent className="p-5">
                                <h3 className="font-bold text-gray-900">{section.title}</h3>
                                <p className="text-sm text-gray-500 mt-1">{section.detail}</p>
                                {section.impact_pct != null && (
                                    <div className="mt-4 flex items-center gap-2">
                                        <span className="text-[10px] font-bold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded">
                                            Est. Impact: +{section.impact_pct}%
                                        </span>
                                    </div>
                                )}
                            </CardContent>
                        </Card>
                    ))}
                </div>
            </section>

            <section className="space-y-4">
                <h2 className="text-lg font-bold text-gray-900 flex items-center gap-2">
                    <AlertTriangle className="h-5 w-5 text-rose-500" />
                    Areas for Improvement
                </h2>
                <div className="grid grid-cols-1 gap-4">
                    {analysis.what_you_did_wrong?.map((section, idx) => (
                        <Card key={idx} className="border-l-4 border-l-rose-500 border-gray-100 hover:shadow-md transition-shadow">
                            <CardContent className="p-5">
                                <h3 className="font-bold text-gray-900">{section.title}</h3>
                                <p className="text-sm text-gray-500 mt-1">{section.detail}</p>
                                {section.impact_pct != null && (
                                    <div className="mt-4 flex items-center gap-2">
                                        <span className="text-[10px] font-bold text-rose-600 bg-rose-50 px-2 py-0.5 rounded">
                                            Est. Impact: {section.impact_pct}%
                                        </span>
                                    </div>
                                )}
                            </CardContent>
                        </Card>
                    ))}
                </div>
            </section>

            <section className="space-y-4">
                <h2 className="text-lg font-bold text-gray-900 flex items-center gap-2">
                    <Target className="h-5 w-5 text-indigo-500" />
                    Strategic Alternatives
                </h2>
                <div className="grid grid-cols-1 gap-4">
                    {analysis.what_you_could_have_done?.map((section, idx) => (
                        <Card key={idx} className="border-l-4 border-l-indigo-500 border-gray-100 bg-gray-50/30">
                            <CardContent className="p-5">
                                <h3 className="font-bold text-gray-900">{section.title}</h3>
                                <p className="text-sm text-gray-500 mt-1">{section.detail}</p>
                            </CardContent>
                        </Card>
                    ))}
                </div>
            </section>

            <section className="space-y-4 pt-4">
                <h2 className="text-lg font-bold text-gray-900 flex items-center gap-2">
                    <MessageSquare className="h-5 w-5 text-gray-400" />
                    Trade-by-Trade Commentary
                </h2>
                <div className="space-y-4">
                    {analysis.trade_by_trade_commentary?.map((comm, idx) => (
                        <div key={idx} className="bg-white border border-gray-100 rounded-xl p-6 shadow-sm">
                            <div className="flex justify-between items-start mb-4">
                                <div>
                                    <h4 className="font-bold text-gray-900 flex items-center gap-2">
                                        {comm.symbol} 
                                        <span className={`text-[10px] uppercase px-1.5 py-0.5 rounded ${comm.side === 'buy' ? 'bg-emerald-100 text-emerald-700' : 'bg-rose-100 text-rose-700'}`}>
                                            {comm.side}
                                        </span>
                                    </h4>
                                    <p className="text-xs text-gray-400 mt-0.5">Date: {new Date(comm.sim_date).toLocaleDateString()}</p>
                                </div>
                                {comm.quality_score != null && (
                                    <div className="text-right">
                                        <div className="text-xs font-bold text-gray-400">Quality Score</div>
                                        <div className="text-lg font-black text-indigo-600">{comm.quality_score}/100</div>
                                    </div>
                                )}
                            </div>
                            <div className="bg-gray-50 rounded-lg p-4 relative">
                                <div className="absolute -left-2 top-4 w-4 h-4 bg-gray-50 rotate-45" />
                                <p className="text-sm text-gray-700 leading-relaxed italic">
                                    "{comm.commentary}"
                                </p>
                            </div>
                        </div>
                    ))}
                </div>
            </section>
        </div>
      </div>
    </div>
  );
}
