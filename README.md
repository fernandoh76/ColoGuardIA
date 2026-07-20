# ColoGuardIA

**ColoGuardIA** es una aplicación web interactiva desarrollada en [R/Shiny](https://shiny.posit.co/) para el análisis de metilación de ADN mediante PCR, orientada al cribado de cáncer colorrectal. Permite procesar múltiples muestras simultáneamente y cuenta con un módulo de **control de calidad basado en inteligencia artificial** (Isolation Forest).

## ¿Qué es la app?

ColoGuardIA interpreta resultados de PCR de metilación para los genes **SDC2** y **TFPI2**, biomarcadores utilizados en la detección temprana de cáncer colorrectal. A partir de los valores de ciclo umbral (Ct) cargados en un CSV, la app:

- Valida cada muestra según el umbral del gen de referencia.
- Determina si cada gen marcador está **metilado** o **no metilado**.
- Emite una interpretación global por muestra: **Positivo** (algún gen metilado) o **Negativo** (sin metilación detectada).
- Genera gráficos de barras de Ct por muestra y gen.
- Ejecuta un modelo de **detección de anomalías offline** (Isolation Forest) para marcar muestras con patrones de Ct inusuales.
- Ofrece interfaz completamente bilingüe: **español e inglés**.

## Demo en línea

La app está desplegada públicamente en shinyapps.io:

👉 **<https://fernandoh76ve.shinyapps.io/shinyappproject/>**

## Requisitos previos

| Requisito | Versión mínima |
|-----------|----------------|
| R         | ≥ 4.0.0        |
| RStudio   | Cualquier versión reciente (recomendado) |

## Instalación de dependencias

Ejecuta lo siguiente en la consola de R para instalar todos los paquetes necesarios:

```r
install.packages(c("shiny", "shinydashboard", "DT", "ggplot2", "solitude"))
```

| Paquete          | Uso en la app                                      |
|------------------|----------------------------------------------------|
| `shiny`          | Framework de la aplicación web                     |
| `shinydashboard` | Diseño de panel con menú lateral y cajas           |
| `DT`             | Tablas interactivas de resultados                  |
| `ggplot2`        | Gráficos de Ct por muestra                         |
| `solitude`       | Modelo Isolation Forest para detección de anomalías|

## Cómo ejecutar la app

**Desde RStudio:**

1. Abre el archivo `app.R`.
2. Haz clic en el botón **Run App** (esquina superior derecha del editor).

**Desde la consola de R:**

```r
shiny::runApp("app.R")
```

**Desde la terminal / línea de comandos:**

```bash
Rscript -e "shiny::runApp('app.R')"
```

La app se abrirá en tu navegador predeterminado en `http://127.0.0.1:<puerto>`.

## Formato del archivo CSV de entrada

El archivo CSV debe contener exactamente estas cuatro columnas (en cualquier orden):

| Columna    | Tipo    | Descripción                                    |
|------------|---------|------------------------------------------------|
| `SampleID` | texto   | Identificador único de la muestra              |
| `Ct_Ref`   | numérico| Valor Ct del gen de referencia                 |
| `Ct_SDC2`  | numérico| Valor Ct del gen marcador SDC2                 |
| `Ct_TFPI2` | numérico| Valor Ct del gen marcador TFPI2                |

- Los valores vacíos o faltantes son aceptados; la muestra se clasificará como **"Sin Ct_Ref"** (si falta `Ct_Ref`) o se indicará **"Sin dato"** en el gen correspondiente.
- El separador debe ser coma (`,`) y el archivo debe estar codificado en UTF-8.

### Archivos de ejemplo incluidos

El repositorio incluye tres CSV de prueba listos para usar:

| Archivo          | Descripción                                                  |
|------------------|--------------------------------------------------------------|
| `test_data_1.csv`| 4 muestras; incluye un valor faltante de `Ct_SDC2`          |
| `test_data_2.csv`| 30 muestras con valores normales y casos atípicos extremos   |
| `test_data_3.csv`| 18 muestras con validez mixta y múltiples valores faltantes  |

## Estructura del proyecto

```
ColoGuardIA/
├── app.R              # Código completo de la aplicación Shiny (UI + servidor)
├── test_data_1.csv    # Datos de prueba: caso básico con valor faltante
├── test_data_2.csv    # Datos de prueba: 30 muestras incluyendo anomalías
├── test_data_3.csv    # Datos de prueba: validez mixta y múltiples NA
├── .gitignore         # Archivos y carpetas excluidos del control de versiones
├── CONTRIBUTING.md    # Guía para contribuir al proyecto
└── rsconnect/         # Metadatos de despliegue en shinyapps.io (auto-generado)
```

## Parámetros de configuración

Los umbrales de interpretación se definen al inicio de `app.R` y pueden modificarse directamente en el código:

```r
ct_ref_SDC2        <- 38.0   # Ct ≤ umbral → SDC2 metilado
ct_ref_TFPI2       <- 38.0   # Ct ≤ umbral → TFPI2 metilado
reference_threshold <- 36.0  # Ct_Ref > umbral → muestra inválida
```

| Variable              | Valor por defecto | Descripción                                              |
|-----------------------|-------------------|----------------------------------------------------------|
| `ct_ref_SDC2`         | `38.0`            | Umbral de Ct para SDC2: valores ≤ se interpretan como metilados |
| `ct_ref_TFPI2`        | `38.0`            | Umbral de Ct para TFPI2: valores ≤ se interpretan como metilados |
| `reference_threshold` | `36.0`            | Umbral de validez: muestras con `Ct_Ref > 36` se marcan como inválidas |

> Edita estas tres líneas antes de ejecutar la app para adaptar los umbrales a tu protocolo de laboratorio.

## Módulo de IA — Detección de anomalías

La pestaña **IA / Control de calidad** aplica un modelo **Isolation Forest** (paquete `solitude`) sobre los valores `Ct_Ref`, `Ct_SDC2` y `Ct_TFPI2` para identificar muestras con patrones estadísticamente inusuales.

### Opciones del módulo

| Opción                                       | Descripción                                                      |
|----------------------------------------------|------------------------------------------------------------------|
| Sensibilidad (slider 1 %–30 %)               | Proporción esperada de muestras marcadas como "Revisar"          |
| Aplicar QC solo a muestras válidas           | Recomendado; excluye muestras inválidas del análisis IA          |

### Requisitos

- **Mínimo 5 muestras** en el conjunto evaluado.
- Se deben procesar los datos primero (pestaña **Ingreso de datos** → botón **Procesar**).

### Interpretación de resultados

| Flag QC   | Significado                                           |
|-----------|-------------------------------------------------------|
| `OK`      | Muestra con patrón de Ct dentro de lo esperado        |
| `Revisar` | Muestra con anomalía estadística; requiere revisión manual |

> ⚠️ Este módulo es una herramienta de apoyo al control de calidad de laboratorio. **No reemplaza el criterio clínico ni el juicio del profesional de la salud.**

## Notas de uso y solución de problemas

| Problema                                     | Causa probable                        | Solución                                                    |
|----------------------------------------------|---------------------------------------|-------------------------------------------------------------|
| Error al cargar el CSV                       | Formato incorrecto                    | Verifica que sea un CSV UTF-8 con separador coma            |
| "Columnas faltantes o incorrectas"           | Nombres de columna con espacios o errores tipográficos | Corrige el encabezado del CSV para que coincida exactamente con `SampleID`, `Ct_Ref`, `Ct_SDC2`, `Ct_TFPI2` |
| El botón "Procesar" no genera resultados     | CSV no válido                         | Revisa el mensaje de validación en la pestaña de carga      |
| "Necesitas al menos 5 muestras para la IA"  | Pocas muestras válidas                | Usa `test_data_2.csv` o un CSV con ≥ 5 filas válidas       |
| Error al instalar `solitude`                 | Versión de R antigua o dependencias   | Actualiza R a ≥ 4.0 y ejecuta `install.packages("solitude")`|
| El gráfico no se muestra                     | Todos los valores de Ct son `NA`      | Asegúrate de que al menos una muestra tenga `Ct_SDC2` o `Ct_TFPI2` con valor numérico |

## Contribuciones

¡Las contribuciones son bienvenidas! Consulta [CONTRIBUTING.md](CONTRIBUTING.md) para conocer cómo reportar errores, proponer mejoras o enviar Pull Requests.
