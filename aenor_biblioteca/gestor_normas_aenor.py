#!/usr/bin/env python3
"""Gestor local de normas UNE/ISO para consulta en AENOR.

Flujo principal:
1) Lee normas desde CSV o JSON.
2) Abre AENOR en navegador controlado con Playwright.
3) Pide login manual solo cuando haga falta (sin guardar credenciales).
4) Busca cada norma y registra metadatos/estado.
5) Detecta descargas existentes y organiza carpetas.
6) Exporta informe en CSV y Excel.

Uso:
    python gestor_normas_aenor.py --input normas.csv --output ./biblioteca_normas
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any

import pandas as pd
from playwright.sync_api import BrowserContext, Page, TimeoutError, sync_playwright

AENOR_URL = "https://plataforma.aenormas.aenor.com/"
DEFAULT_TIMEOUT_MS = 15000

CATEGORY_FOLDERS = {
    "calidad_laboratorio": "01_calidad_laboratorio",
    "laboratorio_clinico_bioseguridad": "02_laboratorio_clinico_bioseguridad",
    "agroalimentaria": "03_agroalimentaria",
    "medioambiente_sostenibilidad": "04_medioambiente_sostenibilidad",
    "agua_microbiologia_ambiental": "05_agua_microbiologia_ambiental",
    "biotecnologia_genomica": "06_biotecnologia_genomica",
    "datos_ia_seguridad": "07_datos_ia_seguridad",
}


@dataclass
class Norma:
    codigo: str
    categoria: str
    notas: str = ""


def slugify_filename(text: str) -> str:
    """Normaliza texto para nombre de archivo."""
    slug = re.sub(r"[^\w\-. ]+", "", text, flags=re.UNICODE).strip()
    slug = re.sub(r"\s+", "_", slug)
    return slug or "norma"


def ensure_structure(output_root: Path) -> dict[str, Path]:
    """Crea estructura de carpetas objetivo y devuelve rutas por categoría."""
    output_root.mkdir(parents=True, exist_ok=True)
    folders: dict[str, Path] = {}
    for key, folder_name in CATEGORY_FOLDERS.items():
        target = output_root / folder_name
        target.mkdir(parents=True, exist_ok=True)
        folders[key] = target

    (output_root / "informes").mkdir(exist_ok=True)
    (output_root / "metadatos").mkdir(exist_ok=True)
    (output_root / "_descargas_temporales").mkdir(exist_ok=True)
    return folders


def read_normas(input_path: Path) -> list[Norma]:
    """Carga normas desde CSV o JSON.

    Formato mínimo esperado:
    - CSV: columnas codigo,categoria,notas(opcional)
    - JSON: lista de objetos con las mismas claves
    """
    if not input_path.exists():
        raise FileNotFoundError(f"No existe el archivo de entrada: {input_path}")

    suffix = input_path.suffix.lower()
    if suffix == ".csv":
        df = pd.read_csv(input_path)
    elif suffix == ".json":
        data = json.loads(input_path.read_text(encoding="utf-8"))
        df = pd.DataFrame(data)
    else:
        raise ValueError("Formato no soportado. Usa CSV o JSON.")

    required = {"codigo", "categoria"}
    missing = required - set(df.columns)
    if missing:
        raise ValueError(f"Faltan columnas requeridas: {missing}")

    normas: list[Norma] = []
    for _, row in df.iterrows():
        codigo = str(row["codigo"]).strip()
        categoria = str(row["categoria"]).strip()
        notas = str(row.get("notas", "")).strip()
        if not codigo:
            continue
        normas.append(Norma(codigo=codigo, categoria=categoria, notas=notas))
    return normas


def wait_for_manual_login(page: Page) -> None:
    """Permite al usuario autenticarse manualmente, sin capturar credenciales."""
    print("\n[LOGIN] Si AENOR pide autenticación universitaria, iníciala manualmente.")
    print("[LOGIN] No se guardará usuario/contraseña.\n")
    input("Cuando termines de iniciar sesión y estés en AENOR, pulsa ENTER...")


def maybe_existing_file(category_folder: Path, codigo: str) -> Path | None:
    pattern = slugify_filename(codigo)
    for file in category_folder.glob("*.pdf"):
        if pattern.lower() in file.stem.lower():
            return file
    return None


def safe_text(locator: Any) -> str:
    try:
        return locator.inner_text(timeout=3000).strip()
    except Exception:
        return ""


def buscar_norma(page: Page, codigo: str) -> dict[str, str]:
    """Busca norma y devuelve metadatos detectados en resultados.

    Nota: los selectores pueden variar con cambios en AENOR.
    """
    result = {
        "titulo_aproximado": "",
        "url_ficha": "",
        "estado_localizacion": "no localizada",
    }

    page.goto(AENOR_URL, wait_until="domcontentloaded", timeout=DEFAULT_TIMEOUT_MS)

    search_selectors = [
        "input[type='search']",
        "input[placeholder*='Buscar']",
        "input[name*='search']",
        "input[id*='search']",
    ]

    search_input = None
    for sel in search_selectors:
        loc = page.locator(sel)
        if loc.count() > 0:
            search_input = loc.first
            break

    if search_input is None:
        result["estado_localizacion"] = "pendiente"
        return result

    search_input.fill(codigo)
    search_input.press("Enter")

    try:
        page.wait_for_load_state("networkidle", timeout=DEFAULT_TIMEOUT_MS)
    except TimeoutError:
        pass

    first_link = page.locator("a:has-text('ISO'), a:has-text('UNE')").first
    if first_link.count() == 0:
        return result

    result["titulo_aproximado"] = safe_text(first_link)
    href = first_link.get_attribute("href") or ""
    if href.startswith("http"):
        result["url_ficha"] = href
    elif href:
        result["url_ficha"] = f"https://plataforma.aenormas.aenor.com{href}"

    result["estado_localizacion"] = "localizada"
    return result


def intentar_descarga(context: BrowserContext, page: Page) -> tuple[str, Path | None]:
    """Intenta descargar desde la ficha abierta.

    Devuelve estado de descarga y ruta temporal si la hubo.
    """
    download_selectors = [
        "a:has-text('Descargar')",
        "button:has-text('Descargar')",
        "a:has-text('PDF')",
        "button:has-text('PDF')",
    ]

    button = None
    for sel in download_selectors:
        loc = page.locator(sel)
        if loc.count() > 0:
            button = loc.first
            break

    if button is None:
        return "no descargada", None

    try:
        with page.expect_download(timeout=DEFAULT_TIMEOUT_MS) as dl_info:
            button.click()
        download = dl_info.value
        temp_path = download.path()
        if temp_path is None:
            return "no descargada", None
        return "descargada", Path(temp_path)
    except Exception:
        return "no descargada", None


def procesar_normas(normas: list[Norma], output_root: Path, headless: bool) -> pd.DataFrame:
    folders = ensure_structure(output_root)
    today = datetime.now().strftime("%Y-%m-%d")
    registros: list[dict[str, str]] = []

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=headless)
        context = browser.new_context(accept_downloads=True)
        page = context.new_page()

        page.goto(AENOR_URL, wait_until="domcontentloaded")
        wait_for_manual_login(page)

        for idx, norma in enumerate(normas, start=1):
            categoria_folder = folders.get(norma.categoria)
            if categoria_folder is None:
                categoria_folder = output_root / "metadatos"

            existing = maybe_existing_file(categoria_folder, norma.codigo)
            if existing:
                registros.append(
                    {
                        "codigo_norma": norma.codigo,
                        "titulo_aproximado": existing.stem,
                        "categoria": norma.categoria,
                        "url_ficha": "",
                        "estado": "descargada",
                        "fecha_revision": today,
                        "notas": f"Archivo ya existente: {existing.name}",
                    }
                )
                continue

            print(f"[{idx}/{len(normas)}] Buscando: {norma.codigo}")
            found = buscar_norma(page, norma.codigo)
            estado = "no localizada"
            temp_download: Path | None = None

            if found["estado_localizacion"] == "localizada" and found["url_ficha"]:
                page.goto(found["url_ficha"], wait_until="domcontentloaded")
                estado_descarga, temp_download = intentar_descarga(context, page)
                estado = estado_descarga
            else:
                estado = found["estado_localizacion"]

            notas = norma.notas
            if temp_download:
                file_name = f"{slugify_filename(norma.codigo)}.pdf"
                final_path = categoria_folder / file_name
                shutil.move(str(temp_download), str(final_path))
                notas = f"{notas} | Guardada en {final_path.name}".strip(" |")

            registros.append(
                {
                    "codigo_norma": norma.codigo,
                    "titulo_aproximado": found["titulo_aproximado"],
                    "categoria": norma.categoria,
                    "url_ficha": found["url_ficha"],
                    "estado": estado,
                    "fecha_revision": today,
                    "notas": notas,
                }
            )

        context.close()
        browser.close()

    return pd.DataFrame(registros)


def exportar_reportes(df: pd.DataFrame, output_root: Path) -> tuple[Path, Path]:
    informes = output_root / "informes"
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    csv_path = informes / f"reporte_biblioteca_{ts}.csv"
    xlsx_path = informes / f"reporte_biblioteca_{ts}.xlsx"

    df.to_csv(csv_path, index=False, encoding="utf-8-sig")
    df.to_excel(xlsx_path, index=False)
    return csv_path, xlsx_path


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Gestor de normas UNE/ISO en AENOR")
    parser.add_argument("--input", required=True, type=Path, help="Ruta a normas.csv o normas.json")
    parser.add_argument("--output", default=Path("biblioteca_normas"), type=Path, help="Directorio de salida")
    parser.add_argument("--headless", action="store_true", help="Ejecutar navegador sin interfaz")
    return parser


def main() -> None:
    args = build_parser().parse_args()
    normas = read_normas(args.input)
    df = procesar_normas(normas, args.output, headless=args.headless)
    csv_report, xlsx_report = exportar_reportes(df, args.output)

    print("\nProceso finalizado.")
    print(f"- Reporte CSV: {csv_report}")
    print(f"- Reporte XLSX: {xlsx_report}")


if __name__ == "__main__":
    main()
