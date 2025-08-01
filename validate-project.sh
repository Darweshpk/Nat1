#!/bin/bash

# NativeChat Project Validation Script v1.8.1
# This script validates the project structure and configuration

echo "🤖 NativeChat Project Validation Script v1.8.1"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Helper functions
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    ((PASSED_CHECKS++))
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    ((FAILED_CHECKS++))
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNING_CHECKS++))
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

check_file() {
    ((TOTAL_CHECKS++))
    if [ -f "$1" ]; then
        print_success "File exists: $1"
        return 0
    else
        print_error "Missing file: $1"
        return 1
    fi
}

check_directory() {
    ((TOTAL_CHECKS++))
    if [ -d "$1" ]; then
        print_success "Directory exists: $1"
        return 0
    else
        print_error "Missing directory: $1"
        return 1
    fi
}

echo ""
echo "🔍 Checking Project Structure..."
echo "--------------------------------"

# Check critical files
check_file "pubspec.yaml"
check_file "lib/main.dart"
check_file "android/app/build.gradle"
check_file "android/app/src/main/AndroidManifest.xml"
check_file "README.md"
check_file "APK_BUILD_GUIDE.md"

# Check directories
check_directory "lib"
check_directory "lib/models"
check_directory "lib/services"
check_directory "lib/components"
check_directory "lib/ai"
check_directory "lib/utils"
check_directory "lib/widgets"
check_directory "android"
check_directory "assets"
check_directory ".github/workflows"

echo ""
echo "🔧 Checking Configuration Files..."
echo "-----------------------------------"

# Check pubspec.yaml content
((TOTAL_CHECKS++))
if grep -q "nativechat" pubspec.yaml; then
    print_success "pubspec.yaml: App name configured"
else
    print_error "pubspec.yaml: App name not found"
fi

((TOTAL_CHECKS++))
if grep -q "version: 1.8.1" pubspec.yaml; then
    print_success "pubspec.yaml: Version 1.8.1 configured"
else
    print_warning "pubspec.yaml: Version might not be latest"
fi

# Check Android configuration
((TOTAL_CHECKS++))
if grep -q "com.nativechat.ai" android/app/build.gradle; then
    print_success "Android: Application ID configured"
else
    print_warning "Android: Application ID might need updating"
fi

((TOTAL_CHECKS++))
if grep -q "minSdk = 21" android/app/build.gradle; then
    print_success "Android: Minimum SDK 21 configured"
else
    print_error "Android: Minimum SDK not properly set"
fi

# Check permissions in AndroidManifest.xml
echo ""
echo "🔐 Checking Permissions..."
echo "--------------------------"

permissions=(
    "android.permission.INTERNET"
    "android.permission.READ_SMS"
    "android.permission.READ_CALL_LOG"
    "android.permission.RECORD_AUDIO"
    "android.permission.ACCESS_FINE_LOCATION"
    "android.permission.CAMERA"
)

for permission in "${permissions[@]}"; do
    ((TOTAL_CHECKS++))
    if grep -q "$permission" android/app/src/main/AndroidManifest.xml; then
        print_success "Permission: $permission"
    else
        print_error "Missing permission: $permission"
    fi
done

echo ""
echo "📦 Checking Dependencies..."
echo "---------------------------"

# Check critical dependencies
dependencies=(
    "flutter:"
    "google_generative_ai:"
    "speech_to_text:"
    "flutter_tts:"
    "hive:"
    "dio:"
    "theme_provider:"
)

for dep in "${dependencies[@]}"; do
    ((TOTAL_CHECKS++))
    if grep -q "$dep" pubspec.yaml; then
        print_success "Dependency: ${dep%:}"
    else
        print_error "Missing dependency: ${dep%:}"
    fi
done

echo ""
echo "🏗️ Checking Build Configuration..."
echo "-----------------------------------"

# Check GitHub Actions workflow
((TOTAL_CHECKS++))
if [ -f ".github/workflows/build-apk.yml" ]; then
    print_success "GitHub Actions workflow configured"
else
    print_error "GitHub Actions workflow missing"
fi

# Check if Flutter can detect the project
((TOTAL_CHECKS++))
if flutter doctor --version > /dev/null 2>&1; then
    print_success "Flutter CLI available"
else
    print_warning "Flutter CLI not found or not in PATH"
fi

echo ""
echo "🎨 Checking Assets..."
echo "---------------------"

# Check assets
assets=(
    "assets/logo/logo.png"
    "assets/logo/logoBorder.png"
)

for asset in "${assets[@]}"; do
    ((TOTAL_CHECKS++))
    if [ -f "$asset" ]; then
        print_success "Asset: $asset"
    else
        print_warning "Asset missing: $asset"
    fi
done

echo ""
echo "🧪 Checking Code Quality..."
echo "---------------------------"

# Check for main entry points
((TOTAL_CHECKS++))
if grep -q "void main()" lib/main.dart; then
    print_success "Main entry point found"
else
    print_error "Main entry point missing"
fi

((TOTAL_CHECKS++))
if grep -q "NativeChatApp" lib/main.dart; then
    print_success "Main app class found"
else
    print_error "Main app class missing"
fi

# Check for critical models
models=(
    "lib/models/llm_provider.dart"
    "lib/models/chat_session.dart"
    "lib/models/settings.dart"
)

for model in "${models[@]}"; do
    ((TOTAL_CHECKS++))
    if [ -f "$model" ]; then
        print_success "Model: $(basename $model)"
    else
        print_error "Missing model: $(basename $model)"
    fi
done

echo ""
echo "📊 Validation Summary"
echo "====================="

TOTAL_SCORE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

echo -e "Total Checks: ${BLUE}$TOTAL_CHECKS${NC}"
echo -e "Passed: ${GREEN}$PASSED_CHECKS${NC}"
echo -e "Failed: ${RED}$FAILED_CHECKS${NC}"
echo -e "Warnings: ${YELLOW}$WARNING_CHECKS${NC}"
echo -e "Score: ${BLUE}$TOTAL_SCORE%${NC}"

echo ""
if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}🎉 PROJECT VALIDATION SUCCESSFUL!${NC}"
    echo "Your NativeChat project is ready for APK build!"
    echo ""
    echo "Next steps:"
    echo "1. Run 'flutter pub get' to install dependencies"
    echo "2. Run 'flutter build apk --release' for local build"
    echo "3. Or push to GitHub for automated build"
else
    echo -e "${RED}❌ PROJECT VALIDATION FAILED${NC}"
    echo "Please fix the issues above before building APK"
    echo ""
    echo "Common fixes:"
    echo "1. Check file paths and names"
    echo "2. Verify pubspec.yaml configuration"
    echo "3. Ensure all dependencies are properly added"
fi

echo ""
echo "For more details, check APK_BUILD_GUIDE.md"
echo "Support: https://github.com/nativechat/nativechat"

exit $FAILED_CHECKS