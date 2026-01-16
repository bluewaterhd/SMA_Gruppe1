# SMA_Gruppe1
RAG-System

---

# Dokumentation
Diese README beschreibt, wie du das Projekt aus GitHub holst (pull/clone) und lokal mit Docker Compose startest, sodass n8n, PostgreSQL, Qdrant, Ollama und Docling laufen. 


## Voraussetzungen  
- Git installiert  
- Docker Desktop (Docker Engine) läuft  
- Docker Compose verfügbar (docker compose ...)  
- (Optional) Zotero Account + Zotero API Key (für Ingestion)


### 1. Projekt aus Github holen 
**Prozess (Clone)**
1. Terminal offnen 

2. In einen gewünschten Ordner wechseln: 
cd ~/Projects  
 
3. Repository klonen: 
git clone <GITHUB_REPO_URL>  
 
4. In den Projektordner wechseln: 
cd <REPO_ORDNERNAME> 

**Prozess (Pull)**
1. In den Projektordner wechseln: 
cd <REPO_ORDNERNAME> 

2. Neueste Änderungen holen: 
git pull 


### 2. Docker Compose Datei finden 
Die Docker-Datei befindet sich im Docker-Ordern, weil dort die docker-compose.yml liegt. 
docker-compose.yml anzeigen lassen: 
MacOS / Linux: 
cd SMA_Gruppe1/Docker 
ls 

Windows: 
cd SMA_Gruppe1\Docker 
Dir 


### 3. Docker Compose starten 

1. Container starten
docker compose up -d  
 
2. Status prüfen: 
docker compose ps  
 
3. Logs ansehen (falls etwas nicht läuft, Optional): 
docker compose logs -f  


### 4. Zugriff auf n8n 
n8n: http://localhost:5678/ öffnen (Bei MacOS nicht über Safari öffnen) 

Qdrant lauft intern auf Port 6333 

Ollama läuft intern auf Port 11434  

Docling läuft intern auf Port 5001  

PostgreSQL lauft intern auf Port 5432 


### 5. Zotero
1. Zotero Account anlegen
2. Zotero App herunterladen oder im Browser ausführen
3. Zotero Collector Extension für Firefox installieren
4. In Settings Zotero API Key erstellt und gespeichert
(Optional:) Zotero Gruppe erstellen, damit mehrere auf die gleiche Library zugreifen können


### 6. n8n Workflow importieren & starten 
1. n8n im Browser offnen 

2. Workflows importieren (über n8n UI) 

3. Credentials setzen: 
- PostgreSQL Credentials (aus .env) 
- Zotero API Key / IDs  

4. Ingestion starten (manueller Trigger) 

Wenn n8n meldet „You cannot execute a workflow without an ID": 
Stelle sicher, dass du den Workflow in n8n gespeichert hast (Save), bevor du ihn ausführst.  

 

Falls Fehler auftauchen sollten, bitte in die Dokumentation nachschauen.


