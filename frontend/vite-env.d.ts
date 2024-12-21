interface ImportMetaEnv {
        readonly VITE_SPOTIFY_CLIENT_ID: string;
        readonly VITE_SPOTIFY_CLIENT_SECRET: string;
        readonly VITE_MOPIDY_WS_URL: string;
        readonly VITE_MOPIDY_HTTP_URL: string;
        readonly VITE_PORT: string;

   
  }
  
  interface ImportMeta {
    readonly env: ImportMetaEnv;
  }
  
