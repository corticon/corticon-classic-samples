#Requires -Modules Microsoft.PowerShell.Management,Microsoft.PowerShell.Utility
<#
.SYNOPSIS
    Automates the process of downloading all Corticon Classic rule project samples from GitHub
    and setting them up for use in Corticon Studio.
#>

# --- START: User Configuration ---

# Set the full path to your Corticon Classic Samples directory.
$CorticonSamplesDirectory = "C:\Progress\Corticon 7.2\Samples"

# --- END: User Configuration ---


# --- Script Body (No edits needed below this line) ---

# Construct the path for the temporary repository clone
$RepoCloneDirectory = Join-Path -Path $env:TEMP -ChildPath "corticon-classic-samples-repo"

# GitHub repository URL for Corticon Classic
$RepoUrl = "https://github.com/corticon/corticon-classic-samples.git"

# Function to write a message to the console
function Write-Log {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host "[$([datetime]::Now.ToString('HH:mm:ss'))] $Message" -ForegroundColor $Color
}

# 1. Check if Git is installed
$gitCheck = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitCheck) {
    Write-Log "ERROR: Git is not installed or not found in your system's PATH. Please install Git to continue." -Color Red
    exit 1
}

# 2. Check if the Corticon Samples directory exists
if (-not (Test-Path -Path $CorticonSamplesDirectory)) {
    Write-Log "ERROR: Corticon samples directory not found at '$CorticonSamplesDirectory'." -Color Red
    Write-Log "Please verify your Corticon Classic installation path." -Color Yellow
    exit 1
}

Write-Log "Target Corticon Samples Directory: $CorticonSamplesDirectory" -Color Cyan

# 3. Clone or update the repository
if (Test-Path -Path $RepoCloneDirectory) {
    Write-Log "Repository already exists. Skipping clone."
}
else {
    Write-Log "Cloning Classic samples repository from GitHub..." -Color Green
    git clone $RepoUrl $RepoCloneDirectory
    if ($LASTEXITCODE -ne 0) {
        Write-Log "ERROR: Failed to clone the GitHub repository." -Color Red
        exit 1
    }
}

# 4. Find all 'Rule Project.zip' files
Write-Log "Scanning for rule projects in '$RepoCloneDirectory'..."
$ruleProjects = Get-ChildItem -Path $RepoCloneDirectory -Recurse -Filter "Rule Project.zip"

if (-not $ruleProjects) {
    Write-Log "No rule projects named 'Rule Project.zip' were found in the repository." -Color Yellow
    exit 0
}

Write-Log "Found $($ruleProjects.Count) rule projects. Processing now..." -Color Green
$processedCount = 0

# 5. Process each found project
foreach ($project in $ruleProjects) {
    $sampleName = $project.Directory.Name
    Write-Log "Processing: '$sampleName'..."

    $destinationPath = Join-Path -Path $CorticonSamplesDirectory -ChildPath $sampleName
    $sourceReadmePath = Join-Path -Path $project.Directory.FullName -ChildPath "README.md"

    $topicName = (Split-Path -Path $project.Directory.FullName -Parent | Split-Path -Leaf)

    if (-not (Test-Path -Path $destinationPath)) {
        New-Item -ItemType Directory -Path $destinationPath | Out-Null
    }

    $newZipName = "$sampleName.zip"
    Copy-Item -Path $project.FullName -Destination (Join-Path -Path $destinationPath -ChildPath $newZipName) -Force

    $shortDescription = $sampleName
    if (Test-Path -Path $sourceReadmePath) {
        $longDescription = Get-Content -Path $sourceReadmePath -Raw
    } else {
        $longDescription = "This sample has been developed from the business requirement of '$sampleName'."
    }
    $propertiesContent = "shortDescription = $shortDescription`r`nlongDescription = $longDescription"
    Set-Content -Path (Join-Path -Path $destinationPath -ChildPath "metadata.properties") -Value $propertiesContent

    # NOTE: The perspectiveID and product id are assumed to be the same as Corticon.js Studio.
    # If samples do not appear correctly, check an existing Corticon Classic sample's metadata.xml for the correct values.
    $xmlContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<IUE id="CorticonSample_$($sampleName.Replace(' ',''))" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.jaxb.iue.branding.tools.progress.com">
	<name>$sampleName</name>
	<category>sample</category>	
	<publicationDate>$(Get-Date -Format 'yyyy-MM-dd')</publicationDate>
	<shortDescription>%shortDescription</shortDescription>
	<description>%longDescription</description>
	<size>65536</size>
	<metadata>
		<contributionType id="com.progress.tools.branding.iue.type.sample">
			<properties key="samplePath">
				<simpleValue>$newZipName</simpleValue>
			</properties>
			<properties key="perspectiveID">
				<simpleValue>com.corticon.eclipse.studio.ui.perspectives.RuleDevelopmentPerspectiveID</simpleValue>
			</properties>			
		</contributionType>
		<filters>
			<topic>$topicName</topic>
			<complexity>Getting Started</complexity>
			<productsSupported>
				<product version="[0.0.0, 9.0.0]" id="com.corticon.eclipse.studio.product">
				<capability>Corticon</capability>
				</product>
			</productsSupported>
		</filters>
	</metadata>		
</IUE>
"@
    Set-Content -Path (Join-Path -Path $destinationPath -ChildPath "metadata.xml") -Value $xmlContent
    $processedCount++
}

Write-Log "--------------------------------------------------" -Color Green
Write-Log "Automation Complete!" -Color Green
Write-Log "Successfully processed and installed $processedCount Corticon Classic samples."
Write-Log "Please restart Corticon Studio and navigate to Help -> Samples to see the new projects."