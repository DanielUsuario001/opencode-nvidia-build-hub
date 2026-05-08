"""Smoke test contra la API OpenAI-compatible de NVIDIA Build."""

from __future__ import annotations

import os
import sys

BASE_URL = "https://integrate.api.nvidia.com/v1"

KEY_VARS = (
    "NVIDIA_API_KEY_MISTRAL",
    "NVIDIA_API_KEY_GPTOSS",
    "NVIDIA_API_KEY_KIMI",
    "NVIDIA_API_KEY_QWEN",
    "NVIDIA_API_KEY",
)

DEFAULT_MODELS: dict[str, str] = {
    "NVIDIA_API_KEY_MISTRAL": "mistralai/mistral-medium-3.5-128b",
    "NVIDIA_API_KEY_GPTOSS": "openai/gpt-oss-120b",
    "NVIDIA_API_KEY_KIMI": "moonshotai/kimi-k2-instruct",
    "NVIDIA_API_KEY_QWEN": "qwen/qwen3-coder-480b-a35b-instruct",
    "NVIDIA_API_KEY": "mistralai/mistral-medium-3.5-128b",
}


def pick_key() -> tuple[str, str]:
    for name in KEY_VARS:
        raw = os.environ.get(name, "")
        value = raw.strip().strip('"').strip("'")
        if not value or value.startswith("#"):
            continue
        if not value.startswith("nvapi-"):
            continue
        if len(value) < 32:
            continue
        return name, value
    return "", ""


def main() -> int:
    name, key = pick_key()
    if not key:
        print(
            "ERROR: define al menos una NVIDIA_API_KEY_* válida en .env "
            "(prefijo nvapi-, longitud suficiente).",
            file=sys.stderr,
        )
        return 1

    model = os.environ.get("NVIDIA_TEST_MODEL", "").strip()
    if not model:
        model = DEFAULT_MODELS.get(name, "mistralai/mistral-medium-3.5-128b")

    try:
        from openai import OpenAI
    except ImportError:
        print("ERROR: ejecuta pip install -r scripts/requirements.txt", file=sys.stderr)
        return 1

    client = OpenAI(base_url=BASE_URL, api_key=key)
    try:
        response = client.chat.completions.create(
            model=model,
            messages=[{"role": "user", "content": "Responde exactamente: ok"}],
            max_tokens=16,
        )
        text = (response.choices[0].message.content or "").strip()
        print(f"OK  variable={name} model={model} reply={text[:120]!r}")
        return 0
    except Exception as exc:  # noqa: BLE001 — CLI smoke test
        print(f"ERROR llamando a la API ({name}): {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
