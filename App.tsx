import React, { useState, useEffect, useCallback, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Layers, Bookmark, RotateCcw, Undo2 } from 'lucide-react';
import { Card } from './components/Card';
import { KeptModal } from './components/KeptModal';
import { SplashScreen } from './components/SplashScreen';
import { ContextMenu } from './components/ContextMenu';
import { Button } from './components/ui/Button';
import { Confetti } from './components/ui/Confetti';
import { INITIAL_PERSONALITIES } from './constants';
import { Personality, KeptItem, SwipeDirection, ContextMenuPosition } from './types';

// Helper to fetch image from Wikipedia API
const fetchWikiImage = async (wikiLink: string): Promise<string | undefined> => {
  try {
    const title = wikiLink.split('/wiki/')[1];
    if (!title) return undefined;

    const response = await fetch(
      `https://en.wikipedia.org/w/api.php?action=query&titles=${title}&prop=pageimages&format=json&pithumbsize=600&origin=*&redirects=1`
    );
    const data = await response.json();
    const pages = data.query?.pages;
    
    if (!pages) return undefined;
    
    const pageId = Object.keys(pages)[0];
    if (pageId === '-1') return undefined;
    
    return pages[pageId]?.thumbnail?.source;
  } catch (error) {
    console.error(`Failed to fetch image for ${wikiLink}:`, error);
    return undefined;
  }
};

// Updated Logo Component matching the splash screen style
const AppLogo = () => (
  <svg width="40" height="40" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg" className="shadow-lg rounded-lg">
    {/* Main Orange Background */}
    <rect width="32" height="32" rx="8" fill="url(#grad1)" />
    
    {/* Card Stack Effect */}
    <path d="M22 8H24C25.1046 8 26 8.89543 26 10V22" stroke="white" strokeOpacity="0.3" strokeWidth="2" strokeLinecap="round"/>
    
    {/* Profile/Person Icon */}
    <path d="M16 8C13.2386 8 11 10.2386 11 13C11 15.7614 13.2386 18 16 18C18.7614 18 21 15.7614 21 13C21 10.2386 18.7614 8 16 8Z" fill="white" fillOpacity="0.95"/>
    <path d="M8 25C8 20.5817 11.5817 17 16 17C20.4183 17 24 20.5817 24 25H8Z" fill="white" fillOpacity="0.95"/>
    
    <defs>
      <linearGradient id="grad1" x1="0" y1="0" x2="32" y2="32" gradientUnits="userSpaceOnUse">
        <stop stopColor="#F97316" />
        <stop offset="1" stopColor="#EA580C" />
      </linearGradient>
    </defs>
  </svg>
);

// History type for Undo
interface HistoryItem {
  index: number;
  action: 'keep' | 'pass';
  id: string;
}

function App() {
  const [loading, setLoading] = useState(true);
  const [personalities, setPersonalities] = useState<Personality[]>(INITIAL_PERSONALITIES);
  const [deck, setDeck] = useState<Personality[]>(INITIAL_PERSONALITIES);
  const [keptList, setKeptList] = useState<KeptItem[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isKeptModalOpen, setIsKeptModalOpen] = useState(false);
  const [history, setHistory] = useState<HistoryItem[]>([]);
  const [showConfetti, setShowConfetti] = useState(false);
  
  // Context Menu State
  const [contextMenu, setContextMenu] = useState<{
    isOpen: boolean;
    position: ContextMenuPosition;
    targetId: string | null;
  }>({
    isOpen: false,
    position: { x: 0, y: 0 },
    targetId: null
  });

  // URL Input Modal State
  const [isUrlModalOpen, setIsUrlModalOpen] = useState(false);
  const urlInputRef = useRef<HTMLInputElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Initialize data and fetch images
  useEffect(() => {
    const initData = async () => {
      const minLoadingTime = new Promise(resolve => setTimeout(resolve, 2000));
      
      const criticalCount = 5;
      const criticalBatch = INITIAL_PERSONALITIES.slice(0, criticalCount);
      const remainingBatch = INITIAL_PERSONALITIES.slice(criticalCount);

      const fetchBatch = async (batch: Personality[]) => {
         return Promise.all(batch.map(async (p) => {
            if (p.imageUrl) return p;
            const url = await fetchWikiImage(p.wikiLink);
            return url ? { ...p, imageUrl: url } : p;
         }));
      };

      const [_, criticalPersonalities] = await Promise.all([
          minLoadingTime, 
          fetchBatch(criticalBatch)
      ]);
      
      const initialDeck = [...criticalPersonalities, ...remainingBatch];
      setPersonalities(initialDeck);
      setDeck(initialDeck);
      setLoading(false);

      const chunkSize = 5;
      for (let i = 0; i < remainingBatch.length; i += chunkSize) {
          const chunk = remainingBatch.slice(i, i + chunkSize);
          const updatedChunk = await fetchBatch(chunk);
          
          setDeck(prevDeck => {
              return prevDeck.map(p => {
                  const updated = updatedChunk.find(u => u.id === p.id);
                  return updated && updated.imageUrl ? { ...p, imageUrl: updated.imageUrl } : p;
              });
          });
      }
    };

    initData();
  }, []);

  // Reset confetti after animation
  useEffect(() => {
    if (showConfetti) {
      const timer = setTimeout(() => setShowConfetti(false), 2000);
      return () => clearTimeout(timer);
    }
  }, [showConfetti]);

  const handleSwipe = useCallback((direction: 'left' | 'right') => {
    // Allow animation to play before updating state
    setTimeout(() => {
      const currentCard = deck[currentIndex];
      
      // Update History
      setHistory(prev => [...prev, { 
        index: currentIndex, 
        action: direction === 'right' ? 'keep' : 'pass',
        id: currentCard.id 
      }]);

      if (direction === 'right') {
        setShowConfetti(true); // Trigger confetti
        setKeptList(prev => {
          if (prev.find(p => p.id === currentCard.id)) return prev;
          return [{ ...currentCard, keptAt: Date.now() }, ...prev];
        });
      }

      setCurrentIndex(prev => prev + 1);
    }, 200); 
  }, [deck, currentIndex]);

  const handleUndo = useCallback(() => {
    if (history.length === 0) return;

    const lastAction = history[history.length - 1];
    
    // Decrement index to show the card again
    setCurrentIndex(prev => Math.max(0, prev - 1));
    
    // If it was kept, remove it from the kept list
    if (lastAction.action === 'keep') {
      setKeptList(prev => prev.filter(item => item.id !== lastAction.id));
    }

    // Remove last history item
    setHistory(prev => prev.slice(0, -1));
  }, [history]);

  // Keyboard Shortcuts
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (isKeptModalOpen || isUrlModalOpen || loading || contextMenu.isOpen) return;
      if (currentIndex >= deck.length) return;

      if (e.key === 'ArrowRight') {
         handleSwipe('right');
      } else if (e.key === 'ArrowLeft') {
         handleSwipe('left');
      } else if (e.key === 'Backspace' || e.key === 'z') {
         handleUndo();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [currentIndex, deck.length, handleSwipe, handleUndo, isKeptModalOpen, isUrlModalOpen, loading, contextMenu.isOpen]);


  const handleContextMenu = (e: React.MouseEvent, id: string) => {
    e.preventDefault();
    setContextMenu({
      isOpen: true,
      position: { x: e.clientX, y: e.clientY },
      targetId: id
    });
  };

  const closeContextMenu = () => {
    setContextMenu(prev => ({ ...prev, isOpen: false }));
  };

  const handleSetImageLocal = () => {
    closeContextMenu();
    if (fileInputRef.current) {
      fileInputRef.current.click();
    }
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file && contextMenu.targetId) {
      const imageUrl = URL.createObjectURL(file);
      updateCardImage(contextMenu.targetId, imageUrl);
    }
    e.target.value = '';
  };

  const handleSetImageUrl = () => {
    closeContextMenu();
    setIsUrlModalOpen(true);
    setTimeout(() => urlInputRef.current?.focus(), 100);
  };

  const submitUrlImage = () => {
    if (urlInputRef.current?.value && contextMenu.targetId) {
      updateCardImage(contextMenu.targetId, urlInputRef.current.value);
      setIsUrlModalOpen(false);
    }
  };

  const handleClearImage = () => {
    if (contextMenu.targetId) {
      updateCardImage(contextMenu.targetId, undefined); 
      closeContextMenu();
    }
  };

  const updateCardImage = (id: string, url: string | undefined) => {
    setDeck(prev => prev.map(p => p.id === id ? { ...p, imageUrl: url } : p));
    setPersonalities(prev => prev.map(p => p.id === id ? { ...p, imageUrl: url } : p));
    setKeptList(prev => prev.map(p => p.id === id ? { ...p, imageUrl: url } : p));
  };

  const handleRestart = () => {
    setCurrentIndex(0);
    setHistory([]);
  };

  const handleClearAllKept = () => {
      setKeptList([]);
  };

  const exportToCSV = () => {
    const headers = ["ID", "Name", "Field", "Bio", "Wiki Link", "Kept At"];
    const rows = keptList.map(item => [
      item.id,
      `"${item.name}"`,
      `"${item.field}"`,
      `"${item.bio.replace(/"/g, '""')}"`,
      item.wikiLink,
      new Date(item.keptAt).toISOString()
    ]);

    const csvContent = "data:text/csv;charset=utf-8," 
      + [headers.join(','), ...rows.map(r => r.join(','))].join('\n');

    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", "kept_personalities.csv");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const visibleCards = deck.slice(currentIndex, currentIndex + 2);
  const isFinished = currentIndex >= deck.length;

  return (
    <>
      <AnimatePresence>
        {loading && <SplashScreen key="splash" />}
      </AnimatePresence>
      
      <Confetti isActive={showConfetti} />

      <div className="h-screen w-screen bg-[#1a1a1a] text-white overflow-hidden flex flex-col relative">
        
        {/* Header */}
        <header className="px-6 py-4 flex items-center justify-between z-40 bg-gradient-to-b from-black/50 to-transparent absolute top-0 w-full pointer-events-none">
          <div className="flex items-center gap-3 pointer-events-auto">
            <AppLogo />
            <h1 className="font-extrabold text-xl md:text-2xl tracking-tight drop-shadow-md">IconDeck India</h1>
          </div>
          
          <button 
            onClick={() => setIsKeptModalOpen(true)}
            className="pointer-events-auto flex items-center gap-2 bg-[#2a2a2a]/80 backdrop-blur-md border border-white/10 px-4 py-2 rounded-full hover:bg-[#333] transition-all group active:scale-95 shadow-lg"
          >
            <span className="text-green-400 font-medium text-sm group-hover:text-green-300">Kept</span>
            <span className="bg-green-500/20 text-green-400 text-xs font-bold px-2 py-0.5 rounded-full">
              {keptList.length}
            </span>
          </button>
        </header>

        {/* Main Deck Area */}
        <main className="flex-1 flex flex-col items-center justify-center relative w-full max-w-lg mx-auto px-4 mt-8">
          
          {isFinished ? (
            <div className="text-center p-8 bg-[#252525] rounded-3xl border border-gray-700 shadow-2xl max-w-xs animate-in zoom-in duration-300">
              <Layers className="w-16 h-16 text-gray-500 mx-auto mb-4" />
              <h2 className="text-2xl font-bold mb-2">You've gone through the deck!</h2>
              <p className="text-gray-400 mb-6">You have kept {keptList.length} personalities.</p>
              <div className="flex flex-col gap-3">
                <Button onClick={handleRestart} variant="secondary" fullWidth className="gap-2">
                  <RotateCcw size={18} /> Restart Deck
                </Button>
                <Button onClick={() => setIsKeptModalOpen(true)} variant="primary" fullWidth className="gap-2">
                  <Bookmark size={18} /> View Kept List
                </Button>
              </div>
            </div>
          ) : (
            <div className="relative w-full h-[65vh] md:h-[600px] flex items-center justify-center">
              {visibleCards.reverse().map((person, index) => {
                const isTop = index === visibleCards.length - 1; 

                return (
                  <Card
                    key={person.id}
                    data={person}
                    active={isTop}
                    onSwipe={handleSwipe}
                    onContextMenu={handleContextMenu}
                  />
                );
              })}
              
              {/* Hint Text */}
              <div className="absolute -bottom-16 left-0 right-0 flex justify-between px-8 text-sm font-medium text-gray-500 pointer-events-none">
                 <div className="flex flex-col items-center gap-1 opacity-50">
                    <div className="w-8 h-8 rounded-full border-2 border-red-500/30 flex items-center justify-center text-red-500/50">✕</div>
                    <span className="hidden sm:inline">Pass</span>
                 </div>
                 
                 {/* Undo Button */}
                 <button 
                   onClick={handleUndo}
                   disabled={history.length === 0}
                   className="pointer-events-auto flex items-center justify-center w-10 h-10 rounded-full bg-gray-800 text-white hover:bg-gray-700 disabled:opacity-30 disabled:hover:bg-gray-800 transition-all shadow-lg active:scale-90"
                   aria-label="Undo last swipe"
                 >
                   <Undo2 size={18} />
                 </button>

                 <div className="flex flex-col items-center gap-1 opacity-50">
                    <div className="w-8 h-8 rounded-full border-2 border-green-500/30 flex items-center justify-center text-green-500/50">✓</div>
                    <span className="hidden sm:inline">Keep</span>
                 </div>
              </div>
            </div>
          )}
        </main>
        
        {/* Navigation Bar */}
        <nav className="bg-[#1a1a1a] border-t border-gray-800 pb-safe pt-2 z-50">
          <div className="flex justify-around items-center h-16 text-gray-500">
             <button onClick={handleRestart} className="flex flex-col items-center gap-1 hover:text-white transition-colors">
               <Layers size={24} />
               <span className="text-[10px] font-medium">Deck</span>
             </button>
             <button onClick={() => setIsKeptModalOpen(true)} className="flex flex-col items-center gap-1 hover:text-white transition-colors">
               <Bookmark size={24} />
               <span className="text-[10px] font-medium">Kept</span>
             </button>
          </div>
        </nav>

        {/* Modals & Overlays */}
        <KeptModal 
          isOpen={isKeptModalOpen} 
          onClose={() => setIsKeptModalOpen(false)} 
          keptList={keptList}
          onRemove={(id) => setKeptList(prev => prev.filter(item => item.id !== id))}
          onExport={exportToCSV}
          onClearAll={handleClearAllKept}
        />

        {contextMenu.isOpen && (
          <ContextMenu 
            position={contextMenu.position} 
            onClose={closeContextMenu}
            onSetImageLocal={handleSetImageLocal}
            onSetImageUrl={handleSetImageUrl}
            onClearImage={handleClearImage}
          />
        )}

        <input 
          type="file" 
          ref={fileInputRef}
          className="hidden"
          accept="image/*"
          onChange={handleFileChange}
        />

        {/* URL Input Modal */}
        {isUrlModalOpen && (
           <div className="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm">
              <div className="bg-[#1e1e1e] rounded-xl p-6 w-full max-w-sm border border-gray-700 shadow-2xl animate-in zoom-in duration-200">
                 <h3 className="text-lg font-bold mb-4">Set Image from URL</h3>
                 <input 
                    ref={urlInputRef}
                    type="text" 
                    placeholder="https://example.com/image.jpg"
                    className="w-full bg-[#2a2a2a] border border-gray-600 rounded-lg px-4 py-2 mb-4 text-white focus:ring-2 focus:ring-blue-500 outline-none placeholder-gray-500"
                    onKeyDown={(e) => e.key === 'Enter' && submitUrlImage()}
                 />
                 <div className="flex justify-end gap-2">
                    <Button variant="secondary" size="sm" onClick={() => setIsUrlModalOpen(false)}>Cancel</Button>
                    <Button variant="primary" size="sm" onClick={submitUrlImage}>Set Image</Button>
                 </div>
              </div>
           </div>
        )}
      </div>
    </>
  );
}

export default App;