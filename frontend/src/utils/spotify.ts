import { SpotifyApi } from '@spotify/web-api-ts-sdk';

let spotifyApi: SpotifyApi | null = null;
let initializationPromise: Promise<void> | null = null;

const initializeSpotifyApi = async () => {
  if (initializationPromise) {
    return initializationPromise;
  }

  initializationPromise = (async () => {
    try {
      const clientId = import.meta.env.VITE_SPOTIFY_CLIENT_ID;
      const clientSecret = import.meta.env.VITE_SPOTIFY_CLIENT_SECRET;

      if (!clientId || !clientSecret) {
        throw new Error('Spotify credentials are not configured. Please check your .env file.');
      }

      spotifyApi = await SpotifyApi.withClientCredentials(clientId, clientSecret);
    } catch (error) {
      console.error('Failed to initialize Spotify API:', error);
      spotifyApi = null;
      throw error;
    } finally {
      initializationPromise = null;
    }
  })();

  return initializationPromise;
};

const ensureSpotifyApi = async () => {
  if (!spotifyApi) {
    await initializeSpotifyApi();
  }
  if (!spotifyApi) {
    throw new Error('Failed to initialize Spotify API');
  }
  return spotifyApi;
};

export async function getArtistImage(artistName: string): Promise<string | null> {
  try {
    const api = await ensureSpotifyApi();
    const result = await api.search(artistName, ['artist'], undefined, 1);
    
    if (result.artists.items?.[0]?.images?.[0]) {
      return result.artists.items[0].images[0].url;
    }
    return null;
  } catch (error) {
    console.error('Error fetching artist image:', error);
    return null;
  }
}

export async function getAlbumImage(albumName: string, artistName: string): Promise<string | null> {
  try {
    const api = await ensureSpotifyApi();
    console.log(`${albumName} ${artistName}`);
    const result = await api.search(`${albumName} ${artistName}`, ['album'], undefined, 1);
    
    if (result.albums?.items?.[0]?.images?.[0]) {
      return result.albums.items[0].images[0].url;
    }
    return null;
  } catch (error) {
    console.error('Error fetching album image:', error);
    return null;
  }
} 