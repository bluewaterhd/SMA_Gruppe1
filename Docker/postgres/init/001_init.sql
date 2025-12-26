CREATE TABLE IF NOT EXISTS public.dokumente_log (
  id BIGSERIAL PRIMARY KEY,
  chunkId TEXT NOT NULL,
  titel TEXT NOT NULL,
  seiteStart INT,
  SeiteEnde INT,
  inhalt TEXT,
  tag TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);