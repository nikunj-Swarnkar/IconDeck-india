import React from 'react';
import { motion } from 'framer-motion';

export const SplashScreen: React.FC = () => {
  return (
    <div className="fixed inset-0 z-[60] flex flex-col items-center justify-center bg-gradient-to-br from-slate-900 to-slate-800 text-white">
      <motion.div
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.5, ease: "easeOut" }}
        className="relative mb-6"
      >
        <div className="w-24 h-24 bg-gradient-to-br from-orange-400 to-orange-600 rounded-2xl shadow-2xl flex items-center justify-center relative overflow-hidden">
          <div className="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] opacity-20"></div>
           {/* Simple Icon Representation */}
           <svg className="w-12 h-12 text-white/90" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
             <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2" />
             <circle cx="12" cy="7" r="4" />
           </svg>
        </div>
        <div className="absolute -bottom-2 -right-2 bg-white text-orange-600 p-1 rounded-lg shadow-lg rotate-12">
            <div className="w-4 h-6 border-2 border-orange-600 rounded-sm bg-white" />
        </div>
      </motion.div>
      
      <motion.h1 
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.3, duration: 0.5 }}
        className="text-3xl font-bold tracking-tight mb-8"
      >
        IconDeck India
      </motion.h1>

      <motion.div 
        className="flex gap-2"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.6 }}
      >
        <span className="w-2 h-2 bg-white/50 rounded-full animate-bounce" style={{ animationDelay: '0ms' }}></span>
        <span className="w-2 h-2 bg-white/50 rounded-full animate-bounce" style={{ animationDelay: '150ms' }}></span>
        <span className="w-2 h-2 bg-white/50 rounded-full animate-bounce" style={{ animationDelay: '300ms' }}></span>
      </motion.div>
    </div>
  );
};