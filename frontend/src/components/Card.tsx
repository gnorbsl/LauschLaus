import React from 'react';
import styled from 'styled-components';

const CardContainer = styled.li`
  padding: 0.25rem;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  cursor: pointer;
  transition: transform 0.2s, background 0.2s;
  -webkit-tap-highlight-color: transparent;
  touch-action: manipulation;
  will-change: transform, background;
  transform: translateZ(0);
  backface-visibility: hidden;
  
  @media (hover: hover) {
    &:hover {
      background: rgba(255, 255, 255, 0.3);
      transform: scale(1.02) translateZ(0);
    }
  }
  
  &:active {
    transform: scale(0.98) translateZ(0);
    background: rgba(255, 255, 255, 0.3);
  }
`;

const CardContent = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 0.15rem;
`;

const CoverArt = styled.img`
  width: 135px;
  height: 135px;
  object-fit: cover;
  border-radius: 6px;
  background-color: rgba(255, 255, 255, 0.1);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
`;

const Title = styled.div`
  font-size: 0.85rem;
  font-weight: bold;
  word-wrap: break-word;
  opacity: 0.9;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
  max-width: 135px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  padding: 0 0.25rem;
`;

interface CardProps {
  name: string;
  imageUrl?: string;
  onClick: () => void;
}

const getEmoji = (name: string): string => {
  const emojiMap: Record<string, string> = {
    'Aladdin': '🧞',
    'Bob der Baumeister': '👷',
    'Das Dschungelbuch': '🐯',
    'Die Playmos': '🎮',
    'PAW Patrol': '🐕',
    'Ratatouille': '🐀',
    'Tarzan': '🦍'
  };
  
  return emojiMap[name] || '🎵';
};

const handleImageError = (e: React.SyntheticEvent<HTMLImageElement, Event>, name: string) => {
  console.log(`Image failed to load for ${name}, falling back to emoji`);
  const target = e.target as HTMLImageElement;
  target.src = `https://placehold.co/100x100/rgba(255,255,255,0.1)/white?text=${getEmoji(name)}`;
};

export const Card: React.FC<CardProps> = React.memo(({ name, imageUrl, onClick }) => {
  const handleTouch = React.useCallback((e: React.TouchEvent) => {
    e.preventDefault();
    onClick();
  }, [onClick]);

  return (
    <CardContainer 
      onClick={onClick}
      onTouchStart={handleTouch}
    >
      <CardContent>
        <CoverArt 
          loading="lazy"
          src={imageUrl || `https://placehold.co/100x100/rgba(255,255,255,0.1)/white?text=${getEmoji(name)}`}
          alt={name}
          onError={(e) => handleImageError(e, name)}
        />
        <Title>{name}</Title>
      </CardContent>
    </CardContainer>
  );
}); 