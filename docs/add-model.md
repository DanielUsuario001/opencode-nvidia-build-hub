# Cómo añadir un modelo nuevo de NVIDIA Build

> NVIDIA Build emite **una API key por modelo**. Para usar un modelo distinto necesitas su propia clave.

## Opción A — Nuevo proyecto bajo `projects/`

```powershell
.\scripts\new-project.ps1 mi-saas
```

Crea la carpeta, un `README.md` y un `.gitignore` base. Los **providers de NVIDIA** se añaden editando `opencode.json` y `.env` (siguiente sección).

---

## Opción B — Añadir un provider de NVIDIA (manual)

### 1. Genera la API key

1. Entra en https://build.nvidia.com
2. Busca el modelo (DeepSeek V4 Pro, Kimi 2.6, etc.)
3. Pulsa **Get API Key** y copia la clave

### 2. Agrégala a `.env`

Descomenta o agrega la línea:

```bash
NVIDIA_API_KEY_DEEPSEEK=nvapi-tu-clave
```

### 3. Agrega el provider en `opencode.json`

Abre `config/providers.template.json`, copia el bloque del provider que quieres y pégalo dentro del objeto `provider` de `opencode.json`.

Por ejemplo:

```json
"provider": {
  "nvidia-mistral": { ... },
  "nvidia-deepseek": {
    "npm": "@ai-sdk/openai-compatible",
    "name": "NVIDIA Build - DeepSeek",
    "options": {
      "baseURL": "https://integrate.api.nvidia.com/v1",
      "apiKey": "{env:NVIDIA_API_KEY_DEEPSEEK}"
    },
    "models": {
      "deepseek-v4-pro": {
        "id": "deepseek-ai/deepseek-v4-pro",
        "name": "DeepSeek V4 Pro",
        "tool_call": true,
        "reasoning": true,
        "options": { "max_tokens": 16384, "temperature": 0.6 }
      }
    }
  }
}
```

### 4. Reinicia OpenCode

```powershell
.\start.ps1
```

Y desde el TUI: `/models` → seleccionas el nuevo modelo.

---

## Añadir un modelo que no está en la plantilla

Edita `config/providers.template.json` y agrega un bloque nuevo siguiendo el mismo patrón:

```json
"nvidia-mi-modelo": {
  "npm": "@ai-sdk/openai-compatible",
  "name": "NVIDIA Build - Mi Modelo",
  "options": {
    "baseURL": "https://integrate.api.nvidia.com/v1",
    "apiKey": "{env:NVIDIA_API_KEY_MIMODELO}"
  },
  "models": {
    "mi-alias": {
      "id": "vendor/exact-model-id-from-build-nvidia-com",
      "name": "Mi Modelo",
      "tool_call": true,
      "options": { "max_tokens": 16384, "temperature": 0.6 }
    }
  }
}
```

> El campo `"id"` debe coincidir EXACTAMENTE con el identificador que sale en la página del modelo en build.nvidia.com (mira el código de ejemplo Python que te dan ahí, en el campo `"model"`).

---

## Modelo por defecto al lanzar OpenCode

Edita el campo `"model"` en `opencode.json`. Por ejemplo, para que arranque con DeepSeek:

```json
"model": "nvidia-deepseek/deepseek-v4-pro"
```

Reinicia y listo.
