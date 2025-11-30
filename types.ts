export interface Personality {
  id: string;
  name: string;
  field: string;
  bio: string;
  imageUrl?: string;
  wikiLink: string;
}

export interface KeptItem extends Personality {
  keptAt: number;
}

export interface ContextMenuPosition {
  x: number;
  y: number;
}

export type SwipeDirection = 'left' | 'right' | null;