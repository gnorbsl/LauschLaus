import React, { useEffect, useState, useRef } from 'react';
import styled from 'styled-components';
import Marquee from 'react-fast-marquee';
import { getImageUrl } from '../utils/imageHandler';

const PlayerContainer = styled.div`
  display: flex;
  height: 100vh;
  width: 100vw;
  position: relative;
  background: linear-gradient(135deg, #4158D0 0%, #C850C0 46%, #FFCC70 100%);
`;

const ControlsContainer = styled.div`
  width: 35%;
  display: flex;
  flex-direction: column;
  padding: 0.5rem;
  padding-bottom: 2rem;
  background: rgba(0, 0, 0, 0.3);
  backdrop-filter: blur(5px);
  z-index: 2;
`;

const BackButton = styled.button`
  background: rgba(255, 255, 255, 0.15);
  border: none;
  border-radius: 50%;
  width: 70px;
  height: 70px;
  min-width: 70px;
  min-height: 70px;
  align-items: center;
  justify-content: center;
  font-size: 3rem;
  border: 1px solid rgba(255, 255, 255, 0.1);
`;

const TitleContainer = styled.div`
  margin: 2rem 0;
  padding: 0.5rem;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  backdrop-filter: blur(5px);
`;

const Title = styled.div`
  font-size: 1.4rem;
  color: rgba(255, 255, 255, 0.9);
  text-align: center;
  font-weight: bold;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
  padding: 0 4rem;
`;

const Controls = styled.div`
  display: flex;
  flex-direction: column;
  gap: 1rem;
  align-items: top;
  flex: 1;
  justify-content: start;
`;

const ProgressBar = styled.div`
  width: 100%;
  height: 4px;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 2px;
  position: relative;
  overflow: hidden;
`;

const Progress = styled.div<{ width: number }>`
  position: absolute;
  left: 0;
  top: 0;
  height: 100%;
  width: ${props => props.width}%;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 2px;
  transition: width 0.3s linear;
`;

const MainControlButton = styled.button`
  background: rgba(255, 255, 255, 0.15);
  border: none;
  border-radius: 50%;
  width: 90px;
  height: 90px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2.2rem;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid rgba(255, 255, 255, 0.1);

  &:active {
    transform: scale(0.95);
    background: rgba(255, 255, 255, 0.2);
  }
`;

const SecondaryControlButton = styled(MainControlButton)`
  width: 70px;
  height: 70px;
  font-size: 1.8rem;
  background: rgba(255, 255, 255, 0.1);
`;

const PlaybackControls = styled.div`
  display: flex;
  gap: 1rem;
  align-items: center;
  justify-content: center;
  width: 100%;
`;

const VolumeControls = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
`;

const VolumeButton = styled(SecondaryControlButton)`
  width: 70px;
  height: 70px;
  font-size: 1.6rem;
  background: rgba(255, 255, 255, 0.08);
`;

const VolumeLevel = styled.div`
  width: 60%;
  height: 40px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
`;

const VolumePyramid = styled.div`
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: row;
  gap: 2px;
  align-items: center;
  justify-content: center;
`;

const VolumeBar = styled.div<{ active: boolean; level: 'safe' | 'medium' | 'loud' }>`
  height: 100%;
  width: 4px;
  background: ${props => props.active
    ? props.level === 'safe'
      ? '#4CAF50'  // Green
      : props.level === 'medium'
        ? '#FFC107'  // Yellow
        : '#F44336'  // Red
    : 'rgba(255, 255, 255, 0.1)'};
  border-radius: 3px;
  transition: all 0.2s ease;
`;

const VolumeEmoji = styled.div`
  font-size: 1.2rem;
  margin-top: 0.25rem;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
`;

const CoverContainer = styled.div`
  flex: 1;
  height: 100vh;
  overflow: hidden;
`;

const AlbumArt = styled.div<{ imageUrl?: string }>`
  padding: 1rem;
  width: 100%;
  height: 100%;
  background: ${props => props.imageUrl 
    ? `url(${props.imageUrl})` 
    : 'linear-gradient(135deg, rgba(255, 255, 255, 0.1), rgba(255, 255, 255, 0.05))'};
  background-size: contain;
  background-position: center;
  background-repeat: no-repeat;
`;

interface PlayerViewProps {
  mopidy: any;
  albumUri: string;
  trackName: string;
  onBackClick: () => void;
}

export const PlayerView: React.FC<PlayerViewProps> = ({ mopidy, albumUri, trackName, onBackClick }) => {
  const [isPlaying, setIsPlaying] = useState(false);
  const [trackImage, setTrackImage] = useState<string>();
  const [volume, setVolume] = useState(50);
  const [progress, setProgress] = useState(0);
  const [currentTrackName, setCurrentTrackName] = useState(trackName);
  const progressInterval = useRef<number>();

  const loadImage = async (uri: string) => {
    try {
      const imageUrl = await getImageUrl(mopidy, uri);
      if (imageUrl) {
        console.log('Image loaded:', imageUrl);
        setTrackImage(imageUrl);
      }
    } catch (error) {
      console.error('Error loading image:', error);
    }
  };

  const updateCurrentTrack = async () => {
    try {
      console.log('Updating current track...');
      const [currentTrack, state] = await Promise.all([
        mopidy.playback.getCurrentTrack(),
        mopidy.playback.getState()
      ]);
      
      console.log('Current track:', JSON.stringify(currentTrack, null, 2));
      console.log('Current playback state:', state);

      if (currentTrack) {
        console.log('Setting track name to:', currentTrack.name);
        setCurrentTrackName(currentTrack.name);
        
        if (currentTrack.album?.uri) {
          console.log('Loading image for album URI:', currentTrack.album.uri);
          await loadImage(currentTrack.album.uri);
        }
      }
      setIsPlaying(state === 'playing');
    } catch (error) {
      console.error('Error getting current track:', error);
    }
  };

  useEffect(() => {
    let isMounted = true;

    const setup = async () => {
      try {
        //clear the tracklist
        await mopidy.tracklist.clear();
        // Get initial volume
        const vol = await mopidy.mixer.getVolume();
        if (isMounted) setVolume(vol);

        // First, get the current track to find its album URI
        const albumTracks = await mopidy.library.lookup({ uris: [albumUri] }) as {[uri: string]: any[]};
       //sort the tracks by name with localCompare
        const sortedTracks = albumTracks[albumUri].sort((a: any, b: any) => a.name.localeCompare(b.name, undefined, { numeric: true }));
        console.log('Sorted tracks:', sortedTracks.map((t: any) => t.name));
        
        //add the tracks to the tracklist
        await mopidy.tracklist.add({ uris: sortedTracks.map((t: any) => t.uri) });
        //play the first track
        await mopidy.playback.play({ tlid: 1 });
        
        if (isMounted) {
          setIsPlaying(true);
          await updateCurrentTrack();
        }
      } catch (error) {
        console.error('Error in setup:', error);
      }
    };

    setup();

    // Set up progress tracking
    progressInterval.current = window.setInterval(() => {
      Promise.all([
        mopidy.playback.getTimePosition(),
        mopidy.playback.getState(),
        mopidy.tracklist.getTracks()
      ]).then(([position, state, tracks]) => {
        if (isMounted && state === 'playing' && tracks[0]?.length) {
          setProgress((position / tracks[0].length) * 100);
        }
      });
    }, 1000);

    return () => {
      isMounted = false;
      mopidy.playback.stop();
      if (progressInterval.current) {
        clearInterval(progressInterval.current);
      }
    };
  }, [mopidy, albumUri]);

  // Track change event listeners
  useEffect(() => {
    // Listen to all relevant track change events
    const events = [
      'event:trackPlaybackStarted',
      'event:trackPlaybackResumed',
      'event:trackPlaybackPaused',
      'event:trackPlaybackEnded',
      'event:playbackStateChanged',
      'event:tracklistChanged'  // Added this to catch all track changes
    ];

    events.forEach(event => {
      mopidy.on(event, updateCurrentTrack);
    });

    return () => {
      events.forEach(event => {
        mopidy.off(event, updateCurrentTrack);
      });
    };
  }, [mopidy]);

  const togglePlayPause = () => {
    if (isPlaying) {
      mopidy.playback.pause();
    } else {
      mopidy.playback.play();
    }
    setIsPlaying(!isPlaying);
  };

  const adjustVolume = (delta: number) => {
    const newVolume = Math.max(0, Math.min(100, volume + delta));
    mopidy.mixer.setVolume({ volume: newVolume });
    setVolume(newVolume);
  };

  const skipTrack = async (direction: 'next' | 'prev') => {
    try {
      console.log(`Skipping to ${direction} track...`);
      
      // Get current track index and all tracks
      const currentTlTrack = await mopidy.playback.getCurrentTlTrack();
      const allTlTracks = await mopidy.tracklist.getTlTracks();
      
      if (!currentTlTrack || !allTlTracks.length) {
        console.log('No tracks available');
        return;
      }

      // Type for TlTrack (Mopidy's timed track)
      interface TlTrack {
        tlid: number;
        track: any;
      }

      const currentIndex = allTlTracks.findIndex((track: TlTrack) => track.tlid === currentTlTrack.tlid);
      console.log('Current track index:', currentIndex, 'Total tracks:', allTlTracks.length);
      
      // Check if we're at the edges
      if (direction === 'prev' && currentIndex <= 0) {
        console.log('Already at first track, staying here');
        return;
      }
      
      if (direction === 'next' && currentIndex >= allTlTracks.length - 1) {
        console.log('Already at last track, staying here');
        return;
      }

      if (direction === 'next') {
        await mopidy.playback.next();
        console.log('Skipped to next track');
      } else {
        await mopidy.playback.previous();
        console.log('Skipped to previous track');
      }
      
      // Give Mopidy a moment to update its state
      await new Promise(resolve => setTimeout(resolve, 100));
      
      console.log('Updating track info after skip...');
      await updateCurrentTrack();
    } catch (error) {
      console.error('Error skipping track:', error);
    }
  };

  return (
    <PlayerContainer>
      <ControlsContainer>
        <BackButton onClick={onBackClick} title="Back">
          ⬅️
        </BackButton>

        <TitleContainer>
          <Marquee gradient={false} speed={40}>
            <Title>{currentTrackName}</Title>
          </Marquee>
        </TitleContainer>

        <Controls>
          <ProgressBar>
            <Progress width={progress} />
          </ProgressBar>

          <PlaybackControls>
            <SecondaryControlButton onClick={() => skipTrack('prev')} title="Previous">
              ⏮️
            </SecondaryControlButton>
            <MainControlButton onClick={togglePlayPause} title="Play/Pause">
              {isPlaying ? '⏸️' : '▶️'}
            </MainControlButton>
            <SecondaryControlButton onClick={() => skipTrack('next')} title="Next">
              ⏭️
            </SecondaryControlButton>
          </PlaybackControls>

          <VolumeControls>
            <VolumeButton onClick={() => adjustVolume(-5)} title="Volume Down">
              🔉
            </VolumeButton>
            <VolumeLevel>
              <VolumePyramid>
                {[...Array(20)].map((_, index) => {
                  const barValue = (index + 1) * 5;
                  const isActive = volume >= barValue;
                  const level = barValue <= 40 ? 'safe' : barValue <= 70 ? 'medium' : 'loud';
                  return (
                    <VolumeBar 
                      key={index}
                      active={isActive}
                      level={level}
                      style={{
                        height: `${10 + index * 1.5}px`,
                      }}
                    />
                  );
                })}
              </VolumePyramid>
              <VolumeEmoji>
                {volume <= 40 ? '😌' : volume <= 70 ? '😊' : '😳'}
              </VolumeEmoji>
            </VolumeLevel>
            <VolumeButton onClick={() => adjustVolume(5)} title="Volume Up">
              🔊
            </VolumeButton>
          </VolumeControls>
        </Controls>
      </ControlsContainer>

      <CoverContainer>
        <AlbumArt imageUrl={trackImage} />
      </CoverContainer>
    </PlayerContainer>
  );
}; 