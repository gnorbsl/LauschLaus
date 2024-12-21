import React, { useEffect, useState } from 'react';
import styled from 'styled-components';
import { Card } from '../components/Card';
import { getImageUrl } from '../utils/imageHandler';
import type { LibraryItem } from '../types/types';
import type Mopidy from 'mopidy';

const Grid = styled.ul`
  list-style: none;
  padding: 0;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 0.25rem;
  justify-content: center;
`;

interface ArtistViewProps {
  mopidy: Mopidy;
  onArtistClick: (uri: string, name: string) => void;
}

export const ArtistView: React.FC<ArtistViewProps> = ({ mopidy, onArtistClick }) => {
  const [artists, setArtists] = useState<LibraryItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [blobUrls, setBlobUrls] = useState<Map<string, string>>(new Map());

  useEffect(() => {
    const loadArtists = async () => {
        console.log('Loading artists...');
        console.log(mopidy);
      try {
        setLoading(true);
        const items = await mopidy.library.browse({ uri: "local:directory?type=artist" });
        console.log('Artists:', items);
        blobUrls.forEach(url => URL.revokeObjectURL(url));
        const newBlobUrls = new Map<string, string>();
        
        const artistsWithImages = await Promise.all(
          items.map(async (item: LibraryItem) => {
            try {
              const imageUrl = await getImageUrl(mopidy, item.uri);
              if (imageUrl) {
                console.log(`Successfully loaded image for ${item.name}: ${imageUrl}`);
                newBlobUrls.set(item.uri, imageUrl);
              }
            } catch (error) {
              console.error(`Error processing artist image for ${item.name}:`, error);
            }
            return item;
          })
        );
        
        setBlobUrls(newBlobUrls);
        setArtists(artistsWithImages);
      } catch (error) {
        console.error('Error loading artists:', error);
      } finally {
        setLoading(false);
      }
    };

    loadArtists();

    return () => {
      blobUrls.forEach(url => URL.revokeObjectURL(url));
    };
  }, [mopidy]);

  if (loading) {
    return <div>Loading artists...</div>;
  }

  return (
    <Grid>
      {artists.map((artist) => (
        <Card
          key={artist.uri}
          name={artist.name}
          imageUrl={blobUrls.get(artist.uri)}
          onClick={() => onArtistClick(artist.uri, artist.name)}
        />
      ))}
    </Grid>
  );
}; 