# Contribuir a ColoGuardIA

¡Gracias por tu interés en mejorar ColoGuardIA! Toda contribución —desde corrección de errores hasta nuevas funcionalidades o mejoras de documentación— es bienvenida.

## Cómo contribuir

1. **Haz un fork** del repositorio en GitHub.
2. **Crea una rama** descriptiva para tu cambio:
   ```bash
   git checkout -b mi-mejora
   ```
3. **Realiza tus cambios** y verifica que la app sigue funcionando:
   ```r
   shiny::runApp("app.R")
   ```
4. **Haz commit** con un mensaje claro:
   ```bash
   git commit -m "Descripción breve del cambio"
   ```
5. **Abre un Pull Request** en GitHub describiendo qué cambiaste y por qué.

## Tipos de contribuciones aceptadas

- **Corrección de errores (bugs):** incluye pasos reproducibles en el reporte.
- **Mejoras de interfaz o usabilidad:** cambios en la UI de `app.R`.
- **Nuevas funcionalidades** alineadas con el propósito clínico de la app.
- **Soporte de idiomas adicionales:** los textos se encuentran en el diccionario `txt` al inicio de `app.R`.
- **Mejoras de documentación:** README, comentarios en el código, ejemplos.

## Convenciones de código

- El código fuente completo está en `app.R`. Mantén el estilo existente:
  - Indentación de **2 espacios**.
  - Secciones separadas con comentarios del tipo `# ---- Nombre de sección ----`.
- Todos los textos visibles en la UI están centralizados en el diccionario `txt` (inicio de `app.R`). Si agregas texto nuevo, inclúyelo en **ambos idiomas** (`es` e `en`).
- No modifiques los parámetros de umbrales (`ct_ref_SDC2`, `ct_ref_TFPI2`, `reference_threshold`) sin documentar el cambio en el PR.

## Reporte de problemas (issues)

Abre un issue en GitHub con la siguiente información:

- **Qué intentabas hacer**
- **Qué resultado esperabas**
- **Qué resultado obtuviste** (incluye mensajes de error completos si aplica)
- **Versión de R** (`R.version.string`)
- **Sistema operativo**
- **Versión de los paquetes relevantes** (`packageVersion("shiny")`, etc.)

## Preguntas

Para preguntas sobre el uso de la app, consulta primero el [README](README.md). Si la duda no está cubierta, abre un issue con la etiqueta *question*.
