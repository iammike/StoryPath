# Product Roadmap

## Phase 1: Foundation & MVP

**Goal:** Build core interactive story reading experience with one complete story demonstrating all features

**Success Criteria:**
- Single fully-functional interactive story with 5+ decision points
- Audio narration working for all story paths
- Basic progress tracking and bookmarking
- App runs smoothly on iOS 16+ devices

### Features

- [x] Xcode project setup with SwiftUI and SwiftData - Create project structure, configure build settings, set up Git repository `S`
- [x] GitHub Actions CI/CD - Setup automated testing that must pass before merging PRs `S`
- [x] Story data model - Design JSON schema for story structure, decision trees, paths, and metadata `M`
- [x] Story content parser - Build system to load and parse story JSON into app data structures `M`
- [x] Basic story reading UI - Create scrollable story view with text display and navigation `M`
- [x] Decision point interface - Interactive choice buttons with branching logic `M`
- [x] Audio playback system - Text-to-speech with play/pause controls and premium voice selection `M`
- [x] Progress tracking - Track completed paths, current position, and story completion percentage `S`
- [x] Bookmark functionality - Auto-resume with "continuing where you left off" notice `S`
- [x] First complete story - "Little Red Riding Hood" with 5 branching paths and TTS narration `XL`

### Dependencies

- Story JSON schema must be finalized before content creation
- Audio narration requires completed story text for all paths
- UI design mockups for story reading experience

## Phase 2: Story Library & Content

**Goal:** Expand to multiple stories with library interface and story discovery

**Success Criteria:**
- 5-7 complete stories available
- Intuitive library browsing experience
- Story preview and selection working smoothly

### Features

- [x] Story library home screen - Grid/list view of available stories with cover art `M`
- [ ] Story detail/preview screen - Synopsis, sample illustration, estimated reading time, path count `S`
- [ ] Story provenance metadata - Original author, publication year, cultural origin, historical context `S`
- [x] Story progress indicators - Visual badges showing completed paths and overall progress `S`
- [ ] Story collections/categories - Group stories by culture, theme, or collection (Grimm, Aesop, etc.) `M`
- [ ] Additional stories authored - 4-6 more classic tales with branching narratives and audio `XL`
- [x] Illustration system - Display and manage story illustrations tied to scenes `M`
- [ ] Story map visualization - Show decision tree and explored/unexplored paths `L`
- [x] Expand Little Red Riding Hood story text - Richer, more atmospheric prose `M`
- [x] Minimal story navigation bar - Pull-to-reveal nav with home, restart, and audio toggle `S`

### Known Issues
- [x] Resume banner scrolls with content instead of staying fixed #77
- [x] Thin white line above illustration in safe area (iPhone) #70

### Dependencies

- Consistent illustration style established
- Audio narration pipeline streamlined for efficiency
- Content approval process for story variations

## Phase 3: Monetization & Polish

**Goal:** Implement in-app purchases and refine user experience for App Store launch

**Success Criteria:**
- StoreKit integration fully tested
- Freemium model working (3 free stories, others purchasable)
- App Store submission ready

### Features

- [ ] StoreKit 2 integration - Product setup, purchase flow, receipt validation `L`
- [ ] Story unlock system - Lock/unlock stories based on purchases `M`
- [ ] Purchase UI - Story bundle browsing, pricing display, purchase confirmation `M`
- [ ] Parental gate - Simple math problem or pattern before purchases `S`
- [ ] Top navigation bar - Controls, settings access, navigation options `M`
- [ ] Settings screen - Audio preferences, text size, app info, restore purchases `S`
- [ ] Reset progress - Option to reset progress for individual stories or all stories `S`
- [ ] Customizable fonts and color schemes - Preselected fonts, color themes, dark mode support `M`
- [ ] Onboarding flow - Welcome screens explaining app features and value `M`
- [ ] App icon and launch screen - Professional branding assets `S`
- [ ] Accessibility improvements - VoiceOver support, Dynamic Type, contrast modes `L`
- [ ] Performance optimization - Reduce app size, optimize asset loading, smooth animations `M`
- [ ] App Store assets - Screenshots, preview video, app description, keywords `M`

### Dependencies

- App Store developer account setup
- Legal review of content usage (public domain verification)
- Privacy policy and terms of service
- TestFlight beta testing feedback

## Phase 4: Enhanced Features & Engagement

**Goal:** Add features that increase replay value and user engagement

**Success Criteria:**
- Users completing multiple paths per story
- Increased session time and return visits
- Positive user reviews mentioning new features

### Features

- [ ] Achievement system - Badges for path discoveries, story completions, collection milestones `M`
- [ ] Authentic ending celebration - Confetti/balloons animation when completing the original story path `S`
- [ ] Page turning animation - Animated transition between story segments `S`
- [ ] Reading statistics - Time spent reading, favorite stories, paths explored `S`
- [ ] Audio customization - Narration speed control, voice selection (if multiple available) `M`
- [ ] Professional voice narration - Pre-recorded audio narration for stories `L`
- [ ] Story favorites - Mark and quickly access favorite stories `XS`
- [ ] Path recommendations - "Haven't tried this path yet" suggestions `S`
- [ ] Back button navigation - Navigate backwards through selected story path `M`
- [ ] Illustration gallery - Unlock and view collected artwork `M`
- [ ] Art style selection - Choose illustration style per story (Classic Fairytale, Soft Watercolor, Bold Graphic, etc.) `L`
- [ ] Expanded story library - 10+ additional stories across diverse cultures `XL`

### Dependencies

- User analytics (privacy-focused) to understand engagement patterns
- User feedback on most-requested features

## Phase 5: Community & Content Expansion

**Goal:** Scale content library and explore community features

**Success Criteria:**
- 25+ stories available
- Regular content release schedule established
- User retention improvements

### Features

- [ ] Seasonal story releases - Holiday and themed story drops `M`
- [ ] Story ratings and reviews - User feedback on individual stories `M`
- [ ] Recommended for you - Personalized story suggestions based on reading history `L`
- [ ] Reading streaks - Encourage daily reading habits `S`
- [ ] Multiple language support - Internationalization framework and first additional language `XL`
- [ ] CloudKit integration - Optional cloud sync for progress across devices `L`
- [ ] Subscription model exploration - Monthly subscription for all content access `M`
- [ ] User-generated content tools (future) - Framework for community story submissions `XL`

### Dependencies

- Sustainable content creation pipeline (AI-assisted workflows)
- Localization partners for translation
- Content moderation system if UGC explored

## Phase 6: Platform Expansion

**Goal:** Bring StoryPath to more platforms and users

**Success Criteria:**
- Feature parity across platforms
- Consistent story experience
- Shared content pipeline

### Features

- [ ] Android port - Kotlin/Compose for phones, tablets, Fire tablets, Fire TV, Google TV `XL`
- [ ] Web app - Browser-based version for universal access `L`
- [ ] Apple TV app - tvOS app for Apple ecosystem families `M`

### Dependencies

- Android/Android TV development expertise
- Web framework selection (React, Vue, etc.)
