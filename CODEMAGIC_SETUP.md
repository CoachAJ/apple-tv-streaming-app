# Codemagic Setup Guide for Apple TV Streaming App

## 🚨 GitHub Actions vs Codemagic

**Current Issue**: GitHub Actions is experiencing exit code 74 errors with tvOS builds due to simulator configuration complexities.

**Recommended Solution**: Use Codemagic for reliable tvOS builds and IPA generation.

## Why Codemagic for tvOS? 🥇

### ✅ **Advantages**:
- **Native tvOS Support**: Optimized for Apple TV app builds
- **IPA Generation**: Can create device-ready files for LambdaTest
- **Apple Developer Integration**: Handles signing automatically
- **Free Tier**: Available for open source projects
- **Reliable**: Less prone to simulator configuration issues

### ❌ **GitHub Actions Limitations**:
- Complex tvOS simulator setup
- Cannot generate signed IPAs without certificates
- Exit code 74 errors with destination configurations
- Limited Apple TV simulator availability

## Quick Codemagic Setup 🚀

### Step 1: Sign Up
1. Go to [codemagic.io](https://codemagic.io/)
2. Click "Sign up with GitHub"
3. Authorize Codemagic to access your repositories

### Step 2: Connect Repository
1. Click "Add application"
2. Select "GitHub"
3. Choose `CoachAJ/apple-tv-streaming-app`
4. Click "Finish"

### Step 3: Configure Build
1. **Use Existing Configuration**: Your project already includes `codemagic.yaml`
2. **Start Build**: Click "Start new build"
3. **Download IPA**: Once complete, download the generated IPA file

## Codemagic Configuration (Already Included)

Your project includes `codemagic.yaml` with:

```yaml
workflows:
  tvos-workflow:
    name: tvOS App Build
    instance_type: mac_mini_m1
    max_build_duration: 60
    environment:
      flutter: false
      xcode: latest
      cocoapods: default
    scripts:
      - name: Build tvOS App
        script: |
          xcodebuild -project StreamingApp.xcodeproj \
                     -scheme StreamingApp \
                     -sdk appletvsimulator \
                     -configuration Release \
                     clean build
    artifacts:
      - StreamingApp.app
    publishing:
      email:
        recipients:
          - your-email@example.com
```

## For LambdaTest Testing 📱

### Option 1: Codemagic (Recommended)
```
Codemagic → Build → Download IPA → Upload to LambdaTest
```

### Option 2: Local Build (Mac Required)
```bash
./build_for_testing.sh
```

### Option 3: GitHub Actions (Build Validation Only)
- ✅ Validates code compiles
- ❌ Cannot generate IPA for device testing
- 🔧 Currently experiencing exit code 74 issues

## Troubleshooting GitHub Actions

If you want to continue using GitHub Actions for validation:

### Common Exit Code 74 Causes:
1. **Simulator Not Available**: Specific Apple TV simulator not found
2. **Destination Mismatch**: Wrong platform/device combination
3. **Xcode Version**: Simulator compatibility issues
4. **Scheme Configuration**: Mismatch between scheme and project

### Current Fixes Applied:
- ✅ Added missing scheme file
- ✅ Simplified destination to use SDK instead of specific simulator
- ✅ Updated workflow to use latest Xcode

### If Still Failing:
The issue might be that GitHub Actions runners don't have the exact Apple TV simulator configuration needed. This is why **Codemagic is recommended** for tvOS builds.

## Next Steps for LambdaTest 🎯

### Immediate Action:
1. **Set up Codemagic** (5 minutes)
2. **Build IPA** (10-15 minutes)
3. **Upload to LambdaTest** (2 minutes)
4. **Start Testing** (follow your comprehensive checklist)

### Long-term Strategy:
- **Codemagic**: For IPA generation and device builds
- **GitHub Actions**: For code validation (once fixed)
- **LambdaTest**: For comprehensive device testing

## Support Resources

### Codemagic:
- [Documentation](https://docs.codemagic.io/)
- [tvOS Build Guide](https://docs.codemagic.io/yaml-basic-configuration/building-a-native-ios-app/)
- [Free Tier Limits](https://codemagic.io/pricing/)

### LambdaTest:
- [App Testing Guide](https://www.lambdatest.com/support/docs/app-testing/)
- [Apple TV Testing](https://www.lambdatest.com/support/docs/app-testing-on-real-devices/)

## File Structure for Codemagic

Your repository is already properly configured:

```
apple-tv-streaming-app/
├── codemagic.yaml                      # ✅ Codemagic configuration
├── StreamingApp.xcodeproj/             # ✅ Xcode project
├── StreamingApp/                       # ✅ Source code
├── StreamingApp/ExportOptions.plist    # ✅ Export settings
└── [documentation and guides]          # ✅ Complete setup
```

---

**Recommendation: Use Codemagic for reliable tvOS builds and IPA generation for LambdaTest testing!** 🚀📺
