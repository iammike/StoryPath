# Technical Stack

## Application Framework
- **Swift 6.0+** - Native iOS development language
- **SwiftUI** - Declarative UI framework for iOS 16.0+

## Platform
- **iOS 16.0+** - Minimum deployment target
- **Xcode 15+** - Development environment

## Data & Storage
- **SwiftData** - Local data persistence for user progress, bookmarks, and purchased content
- **Core Data** (fallback) - Alternative persistence framework if SwiftData limitations encountered
- **UserDefaults** - App preferences and settings
- **FileManager** - Local file storage for story content, audio files, and illustrations

## State Management
- **SwiftUI @State, @Binding, @Observable** - Built-in state management
- **Environment Objects** - Shared app state across views

## Audio & Media
- **AVFoundation** - Audio playback for narration
- **AVPlayer** - Advanced audio controls and playback management

## UI & Design
- **SF Symbols** - Native iOS iconography
- **SwiftUI Native Components** - Standard iOS UI elements
- **Custom SwiftUI Views** - Bespoke story interface components

## Content Format
- **JSON** - Story structure, decision trees, and metadata
- **Markdown** (optional) - Story text formatting
- **MP3/M4A** - Audio narration files
- **PNG/JPEG** - Illustration assets

## In-App Purchases
- **StoreKit 2** - Native in-app purchase framework
- **StoreKit Testing** - Local testing of purchase flows

## Development Tools
- **Git** - Version control
- **GitHub** - Code repository (URL: TBD)
- **SwiftLint** - Code style and quality enforcement
- **Swift Package Manager** - Dependency management

## AI Content Generation Tools (Development Phase)
- **ChatGPT/Claude** - Story path generation and variation creation
- **Midjourney/DALL-E/Stable Diffusion** - Illustration generation
- **ElevenLabs/Google Cloud TTS** - Audio narration generation

## Testing
- **XCTest** - Unit and integration testing
- **SwiftUI Previews** - Rapid UI development and testing
- **TestFlight** - Beta distribution and testing

## Deployment
- **App Store Connect** - iOS app distribution
- **TestFlight** - Pre-release testing platform

## Asset Hosting
- **Local Bundle** - All assets bundled with app initially
- **CloudKit** (future) - Potential cloud storage for additional content downloads

## Analytics (Future Consideration)
- **TelemetryDeck** (privacy-focused) - Optional usage analytics
- **App Store Analytics** - Built-in download and engagement metrics

## Accessibility
- **UIAccessibility** - VoiceOver support
- **Dynamic Type** - Text size scaling
- **Reduce Motion** - Animation preferences
