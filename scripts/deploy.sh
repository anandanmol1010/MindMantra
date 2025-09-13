#!/bin/bash

# MindMitra Deployment Script
# This script automates the deployment process for the MindMitra app

set -e  # Exit on any error

echo "🚀 Starting MindMitra Deployment Process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Check Firebase CLI
    if ! command -v firebase &> /dev/null; then
        print_error "Firebase CLI is not installed"
        exit 1
    fi
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed"
        exit 1
    fi
    
    print_success "All prerequisites are installed"
}

# Clean and prepare project
prepare_project() {
    print_status "Preparing project..."
    
    # Clean Flutter project
    flutter clean
    flutter pub get
    
    # Install Cloud Functions dependencies
    cd functions
    npm install
    cd ..
    
    print_success "Project prepared successfully"
}

# Deploy Cloud Functions
deploy_functions() {
    print_status "Deploying Cloud Functions..."
    
    # Check if Gemini API key is configured
    if ! firebase functions:config:get gemini.api_key &> /dev/null; then
        print_warning "Gemini API key not configured. Please run:"
        print_warning "firebase functions:config:set gemini.api_key=\"YOUR_API_KEY\""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    firebase deploy --only functions
    print_success "Cloud Functions deployed successfully"
}

# Deploy Firestore rules and indexes
deploy_firestore() {
    print_status "Deploying Firestore rules and indexes..."
    
    firebase deploy --only firestore
    print_success "Firestore rules and indexes deployed successfully"
}

# Build and deploy web app
deploy_web() {
    print_status "Building and deploying web app..."
    
    flutter build web --release
    firebase deploy --only hosting
    print_success "Web app deployed successfully"
}

# Build Android APK
build_android() {
    print_status "Building Android APK..."
    
    flutter build apk --release
    print_success "Android APK built successfully"
    print_status "APK location: build/app/outputs/flutter-apk/app-release.apk"
}

# Build Android App Bundle
build_android_bundle() {
    print_status "Building Android App Bundle..."
    
    flutter build appbundle --release
    print_success "Android App Bundle built successfully"
    print_status "Bundle location: build/app/outputs/bundle/release/app-release.aab"
}

# Build iOS app
build_ios() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_status "Building iOS app..."
        
        flutter build ios --release
        print_success "iOS app built successfully"
        print_status "Open ios/Runner.xcworkspace in Xcode to archive and upload"
    else
        print_warning "iOS build skipped (requires macOS)"
    fi
}

# Run tests
run_tests() {
    print_status "Running tests..."
    
    # Unit tests
    flutter test
    
    # Integration tests (if available)
    if [ -d "integration_test" ]; then
        flutter test integration_test/
    fi
    
    print_success "All tests passed"
}

# Main deployment function
main() {
    echo "🎯 MindMitra Deployment Script"
    echo "=============================="
    
    # Parse command line arguments
    DEPLOY_FUNCTIONS=false
    DEPLOY_FIRESTORE=false
    DEPLOY_WEB=false
    BUILD_ANDROID=false
    BUILD_IOS=false
    RUN_TESTS=false
    FULL_DEPLOY=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --functions)
                DEPLOY_FUNCTIONS=true
                shift
                ;;
            --firestore)
                DEPLOY_FIRESTORE=true
                shift
                ;;
            --web)
                DEPLOY_WEB=true
                shift
                ;;
            --android)
                BUILD_ANDROID=true
                shift
                ;;
            --ios)
                BUILD_IOS=true
                shift
                ;;
            --test)
                RUN_TESTS=true
                shift
                ;;
            --full)
                FULL_DEPLOY=true
                shift
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --functions    Deploy Cloud Functions"
                echo "  --firestore    Deploy Firestore rules and indexes"
                echo "  --web          Build and deploy web app"
                echo "  --android      Build Android APK and App Bundle"
                echo "  --ios          Build iOS app (macOS only)"
                echo "  --test         Run tests before deployment"
                echo "  --full         Full deployment (all components)"
                echo "  --help         Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # If no specific options, ask user
    if [[ "$DEPLOY_FUNCTIONS" == false && "$DEPLOY_FIRESTORE" == false && "$DEPLOY_WEB" == false && "$BUILD_ANDROID" == false && "$BUILD_IOS" == false && "$RUN_TESTS" == false && "$FULL_DEPLOY" == false ]]; then
        echo "What would you like to deploy?"
        echo "1) Full deployment (recommended)"
        echo "2) Cloud Functions only"
        echo "3) Web app only"
        echo "4) Mobile apps only"
        echo "5) Run tests only"
        read -p "Enter your choice (1-5): " choice
        
        case $choice in
            1)
                FULL_DEPLOY=true
                ;;
            2)
                DEPLOY_FUNCTIONS=true
                DEPLOY_FIRESTORE=true
                ;;
            3)
                DEPLOY_WEB=true
                ;;
            4)
                BUILD_ANDROID=true
                BUILD_IOS=true
                ;;
            5)
                RUN_TESTS=true
                ;;
            *)
                print_error "Invalid choice"
                exit 1
                ;;
        esac
    fi
    
    # Check prerequisites
    check_prerequisites
    
    # Prepare project
    prepare_project
    
    # Run tests if requested
    if [[ "$RUN_TESTS" == true || "$FULL_DEPLOY" == true ]]; then
        run_tests
    fi
    
    # Deploy components based on selection
    if [[ "$FULL_DEPLOY" == true ]]; then
        deploy_functions
        deploy_firestore
        deploy_web
        build_android_bundle
        build_ios
    else
        if [[ "$DEPLOY_FUNCTIONS" == true ]]; then
            deploy_functions
        fi
        
        if [[ "$DEPLOY_FIRESTORE" == true ]]; then
            deploy_firestore
        fi
        
        if [[ "$DEPLOY_WEB" == true ]]; then
            deploy_web
        fi
        
        if [[ "$BUILD_ANDROID" == true ]]; then
            build_android
            build_android_bundle
        fi
        
        if [[ "$BUILD_IOS" == true ]]; then
            build_ios
        fi
    fi
    
    print_success "🎉 Deployment completed successfully!"
    
    # Show next steps
    echo ""
    echo "📋 Next Steps:"
    if [[ "$BUILD_ANDROID" == true || "$FULL_DEPLOY" == true ]]; then
        echo "• Upload app-release.aab to Google Play Console"
    fi
    if [[ "$BUILD_IOS" == true || "$FULL_DEPLOY" == true ]]; then
        echo "• Archive and upload iOS app via Xcode"
    fi
    if [[ "$DEPLOY_WEB" == true || "$FULL_DEPLOY" == true ]]; then
        echo "• Web app is live at your Firebase Hosting URL"
    fi
    echo "• Monitor Cloud Functions logs: firebase functions:log"
    echo "• Check app performance in Firebase Console"
}

# Run main function with all arguments
main "$@"
