'use client';

import { useState } from 'react';
import {
  useLessons,
  useLessonDetail,
  useCreateLesson,
  useUpdateLesson,
  useDeleteLesson,
  useCreateQuiz,
} from '@/hooks';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Skeleton } from '@/components/ui';
import {
  BookOpen, Search, Pencil, Trash2, Plus, HelpCircle, ChevronRight, GraduationCap, Clock, Layers,
} from 'lucide-react';
import type { LessonSummary, LessonDetail } from '@/types';

function LessonRow({ 
  lesson, 
  onEdit, 
  onDelete, 
  onManageQuiz 
}: {
  lesson: LessonSummary;
  onEdit: (id: number) => void;
  onDelete: (id: number) => void;
  onManageQuiz: (id: number) => void;
}) {
  return (
    <div className="flex items-center justify-between p-4 bg-slate-900 border border-slate-800 rounded-xl hover:border-slate-700 transition-all group">
      <div className="flex items-center gap-4">
        <div className="h-10 w-10 rounded-lg bg-indigo-900/30 flex items-center justify-center text-indigo-400 border border-indigo-500/20">
          <BookOpen className="h-5 w-5" />
        </div>
        <div>
          <h3 className="text-sm font-bold text-white group-hover:text-indigo-400 transition-colors">{lesson.title}</h3>
          <div className="flex items-center gap-3 mt-1">
            <span className="text-xs text-slate-500 flex items-center gap-1">
              <Layers className="h-3 w-3" /> {lesson.section}
            </span>
            <span className="text-xs text-slate-500 flex items-center gap-1">
              <Clock className="h-3 w-3" /> {lesson.read_time_minutes} min
            </span>
            <span className={`text-[10px] font-bold uppercase px-1.5 py-0.5 rounded border ${
              lesson.difficulty_level === 'beginner' ? 'text-emerald-400 border-emerald-900/50 bg-emerald-900/10' :
              lesson.difficulty_level === 'intermediate' ? 'text-amber-400 border-amber-900/50 bg-amber-900/10' :
              'text-rose-400 border-rose-900/50 bg-rose-900/10'
            }`}>
              {lesson.difficulty_level}
            </span>
          </div>
        </div>
      </div>
      
      <div className="flex items-center gap-2">
        <Button 
          variant="ghost" 
          size="sm" 
          onClick={() => onManageQuiz(lesson.id)}
          className={`h-8 gap-1.5 text-xs ${lesson.has_quiz ? 'text-emerald-400 hover:text-emerald-300' : 'text-slate-500 hover:text-indigo-400'}`}
        >
          <HelpCircle className="h-3.5 w-3.5" />
          {lesson.has_quiz ? 'Quiz Ready' : 'Add Quiz'}
        </Button>
        <div className="w-px h-4 bg-slate-800 mx-1" />
        <button
          onClick={() => onEdit(lesson.id)}
          className="p-2 text-slate-400 hover:text-white rounded-lg hover:bg-slate-800"
        >
          <Pencil className="h-4 w-4" />
        </button>
        <button
          onClick={() => onDelete(lesson.id)}
          className="p-2 text-rose-500/70 hover:text-rose-400 rounded-lg hover:bg-rose-900/20"
        >
          <Trash2 className="h-4 w-4" />
        </button>
      </div>
    </div>
  );
}

function LessonEditorModal({ id, onClose }: { id?: number; onClose: () => void }) {
  const isEdit = !!id;
  const { data: existingLesson, isLoading: isLoadingDetail } = useLessonDetail(id ?? 0);
  const createLesson = useCreateLesson();
  const updateLesson = useUpdateLesson();

  const [formData, setFormData] = useState({
    title: existingLesson?.title ?? '',
    section: existingLesson?.section ?? 'Introduction',
    content_html: existingLesson?.content_html ?? '',
    difficulty_level: existingLesson?.difficulty_level ?? 'beginner',
    read_time_minutes: existingLesson?.read_time_minutes ?? 5,
    order_index: existingLesson?.order_index ?? 1,
  });

  // Sync with loaded data
  if (isEdit && existingLesson && formData.title === '') {
    setFormData({
      title: existingLesson.title,
      section: existingLesson.section,
      content_html: existingLesson.content_html,
      difficulty_level: existingLesson.difficulty_level,
      read_time_minutes: existingLesson.read_time_minutes,
      order_index: existingLesson.order_index,
    });
  }

  const handleSave = () => {
    if (isEdit && id) {
      updateLesson.mutate({ lesson_id: id, data: formData }, { onSuccess: onClose });
    } else {
      createLesson.mutate(formData, { onSuccess: onClose });
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
      <Card className="w-full max-w-4xl bg-slate-900 border-slate-700 shadow-2xl max-h-[90vh] flex flex-col">
        <CardHeader className="border-b border-slate-800">
          <CardTitle className="text-white flex items-center gap-2">
            {isEdit ? <Pencil className="h-5 w-5 text-indigo-400" /> : <Plus className="h-5 w-5 text-indigo-400" />}
            {isEdit ? 'Edit Lesson' : 'Create New Lesson'}
          </CardTitle>
        </CardHeader>
        <CardContent className="flex-1 overflow-y-auto p-6 space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <label className="text-sm font-medium text-slate-300">Title</label>
              <Input
                placeholder="Lesson Title"
                value={formData.title}
                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                className="bg-slate-800 border-slate-700 text-white"
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium text-slate-300">Section</label>
              <Input
                placeholder="e.g. Technical Indicators"
                value={formData.section}
                onChange={(e) => setFormData({ ...formData, section: e.target.value })}
                className="bg-slate-800 border-slate-700 text-white"
              />
            </div>
          </div>

          <div className="grid grid-cols-3 gap-4">
            <div className="space-y-2">
              <label className="text-sm font-medium text-slate-300">Difficulty</label>
              <select
                value={formData.difficulty_level}
                onChange={(e) => setFormData({ ...formData, difficulty_level: e.target.value })}
                className="w-full h-10 px-3 rounded-md border border-slate-700 bg-slate-800 text-white text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
              >
                <option value="beginner">Beginner</option>
                <option value="intermediate">Intermediate</option>
                <option value="advanced">Advanced</option>
              </select>
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium text-slate-300">Read Time (min)</label>
              <Input
                type="number"
                value={formData.read_time_minutes}
                onChange={(e) => setFormData({ ...formData, read_time_minutes: parseInt(e.target.value) })}
                className="bg-slate-800 border-slate-700 text-white"
              />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium text-slate-300">Order Index</label>
              <Input
                type="number"
                value={formData.order_index}
                onChange={(e) => setFormData({ ...formData, order_index: parseInt(e.target.value) })}
                className="bg-slate-800 border-slate-700 text-white"
              />
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-sm font-medium text-slate-300">Content (HTML)</label>
            <textarea
              className="w-full min-h-[300px] p-4 rounded-md border border-slate-700 bg-slate-800 text-white font-mono text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="<h2>Introduction</h2><p>Content goes here...</p>"
              value={formData.content_html}
              onChange={(e) => setFormData({ ...formData, content_html: e.target.value })}
            />
            <p className="text-[10px] text-slate-500 uppercase tracking-widest font-bold">Standard HTML tags are supported (h2, p, ul, li, strong, etc)</p>
          </div>
        </CardContent>
        <div className="p-4 border-t border-slate-800 flex justify-end gap-3 bg-slate-900/50">
          <Button variant="outline" onClick={onClose} className="border-slate-700 text-slate-300 hover:bg-slate-800">Cancel</Button>
          <Button 
            onClick={handleSave} 
            isLoading={createLesson.isPending || updateLesson.isPending}
            className="bg-indigo-600 hover:bg-indigo-700 text-white"
          >
            {isEdit ? 'Save Changes' : 'Create Lesson'}
          </Button>
        </div>
      </Card>
    </div>
  );
}

export default function LearnAdminPage() {
  const { data: curriculum, isLoading } = useLessons();
  const deleteLesson = useDeleteLesson();
  
  const [search, setSearch] = useState('');
  const [editingId, setEditingId] = useState<number | null>(null);
  const [isAdding, setIsAdding] = useState(false);

  const flatLessons = (curriculum ?? []).flatMap(section => section.lessons);
  const filteredLessons = flatLessons.filter(l => 
    l.title.toLowerCase().includes(search.toLowerCase()) || 
    l.section.toLowerCase().includes(search.toLowerCase())
  );

  const handleDelete = (id: number) => {
    if (confirm('Are you sure you want to delete this lesson? This will also remove any associated quiz.')) {
      deleteLesson.mutate(id);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white flex items-center gap-2">
            <GraduationCap className="h-6 w-6 text-indigo-400" />
            Educational Content CMS
          </h1>
          <p className="text-slate-400">Curate lessons and quizzes for the trading curriculum</p>
        </div>
        <Button onClick={() => setIsAdding(true)} className="bg-indigo-600 hover:bg-indigo-700 text-white shadow-lg shadow-indigo-500/20">
          <Plus className="h-4 w-4 mr-2" />
          New Lesson
        </Button>
      </div>

      <div className="relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-500" />
        <Input
          placeholder="Search lessons by title or section..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="pl-10 bg-slate-900 border-slate-700 text-white focus:ring-indigo-500 w-full"
        />
      </div>

      <div className="space-y-4">
        {isLoading ? (
          <Skeleton className="h-20 w-full bg-slate-800" />
        ) : filteredLessons.length === 0 ? (
          <Card className="bg-slate-900 border-slate-700 border-dashed p-12 text-center">
            <GraduationCap className="h-12 w-12 text-slate-700 mx-auto mb-4" />
            <p className="text-slate-500">No lessons found. Start by creating one!</p>
          </Card>
        ) : (
          filteredLessons.map((lesson) => (
            <LessonRow
              key={lesson.id}
              lesson={lesson}
              onEdit={(id) => setEditingId(id)}
              onDelete={handleDelete}
              onManageQuiz={(id) => setEditingId(id)} // Reusing edit for now, can add quiz specific view if needed
            />
          ))
        )}
      </div>

      {(isAdding || editingId) && (
        <LessonEditorModal 
          id={editingId ?? undefined} 
          onClose={() => {
            setIsAdding(false);
            setEditingId(null);
          }} 
        />
      )}
    </div>
  );
}
