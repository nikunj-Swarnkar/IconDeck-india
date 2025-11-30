import React, { useState } from 'react';
import { motion, useMotionValue, useTransform, PanInfo } from 'framer-motion';
import { Check, X } from 'lucide-react';
import { Personality } from '../types';

interface CardProps {
  data: Personality;
  active: boolean;
  onSwipe: (direction: 'left' | 'right') => void;
  onContextMenu: (e: React.MouseEvent, id: string) => void;
}

export const Card: React.FC<CardProps> = ({ data, active, onSwipe, onContextMenu }) => {
  const x = useMotionValue(0);
  const rotate = useTransform(x, [-200, 200], [-15, 15]);
  const opacityKeep = useTransform(x, [50, 150], [0, 1]);
  const opacityPass = useTransform(x, [-50, -150], [0, 1]);
  
  // Overlay colors
  const keepOverlayOpacity = useTransform(x, [20, 150], [0, 0.4]); // Green tint
  const passOverlayOpacity = useTransform(x, [-20, -150], [0, 0.4]); // Red tint

  const [isDragging, setIsDragging] = useState(false);
  const [imageError, setImageError] = useState(false);

  const handleDragEnd = (event: MouseEvent | TouchEvent | PointerEvent, info: PanInfo) => {
    setIsDragging(false);
    if (info.offset.x > 100) {
      onSwipe('right');
    } else if (info.offset.x < -100) {
      onSwipe('left');
    }
  };

  const initials = data.name
    .split(' ')
    .map(n => n[0])
    .join('')
    .substring(0, 2)
    .toUpperCase();

  const handleImageError = () => {
    setImageError(true);
  };

  const showImage = data.imageUrl && !imageError;

  return (
    <motion.div
      style={{
        x: active ? x : 0,
        rotate: active ? rotate : 0,
        zIndex: active ? 10 : 0,
      }}
      drag={active ? 'x' : false}
      dragConstraints={{ left: 0, right: 0 }}
      onDragStart={() => setIsDragging(true)}
      onDragEnd={handleDragEnd}
      whileTap={{ scale: 1.02 }}
      className="absolute top-0 w-full h-full max-w-[360px] cursor-grab active:cursor-grabbing perspective-1000"
      onContextMenu={(e) => onContextMenu(e, data.id)}
    >
      <div className="relative w-full h-full bg-white rounded-3xl shadow-2xl overflow-hidden flex flex-col select-none">
        
        {/* Pass Indicator */}
        <motion.div 
          style={{ opacity: opacityPass }}
          className="absolute top-8 right-8 z-20 border-4 border-red-500 rounded-lg p-2 transform rotate-12"
        >
          <X className="text-red-500 w-12 h-12 stroke-[4]" />
        </motion.div>

        {/* Keep Indicator */}
        <motion.div 
          style={{ opacity: opacityKeep }}
          className="absolute top-8 left-8 z-20 border-4 border-green-500 rounded-lg p-2 transform -rotate-12"
        >
          <Check className="text-green-500 w-12 h-12 stroke-[4]" />
        </motion.div>

        {/* Swipe Color Overlays */}
        <motion.div 
          style={{ opacity: keepOverlayOpacity }}
          className="absolute inset-0 bg-green-500 z-10 pointer-events-none mix-blend-multiply"
        />
        <motion.div 
          style={{ opacity: passOverlayOpacity }}
          className="absolute inset-0 bg-red-500 z-10 pointer-events-none mix-blend-multiply"
        />

        {/* Image Section */}
        <div className="h-[55%] relative bg-gray-100">
          {showImage ? (
            <img 
              src={data.imageUrl} 
              alt={data.name} 
              className="w-full h-full object-cover object-top pointer-events-none"
              onError={handleImageError}
            />
          ) : (
            <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-blue-100 to-indigo-200">
              <span className="text-6xl font-bold text-indigo-400">{initials}</span>
            </div>
          )}
          <div className="absolute inset-0 bg-gradient-to-b from-transparent to-black/30 opacity-60"></div>
        </div>

        {/* Content Section */}
        <div className="flex-1 p-6 flex flex-col items-center text-center bg-white relative z-10 -mt-6 rounded-t-3xl">
          {/* Avatar Circle Overlay */}
          <div className="w-24 h-24 rounded-full border-4 border-white bg-gray-200 -mt-16 mb-3 overflow-hidden shadow-lg relative z-20">
             {showImage ? (
                <img src={data.imageUrl} alt="" className="w-full h-full object-cover object-center" />
             ) : (
                <div className="w-full h-full flex items-center justify-center bg-gray-300 text-gray-500 font-bold text-2xl">
                    {initials}
                </div>
             )}
          </div>

          <h2 className="text-2xl font-bold text-gray-900 leading-tight mb-1">{data.name}</h2>
          <span className="inline-block px-3 py-1 bg-slate-100 text-slate-600 text-xs font-bold tracking-wider uppercase rounded-full mb-4">
            {data.field}
          </span>
          
          <p className="text-gray-600 text-sm leading-relaxed mb-6 line-clamp-4">
            {data.bio}
          </p>

          <a 
            href={data.wikiLink} 
            target="_blank" 
            rel="noopener noreferrer"
            className="mt-auto flex items-center gap-1 text-blue-600 font-semibold text-sm hover:text-blue-800 transition-colors group"
            onPointerDown={(e) => e.stopPropagation()} // Prevent drag start on link click
          >
            More about them 
            <span className="group-hover:translate-x-1 transition-transform">➜</span>
          </a>
        </div>
      </div>
    </motion.div>
  );
};