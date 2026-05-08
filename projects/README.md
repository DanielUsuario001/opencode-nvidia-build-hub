# projects/

Carpeta donde **OpenCode crea todos los proyectos** (SaaS, plataformas, prototipos).

## Convención

Cada proyecto vive en su propia subcarpeta:

```
projects/
├── mi-saas-facturacion/
│   ├── package.json
│   ├── app/
│   ├── .env.local
│   └── ...
├── plataforma-cursos/
└── prototipo-chat-ia/
```

## Reglas

- **Cada proyecto es independiente**: tiene su propio `package.json`, su propio `.env.local`, su propio `.git` si hace falta.
- **No se trackean en este repo**: `.gitignore` ignora todo lo que está dentro de `projects/` excepto este README. Si quieres versionar un proyecto, inicializa git dentro de su carpeta (`cd projects/mi-saas && git init`).
- **El contexto compartido vive en la raíz**: `opencode.json`, `AGENTS.md` y las claves del hub en `.env` (no versionado). OpenCode los lee desde donde lances `start.ps1`.

## Crear un proyecto nuevo

Opción rápida con el helper:

```powershell
.\scripts\new-project.ps1 mi-saas-facturacion
```

Crea la carpeta vacía con un `README.md` y un `.gitignore` base. Luego en OpenCode describe lo que quieres construir en esa ruta.

Ejemplo de prompt:

> *"Crea un SaaS de facturación con Next.js 16, Supabase y Stripe en `projects/saas-facturacion/`. Plantea la arquitectura primero."*

Las reglas en `AGENTS.md` indican que todo proyecto nuevo debe vivir aquí dentro.
