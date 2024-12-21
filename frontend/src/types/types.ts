export interface MopidyImage {
  height?: number;
  width?: number;
  uri: string;
}

export interface MopidyRef {
  name: string;
  type: string;
  uri: string;
  images?: MopidyImage[];
}

export interface LibraryItem extends MopidyRef {
  imageUrl?: string;
  type: 'artist' | 'album' | 'track';
  artists?: { name: string }[];
}export type ViewType = 'artists' | 'albums' | 'tracks'; 

