import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { Modal } from '../components/Modal';
import { 
  Plus, 
  Search, 
  Settings2, 
  Edit2, 
  Trash2, 
  Tag, 
  Trophy, 
  Coins,
  Loader2
} from 'lucide-react';

interface Category {
  id: string;
  name: string;
  icon: string;
  color: string;
}

interface TaskTemplate {
  id: string;
  title: string;
  category_id: string;
  difficulty: string;
  xp_reward: number;
  coin_reward: number;
  icon: string;
}

export const TaskTemplates = () => {
  const [templates, setTemplates] = useState<TaskTemplate[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  
  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingTemplate, setEditingTemplate] = useState<TaskTemplate | null>(null);
  const [formData, setFormData] = useState({
    title: '',
    category_id: '',
    xp_reward: 10,
    coin_reward: 5,
    icon: '📋'
  });

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    setLoading(true);
    const [templatesRes, categoriesRes] = await Promise.all([
      supabase.from('task_templates').select('*').order('created_at', { ascending: false }),
      supabase.from('categories').select('*').order('sort_order', { ascending: true })
    ]);

    if (templatesRes.data) setTemplates(templatesRes.data);
    if (categoriesRes.data) setCategories(categoriesRes.data);
    setLoading(false);
  };

  const handleOpenModal = (template?: TaskTemplate) => {
    if (template) {
      setEditingTemplate(template);
      setFormData({
        title: template.title,
        category_id: template.category_id,
        xp_reward: template.xp_reward,
        coin_reward: template.coin_reward,
        icon: template.icon || '📋'
      });
    } else {
      setEditingTemplate(null);
      setFormData({
        title: '',
        category_id: categories[0]?.id || '',
        xp_reward: 10,
        coin_reward: 5,
        icon: '📋'
      });
    }
    setIsModalOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    if (editingTemplate) {
      await supabase
        .from('task_templates')
        .update(formData)
        .eq('id', editingTemplate.id);
    } else {
      await supabase
        .from('task_templates')
        .insert([formData]);
    }

    await fetchData();
    setIsModalOpen(false);
  };

  const handleDelete = async (id: string) => {
    if (confirm('Are you sure you want to delete this master template?')) {
      setLoading(true);
      await supabase.from('task_templates').delete().eq('id', id);
      await fetchData();
    }
  };

  const filteredTemplates = templates.filter(t => 
    t.title.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Master Task Templates</h2>
          <p className="text-gray-400 mt-1">Configure the default tasks available to all users.</p>
        </div>
        
        <div className="flex items-center gap-3">
          <button className="flex items-center gap-2 px-4 py-2 bg-white/5 border border-white/10 rounded-xl hover:bg-white/10 transition-colors">
            <Settings2 className="w-4 h-4" />
            <span>Manage Categories</span>
          </button>
          <button 
            onClick={() => handleOpenModal()}
            className="flex items-center gap-2 px-4 py-2 bg-primary rounded-xl font-bold hover:opacity-90 transition-all glow-violet"
          >
            <Plus className="w-4 h-4" />
            <span>Add Template</span>
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
        {/* Sidebar: Categories */}
        <div className="lg:col-span-1 space-y-4">
          <div className="glass-dark p-6 rounded-2xl h-fit">
            <h3 className="text-sm font-bold uppercase tracking-widest text-secondary mb-4">Categories</h3>
            <div className="space-y-2">
              {categories.map(cat => (
                <button 
                  key={cat.id}
                  className="w-full flex items-center justify-between px-3 py-2 rounded-lg hover:bg-white/5 transition-colors group"
                >
                  <div className="flex items-center gap-3">
                    <span className="text-xl">{cat.icon}</span>
                    <span className="text-gray-300 group-hover:text-white transition-colors">{cat.name}</span>
                  </div>
                  <span className="text-[10px] bg-white/10 px-2 py-0.5 rounded-full text-gray-400">
                    {templates.filter(t => t.category_id === cat.id).length}
                  </span>
                </button>
              ))}
              <button className="w-full flex items-center gap-3 px-3 py-2 rounded-lg border border-dashed border-white/10 text-gray-500 hover:text-white hover:border-white/30 transition-all mt-4">
                <Plus className="w-4 h-4" />
                <span className="text-sm">New Category</span>
              </button>
            </div>
          </div>
        </div>

        {/* Main: Template Grid */}
        <div className="lg:col-span-3 space-y-6">
          <div className="relative">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-500" />
            <input 
              type="text" 
              placeholder="Search templates by title..."
              className="w-full bg-white/5 border border-white/10 rounded-2xl py-3 pl-12 pr-4 focus:outline-none focus:ring-2 focus:ring-primary/50 transition-all"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>

          {loading && !templates.length ? (
            <div className="h-64 flex items-center justify-center">
              <Loader2 className="w-8 h-8 text-primary animate-spin" />
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {filteredTemplates.map(template => {
                const category = categories.find(c => c.id === template.category_id);
                return (
                  <div key={template.id} className="glass group p-5 rounded-2xl hover:border-primary/50 transition-all relative overflow-hidden">
                    <div className="flex justify-between items-start mb-4">
                      <div className="w-12 h-12 rounded-xl bg-white/5 flex items-center justify-center text-2xl">
                        {template.icon || category?.icon || '📋'}
                      </div>
                      <div className="flex gap-1">
                        <button 
                          onClick={() => handleOpenModal(template)}
                          className="p-2 hover:bg-white/10 rounded-lg text-gray-400 hover:text-primary transition-colors"
                        >
                          <Edit2 className="w-4 h-4" />
                        </button>
                        <button 
                          onClick={() => handleDelete(template.id)}
                          className="p-2 hover:bg-white/10 rounded-lg text-gray-400 hover:text-red-500 transition-colors"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </div>

                    <h4 className="font-bold text-lg mb-1">{template.title}</h4>
                    
                    <div className="flex items-center gap-2 mb-4">
                      <Tag className="w-3 h-3 text-secondary" />
                      <span className="text-xs font-semibold uppercase tracking-wider text-secondary">
                        {category?.name || template.category_id}
                      </span>
                    </div>

                    <div className="flex items-center gap-4 pt-4 border-t border-white/5">
                      <div className="flex items-center gap-1.5 text-emerald-400">
                        <Trophy className="w-4 h-4" />
                        <span className="text-sm font-bold">+{template.xp_reward} XP</span>
                      </div>
                      <div className="flex items-center gap-1.5 text-amber-400">
                        <Coins className="w-4 h-4" />
                        <span className="text-sm font-bold">+{template.coin_reward} Coins</span>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>

      <Modal 
        isOpen={isModalOpen} 
        onClose={() => setIsModalOpen(false)} 
        title={editingTemplate ? 'Edit Template' : 'Add New Template'}
      >
        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label className="block text-sm font-bold text-gray-400 uppercase tracking-widest mb-2">Task Title</label>
            <input 
              required
              className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/50"
              value={formData.title}
              onChange={e => setFormData({ ...formData, title: e.target.value })}
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-bold text-gray-400 uppercase tracking-widest mb-2">Category</label>
              <select 
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/50 appearance-none"
                value={formData.category_id}
                onChange={e => setFormData({ ...formData, category_id: e.target.value })}
              >
                {categories.map(c => <option key={c.id} value={c.id} className="bg-dark">{c.name}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-sm font-bold text-gray-400 uppercase tracking-widest mb-2">Icon</label>
              <input 
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/50"
                value={formData.icon}
                onChange={e => setFormData({ ...formData, icon: e.target.value })}
                placeholder="Emoji icon"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-bold text-gray-400 uppercase tracking-widest mb-2">XP Reward</label>
              <input 
                type="number"
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/50"
                value={formData.xp_reward}
                onChange={e => setFormData({ ...formData, xp_reward: parseInt(e.target.value) })}
              />
            </div>
            <div>
              <label className="block text-sm font-bold text-gray-400 uppercase tracking-widest mb-2">Coins</label>
              <input 
                type="number"
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/50"
                value={formData.coin_reward}
                onChange={e => setFormData({ ...formData, coin_reward: parseInt(e.target.value) })}
              />
            </div>
          </div>

          <button 
            type="submit"
            className="w-full py-4 bg-primary text-white font-bold rounded-2xl hover:opacity-90 transition-all glow-violet flex items-center justify-center gap-2"
          >
            {loading ? <Loader2 className="w-5 h-5 animate-spin" /> : editingTemplate ? 'Update Template' : 'Create Template'}
          </button>
        </form>
      </Modal>
    </div>
  );
};
