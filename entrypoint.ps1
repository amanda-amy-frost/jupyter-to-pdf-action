# Set as environment variables by GitHub Actions.
# None of these are mandatory, so don't explicitly
# specify [Parameter(Mandatory=$false)] for every one.
# PowerShell variable names are case-insensitive, so
# although GitHub expects the variable names to match
# the input parameters in action.yml, I use all caps
# to indicate that they are environment variables.
param(
    [string]$INPUT_DIRS,
    [string]$OUTPUT_DIR,
    [string]$DRY_RUN,
    [string]$EXECUTE
)

Write-Host "=== Jupyter PDF Conversion Action ===" -ForegroundColor Blue
Write-Host "Input directories: $INPUT_DIRS"
Write-Host "Output directory: $OUTPUT_DIR"
Write-Host "Dry run: $DRY_RUN"
Write-Host "Execute notebooks: $EXECUTE"
Write-Host "=====================================" -ForegroundColor Blue

# Normalize booleans
$DryRun = $DRY_RUN.ToLower() -eq "true"
$ExecBook = $EXECUTE.ToLower() -eq "true"

# Default output directory
if (-not $OUTPUT_DIR) {
    $OUTPUT_DIR = "pdf"
}

# Determine notebook list
$Notebooks = @()

if ([string]::IsNullOrWhiteSpace($INPUT_DIRS)) {
    Write-Host "Searching entire repository for notebooks..."
    $Notebooks = Get-ChildItem -Recurse -Filter *.ipynb |
        Select-Object -ExpandProperty FullName
} else {
    Write-Host "Searching in specified directories..."
    $Directories = $INPUT_DIRS -split ","
    foreach ($Dir in $Directories) {
        if (Test-Path $Dir) {
            $FoundBooks = Get-ChildItem -Recurse -Path $Dir -Filter *.ipynb |
                Select-Object -ExpandProperty FullName
            $Notebooks += $FoundBooks
        } else {
            Write-Warning "Directory not found: $Dir"
        }
    }
}

# Make sure to handle the edge case first
if ($Notebooks.Count -eq 0) {
    Write-Warning "No notebooks found. Exiting."
    exit 0
}

Write-Host "Found $($Notebooks.Count) notebook(s):" -ForegroundColor Green
$Notebooks | ForEach-Object { Write-Host "- $_" }

if ($DryRun) {
    "Dry run enabled — no execution or conversion will be performed." |
        Write-Host -ForegroundColor Blue
    exit 0
}

# Ensure output directory exists
if (-not (Test-Path $OUTPUT_DIR)) {
    Write-Host "Creating output directory: $OUTPUT_DIR" -ForegroundColor Green
    New-Item -ItemType Directory -Path $OUTPUT_DIR | Out-Null
}

# Convert each notebook
foreach ($Book in $Notebooks) {
    Write-Host "Processing: $Book"

    if ($ExecBook) {
        $ExecFlag = "--execute"
    } else {
        $ExecFlag = ""
    }

    try {
        jupyter nbconvert `
            --to pdf `
            $ExecFlag `
            $Book `
            --output-dir $OUTPUT_DIR

        Write-Host "Successfully converted: $Book" -ForegroundColor Green
    } catch {
        Write-Error "Failed to convert ${Book}: $_"
    }
}

Write-Host "=== Conversion complete ===" -ForegroundColor Blue
