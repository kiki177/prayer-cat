# macOS source · v2.4.1

- `main.m`: application entry point and UI
- `MosqueFeature.h`, `MosqueFeature.m`: MapKit mosque search, route opening, and opt-in reminders
- `Info.plist`: application metadata
- `AppStore.entitlements`: App Sandbox entitlements
- `AppIcon.icns`, `AppIcon-master.png`, `AppIcon.iconset/`: application icon assets

Build and signing require Xcode and an Apple Developer account.

Nearby-mosque search uses Apple MapKit by default, so users do not need a Google API key. Google Places remains a future optional enhancement delivered through a developer-operated backend.
