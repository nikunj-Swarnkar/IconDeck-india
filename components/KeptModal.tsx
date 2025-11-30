import React, { useState } from 'react';
import { X, ExternalLink, Trash2, Download, AlertTriangle, Bookmark, Search, CheckCircle2 } from 'lucide-react';
import { KeptItem } from '../types';
import { Button } from './ui/Button';

interface KeptModalProps {
  isOpen: boolean;
  onClose: () => void;
  keptList: KeptItem[];
  onRemove: (id: string) => void;
  onExport: () => void;
  onClearAll: () => void;
}

export const KeptModal: React.FC<KeptModalProps> = ({ 
  isOpen, 
  onClose, 
  keptList, 
  onRemove,
  onExport,
  onClearAll
}) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [isConfirmingClear, setIsConfirmingClear] = useState(false);

  if (!isOpen) return null;

  const filteredList = keptList.filter(item => 
    item.name.toLowerCase().includes(searchTerm.toLowerCase()) || 
    item.field.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleClearClick = () => {
    if (isConfirmingClear) {
      onClearAll();
      setIsConfirmingClear(false);
    } else {
      setIsConfirmingClear(true);
      // Reset confirmation if user doesn't click within 3 seconds
      setTimeout(() => setIsConfirmingClear(false), 3000);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div 
        className="absolute inset-0 bg-black/70 backdrop-blur-sm transition-opacity" 
        onClick={onClose}
      />
      <div className="relative bg-[#1e1e1e] w-full max-w-md rounded-2xl shadow-2xl overflow-hidden flex flex-col max-h-[85vh] animate-in slide-in-from-bottom-4 duration-300 border border-gray-800">
        
        {/* Header */}
        <div className="px-6 py-4 border-b border-gray-800 flex items-center justify-between bg-[#252525]">
          <h2 className="text-xl font-bold text-white">Kept List ({keptList.length})</h2>
          <button 
            onClick={onClose}
            className="p-2 rounded-full hover:bg-gray-700 text-gray-400 hover:text-white transition-colors"
          >
            <X size={20} />
          </button>
        </div>

        {/* Search Bar */}
        <div className="px-4 py-3 bg-[#1a1a1a] border-b border-gray-800">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-500" size={16} />
            <input 
              type="text" 
              placeholder="Search by name or field..." 
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full bg-[#2a2a2a] text-white text-sm rounded-lg pl-9 pr-4 py-2 border border-gray-700 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 outline-none placeholder-gray-500 transition-all"
            />
          </div>
        </div>

        {/* List */}
        <div className="flex-1 overflow-y-auto p-4 space-y-3 no-scrollbar bg-[#1a1a1a]">
          {keptList.length === 0 ? (
            <div className="text-center py-16 text-gray-500 flex flex-col items-center">
              <div className="w-16 h-16 bg-gray-800 rounded-full flex items-center justify-center mb-4">
                <Bookmark size={32} className="opacity-20" />
              </div>
              <p className="font-medium text-lg text-gray-400">No cards kept yet</p>
              <p className="text-sm mt-2 text-gray-600 max-w-[200px]">Swipe right on cards to add them to your collection.</p>
            </div>
          ) : filteredList.length === 0 ? (
            <div className="text-center py-12 text-gray-500">
              <p>No matches found for "{searchTerm}"</p>
            </div>
          ) : (
            filteredList.map((item) => (
              <div key={item.id} className="bg-[#252525] p-3 rounded-xl flex items-center gap-3 border border-gray-800 hover:border-gray-700 transition-colors group">
                <div className="w-12 h-12 rounded-full overflow-hidden bg-gray-700 flex-shrink-0 relative ring-1 ring-white/10">
                  {item.imageUrl ? (
                    <img 
                        src={item.imageUrl} 
                        alt={item.name} 
                        className="w-full h-full object-cover" 
                        onError={(e) => {
                            e.currentTarget.style.display = 'none';
                            e.currentTarget.parentElement?.classList.add('flex', 'items-center', 'justify-center', 'text-gray-400', 'font-bold', 'text-xs');
                            const fallback = document.createElement('span');
                            fallback.innerText = item.name.substring(0,2).toUpperCase();
                            e.currentTarget.parentElement?.appendChild(fallback);
                        }}
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center text-gray-400 font-bold text-xs">
                      {item.name.substring(0,2).toUpperCase()}
                    </div>
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <h3 className="font-semibold text-white text-sm truncate">{item.name}</h3>
                  <p className="text-gray-400 text-xs truncate">{item.field}</p>
                </div>
                <div className="flex flex-col gap-2">
                  <a 
                    href={item.wikiLink} 
                    target="_blank" 
                    rel="noopener noreferrer"
                    className="flex items-center gap-1 bg-blue-500/10 hover:bg-blue-500/20 text-blue-400 text-xs px-2 py-1 rounded transition-colors"
                  >
                    Wiki <ExternalLink size={10} />
                  </a>
                  <button 
                    onClick={() => onRemove(item.id)}
                    className="flex items-center gap-1 bg-red-500/10 hover:bg-red-500/20 text-red-400 text-xs px-2 py-1 rounded transition-colors"
                  >
                    Remove <Trash2 size={10} />
                  </button>
                </div>
              </div>
            ))
          )}
        </div>

        {/* Footer */}
        <div className="p-4 border-t border-gray-800 bg-[#252525] flex gap-3">
           <Button 
            onClick={handleClearClick} 
            variant={isConfirmingClear ? "danger" : "danger-outline"}
            disabled={keptList.length === 0}
            className={`flex-1 flex items-center gap-2 justify-center transition-all ${isConfirmingClear ? 'animate-pulse' : ''}`}
          >
            {isConfirmingClear ? (
              <>
                <AlertTriangle size={18} /> Confirm?
              </>
            ) : (
              <>
                <Trash2 size={18} /> Clear All
              </>
            )}
          </Button>
          <Button 
            onClick={onExport} 
            variant="primary"
            disabled={keptList.length === 0}
            className="flex-[2] flex items-center gap-2 justify-center"
          >
            <Download size={18} />
            Export CSV
          </Button>
        </div>
      </div>
    </div>
  );
};