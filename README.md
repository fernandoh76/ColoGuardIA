# ColoGuardIA

A Shiny R application for analyzing PCR methylation results in multiple samples, with an additional Quality Control (QC) module based on anomaly detection using Isolation Forest.

## Description

ColoGuardIA allows you to upload a CSV file with Ct values ​​per sample and generate:

- basic validation of the input file,
- sample validity classification based on `Ct_Ref`,
- gene-specific interpretation for SDC2 and TFPI2,
- overall methylation interpretation,
- graphical visualization of Ct per sample,
- AI-assisted quality control to detect unusual patterns.

The application includes a Spanish and English interface.

## Features

### 1. Data Loading
The app receives CSV files with the following required columns:

- `SampleID`
- `Ct_Ref`
- `Ct_SDC2`
- `Ct_TFPI2`

### 2. File Validation
Before processing the data, the application:

- attempts to read the CSV file,
- verifies that the required columns exist,
- displays error messages if the format is incorrect.

### 3. Rule-Based Analysis
The logic implemented in the app uses the following thresholds:

- `reference_threshold = 36.0`
- `ct_ref_SDC2 = 38.0`
- `ct_ref_TFPI2 = 38.0`

#### Sample Validity
Based on `Ct_Ref`:

- **No Ct_Ref**: if `Ct_Ref` is empty or `NA`
- **Invalid**: if `Ct_Ref > 36.0`
- **Valid**: if `Ct_Ref <= 36.0`

#### Result by Gene
Only calculated when the sample is **valid**.

For **SDC2**:
- **No data**: if `Ct_SDC2` is `NA`
- **Methylated**: if `Ct_SDC2 <= 38.0`
- **Not methylated**: if `Ct_SDC2 > 38.0`

For **TFPI2**:
- **No data**: if `Ct_TFPI2` is `NA`
- **Methylated**: if `Ct_TFPI2 <= 38.0`
- **Not methylated**: if `Ct_TFPI2 > 38.0`

If the sample is invalid, the result per gene is reported as **No result**.

#### Overall Interpretation
- **Positive**: if at least one of the genes appears as **Methylated**
- **Negative**: if none of the genes appear as methylated in a valid sample
- **Not Interpretable**: if the sample is invalid

### 4. Visualization
The application generates a bar graph with:

- Ct values ​​per sample,
- separation by gene (`SDC2`, `TFPI2`),
- a dotted line representing the methylation threshold for each gene,
- color indicating sample validity.


### 5. Quality Control with AI
The **AI / Quality Control** section applies an **Isolation Forest** model using:

- `Ct_Ref`
- `Ct_SDC2`
- `Ct_TFPI2`

QC module features:

- can be run only on **valid** samples or on all samples,
- requires at least **5 samples** to run,
- replaces missing values ​​with the **median** of each variable before analysis,
- assigns a `QC_Score` for anomalies,
- marks samples with the highest scores according to the sensitivity parameter (`contamination`) as requiring `Review`.

> Important: this module is geared towards **quality control** and **does not replace** interpretation by thresholds or laboratory judgment.

## Current repository structure

```text


├── app.R
├── test_data_1.csv
├── test_data_2.csv
├── test_data_3.csv
└── rsconnect/
```

### Main Files

- `app.R`: Complete Shiny application.

- `test_data_1.csv`: Small example with valid, invalid, and missing data.

- `test_data_2.csv`: Example with more varied data and several outliers.

- `test_data_3.csv`: Example with combinations of missing data and values ​​close to thresholds.

## Requirements

You need to have **R** installed and the following packages:

- `shiny`
- `shinydashboard`
- `DT`
- `ggplot2`
- `solitude`

## Installation

You can install the dependencies with:

```r
install.packages(c(
"shiny",
"shinydashboard",
"DT",
"ggplot2",
"solitude"
))
```

## Local Execution

From the repository root, run the following in R:

```r
shiny::runApp()
```

Or:

```r
source("app.R")
```

## Input CSV Format

Example Minimum:

```csv
SampleID,Ct_Ref,Ct_SDC2,Ct_TFPI2
S001,28.4,35.2,39.1
S002,30.1,40.0,37.5
S003,36.5,34.8,35.9
```

## Sample Data Included

The repository already includes test files to validate functionality:

- `test_data_1.csv`
- `test_data_2.csv`
- `test_data_3.csv`

You can use them to test:

- column validation,
- handling of missing values,
- interpretation rules,
- anomaly detection in QC.

## Usage Flow

1. Open the application.

2. Select language.

3. Load a CSV file.

4. Verify the validation message.

5. Click **Process**.

6. Review:

- summary,

- results table,

- Ct graph.

7. Optionally, go to **AI / Quality Control**.

8. Adjust the sensitivity.

9. Run the QC and review `QC_Flag` and `QC_Score`.

## Generated Outputs

The main table includes derived columns such as:

- `Validity`
- `SDC2_Result`
- `TFPI2_Result`
- `Global_Interpretation`

The QC table also includes:

- `QC_Flag`
- `QC_Score`

## Current Limitations

- The logic uses fixed thresholds defined in `app.R`.

- There is no persistence of results or export.
