import React, { useRef, useEffect } from 'react';
import { Image, Link, Trash2, X } from 'lucide-react';
import { ContextMenuPosition } from '../types';

interface ContextMenuProps {
  position: ContextMenuPosition;
  onClose: () => void;
  onSetImageLocal: () => void;
  onSetImageUrl: () => void;
  onClearImage: () => void;
}

export const ContextMenu: React.FC<ContextMenuProps> = ({
  position,
  onClose,
  onSetImageLocal,
  onSetImageUrl,
  onClearImage,
}) => {
  const menuRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        onClose();
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [onClose]);

  return (
    <div
      ref={menuRef}
      className="fixed z-50 w-56 bg-gray-800 border border-gray-700 rounded-lg shadow-xl overflow-hidden animate-in fade-in zoom-in duration-150"
      style={{ top: position.y, left: position.x }}
    >
      <div className="py-1">
        <button
          onClick={onSetImageLocal}
          className="w-full px-4 py-2.5 text-left text-sm text-gray-200 hover:bg-gray-700 flex items-center gap-2 transition-colors"
        >
          <Image size={16} />
          <span>Set Image (Local)...</span>
        </button>
        <button
          onClick={onSetImageUrl}
          className="w-full px-4 py-2.5 text-left text-sm text-gray-200 hover:bg-gray-700 flex items-center gap-2 transition-colors"
        >
          <Link size={16} />
          <span>Set Image from URL...</span>
        </button>
        <div className="h-px bg-gray-700 my-1"></div>
        <button
          onClick={onClearImage}
          className="w-full px-4 py-2.5 text-left text-sm text-red-400 hover:bg-gray-700 flex items-center gap-2 transition-colors"
        >
          <Trash2 size={16} />
          <span>Clear Image</span>
        </button>
        <button
          onClick={onClose}
          className="w-full px-4 py-2.5 text-left text-sm text-gray-400 hover:bg-gray-700 flex items-center gap-2 transition-colors lg:hidden"
        >
          <X size={16} />
          <span>Cancel</span>
        </button>
      </div>
    </div>
  );
};