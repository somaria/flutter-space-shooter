# App Store Publishing Guide for FlutterGames

This document provides instructions for publishing FlutterGames to the App Store.

## Prerequisites
- Apple Developer account
- App created in App Store Connect
- App-specific information configured in App Store Connect (pricing, descriptions, screenshots, etc.)

## Steps to publish

### 1. Clean build artifacts
```
flutter clean
```

### 2. Update app version
Update the version in `pubspec.yaml`:
```yaml
version: 1.0.0+4  # Increment as needed
```

### 3. Build release version
```
flutter build ios --release
```

### 4. Create IPA for App Store submission
```
flutter build ipa --export-options-plist=/Volumes/wd/code/Flutter/fluttergames/ios/exportOptions.plist
```

### 5. Upload to App Store
Either:
- Drag and drop the IPA file into the Apple Transporter macOS app
- Use the `xcrun altool` command:
```
xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey your_api_key --apiIssuer your_issuer_id
```

### 6. Complete submission in App Store Connect
- Log in to App Store Connect
- Navigate to your app
- Complete any remaining information
- Submit for review

## Notes
- Make sure app icons and launch images are not placeholders
- Ensure all required privacy descriptions are in Info.plist
- Keep exportOptions.plist updated with correct team ID

## Important Files
- `pubspec.yaml`: App version and dependencies
- `ios/Runner/Info.plist`: iOS-specific configurations
- `ios/exportOptions.plist`: Export options for App Store submission
