# CLAUDE.md

Guía para Claude Code (y para ti) al trabajar en este repo.

## Qué es

App web de una sola página para llevar el control de los cromos **repetidos**
y **faltantes** del álbum Panini del **Mundial 2026**, pensada para usarse desde
el móvil y publicada en **GitHub Pages**.

- **En vivo:** https://pollitosabroson.github.io/album-mundial-2026/
- **Repo:** https://github.com/pollitosabroson/album-mundial-2026 (público)

## Estructura

Solo dos archivos importan:

- `index.html` — toda la app (HTML + CSS + JS inline, sin dependencias ni build).
- `data.json` — los datos del usuario: `{ "repes": {...}, "faltan": {...} }`.

No hay framework, ni `package.json`, ni paso de compilación. Se edita el HTML
directamente.

## Modelo de datos

- `repes[CODE][num] = cantidad` — cromos que tienes repetidos (cantidad extra).
- `faltan[CODE] = [nums]` — números de cromo que te faltan de esa selección.
- Un cromo se considera **conseguido** si está en el rango de la selección y
  **no** está en `faltan`. Ver `ownedNums(code)`.
- Rango por selección: 20 por defecto; excepciones en `RANGE`
  (`PANINI:1`, `FWC:19`, `CC:14`). `maxOf(code)` lo resuelve.
- `ORDER` define el orden de las selecciones; `NAMES_ES`/`NAMES_EN` los nombres.
- `REPES_DEFAULT` / `FALTAN_DEFAULT` son copias de respaldo embebidas (fallback
  y base para "ver conseguidas"); deben mantenerse en sintonía con `data.json`.

## Flujo de datos (importante)

**`data.json` del repo es la fuente de verdad.**

1. Al cargar, `init()` hace `fetch('./data.json')` y **sobrescribe** el
   `localStorage` (el repo siempre manda al entrar).
2. Las ediciones en la UI se guardan en `localStorage` como copia de trabajo de
   la sesión y marcan el estado "sucio".
3. Cuando hay cambios sin volcar, aparece un **banner** con el botón
   **"Generar data.json"** (descarga el archivo).
4. El usuario reemplaza `data.json` en el repo, hace commit + push, y al recargar
   la web ya muestra los datos nuevos.

Si `fetch` falla (p. ej. abierto como `file://`), cae a `localStorage` o a los
valores por defecto.

## Pestañas

- **Mis repes** — solo cromos con repe (`q>=1`). Botones −/+ por chip. El selector
  "Añadir repe manualmente" sirve para registrar una repe nueva.
- **Me faltan** — los que faltan (chips rojos); "Ver conseguidas" muestra también
  los obtenidos.
- **Estadísticas** — `computeStats()` + `renderStats()`: progreso, estimación de
  sobres/coste para completar (modelo del coleccionista, `PER_PACK=7` cromos a
  `PACK_PRICE=1.5 €`), próximo sobre, rankings (PANINI se excluye del de "más
  completas") y resumen de repes.

## Convenciones

- Estilo del código existente: JS compacto, funciones cortas, sin librerías.
  Mantener todo inline en `index.html`.
- Bilingüe ES/EN: cualquier texto nuevo va en `STR.es` **y** `STR.en`, y se
  pinta con `t('clave')`.
- Tras tocar la UI, `render()` repinta todo desde `data`.

## Verificar cambios

No hay tests. Para comprobar visualmente/interactivamente sin desplegar:

```bash
# servir en local
python3 -m http.server 8799   # luego abrir http://localhost:8799/
```

Se ha usado el Chrome del sistema vía DevTools Protocol (Node + WebSocket nativo)
para clics e inspección del DOM, y `--headless --screenshot` para capturas. Si el
MCP de Playwright está cargado, usarlo en su lugar.

Comprobación rápida de sintaxis del script embebido:

```bash
awk '/<script>/{f=1;next}/<\/script>/{f=0}f' index.html > /tmp/_c.js && node --check /tmp/_c.js
```

## Deploy (GitHub Pages)

Pages sirve desde `main` / raíz. Publicar = push a `main`:

```bash
git add data.json index.html && git commit -m "..." && git push
```

El build tarda ~30-60 s. Estado:
`gh api repos/pollitosabroson/album-mundial-2026/pages/builds/latest --jq '.status'`.
`gh` ya está configurado como credential helper de git en esta máquina.
