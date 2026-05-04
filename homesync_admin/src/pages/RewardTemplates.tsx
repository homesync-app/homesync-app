import React, { useCallback, useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { Modal } from '../components/Modal';
import { 
  Plus, 
  Search, 
  Edit2, 
  Trash2, 
  Coins,
  Loader2
} from 'lucide-react';
import { EmptyState, ErrorState, LoadingState } from '../components/PageState';

interface RewardTemplate {
  id: string;
  title: string;
  description: string;
  cost: number;
  icon: string;
  sort_order: number;
}

export const RewardTemplates = () => {
  const [templates, setTemplates] = useState<RewardTemplate[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  
  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingTemplate, setEditingTemplate] = useState<RewardTemplate | null>(null);
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    cost: 5,
    icon: '🎁',
    sort_order: 0
  });

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(null);
    const { data, error } = await supabase.from('reward_templates').select('*').order('sort_order', { ascending: true });
    if (error) {
      setError('No pudimos cargar los premios.');
      setLoading(false);
      return;
    }
    if (data) setTemplates(data);
    setLoading(false);
  }, []);

  useEffect(() => {
    const timeoutId = window.setTimeout(() => {
      void fetchData();
    }, 0);
    return () => window.clearTimeout(timeoutId);
  }, [fetchData]);

  const handleOpenModal = (template?: RewardTemplate) => {
    if (template) {
      setEditingTemplate(template);
      setFormData({
        title: template.title,
        description: template.description || '',
        cost: template.cost,
        icon: template.icon || '🎁',
        sort_order: template.sort_order
      });
    } else {
      setEditingTemplate(null);
      setFormData({
        title: '',
        description: '',
        cost: 10,
        icon: '🎁',
        sort_order: templates.length > 0 ? templates[templates.length - 1].sort_order + 1 : 1
      });
    }
    setIsModalOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    if (editingTemplate) {
      await supabase
        .from('reward_templates')
        .update(formData)
        .eq('id', editingTemplate.id);
    } else {
      await supabase
        .from('reward_templates')
        .insert([formData]);
    }

    await fetchData();
    setIsModalOpen(false);
  };

  const handleDelete = async (id: string) => {
    if (confirm('Are you sure you want to delete this reward template?')) {
      setLoading(true);
      await supabase.from('reward_templates').delete().eq('id', id);
      await fetchData();
    }
  };

  const filteredTemplates = templates.filter(t => 
    t.title.toLowerCase().includes(searchQuery.toLowerCase()) || 
    (t.description && t.description.toLowerCase().includes(searchQuery.toLowerCase()))
  );

  return (
    <div className="space-y-8 animate-in fade-in duration-500">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Plantillas de Premios</h2>
          <p className="text-gray-400 mt-1">Configurá los premios predeterminados disponibles para todos los hogares.</p>
        </div>
        
        <div className="flex items-center gap-3">
          <button 
            onClick={() => handleOpenModal()}
            className="flex items-center gap-2 px-4 py-2 bg-amber-500 text-black rounded-xl font-bold hover:opacity-90 transition-all glow-amber"
          >
            <Plus className="w-4 h-4" />
            <span>Nuevo Premio</span>
          </button>
        </div>
      </div>

      <div className="space-y-6">
        <div className="relative max-w-md">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-500" />
          <input 
            type="text" 
              placeholder="Buscar premios por título..."
            className="w-full bg-white/5 border border-white/10 rounded-2xl py-3 pl-12 pr-4 focus:outline-none focus:ring-2 focus:ring-amber-500/50 transition-all"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>

        {loading && !templates.length ? (
          <LoadingState title="Cargando premios..." />
        ) : error ? (
          <ErrorState title="Error al cargar premios" description={error} />
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {filteredTemplates.length === 0 ? (
              <div className="md:col-span-3 lg:col-span-4">
                <EmptyState title="Sin resultados" description="Prueba otra búsqueda o crea un premio nuevo." />
              </div>
            ) : filteredTemplates.map(template => (
              <div key={template.id} className="glass group p-5 rounded-2xl border-amber-500/10 hover:border-amber-500/50 transition-all relative overflow-hidden flex flex-col justify-between h-full">
                <div>
                  <div className="flex justify-between items-start mb-4">
                    <div className="w-14 h-14 rounded-2xl bg-amber-500/10 flex items-center justify-center text-3xl">
                      {template.icon || '🎁'}
                    </div>
                    <div className="flex gap-1 absolute top-4 right-4 bg-dark/80 backdrop-blur-md rounded-lg opacity-0 group-hover:opacity-100 transition-opacity">
                      <button 
                        onClick={() => handleOpenModal(template)}
                        className="p-2 hover:bg-white/10 rounded-lg text-gray-400 hover:text-amber-500 transition-colors"
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
                  <p className="text-gray-400 text-sm mb-4 line-clamp-2">{template.description}</p>
                </div>
                
                <div className="flex items-center gap-1.5 text-amber-400 pt-4 border-t border-white/5">
                  <Coins className="w-5 h-5" />
                  <span className="font-black text-lg">{template.cost}</span>
                  <span className="text-sm font-bold opacity-80 ml-1">Coins</span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      <Modal 
        isOpen={isModalOpen} 
        onClose={() => setIsModalOpen(false)} 
        title={editingTemplate ? 'Editar Premio' : 'Nuevo Premio'}
      >
        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label className="block text-sm font-bold text-gray-400 uppercase tracking-widest mb-2">Título del premio</label>
            <input 
              required
              className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-amber-500/50"
              value={formData.title}
              onChange={e => setFormData({ ...formData, title: e.target.value })}
            />
          </div>

          <div>
            <label className="block text-sm font-bold text-gray-400 uppercase tracking-widest mb-2">Descripción</label>
            <textarea 
              className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-amber-500/50 min-h-[80px]"
              value={formData.description}
              onChange={e => setFormData({ ...formData, description: e.target.value })}
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-bold text-gray-400 uppercase tracking-widest mb-2">Icono (Emoji)</label>
              <input 
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-amber-500/50"
                value={formData.icon}
                onChange={e => setFormData({ ...formData, icon: e.target.value })}
                placeholder="🎁"
              />
            </div>
            <div>
              <label className="block text-sm font-bold text-gray-400 uppercase tracking-widest mb-2">Costo en Monedas</label>
              <input 
                type="number"
                min="0"
                required
                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-amber-500/50 font-bold text-amber-500"
                value={formData.cost}
                onChange={e => setFormData({ ...formData, cost: parseInt(e.target.value) || 0 })}
              />
            </div>
          </div>

          <button 
            type="submit"
            className="w-full py-4 bg-amber-500 text-black font-black rounded-2xl hover:opacity-90 transition-all glow-amber flex items-center justify-center gap-2"
          >
            {loading ? <Loader2 className="w-5 h-5 animate-spin" /> : editingTemplate ? 'Actualizar Premio' : 'Crear Premio'}
          </button>
        </form>
      </Modal>
    </div>
  );
};
