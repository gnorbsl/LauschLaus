import React, { useEffect, useState } from 'react';
import styled from 'styled-components';
import { Card } from '../components/Card';
import { getImageUrl } from '../utils/imageHandler';
import type { LibraryItem } from '../types/types';

const Grid = styled.ul`
  list-style: none;
  padding: 0;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 0.25rem;
  justify-content: center;
`;

const HistoryItem = styled.div`
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  backdrop-filter: blur(10px);
  
  .timestamp {
    font-size: 0.8rem;
    opacity: 0.7;
  }

  .artist-name {
    font-size: 0.8rem;
    opacity: 0.8;
  }
`;

interface HistoryLibraryItem extends LibraryItem {
  timestamp: number;
  artistName?: string;
}

interface HistoryViewProps {
  mopidy: any;
  onAlbumClick: (uri: string, name: string, artistName?: string) => void;
}

export const HistoryView: React.FC<HistoryViewProps> = ({ mopidy, onAlbumClick }) => {
  const [historyItems, setHistoryItems] = useState<HistoryLibraryItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [blobUrls, setBlobUrls] = useState<Map<string, string>>(new Map());

  useEffect(() => {
    const loadHistory = async () => {
      if (!mopidy) return;

      try {
        setLoading(true);
        const history = await mopidy.history.getHistory();
        console.log('Raw history:', history);

        // Process history data
        const processedHistory = await Promise.all(
          history.map(async ([timestamp, track]: [number, any]) => {
            try {
              // Get track info
              const trackInfo = await mopidy.library.lookup({ uris: [track.uri] });
              const trackDetails = trackInfo[track.uri]?.[0];
              if (!trackDetails?.album?.uri) return null;

              // Get album images
              const imageUrl = await getImageUrl(mopidy, trackDetails.album.uri);
              if (imageUrl) {
                setBlobUrls(prev => new Map(prev).set(trackDetails.album.uri, imageUrl));
              }

              return {
                uri: trackDetails.album.uri,
                name: trackDetails.album.name,
                type: 'albums' as const,
                artistName: trackDetails.artists?.[0]?.name,
                timestamp
              };
            } catch (error) {
              console.error('Error processing track:', error);
              return null;
            }
          })
        );

        // Filter out nulls and duplicates, keep only latest entry per album
        const latestByAlbum = processedHistory
          .filter((item): item is NonNullable<typeof item> => item !== null)
          .reduce((acc, current) => {
            const existing = acc.get(current.uri);
            if (!existing || existing.timestamp < current.timestamp) {
              acc.set(current.uri, current as HistoryLibraryItem);
            }
            return acc;
          }, new Map<string, HistoryLibraryItem>());

        const sortedItems = Array.from(latestByAlbum.values()) as HistoryLibraryItem[];
        setHistoryItems(sortedItems.sort((a, b) => b.timestamp - a.timestamp));
      } catch (error) {
        console.error('Error loading history:', error);
      } finally {
        setLoading(false);
      }
    };

    loadHistory();

    return () => {
      blobUrls.forEach(url => URL.revokeObjectURL(url));
    };
  }, [mopidy]);

  const formatTimestamp = (timestamp: number) => {
    const date = new Date(timestamp);
    return date.toLocaleString();
  };

  if (loading) {
    return <div>Loading history...</div>;
  }

  return (
    <Grid>
      {historyItems.map((item) => (
        <HistoryItem
          key={`${item.uri}-${item.timestamp}`}
          onClick={() => onAlbumClick(item.uri, item.name, item.artistName)}
        >
          <div className="timestamp">{formatTimestamp(item.timestamp)}</div>
          <Card
            name={item.name}
            imageUrl={blobUrls.get(item.uri)}
            onClick={() => onAlbumClick(item.uri, item.name, item.artistName)}
          />
          {item.artistName && (
            <div className="artist-name">{item.artistName}</div>
          )}
        </HistoryItem>
      ))}
      {historyItems.length === 0 && (
        <div>No playback history available</div>
      )}
    </Grid>
  );
}; 