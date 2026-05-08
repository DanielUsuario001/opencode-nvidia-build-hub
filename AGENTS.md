# Instrucciones del workspace (OpenCode)

OpenCode carga este archivo al iniciar (ver `opencode.json` → `instructions`). Define reglas del proyecto y cómo debe responder el asistente en este repositorio.

## Contexto del workspace

Este NO es un proyecto: es un **hub de configuración** para construir múltiples SaaS y plataformas usando los modelos de NVIDIA Build (Mistral, DeepSeek, Kimi, Qwen, Nemotron…) a través de OpenCode.

El usuario habla **español**: responde siempre en español salvo que pida lo contrario.

## REGLA CRÍTICA: dónde crear proyectos

**Todo proyecto nuevo se crea SIEMPRE dentro de `projects/<nombre-del-proyecto>/`**.

- ✅ Correcto: `projects/saas-facturacion/`, `projects/plataforma-cursos/`
- ❌ Incorrecto: crear archivos del proyecto en la raíz del workspace
- ❌ Incorrecto: contaminar la raíz con `package.json`, `app/`, `node_modules/`, etc.

La raíz del workspace contiene SOLO:
- `opencode.json`, `AGENTS.md`, `.env`, `.env.example`, `.gitignore`, `.editorconfig`
- `start.ps1`, `README.md`
- Carpetas: `config/`, `scripts/`, `docs/`, `projects/`

Si el usuario pide "crea un SaaS de X", primero pregunta el nombre corto (kebab-case) o propón uno, y trabaja siempre dentro de `projects/<ese-nombre>/`.

Cada proyecto en `projects/` es **completamente independiente**: su propio `package.json`, su propio `.env.local`, su propia config. No comparte `node_modules` con la raíz.

## Stack preferido (cuando se cree un nuevo proyecto)

- **Framework web**: Next.js 16 (App Router) con TypeScript estricto.
- **UI**: Tailwind CSS + shadcn/ui.
- **DB**: Supabase (Postgres + Auth + Storage) o Neon Postgres si el usuario lo pide.
- **Auth**: Supabase Auth o Clerk según el caso.
- **Pagos**: Stripe.
- **Despliegue**: Vercel.
- **Gestor de paquetes**: pnpm.
- **Tests**: Vitest + Playwright.

Pregunta antes de instalar dependencias pesadas o cambiar el stack base.

## Reglas de trabajo

1. **Planifica antes de codear** en tareas con más de 3 pasos: muestra el plan, espera confirmación.
2. **No hardcodees secretos**. Cada proyecto usa su propio `projects/<nombre>/.env.local`.
3. **TypeScript estricto**: nada de `any` salvo justificación clara en comentario.
4. **Comentarios solo cuando aporten**: no narres lo obvio.
5. **Estructura de carpetas clara dentro de cada proyecto**: separa `app/`, `components/`, `lib/`, `server/`, `db/`.
6. **Migraciones versionadas** si se usa una BD relacional.
7. **Validación de inputs** con Zod en cualquier endpoint público.
8. **Errores tipados**: nunca `throw "string"`, usa `Error` o clases custom.
9. **Antes de instalar paquetes**, verifica que no exista ya algo equivalente.
10. **Commits pequeños** con mensajes en imperativo y en español. Para cada SaaS dentro de `projects/<nombre>/`, inicializa `git` ahí si quieres versionarlo aparte. **Excepción:** este repositorio plantilla del hub (raíz con `opencode.json` y `AGENTS.md`) puede versionarse con `git` en la raíz para compartir la configuración en GitHub.

## Estrategia de modelos (routing)

Cambia con `/models` en el TUI. 5 variantes activas y probadas:

| Variante | Velocidad real | Cuándo usarla |
|---|---|---|
| `nvidia-gptoss/120b` ⭐ | 14s, razonamiento interno | **Default**. Balance ideal: componentes, features, endpoints, TypeScript + Tailwind correcto |
| `nvidia-kimi/k2` | 7s — 16 tok/s | Tareas rápidas: fix puntual, snippet corto, preguntas, rename |
| `nvidia-mistral/plan` | lento (razonamiento alto) | Arquitectura, ADR, decisiones de stack, code review profundo |
| `nvidia-mistral/code` | ~41s | Mistral rápido para tareas medianas sin razonamiento |
| `nvidia-qwen/coder` | 74s | Features muy grandes que necesitan máximo detalle (usar con moderación) |

### Workflow recomendado

1. **Planifica** con `nvidia-mistral/plan` (Tab → modo plan). Mistral razona bien, propone arquitectura sólida.
2. **Implementa** con `nvidia-gptoss/120b` (default). Razonamiento interno, código limpio en ~14s.
3. **Fixes rápidos** (typo, rename, snippet puntual): cambia a `nvidia-kimi/k2` (necesitas `NVIDIA_API_KEY_KIMI` en `.env`).
4. **Review final** de vuelta a `nvidia-mistral/plan`.

`small_model` en `opencode.json` coincide con el modelo por defecto (`nvidia-gptoss/120b`) para que **una sola API key** (`NVIDIA_API_KEY_GPTOSS`) baste al clonar el repo. Si añades la key de Kimi, puedes poner `"small_model": "nvidia-kimi/k2"` para tareas internas más rápidas.

## Qué NO hacer

- NO crear archivos de proyecto en la raíz del workspace (siempre dentro de `projects/<nombre>/`).
- NO subir `.env` ni `.env.local` a git.
- NO desplegar a producción sin pasar tests.
- NO usar `--force` en git push sin pedir confirmación explícita.
- NO crear archivos README/markdown gigantes sin que el usuario los pida.
