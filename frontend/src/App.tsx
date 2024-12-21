import React, { useEffect, useState, useCallback, useRef } from 'react';
import styled from 'styled-components';
import Mopidy from "mopidy";
import { ArtistView } from './views/ArtistView';
import { AlbumView } from './views/AlbumView';
import { PlayerView } from './views/PlayerView';
import { HistoryView } from './views/HistoryView';
import type { ViewType } from './types/types';

const AppContainer = styled.div`
  display: flex;
  flex-direction: column;
  height: 100vh;
  max-height: 100vh;
  background: linear-gradient(135deg, #4158D0 0%, #C850C0 46%, #FFCC70 100%);
  color: white;
  font-family: 'Nunito', 'Comic Sans MS', sans-serif;
  overflow: hidden;
`;

const MainContent = styled.main`
  flex: 1;
  min-height: 0;
  padding: 0.50rem;
  text-align: left;
  overflow-y: auto;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  margin: 0.75rem;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  -webkit-overflow-scrolling: touch;
  overscroll-behavior: contain;
  scroll-behavior: smooth;
  position: relative;
  touch-action: none;
  
  /* Hide scrollbar for touch interface */
  &::-webkit-scrollbar {
    display: none;
  }
  -ms-overflow-style: none;
  scrollbar-width: none;
`;

const Navigation = styled.nav`
  display: flex;
  align-items: center;
  padding: 0.25rem;
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  border-bottom: 2px solid rgba(255, 255, 255, 0.1);
  box-shadow: 0 4px 30px rgba(0, 0, 0, 0.1);
  flex-shrink: 0;
`;

const NavButton = styled.button<{ $active?: boolean }>`
  background: ${props => props.$active 
    ? 'linear-gradient(135deg, rgba(255, 255, 255, 0.4), rgba(255, 255, 255, 0.2))' 
    : 'rgba(255, 255, 255, 0.1)'};
  border: none;
  color: white;
  font-size: 2.8rem;
  cursor: pointer;
  padding: 0.5rem 0.75rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.4rem;
  border-radius: 16px;
  transition: all 0.2s ease;
  margin-right: 0.5rem;
  flex: 1;
  box-shadow: ${props => props.$active 
    ? '0 6px 12px rgba(0, 0, 0, 0.15)' 
    : '0 4px 8px rgba(0, 0, 0, 0.1)'};

  &:active {
    transform: scale(0.98);
  }

  span {
    font-size: 0.9rem;
    font-weight: 600;
    opacity: 0.9;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }
`;

const NavIcons = styled.div`
  display: flex;
  flex: 1;
  gap: 1rem;
  justify-content: center;
  padding: 0.25rem;
  margin: 0 1rem;

  ${NavButton} {
    min-width: 0;
    flex: 1;
  }
`;

const WifiButton = styled(NavButton)`
  margin-left: 0;
  margin-right: 0;
  min-width: unset;
  width: 70px;
  height: 70px;
  flex: 0 0 auto;
  font-size: 2.2rem;
  padding: 0.75rem;
  background: ${props => props.$active 
    ? 'rgba(255, 255, 255, 0.25)' 
    : 'rgba(255, 255, 255, 0.1)'};
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
`;

const BackButton = styled(NavButton)`
  font-size: 2.4rem;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 14px;
  min-width: unset;
  width: 70px;
  height: 70px;
  flex: 0 0 auto;
  padding: 0.75rem;
  justify-content: center;
  margin-right: 0;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);

  &:active {
    transform: scale(0.95);
  }
`;

const HistoryButton = styled(BackButton)`
  background: rgba(255, 255, 255, 0.15);
  font-size: 2rem;
`;

const ParentSettings = styled.div`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.85);
  backdrop-filter: blur(10px);
  padding: 2rem;
  color: white;
  z-index: 1000;
  display: flex;
  flex-direction: column;
  align-items: center;

  h2 {
    font-size: 2rem;
    margin-bottom: 2rem;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  }

  button {
    padding: 1rem 2rem;
    font-size: 1.2rem;
    background: rgba(255, 255, 255, 0.15);
    border: none;
    border-radius: 12px;
    color: white;
    cursor: pointer;
    transition: all 0.2s;

    &:active {
      transform: scale(0.98);
      background: rgba(255, 255, 255, 0.2);
    }
  }
`;

interface NavigationState {
  uri: string;
  name: string;
  type: ViewType | 'root';
}

const ScrollableContent: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const contentRef = useRef<HTMLDivElement>(null);

  return (
    <MainContent
      ref={contentRef}
    >
      {children}
    </MainContent>
  );
};

const App: React.FC = () => {
  const [connected, setConnected] = useState(false);
  const [mopidyInstance, setMopidyInstance] = useState<Mopidy | null>(null);
  const [showSettings, setShowSettings] = useState(false);
  const [wifiClickCount, setWifiClickCount] = useState(0);
  const [lastClickTime, setLastClickTime] = useState(0);
  const [navigationQueue, setNavigationQueue] = useState<NavigationState[]>([{
    uri: "local:directory?type=artist",
    name: 'Root',
    type: 'root'
  }]);
  const [activeTab, setActiveTab] = useState('audiobooks');
  const [showHistory, setShowHistory] = useState(false);

  useEffect(() => {
    console.log('Initializing Mopidy...');
    let mopidy: Mopidy;
    
    const initMopidy = () => {
      mopidy = new Mopidy({
        webSocketUrl: '/mopidy/ws',
      });

      mopidy.on('websocket:error', () => {
        console.warn('WebSocket error - will retry connection');
      });

      mopidy.on('state:online', () => {
        console.log('Connected to Mopidy');
        setConnected(true);
        setMopidyInstance(mopidy);
        setNavigationQueue([{ 
          uri: "local:directory?type=artist",
          name: 'Root',
          type: 'root'
        }]);
        
        // Set initial volume to 40%
        try {
          if (mopidy.mixer) {
            mopidy.mixer.setVolume({ volume: 40 });
            console.log('Set initial volume to 40%');
          }
        } catch (error) {
          console.error('Failed to set initial volume:', error);
        }

        // Add window unload handler
        const handleUnload = () => {
          console.log('Window unloading, stopping playback...');
          if (mopidy.playback) {
            mopidy.playback.stop();
          }
        };

        window.addEventListener('beforeunload', handleUnload);
        window.addEventListener('unload', handleUnload);

        return () => {
          window.removeEventListener('beforeunload', handleUnload);
          window.removeEventListener('unload', handleUnload);
        };
      });

      mopidy.on('state:offline', () => {
        console.log('Disconnected from Mopidy');
        setConnected(false);
        setMopidyInstance(null);
      });
    };

    initMopidy();

    return () => {
      if (mopidy && mopidy.playback) {
        console.log('Cleaning up Mopidy connection...');
        // Stop playback before closing the connection
        mopidy.playback.stop()
          .then(() => {
            console.log('Playback stopped');
            mopidy.close();
            console.log('Mopidy connection closed');
          })
          .catch(error => {
            console.error('Error stopping playback:', error);
            mopidy.close();
          });
      } else if (mopidy) {
        mopidy.close();
      }
    };
  }, []);

  const handleArtistClick = (uri: string, name: string) => {
    setNavigationQueue(prev => [...prev, { uri, name, type: 'artists' }]);
  };

  const handleAlbumClick = async (uri: string, name: string) => {
    setNavigationQueue(prev => [...prev, { uri, name, type: 'albums' }]);
  };

  const handleBack = () => {
    if (navigationQueue.length > 1) {
      setNavigationQueue(prev => prev.slice(0, -1));
    }
  };

  const handleWifiClick = useCallback(() => {
    const currentTime = Date.now();
    if (currentTime - lastClickTime > 1000) {
      setWifiClickCount(1);
    } else {
      setWifiClickCount(prev => prev + 1);
    }
    setLastClickTime(currentTime);
  }, [lastClickTime]);

  useEffect(() => {
    if (wifiClickCount >= 7) {
      setShowSettings(true);
      setWifiClickCount(0);
    }
  }, [wifiClickCount]);

  const isPlayerView = () => {
    const currentLocation = navigationQueue[navigationQueue.length - 1];
    return currentLocation?.type === 'albums' || currentLocation?.type === 'tracks';
  };

  const handleHistoryClick = () => {
    if (navigationQueue.length === 1) { // Only in root view
      setShowHistory(prev => !prev);
    }
  };

  const renderCurrentView = () => {
    console.log('Navigation queue:', navigationQueue);
    console.log('Mopidy instance:', mopidyInstance);
    if (!connected) {
        //TODO: show loading animation instead of message
    }

    const currentLocation = navigationQueue[navigationQueue.length - 1];
    console.log('Current location:', currentLocation);
    if (!currentLocation) {
      return (
        <HistoryView
          mopidy={mopidyInstance}
          onAlbumClick={handleAlbumClick}
        />
      );
    }

    if (!mopidyInstance) {
      return <div>Loading...</div>;
    }

    switch (currentLocation.type) {
      case 'root':
        return (
          <ArtistView
            mopidy={mopidyInstance}
            onArtistClick={handleArtistClick}
          />
        );
      case 'artists':
        return (
          <AlbumView
            mopidy={mopidyInstance}
            artistUri={currentLocation.uri}
            artistName={currentLocation.name}
            onAlbumClick={handleAlbumClick}
          />
        );
      case 'albums':
      case 'tracks':
        return (
          <PlayerView
            mopidy={mopidyInstance}
            albumUri={currentLocation.uri}
            trackName={currentLocation.name}
            onBackClick={handleBack}
          />
        );
      default:
        return null;
    }
  };

  return (
    <AppContainer>
      {!isPlayerView() && (
        <Navigation>
          {navigationQueue.length > 1 ? (
            <BackButton onClick={handleBack} title="Back">
              ⬅️
            </BackButton>
          ) : (
            <HistoryButton onClick={handleHistoryClick} title="History">
              {showHistory ? '⬅️' : '⏱️'}
            </HistoryButton>
          )}
          <NavIcons>
            <NavButton 
              $active={activeTab === 'audiobooks'} 
              onClick={() => setActiveTab('audiobooks')}
              title="Audiobooks"
            >
              📚
            </NavButton>
            <NavButton 
              $active={activeTab === 'music'} 
              onClick={() => setActiveTab('music')}
              title="Music"
            >
              🎵
            </NavButton>
            <NavButton 
              $active={activeTab === 'favorites'} 
              onClick={() => setActiveTab('favorites')}
              title="Favorites"
            >
              ⭐
            </NavButton>
          </NavIcons>
          <WifiButton 
            onClick={handleWifiClick}
            title="Connection Status"
          >
            {connected ? '📶' : '📴'}
          </WifiButton>
        </Navigation>
      )}
      
      {isPlayerView() ? (
        renderCurrentView()
      ) : (
        <ScrollableContent>
          {renderCurrentView()}
        </ScrollableContent>
      )}

      {showSettings && (
        <ParentSettings>
          <h2>Parent Settings</h2>
          <button onClick={() => setShowSettings(false)}>Close</button>
        </ParentSettings>
      )}
    </AppContainer>
  );
};

export default App; 