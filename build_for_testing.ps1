# PowerShell Build Script for Apple TV Streaming App
# This script helps prepare the app for testing on LambdaTest

param(
    [switch]$Help
)

if ($Help) {
    Write-Host @"
Apple TV Streaming App - Build for Testing

This script helps prepare your tvOS app for testing on LambdaTest.com

USAGE:
    .\build_for_testing.ps1

REQUIREMENTS:
    - Xcode (Mac only) OR
    - Codemagic CI/CD account for cloud building

STEPS:
    1. Commit and push code to Git repository
    2. Use Codemagic for cloud building (recommended for Windows)
    3. Download IPA from build artifacts
    4. Upload IPA to LambdaTest for testing

For detailed instructions, see LAMBDATEST_GUIDE.md
"@
    exit 0
}

Write-Host "🚀 Apple TV Streaming App - Build Preparation" -ForegroundColor Green
Write-Host ""

# Check if we're on Windows (most likely scenario)
if ($IsWindows -or $env:OS -eq "Windows_NT") {
    Write-Host "🖥️  Windows detected - Using cloud build approach" -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "📋 Recommended build process for Windows:" -ForegroundColor Cyan
    Write-Host "1. Push code to GitHub repository"
    Write-Host "2. Connect repository to Codemagic.io"
    Write-Host "3. Use the provided codemagic.yaml configuration"
    Write-Host "4. Download IPA from build artifacts"
    Write-Host ""
    
    Write-Host "🔧 Alternative: Use GitHub Actions" -ForegroundColor Cyan
    Write-Host "1. Set up GitHub Actions workflow"
    Write-Host "2. Configure iOS build environment"
    Write-Host "3. Build and export IPA in cloud"
    Write-Host ""
} else {
    Write-Host "🍎 macOS detected - Can build locally" -ForegroundColor Green
    Write-Host ""
    
    # Check if Xcode is available
    if (Get-Command xcodebuild -ErrorAction SilentlyContinue) {
        Write-Host "✅ Xcode found - Ready to build locally" -ForegroundColor Green
        Write-Host ""
        Write-Host "Run the following commands to build:"
        Write-Host "chmod +x build_for_testing.sh"
        Write-Host "./build_for_testing.sh"
    } else {
        Write-Host "❌ Xcode not found - Install Xcode to build locally" -ForegroundColor Red
        Write-Host "Or use cloud build approach above"
    }
}

Write-Host ""
Write-Host "📁 Project files ready for testing:" -ForegroundColor Green
Get-ChildItem -Path . -Name | Where-Object { 
    $_ -match '\.(swift|plist|yaml|md)$' -or $_ -eq 'StreamingApp.xcodeproj'
} | ForEach-Object { Write-Host "  ✓ $_" -ForegroundColor White }

Write-Host ""
Write-Host "📖 Next steps:" -ForegroundColor Cyan
Write-Host "1. Review LAMBDATEST_GUIDE.md for detailed testing instructions"
Write-Host "2. Ensure Vimeo API credentials are configured"
Write-Host "3. Build IPA using preferred method above"
Write-Host "4. Upload IPA to LambdaTest.com for testing"
Write-Host ""
Write-Host "🧪 For testing support, see LAMBDATEST_GUIDE.md" -ForegroundColor Yellow
