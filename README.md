<div align="center">

# OpenCode · NVIDIA Build Hub

**Plantilla de workspace** para orquestar [OpenCode](https://opencode.ai) con modelos de [NVIDIA Build](https://build.nvidia.com) (API compatible con OpenAI), más proveedores opcionales (Google Gemini, MCP).

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![OpenCode docs](https://img.shields.io/badge/OpenCode-docs-6366f1)](https://opencode.ai/docs)
[![NVIDIA Build](https://img.shields.io/badge/NVIDIA-Build-76B900?logo=nvidia&logoColor=white)](https://build.nvidia.com/explore/discover)

[Características](#-qué-incluye) · [Inicio rápido](#-inicio-rápido) · [Variables de entorno](#-variables-de-entorno) · [Modelos](#-modelos-y-flujo-de-trabajo) · [Seguridad](#-seguridad)

</div>

---

## Por qué existe este repo

La raíz del workspace es **solo configuración de OpenCode**: reglas (`AGENTS.md`), proveedores (`opencode.json`), tema TUI (`tui.json`) y scripts auxiliares. Todo lo que construyas (SaaS, landings, APIs) vive en `projects/<nombre>/`, con su propio `package.json` y `.env.local` cuando toque.

Así puedes **clonar, copiar `.env.example` → `.env`, instalar OpenCode y empezar** sin mezclar el código de producto con la config del hub.

---

## Qué incluye

| Área | Detalle |
|------|---------|
| **Proveedores** | NVIDIA (Mistral, Kimi, Qwen, GPT-OSS), Google Gemini, MCP `fetch` y Brave Search (opcional, desactivado por defecto) |
| **Windows** | `start.ps1` carga `.env`, valida claves y lanza OpenCode; `-Test` hace smoke test HTTP |
| **Plantillas** | `config/providers.template.json` para copiar bloques JSON al añadir modelos |
| **Proyectos** | `scripts/new-project.ps1` crea el esqueleto bajo `projects/` |

> **Nota:** por defecto `.gitignore` **no versiona** el contenido de `projects/*` (solo `README.md` y `.gitkeep`). Así el hub queda limpio en GitHub; cada SaaS puede tener su propio repositorio dentro de su carpeta.

---

## Requisitos

- **Windows** con PowerShell (el launcher está pensado para `.ps1`).
- **Node.js + npm** (OpenCode se instala con `npm i -g opencode-ai` si no existe).
- **Python 3.11+** (solo para `.\start.ps1 -Test` y el venv local `.venv/`).
- Cuenta en **NVIDIA Build** y claves por modelo que vayas a usar.

---

## Inicio rápido

```powershell
git clone <tu-repo>.git
cd <tu-repo>

Copy-Item .env.example .env
# Edita .env: con la config por defecto basta NVIDIA_API_KEY_GPTOSS (build.nvidia.com → modelo gpt-oss-120b → Get API Key)

.\start.ps1 -Test
.\start.ps1
```

Si PowerShell bloquea los scripts: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` (una vez).

Dentro del TUI de OpenCode:

| Acción | Cómo |
|--------|------|
| Cambiar modelo | `/models` |
| Reglas del workspace | `AGENTS.md` (referenciado en `opencode.json`) |
| Salir | `Ctrl+C` (dos veces según tu terminal) |

Documentación oficial OpenCode: [opencode.ai/docs](https://opencode.ai/docs)

---

## Variables de entorno

Crea `.env` desde `.env.example`. **No subas `.env`**; ya está en `.gitignore`.

| Variable | Uso |
|----------|-----|
| `NVIDIA_API_KEY_MISTRAL` | Provider `nvidia-mistral` |
| `NVIDIA_API_KEY_KIMI` | Provider `nvidia-kimi` (opcional; pon `"small_model": "nvidia-kimi/k2"` en `opencode.json` si quieres Kimi para tareas internas) |
| `NVIDIA_API_KEY_QWEN` | Provider `nvidia-qwen` |
| `NVIDIA_API_KEY_GPTOSS` | Provider `nvidia-gptoss` (modelo por defecto del hub) |
| `GOOGLE_GENERATIVE_AI_API_KEY` | Modelos Gemini en `opencode.json` |
| `BRAVE_API_KEY` | MCP Brave Search; pon `"enabled": true` en `opencode.json` → `mcp.brave-search` cuando la tengas |

Cada modelo en NVIDIA Build puede tener **su propia** API key: entra al modelo en [build.nvidia.com](https://build.nvidia.com) → **Get API Key**.

---

## Modelos y flujo de trabajo

La matriz recomendada está en [`AGENTS.md`](./AGENTS.md). Resumen alineado con esta plantilla:

1. **Plan / arquitectura** → `nvidia-mistral/plan`
2. **Implementación diaria** → `nvidia-gptoss/120b` (default en `opencode.json`)
3. **Cambios pequeños rápidos** → `nvidia-kimi/k2` (tras añadir `NVIDIA_API_KEY_KIMI` y opcionalmente `"small_model": "nvidia-kimi/k2"`)

Por defecto `small_model` usa el mismo `nvidia-gptoss/120b` que el modelo principal para no exigir dos claves al clonar. Ajusta `"model"` y `"small_model"` en `opencode.json` si tu equipo prefiere otra combinación.

---

## Estructura del repositorio

```
.
├── opencode.json          # Providers, modelo por defecto, MCP, permisos
├── tui.json               # Tema del TUI
├── AGENTS.md              # Reglas del workspace (idioma, projects/, stack…)
├── start.ps1              # Launcher Windows
├── LICENSE                # MIT
├── .env.example           # Plantilla sin secretos
├── .gitignore
├── config/
│   └── providers.template.json
├── docs/
│   └── add-model.md       # Cómo añadir modelos NVIDIA
├── scripts/
│   ├── new-project.ps1
│   ├── test_nvidia.py
│   └── requirements.txt
└── projects/              # Tus SaaS (ignorados en git salvo README / .gitkeep)
    └── README.md
```

---

## Añadir modelos o providers

Guía paso a paso: [`docs/add-model.md`](./docs/add-model.md). Resumen: copia un bloque desde `config/providers.template.json` al objeto `provider` de `opencode.json`, añade la variable `NVIDIA_API_KEY_*` en `.env`, reinicia OpenCode.

---

## Solución de problemas

| Síntoma | Qué hacer |
|--------|-----------|
| `no se puede cargar el archivo ... start.ps1` / scripts bloqueados | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |
| `ERROR: no hay ninguna API key reconocible` | Las claves NVIDIA deben empezar por `nvapi-` y tener longitud suficiente (no pegues espacios ni comillas de más). Con la config por defecto rellena al menos `NVIDIA_API_KEY_GPTOSS`. |
| `404` / `401` al usar un modelo | La key es de **otro** modelo en Build, o el `id` del modelo en `opencode.json` no coincide con el de la página del modelo. |
| OpenCode no instalado | El script ejecuta `npm install -g opencode-ai`. Necesitas Node + npm en el PATH. |
| `python` no encontrado | Instala Python 3.11+ y marca “Add to PATH”, o usa solo `.\start.ps1` sin `-Test`. |

---

## Seguridad

- **Nunca** commitees `.env`, `.env.local` ni claves en issues o PRs.
- Si una clave llegó a un historial público, **revócala y genera otra** en el panel del proveedor.
- El MCP **Brave Search** está en `enabled: false` por defecto para que un clon fresco no falle sin `BRAVE_API_KEY`. Actívalo cuando tengas clave.

---

## Licencia

Este proyecto se publica bajo la licencia **MIT** — ver [`LICENSE`](./LICENSE).
