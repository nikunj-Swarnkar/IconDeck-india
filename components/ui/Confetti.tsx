import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';

const colors = ['#EF4444', '#3B82F6', '#10B981', '#F59E0B', '#8B5CF6', '#EC4899'];

interface ConfettiProps {
  isActive: boolean;
}

export const Confetti: React.FC<ConfettiProps> = ({ isActive }) => {
  const [pieces, setPieces] = useState<{ id: number; x: number; y: number; color: string; rotation: number }[]>([]);

  useEffect(() => {
    if (isActive) {
      const newPieces = Array.from({ length: 30 }).map((_, i) => ({
        id: i,
        x: Math.random() * 100, // percentage
        y: Math.random() * 100, // percentage
        color: colors[Math.floor(Math.random() * colors.length)],
        rotation: Math.random() * 360,
      }));
      setPieces(newPieces);
    } else {
      setPieces([]);
    }
  }, [isActive]);

  if (!isActive) return null;

  return (
    <div className="fixed inset-0 pointer-events-none z-50 overflow-hidden">
      {pieces.map((piece) => (
        <motion.div
          key={piece.id}
          initial={{ opacity: 1, y: '100vh', x: `${piece.x}vw` }}
          animate={{ 
            opacity: 0, 
            y: '-10vh', 
            x: [`${piece.x}vw`, `${piece.x + (Math.random() * 20 - 10)}vw`],
            rotate: [piece.rotation, piece.rotation + 360]
          }}
          transition={{ 
            duration: 1.5 + Math.random(), 
            ease: "easeOut" 
          }}
          style={{
            position: 'absolute',
            width: '10px',
            height: '10px',
            backgroundColor: piece.color,
            borderRadius: Math.random() > 0.5 ? '50%' : '2px',
          }}
        />
      ))}
    </div>
  );
};