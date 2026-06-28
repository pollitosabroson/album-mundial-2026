#!/bin/bash
# Doble clic para probar la app en local (sirve por HTTP para que funcione data.json).
cd "$(dirname "$0")" || exit 1

# busca un puerto libre a partir de 8090 (evita choques con Docker en 8000, etc.)
PORT=8090
while lsof -ti tcp:$PORT >/dev/null 2>&1; do PORT=$((PORT+1)); done

( sleep 1; open "http://localhost:$PORT/" ) &
echo "Sirviendo en http://localhost:$PORT/  (Ctrl+C para parar)"
python3 -m http.server "$PORT"
