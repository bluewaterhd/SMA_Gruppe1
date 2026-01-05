# SMA_Gruppe1
RAG-System

---

# Dokumentation

## Ingestion Pipeline
### Zotero
**Setup**
- Zotero Account anlegen
- Zotero App herunterladen oder im Browser ausführen
- Zotero Collector Extension für Firefox installieren
- In Settings Zotero API Key erstellt und gespeichert
- (Optional:) Zotero Gruppe erstellen, damit mehrere auf die gleiche Library zugreifen können

**Nutzung**
- PDFs über den Zotero Connector in die Library laden
- In **n8n**:
  - Für Gruppen-Libraries wird die **Group ID** verwendet
  - Für persönliche Libraries muss die **persönliche User ID** verwendet werden
 
### Docker & Datenbanken
**Qdrant**
Qdrant Collection wird beim Start über `docker-compose` initialisiert:
```bash
curl -s -X PUT http://qdrant:6333/collections/chunks \
  -H "Content-Type: application/json" \
  --data-raw '{
    "vectors": { "size": 768, "distance": "Cosine" }
  }'
```

**PostgreSQL**
Postgres wird über ein Init-Script initialisiert:
```volumes:
  - ./postgres/init:/docker-entrypoint-initdb.d
```
001_init.sql:
```bash 
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
```

### n8n Workflow
**Allgemeines:**
* Ein manueller Trigger startet die Ingestion für alle Zotero-Elemente (TODO: Zotero Filing – nur neue Dokumente verarbeiten)
* Ein Set Node definiert Konstanten wie:
  * Zotero API Key
  * API URLs
* Zotero Items werden sequenziell verarbeitet

**Zotero Datenabruf**  
Unterschieden in 
* Parent Item
  * Enthält Metadaten (Titel, Autor, Jahr, etc.)
* Attachment (PDF)
  * enthält eigentliche PDF
Request für Parent Item:
`https://api.zotero.org/groups/<groupId>/items/top`
Request für Attachment:
`https://api.zotero.org/groups/<groupId>/items/children`
Request für PDF Download:
`https://api.zotero.org/groups/<groupId>/items/<key>/file`
Zotero GET Request liefern Items, Key wird genutzt um die gewünschte PDF herunterzuladen
Jeder Zotero API Request muss API Key und Zotero Version im Request Header hinzugefügt sein (siehe Requests in n8n)  

**PDF Chunking (docling)**  
Unterscheidung nach Dateigröße
* Kleine PDFs (< 2 MB): synchron verarbeitet
* Große PDFs (≥ 2 MB): asynchron verarbeitet  

Chunking Endpoints:  
Synchron:  `http://docling:5001/v1/chunk/hybrid/file`  
Asynchron: `http://docling:5001/v1/chunk/hybrid/file/async`  

Chunking-Konfiguration:  
* Max Tokens: 800
* Sehr nahe Chunks werden gemerged (merge_peers)
* Tokenizer: MiniLM-L6-v2  

Asynchrones Chunken wird jede Minute nach Ergebnis gepollt und nach Success wird das Ergebnis eingeholt  
Polling: `http://docling:5001/v1/status/poll/<taskId>`  
Ergebnis: `Ergebnis: http://docling:5001/v1/result/<taskId>`  

**Chunk Verarbeitung**
Ergebnis ist ein Chunk Array  
Chunks werden:
1. in einzelne Chunks gesplittet
2. formattiert (Schema entspricht SQL Tabelle)
3. in PostgreSQL gespeichert
PostreSQL Credentials müssen aus `.env` entnommen werden

**Embeddings**
Chunks werden in Batches von 3 via Ollama Embedding API verarbeitet  
Ollama API Endpunkt: `http://ollama:11434/api/embeddings`
Request Body enthält Embedding Modell (nomic-embed-text) und prompt (Chunk Text)  
Ergebnis ist ein numerischer Vektor (Embedding) pro Chunk  

**Speicherung in Qdrant**
Endpoint: `http://qdrant:6333/collections/chunks/points`  
Im request body wird Vektorpunkt Schema spezifiziert:  
```bash
{{
  {
    "points": [
      {
        "id": <id>,
        "vector": <embedding>,
        "payload": {
          "chunkid": <chunkid>,
          "titel": <titel>,
          "seitestart": <seitestart>,
          "seiteende": <seiteende>,
          "text": <inhalt>,
          "tag": <tag>
        }
      }
    ]
  }
}}
```
gespeichert wird:
* eindeutige ChunkID
* Vektorpunkt (Embedding)
* vollständigen Metadaten
