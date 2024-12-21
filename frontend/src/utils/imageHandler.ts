import { getArtistImage as getSpotifyArtistImage, getAlbumImage as getSpotifyAlbumImage } from './spotify';

interface MopidyImage {
  __model__: string;
  height?: number;
  uri: string;
  width?: number;
}

const MOPIDY_HTTP_URL = import.meta.env.VITE_MOPIDY_HTTP_URL || 'http://localhost:6680';

export async function getImageUrl(mopidy: any, uri: string): Promise<string | undefined> {
  if (!uri) {
    console.error('No URI provided to getImageUrl');
    return undefined;
  }

  console.log(`Getting image for URI: ${uri}`);

  // Try Mopidy first
  try {
    console.log(`Fetching image from Mopidy for URI: ${uri}`);
    const images = await mopidy.library.getImages({ uris: [uri] });
    
    if (images && images[uri] && images[uri].length > 0) {
      const sortedImages = (images[uri] as MopidyImage[])
        .sort((a, b) => (b.width || 0) - (a.width || 0));
      
      const selectedImage = sortedImages[0];
      if (selectedImage && selectedImage.uri) {
        const mopidyImageUrl = `${MOPIDY_HTTP_URL}${selectedImage.uri}`;
        console.log(`Found Mopidy image: ${mopidyImageUrl}`);
        return mopidyImageUrl;
      }
    }
  } catch (error) {
    console.error(`Error fetching image from Mopidy:`, error);
  }

  // Try Spotify as fallback
  try {
    const lookupInfo = await mopidy.library.lookup({ uris: [uri] });
    if (!lookupInfo || !lookupInfo[uri]?.[0]) {
      console.log(`No lookup info found for URI: ${uri}`);
      return undefined;
    }

    const item = lookupInfo[uri][0];
    let spotifyUrl: string | null = null;

    if (item.artists?.[0]?.name) {
      console.log(`Searching Spotify for artist: ${item.artists[0].name}`);
      spotifyUrl = await getSpotifyArtistImage(item.artists[0].name);
    }

    if (!spotifyUrl && item.album?.name) {
      const artistName = item.artists?.[0]?.name || '';
      console.log(`Searching Spotify for album: ${item.album.name} by ${artistName}`);
      spotifyUrl = await getSpotifyAlbumImage(item.album.name, artistName);
    }

    if (spotifyUrl) {
      console.log(`Found Spotify image for URI: ${uri}`);
      return spotifyUrl;
    }
  } catch (error) {
    console.error(`Error fetching image from Spotify:`, error);
  }

  console.log(`No image found for URI: ${uri} from any source`);
  return undefined;
}