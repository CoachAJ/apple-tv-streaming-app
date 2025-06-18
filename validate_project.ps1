# Project Validation Script for LambdaTest Preparation
# This script validates that all required files are present and properly configured

Write-Host "`u{1F50D} Validating Apple TV Streaming App for LambdaTest..." -ForegroundColor Green
Write-Host ""

$validationResults = @()
$criticalIssues = 0
$warnings = 0

function Test-FileExists {
    param($FilePath, $Description, $Critical = $true)
    
    if (Test-Path $FilePath) {
        Write-Host "`u{2705} $Description" -ForegroundColor Green
        $validationResults += @{Status="PASS"; Item=$Description; Critical=$Critical}
        return $true
    } else {
        if ($Critical) {
            Write-Host "`u{274C} $Description" -ForegroundColor Red
            $script:criticalIssues++
        } else {
            Write-Host "`u{26A0} $Description" -ForegroundColor Yellow
            $script:warnings++
        }
        $validationResults += @{Status="FAIL"; Item=$Description; Critical=$Critical}
        return $false
    }
}

function Test-FileContent {
    param($FilePath, $Pattern, $Description, $Critical = $true)
    
    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw
        if ($content -match $Pattern) {
            Write-Host "`u{2705} $Description" -ForegroundColor Green
            $validationResults += @{Status="PASS"; Item=$Description; Critical=$Critical}
            return $true
        }
    }
    
    if ($Critical) {
        Write-Host "`u{274C} $Description" -ForegroundColor Red
        $script:criticalIssues++
    } else {
        Write-Host "`u{26A0} $Description" -ForegroundColor Yellow
        $script:warnings++
    }
    $validationResults += @{Status="FAIL"; Item=$Description; Critical=$Critical}
    return $false
}

Write-Host "`u{1F4C1} Checking Core Project Files..." -ForegroundColor Cyan

# Core Xcode project files
Test-FileExists "StreamingApp.xcodeproj" "Xcode project file exists"
Test-FileExists "StreamingApp.xcodeproj/project.pbxproj" "Xcode project configuration exists"

# Swift source files
Test-FileExists "StreamingApp/StreamingAppApp.swift" "Main app file exists"
Test-FileExists "StreamingApp/ContentView.swift" "Content view exists"
Test-FileExists "StreamingApp/HomeView.swift" "Home view exists"
Test-FileExists "StreamingApp/ShowcaseView.swift" "Showcase view exists"
Test-FileExists "StreamingApp/VideoPlayerView.swift" "Video player exists"
Test-FileExists "StreamingApp/VimeoService.swift" "Vimeo service exists"

# Configuration files
Test-FileExists "StreamingApp/Info.plist" "Info.plist exists"
Test-FileExists "StreamingApp/ExportOptions.plist" "Export options exists"

# Assets
Test-FileExists "StreamingApp/Assets.xcassets" "Assets catalog exists"

Write-Host ""
Write-Host "`u{1F6E0} Checking Build Configuration..." -ForegroundColor Cyan

# Build scripts
Test-FileExists "build_for_testing.sh" "Mac build script exists" $false
Test-FileExists "build_for_testing.ps1" "Windows build helper exists" $false
Test-FileExists "codemagic.yaml" "Codemagic configuration exists" $false
Test-FileExists ".github/workflows/build-tvos.yml" "GitHub Actions workflow exists" $false

Write-Host ""
Write-Host "`u{1F4D6} Checking Documentation..." -ForegroundColor Cyan

# Documentation files
Test-FileExists "README.md" "Project README exists"
Test-FileExists "LAMBDATEST_GUIDE.md" "LambdaTest guide exists"
Test-FileExists "TESTING_CHECKLIST.md" "Testing checklist exists"
Test-FileExists "LAMBDATEST_READY.md" "Ready summary exists"
Test-FileExists "VIMEO_SETUP.md" "Vimeo setup guide exists"
Test-FileExists "VIMEO_CREDENTIALS.md" "Vimeo credentials guide exists"

Write-Host ""
Write-Host "`u{1F50D} Checking File Contents..." -ForegroundColor Cyan

# Check for Vimeo showcase IDs
Test-FileContent "StreamingApp/ContentView.swift" "18401281" "Main showcase ID configured"
Test-FileContent "StreamingApp/ContentView.swift" "18401283" "Secondary showcase ID configured"
Test-FileContent "StreamingApp/ContentView.swift" "18401278" "Third showcase ID configured"

# Check for tvOS configuration
Test-FileContent "StreamingApp/Info.plist" "UIRequiredDeviceCapabilities" "tvOS device capabilities configured"
Test-FileContent "StreamingApp/Info.plist" "UISupportedInterfaceOrientations" "Interface orientations configured"

# Check for SwiftUI implementation
Test-FileContent "StreamingApp/StreamingAppApp.swift" "@main" "SwiftUI app entry point configured"
Test-FileContent "StreamingApp/ContentView.swift" "TabView" "Tab navigation implemented"

Write-Host ""
Write-Host "`u{1F4F1} Checking Git Repository..." -ForegroundColor Cyan

# Git repository
if (Test-Path ".git") {
    Write-Host "`u{2705} Git repository initialized" -ForegroundColor Green
    
    # Check if files are committed
    $gitStatus = git status --porcelain 2>$null
    if ([string]::IsNullOrEmpty($gitStatus)) {
        Write-Host "`u{2705} All files committed to Git" -ForegroundColor Green
    } else {
        Write-Host "`u{26A0} Uncommitted changes in repository" -ForegroundColor Yellow
        $warnings++
    }
} else {
    Write-Host "`u{274C} Git repository not initialized" -ForegroundColor Red
    $criticalIssues++
}

Write-Host ""
Write-Host "Validation Summary" -ForegroundColor Magenta
Write-Host "===================" -ForegroundColor Magenta

$totalTests = $validationResults.Count
$passedTests = ($validationResults | Where-Object {$_.Status -eq "PASS"}).Count
$failedTests = $totalTests - $passedTests

Write-Host "Total Tests: $totalTests" -ForegroundColor White
Write-Host "Passed: $passedTests" -ForegroundColor Green
Write-Host "Failed: $failedTests" -ForegroundColor Red
Write-Host "Critical Issues: $criticalIssues" -ForegroundColor Red
Write-Host "Warnings: $warnings" -ForegroundColor Yellow

Write-Host ""

if ($criticalIssues -eq 0) {
    Write-Host "`u{1F389} PROJECT READY FOR LAMBDATEST!" -ForegroundColor Green
    Write-Host ""
    Write-Host "All critical requirements met" -ForegroundColor Green
    Write-Host "Project can be built and tested" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Build IPA using preferred method (see LAMBDATEST_GUIDE.md)"
    Write-Host "2. Upload IPA to LambdaTest.com"
    Write-Host "3. Follow testing checklist (TESTING_CHECKLIST.md)"
    Write-Host "4. Review results and fix any issues found"
    
    if ($warnings -gt 0) {
        Write-Host ""
        Write-Host "Note: $warnings warnings found - review for optimal setup" -ForegroundColor Yellow
    }
} else {
    Write-Host "`u{274C} PROJECT NOT READY" -ForegroundColor Red
    Write-Host ""
    Write-Host "Critical issues must be resolved before testing:" -ForegroundColor Red
    
    $criticalFailures = $validationResults | Where-Object {$_.Status -eq "FAIL" -and $_.Critical -eq $true}
    foreach ($failure in $criticalFailures) {
        Write-Host "  - $($failure.Item)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "Please fix these issues and run validation again." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "For detailed testing instructions, see:" -ForegroundColor Cyan
Write-Host "  - LAMBDATEST_GUIDE.md - Complete testing guide"
Write-Host "  - TESTING_CHECKLIST.md - Detailed test cases"
Write-Host "  - LAMBDATEST_READY.md - Quick start summary"
