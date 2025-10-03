# StoryPath

An interactive storytelling iOS app featuring classic fairy tales and folk stories in a choose-your-own-adventure format.

## Overview

StoryPath brings timeless public domain stories to life with branching narratives, beautiful illustrations, and audio narration. Each story maintains a path to the original tale while offering creative alternatives for young readers to explore.

## Features

- Interactive choose-your-own-adventure storytelling
- Classic fairy tales and folk stories from diverse cultures
- Audio narration for all story paths
- Progress tracking and bookmarking
- Beautiful AI-generated illustrations
- Freemium model with in-app purchases

## Tech Stack

- Swift 6.0+
- SwiftUI (iOS 16.0+)
- Local storage (UserDefaults, FileManager)
- StoreKit 2 for in-app purchases
- AVFoundation for audio playback

## Project Structure

```
choose-your-own-story/
├── .agent-os/          # Product documentation
├── StoryPath/          # Xcode project
│   ├── StoryPath/      # Source code
│   │   ├── Models/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   ├── Services/
│   │   └── Resources/
│   └── StoryPath.xcodeproj
```

## Development

Open `StoryPath/StoryPath.xcodeproj` in Xcode 15+ and build for iOS 16.0+.

## License

TBD
