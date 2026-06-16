library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(solitude)

# ---- Parameters / thresholds ----
ct_ref_SDC2 <- 38.0
ct_ref_TFPI2 <- 38.0
reference_threshold <- 36.0

# ---- Language dictionary ----
txt <- list(
  es = list(
    app_title = "Metilación PCR - Múltiples muestras + IA (QC)",
    menu_data = "Ingreso de datos",
    menu_results = "Resultados",
    menu_ai = "IA / Control de calidad",
    menu_help = "Ayuda",

    upload_title = "Cargar CSV",
    upload_label = "Selecciona un CSV",
    required_cols = "Columnas requeridas: SampleID, Ct_Ref, Ct_SDC2, Ct_TFPI2",
    process_button = "Procesar",
    validation_read_error = "No se pudo leer el CSV.",
    validation_missing_cols = "Columnas faltantes o incorrectas.",
    validation_required = "Se requieren:",
    validation_found = "Encontradas:",
    validation_ok = "Archivo OK. Listo para procesar.",
    csv_must_include = "El CSV debe incluir:",

    summary_title = "Resumen",
    results_title = "Resultados",
    plot_title_box = "Gráfico Ct por muestra",

    total = "Total:",
    valid = "Válidas:",
    invalid = "Inválidas:",
    no_ct_ref = "Sin Ct_Ref:",

    validity_valid = "Válida",
    validity_invalid = "Inválida",
    validity_no_ref = "Sin Ct_Ref",

    no_data = "Sin dato",
    no_result = "Sin resultado",
    methylated = "Metilado",
    not_methylated = "No metilado",
    not_interpretable = "No interpretable",
    global_positive = "Positivo (algún gen metilado)",
    global_negative = "Negativo (sin metilación detectada)",

    no_plot_data = "No hay Ct para graficar.",
    plot_title = "Ct por muestra (SDC2 y TFPI2)",
    plot_subtitle = "Línea punteada = umbral de metilación por gen",
    sample = "Muestra",
    validity = "Validez",

    ai_title = "IA (offline): detección de anomalías (Isolation Forest)",
    ai_description = "Objetivo: marcar muestras inusuales para revisión (control de calidad).",
    contamination = "Sensibilidad (proporción esperada de anomalías):",
    qc_only_valid = "Aplicar QC solo a muestras 'Válidas' (recomendado)",
    run_qc = "Ejecutar QC IA",
    qc_min_samples = "Necesitas al menos 5 muestras para un QC con IA razonable.",
    qc_evaluated = "Muestras evaluadas:",
    qc_flagged = "Marcadas 'Revisar':",
    qc_flag_ok = "OK",
    qc_flag_review = "Revisar",

    help_title = "Ayuda",
    help_ai_title = "¿Qué es la parte de IA?",
    help_ai_text = "Se usa un modelo de detección de anomalías (Isolation Forest) para marcar muestras con patrones de Ct inusuales. Esto no reemplaza el análisis por umbrales ni el criterio del laboratorio."
  ),
  en = list(
    app_title = "PCR Methylation - Multiple Samples + AI (QC)",
    menu_data = "Data Input",
    menu_results = "Results",
    menu_ai = "AI / Quality Control",
    menu_help = "Help",

    upload_title = "Upload CSV",
    upload_label = "Select a CSV",
    required_cols = "Required columns: SampleID, Ct_Ref, Ct_SDC2, Ct_TFPI2",
    process_button = "Process",
    validation_read_error = "Could not read the CSV.",
    validation_missing_cols = "Missing or incorrect columns.",
    validation_required = "Required:",
    validation_found = "Found:",
    validation_ok = "File OK. Ready to process.",
    csv_must_include = "The CSV must include:",

    summary_title = "Summary",
    results_title = "Results",
    plot_title_box = "Ct Plot by Sample",

    total = "Total:",
    valid = "Valid:",
    invalid = "Invalid:",
    no_ct_ref = "No Ct_Ref:",

    validity_valid = "Valid",
    validity_invalid = "Invalid",
    validity_no_ref = "No Ct_Ref",

    no_data = "No data",
    no_result = "No result",
    methylated = "Methylated",
    not_methylated = "Not methylated",
    not_interpretable = "Not interpretable",
    global_positive = "Positive (at least one methylated gene)",
    global_negative = "Negative (no methylation detected)",

    no_plot_data = "There are no Ct values available for plotting.",
    plot_title = "Ct by Sample (SDC2 and TFPI2)",
    plot_subtitle = "Dashed line = methylation threshold by gene",
    sample = "Sample",
    validity = "Validity",

    ai_title = "AI (offline): anomaly detection (Isolation Forest)",
    ai_description = "Objective: flag unusual samples for review (quality control).",
    contamination = "Sensitivity (expected proportion of anomalies):",
    qc_only_valid = "Apply QC only to 'Valid' samples (recommended)",
    run_qc = "Run AI QC",
    qc_min_samples = "You need at least 5 samples for a reasonable AI QC.",
    qc_evaluated = "Evaluated samples:",
    qc_flagged = "Flagged as 'Review':",
    qc_flag_ok = "OK",
    qc_flag_review = "Review",

    help_title = "Help",
    help_ai_title = "What is the AI section?",
    help_ai_text = "An anomaly detection model (Isolation Forest) is used to flag samples with unusual Ct patterns. This does not replace threshold-based analysis or laboratory judgment."
  )
)

ui <- dashboardPage(
  dashboardHeader(title = uiOutput("app_title")),
  dashboardSidebar(
    selectInput(
      "lang",
      "Language / Idioma",
      choices = c("Español" = "es", "English" = "en"),
      selected = "es"
    ),
    sidebarMenu(
      menuItem(textOutput("menu_data"), tabName = "data", icon = icon("upload")),
      menuItem(textOutput("menu_results"), tabName = "results", icon = icon("table")),
      menuItem(textOutput("menu_ai"), tabName = "ai", icon = icon("brain")),
      menuItem(textOutput("menu_help"), tabName = "help", icon = icon("info-circle"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "data",
        fluidRow(
          box(
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            title = uiOutput("upload_title"),
            uiOutput("upload_input_ui"),
            tags$hr(),
            uiOutput("process_button_ui"),
            tags$hr(),
            uiOutput("validation_msg")
          )
        )
      ),

      tabItem(
        tabName = "results",
        fluidRow(
          box(
            width = 12,
            status = "warning",
            solidHeader = TRUE,
            title = uiOutput("summary_title"),
            uiOutput("validity_summary")
          ),
          box(
            width = 12,
            status = "info",
            solidHeader = TRUE,
            title = uiOutput("results_title"),
            DTOutput("results_table")
          ),
          box(
            width = 12,
            status = "success",
            solidHeader = TRUE,
            title = uiOutput("plot_box_title"),
            plotOutput("ct_plot_multi")
          )
        )
      ),

      tabItem(
        tabName = "ai",
        fluidRow(
          box(
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            title = uiOutput("ai_title"),
            uiOutput("ai_description"),
            sliderInput(
              "contamination",
              label = NULL,
              min = 0.01, max = 0.30, value = 0.08, step = 0.01
            ),
            uiOutput("qc_only_valid_ui"),
            uiOutput("run_qc_ui"),
            tags$hr(),
            uiOutput("qc_summary"),
            DTOutput("qc_table")
          )
        )
      ),

      tabItem(
        tabName = "help",
        box(
          width = 12,
          status = "primary",
          solidHeader = TRUE,
          title = uiOutput("help_title"),
          uiOutput("help_content")
        )
      )
    )
  )
)

server <- function(input, output, session) {

  lang <- reactive({
    txt[[req(input$lang)]]
  })

  output$app_title <- renderUI({ span(lang()$app_title) })
  output$menu_data <- renderText({ lang()$menu_data })
  output$menu_results <- renderText({ lang()$menu_results })
  output$menu_ai <- renderText({ lang()$menu_ai })
  output$menu_help <- renderText({ lang()$menu_help })

  output$upload_title <- renderUI({ span(lang()$upload_title) })
  output$summary_title <- renderUI({ span(lang()$summary_title) })
  output$results_title <- renderUI({ span(lang()$results_title) })
  output$plot_box_title <- renderUI({ span(lang()$plot_title_box) })
  output$ai_title <- renderUI({ span(lang()$ai_title) })
  output$help_title <- renderUI({ span(lang()$help_title) })

  output$upload_input_ui <- renderUI({
    tagList(
      fileInput("file", lang()$upload_label, accept = c(".csv")),
      tags$small(lang()$required_cols)
    )
  })

  output$process_button_ui <- renderUI({
    actionButton("process", lang()$process_button, icon = icon("calculator"))
  })

  output$ai_description <- renderUI({
    tagList(
      p(lang()$ai_description),
      tags$label(lang()$contamination)
    )
  })

  output$qc_only_valid_ui <- renderUI({
    checkboxInput("qc_only_valid", lang()$qc_only_valid, value = TRUE)
  })

  output$run_qc_ui <- renderUI({
    actionButton("run_qc", lang()$run_qc, icon = icon("brain"))
  })

  output$help_content <- renderUI({
    tagList(
      h4(lang()$help_ai_title),
      p(lang()$help_ai_text)
    )
  })

  raw_data <- reactive({
    req(input$file)
    df <- read.csv(
      input$file$datapath,
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
    colnames(df) <- trimws(colnames(df))
    df
  })

  output$validation_msg <- renderUI({
    req(input$file)
    df <- tryCatch(raw_data(), error = function(e) NULL)

    if (is.null(df)) {
      return(tags$span(style = "color:red;", lang()$validation_read_error))
    }

    required_cols <- c("SampleID", "Ct_Ref", "Ct_SDC2", "Ct_TFPI2")
    if (!all(required_cols %in% colnames(df))) {
      return(tags$div(
        tags$span(style = "color:red;font-weight:bold;", lang()$validation_missing_cols),
        tags$p(lang()$validation_required),
        tags$code(paste(required_cols, collapse = ", ")),
        tags$p(lang()$validation_found),
        tags$code(paste(colnames(df), collapse = ", "))
      ))
    }

    tags$span(style = "color:green;font-weight:bold;", lang()$validation_ok)
  })

  analyze_samples <- function(df, lang_text) {
    required_cols <- c("SampleID", "Ct_Ref", "Ct_SDC2", "Ct_TFPI2")
    stopifnot(all(required_cols %in% colnames(df)))

    df$Ct_Ref <- suppressWarnings(as.numeric(df$Ct_Ref))
    df$Ct_SDC2 <- suppressWarnings(as.numeric(df$Ct_SDC2))
    df$Ct_TFPI2 <- suppressWarnings(as.numeric(df$Ct_TFPI2))

    df$Validity <- ifelse(
      is.na(df$Ct_Ref),
      lang_text$validity_no_ref,
      ifelse(df$Ct_Ref > reference_threshold, lang_text$validity_invalid, lang_text$validity_valid)
    )

    df$SDC2_Result <- ifelse(
      df$Validity == lang_text$validity_valid,
      ifelse(
        is.na(df$Ct_SDC2),
        lang_text$no_data,
        ifelse(df$Ct_SDC2 <= ct_ref_SDC2, lang_text$methylated, lang_text$not_methylated)
      ),
      lang_text$no_result
    )

    df$TFPI2_Result <- ifelse(
      df$Validity == lang_text$validity_valid,
      ifelse(
        is.na(df$Ct_TFPI2),
        lang_text$no_data,
        ifelse(df$Ct_TFPI2 <= ct_ref_TFPI2, lang_text$methylated, lang_text$not_methylated)
      ),
      lang_text$no_result
    )

    df$Global_Interpretation <- ifelse(
      df$Validity != lang_text$validity_valid,
      lang_text$not_interpretable,
      ifelse(
        df$SDC2_Result == lang_text$methylated | df$TFPI2_Result == lang_text$methylated,
        lang_text$global_positive,
        lang_text$global_negative
      )
    )

    df
  }

  results <- eventReactive(input$process, {
    req(input$file)
    df <- raw_data()

    required_cols <- c("SampleID", "Ct_Ref", "Ct_SDC2", "Ct_TFPI2")
    validate(
      need(
        all(required_cols %in% colnames(df)),
        paste(lang()$csv_must_include, paste(required_cols, collapse = ", "))
      )
    )

    analyze_samples(df, lang())
  })

  output$validity_summary <- renderUI({
    req(results())
    df <- results()

    tags$div(
      tags$p(tags$b(lang()$total), nrow(df)),
      tags$p(tags$b(lang()$valid), sum(df$Validity == lang()$validity_valid, na.rm = TRUE)),
      tags$p(tags$b(lang()$invalid), sum(df$Validity == lang()$validity_invalid, na.rm = TRUE)),
      tags$p(tags$b(lang()$no_ct_ref), sum(df$Validity == lang()$validity_no_ref, na.rm = TRUE))
    )
  })

  output$results_table <- renderDT({
    req(results())
    df <- results()
    DT::datatable(
      df,
      options = list(pageLength = 10, scrollX = TRUE),
      rownames = FALSE
    )
  })

  output$ct_plot_multi <- renderPlot({
    req(results())
    df <- results()

    long <- rbind(
      data.frame(
        SampleID = df$SampleID,
        Gene = "SDC2",
        Ct = df$Ct_SDC2,
        Validity = df$Validity,
        stringsAsFactors = FALSE
      ),
      data.frame(
        SampleID = df$SampleID,
        Gene = "TFPI2",
        Ct = df$Ct_TFPI2,
        Validity = df$Validity,
        stringsAsFactors = FALSE
      )
    )

    long <- long[!is.na(long$Ct), , drop = FALSE]
    validate(need(nrow(long) > 0, lang()$no_plot_data))

    ref <- data.frame(
      Gene = c("SDC2", "TFPI2"),
      Ct_ref = c(ct_ref_SDC2, ct_ref_TFPI2)
    )

    ggplot(long, aes(x = SampleID, y = Ct, fill = Validity)) +
      geom_col() +
      facet_wrap(~Gene, scales = "free_y") +
      geom_hline(
        data = ref,
        aes(yintercept = Ct_ref),
        linetype = "dashed",
        linewidth = 0.7,
        inherit.aes = FALSE
      ) +
      labs(
        title = lang()$plot_title,
        subtitle = lang()$plot_subtitle,
        x = lang()$sample,
        y = "Ct",
        fill = lang()$validity
      ) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })

  # ---- AI QC ----
  qc_result <- eventReactive(input$run_qc, {
    req(results())
    df <- results()

    if (isTRUE(input$qc_only_valid)) {
      df_qc <- df[df$Validity == lang()$validity_valid, , drop = FALSE]
    } else {
      df_qc <- df
    }

    validate(need(nrow(df_qc) >= 5, lang()$qc_min_samples))

    X <- df_qc[, c("Ct_Ref", "Ct_SDC2", "Ct_TFPI2")]
    X$Ct_Ref <- as.numeric(X$Ct_Ref)
    X$Ct_SDC2 <- as.numeric(X$Ct_SDC2)
    X$Ct_TFPI2 <- as.numeric(X$Ct_TFPI2)

    for (nm in names(X)) {
      med <- median(X[[nm]], na.rm = TRUE)
      if (!is.finite(med)) med <- 0
      X[[nm]][is.na(X[[nm]])] <- med
    }

    iso <- isolationForest$new(
      sample_size = min(256, nrow(X)),
      num_trees = 200,
      seed = 42
    )
    iso$fit(X)

    score <- iso$predict(X)
    df_qc$QC_Score <- score$anomaly_score

    k <- max(1, floor(nrow(df_qc) * input$contamination))
    ord <- order(df_qc$QC_Score, decreasing = TRUE)

    flag <- rep(lang()$qc_flag_ok, nrow(df_qc))
    flag[ord[seq_len(k)]] <- lang()$qc_flag_review

    df_qc$QC_Flag <- flag
    df_qc
  })

  output$qc_summary <- renderUI({
    req(qc_result())
    df <- qc_result()

    tags$div(
      tags$p(tags$b(lang()$qc_evaluated), nrow(df)),
      tags$p(tags$b(lang()$qc_flagged), sum(df$QC_Flag == lang()$qc_flag_review))
    )
  })

  output$qc_table <- renderDT({
    req(qc_result())
    df <- qc_result()

    out <- df[, c(
      "SampleID", "Validity", "Ct_Ref", "Ct_SDC2", "Ct_TFPI2",
      "SDC2_Result", "TFPI2_Result", "Global_Interpretation",
      "QC_Flag", "QC_Score"
    )]

    DT::datatable(
      out,
      options = list(pageLength = 10, scrollX = TRUE),
      rownames = FALSE
    )
  })
}

shinyApp(ui, server)