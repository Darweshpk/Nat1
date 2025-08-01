#!/bin/bash

# Flutter Project Validation Script
# This script validates if the Flutter project is ready for APK build

echo "🔍 Flutter Project Validation Report"
echo "====================================="
echo

# Check pubspec.yaml
echo "📦 Dependencies Check:"
if [ -f "pubspec.yaml" ]; then
    echo "✅ pubspec.yaml found"
    
    # Check for critical plugins
    if grep -q "flutter_sms_inbox: \^1.0.4" pubspec.yaml; then
        echo "✅ flutter_sms_inbox updated to v1.0.4"
    else
        echo "❌ flutter_sms_inbox needs to be v1.0.4"
    fi
    
    if grep -q "permission_handler: \^12.0.1" pubspec.yaml; then
        echo "✅ permission_handler updated to v12.0.1"
    else
        echo "❌ permission_handler needs to be v12.0.1"
    fi
else
    echo "❌ pubspec.yaml not found"
fi

echo

# Check Android configuration
echo "🤖 Android Configuration:"
if [ -f "android/app/build.gradle" ]; then
    echo "✅ Android build.gradle found"
    
    if grep -q "minSdk = 21" android/app/build.gradle; then
        echo "✅ minSdk set to 21"
    else
        echo "❌ minSdk should be set to 21"
    fi
else
    echo "❌ Android build.gradle not found"
fi

if [ -f "android/settings.gradle" ]; then
    if grep -q "8.3.1" android/settings.gradle; then
        echo "✅ Android Gradle Plugin updated to 8.3.1"
    else
        echo "❌ Android Gradle Plugin should be 8.3.1"
    fi
fi

echo

# Check AndroidManifest.xml
echo "📱 Manifest Check:"
if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
    echo "✅ AndroidManifest.xml found"
    
    # Check permissions
    if grep -q "READ_SMS" android/app/src/main/AndroidManifest.xml; then
        echo "✅ SMS permission present"
    fi
    
    if grep -q "READ_CALL_LOG" android/app/src/main/AndroidManifest.xml; then
        echo "✅ Call log permission present"
    fi
    
    # Check for Flutter v2 embedding
    if grep -q "flutterEmbedding.*2" android/app/src/main/AndroidManifest.xml; then
        echo "✅ Flutter v2 embedding configured"
    fi
else
    echo "❌ AndroidManifest.xml not found"
fi

echo

# Check main Dart file
echo "🎯 Code Check:"
if [ -f "lib/main.dart" ]; then
    echo "✅ main.dart found"
    
    if grep -q "WidgetsFlutterBinding.ensureInitialized" lib/main.dart; then
        echo "✅ Flutter binding initialized"
    fi
    
    if grep -q "Hive.initFlutter" lib/main.dart; then
        echo "✅ Hive database initialized"
    fi
else
    echo "❌ main.dart not found"
fi

echo

# Check GitHub Actions
echo "🔄 CI/CD Check:"
if [ -f ".github/workflows/build-apk.yml" ]; then
    echo "✅ GitHub Actions workflow configured"
    echo "   📌 APK will be built automatically on GitHub"
else
    echo "❌ GitHub Actions workflow not found"
fi

echo

# Build readiness summary
echo "🎯 Build Readiness Summary:"
echo "=========================="

# Count checks
TOTAL_CHECKS=8
PASSED_CHECKS=0

[ -f "pubspec.yaml" ] && ((PASSED_CHECKS++))
[ -f "android/app/build.gradle" ] && ((PASSED_CHECKS++))
[ -f "android/settings.gradle" ] && ((PASSED_CHECKS++))
[ -f "android/app/src/main/AndroidManifest.xml" ] && ((PASSED_CHECKS++))
[ -f "lib/main.dart" ] && ((PASSED_CHECKS++))
[ -f ".github/workflows/build-apk.yml" ] && ((PASSED_CHECKS++))

grep -q "flutter_sms_inbox: \^1.0.4" pubspec.yaml 2>/dev/null && ((PASSED_CHECKS++))
grep -q "minSdk = 21" android/app/build.gradle 2>/dev/null && ((PASSED_CHECKS++))

PERCENTAGE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

echo "📊 Score: $PASSED_CHECKS/$TOTAL_CHECKS ($PERCENTAGE%)"

if [ $PERCENTAGE -ge 90 ]; then
    echo "🎉 EXCELLENT! Project is ready for APK build!"
    echo "   👍 You can use GitHub Actions to build APK"
elif [ $PERCENTAGE -ge 70 ]; then
    echo "✅ GOOD! Minor issues need fixing"
    echo "   🔧 Fix remaining issues before building"
else
    echo "⚠️  NEEDS WORK! Several issues found"
    echo "   🛠️ Address the issues above before building"
fi

echo
echo "🚀 Next Steps:"
echo "1. Push code to GitHub repository"
echo "2. Go to Actions tab in GitHub"
echo "3. Run 'Flutter APK Build' workflow"
echo "4. Download APK from Artifacts section"
echo
echo "📱 Alternative: Use online build services like"
echo "   - GitHub Actions (recommended)"
echo "   - Codemagic"
echo "   - AppCenter"
echo "   - Firebase App Distribution"