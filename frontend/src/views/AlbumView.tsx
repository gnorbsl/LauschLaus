import React, { useEffect, useState } from 'react';
import styled from 'styled-components';
import { Card } from '../components/Card';
import { getImageUrl } from '../utils/imageHandler';
import { LibraryItem } from '../types/types';

const Grid = styled.ul`
  list-style: none;
  padding: 0;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 0.25rem;
  justify-content: center;
`;

interface AlbumViewProps {
  mopidy: any;
  artistUri: string;
  artistName: string;
  onAlbumClick: (uri: string, name: string) => void;
}

export const AlbumView: React.FC<AlbumViewProps> = ({ 
  mopidy, 
  artistUri, 
  artistName,
  onAlbumClick 
}) => {
  const [albums, setAlbums] = useState<LibraryItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadAlbums = async () => {
      try {
        setLoading(true);

        const items = await mopidy.library.browse({ uri: artistUri });
        console.log('Albums:', items);

        // Get image URLs for all albums
        const albumsWithImages = await Promise.all(
          items.map(async (item: LibraryItem) => {
            try {
              const imageUrl = await getImageUrl(mopidy, item.uri);
              return {
                ...item,
                imageUrl
              };
            } catch (error) {
              console.error(`Error getting image for album ${item.name}:`, error);
              return item;
            }
          })
        );

        setAlbums(albumsWithImages);
      } catch (error) {
        console.error('Error loading albums:', error);
      } finally {
        setLoading(false);
      }
    };

    loadAlbums();
  }, [mopidy, artistUri, artistName]);

  if (loading) {
    return <div>Loading albums...</div>;
  }

  return (
    <>
      <Grid>
        {albums.map((album) => (
          <Card
            key={album.uri}
            name={album.name}
            imageUrl={album.imageUrl}
            onClick={() => onAlbumClick(album.uri, album.name)}
          />
        ))}
      </Grid>
    </>
  );
}; 