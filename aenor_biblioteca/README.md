# Gestor local de normas UNE/ISO (AENOR)

Automatiza la búsqueda y descarga (dentro de tus permisos universitarios) de normas en AENOR **sin almacenar credenciales**.

## Requisitos

- Python 3.11+
- Navegador Chromium (Playwright lo descarga con `playwright install`)

## Instalación

```bash
python -m venv .venv
source .venv/bin/activate  # En Windows: .venv\Scripts\activate
pip install -U pip
pip install pandas openpyxl playwright
playwright install chromium
```

## Estructura creada automáticamente

Al ejecutar, se crea esta estructura bajo `--output` (por defecto `biblioteca_normas/`):

- `01_calidad_laboratorio/`
- `02_laboratorio_clinico_bioseguridad/`
- `03_agroalimentaria/`
- `04_medioambiente_sostenibilidad/`
- `05_agua_microbiologia_ambiental/`
- `06_biotecnologia_genomica/`
- `07_datos_ia_seguridad/`
- `informes/`
- `metadatos/`

## Ejecución

### Con interfaz gráfica (recomendado para login manual)

```bash
python aenor_biblioteca/gestor_normas_aenor.py --input aenor_biblioteca/normas.csv --output biblioteca_normas
```

### Modo headless

```bash
python aenor_biblioteca/gestor_normas_aenor.py --input aenor_biblioteca/normas.csv --output biblioteca_normas --headless
```

## Flujo funcional

1. Abre `https://plataforma.aenormas.aenor.com/`.
2. Te pide iniciar sesión manualmente solo la primera vez que haga falta.
3. Busca cada norma por código.
4. Si encuentra ficha, intenta descargar PDF.
5. Si ya existe PDF local de esa norma, la marca como `descargada` sin volver a bajar.
6. Genera informe final en:
   - CSV (`informes/reporte_biblioteca_*.csv`)
   - Excel (`informes/reporte_biblioteca_*.xlsx`)

## Columnas de informe

- `codigo_norma`
- `titulo_aproximado`
- `categoria`
- `url_ficha`
- `estado` (`localizada/no localizada/pendiente/descargada/no descargada`)
- `fecha_revision`
- `notas`

## Notas

- El script **no guarda usuario ni contraseña**.
- Los selectores web pueden cambiar si AENOR actualiza su interfaz.
- Usa la herramienta respetando siempre tus licencias y permisos de acceso.
