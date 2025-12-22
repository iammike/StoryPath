# StoryPath

An interactive storytelling app featuring classic fairy tales and folk stories in a choose-your-own-adventure format.

## Overview

StoryPath brings timeless public domain stories to life with branching narratives. Each story maintains a path to the original tale while offering creative alternatives for readers to explore.

## Current Features

- Interactive choose-your-own-adventure story reading
- Branching narrative with multiple endings
- "Authentic path" indicators showing choices that follow the original story
- Story restart from any ending
- VoiceOver accessibility support
- Text-to-speech narration with play/pause controls
- Progress tracking with completion percentage
- Auto-resume from bookmarked position

## Planned Features

- Story library with multiple tales
- AI-generated illustrations
- In-app purchases for additional stories

## Tech Stack

- Swift 6.0
- SwiftUI with @Observable
- iOS 17.0+ / macOS 15.0+
- JSON-based story content
- Swift Testing framework

## Project Structure

```
choose-your-own-story/
├── .agent-os/              # Product documentation & specs
├── StoryPath/
│   ├── StoryPath/
│   │   ├── Models/         # Story, StorySegment, StoryChoice
│   │   ├── Views/          # StoryReadingView
│   │   ├── ViewModels/     # StoryReadingViewModel
│   │   ├── Services/       # StoryLoader, StoryRepository, ProgressService, AudioService
│   │   └── Resources/      # Story JSON content
│   ├── StoryPathTests/     # Unit tests
│   └── StoryPath.xcodeproj
```

## Development

Open `StoryPath/StoryPath.xcodeproj` in Xcode 16+ and build for iOS 17.0+ or macOS 15.0+.

Run tests: `xcodebuild test -scheme StoryPath -destination 'platform=macOS'`

## License

TBD
