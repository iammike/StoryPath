# Story Content Parser - Technical Specification

## Architecture

### StoryLoader (Services/StoryLoader.swift)
**Purpose**: Core service for loading and parsing JSON story files

**Key Responsibilities**:
- Load story JSON files from bundle
- Decode JSON to Story model
- Validate story structure
- Cache loaded stories
- Provide segment lookup utilities

**Implementation Details**:
```swift
@MainActor class StoryLoader
- Singleton pattern (StoryLoader.shared)
- Private cache: [String: Story]
- JSONDecoder for parsing
- Async/await for file I/O
```

**Key Methods**:
- `loadStory(withId:validate:)` - Load single story with optional validation
- `loadAllStories(validate:)` - Load all stories from Stories directory
- `validateStory(_:)` - Validate story structure, return warnings
- `getSegment(withId:in:)` - Lookup segment within story
- `getStartingSegment(for:)` - Get first segment
- `clearCache()` - Clear story cache
- `preloadStory(withId:)` - Background preload without validation

**Validation Rules**:
1. Story must have at least one segment
2. All choice.nextSegmentId must reference existing segments
3. At least one segment marked as authenticPath
4. All segments (except first) must be reachable from start

**Error Handling**:
```swift
enum StoryLoaderError: Error {
    case fileNotFound
    case fileReadError(Error)
    case decodingError(Error)
    case invalidStory(warnings: [String])
}
```

### StoryRepository (Services/StoryRepository.swift)
**Purpose**: High-level service for managing story collections

**Key Responsibilities**:
- Load and manage all stories
- Filter stories by various criteria
- Search functionality
- Sort stories
- Observable state for UI binding

**Implementation Details**:
```swift
@MainActor class StoryRepository: ObservableObject
- Singleton pattern (StoryRepository.shared)
- @Published stories: [Story]
- @Published isLoading: Bool
- Uses StoryLoader internally
```

**Key Methods**:
- `loadStories()` - Load all stories from bundle
- `refreshStories()` - Clear cache and reload
- `getStory(withId:)` - Get single story (from memory or disk)
- `stories(withTag:)` - Filter by tag
- `stories(forAgeRange:)` - Filter by age range
- `stories(fromCulture:)` - Filter by cultural origin
- `searchStories(query:)` - Search title/synopsis
- `sortedStories(by:)` - Sort by various criteria

**Computed Properties**:
- `purchasedStories` - Filter purchased stories
- `unpurchasedStories` - Filter unpurchased stories
- `allTags` - Unique tags across all stories
- `allCultures` - Unique cultural origins
- `allAgeRanges` - Unique age ranges

**Sort Options**:
```swift
enum StorySortOption {
    case titleAscending, titleDescending
    case readingTimeAscending, readingTimeDescending
    case pathCountAscending, pathCountDescending
}
```

## File Structure
```
StoryPath/
├── Services/
│   ├── StoryLoader.swift       (Core parsing/validation)
│   └── StoryRepository.swift   (High-level management)
└── Resources/
    └── Stories/
        └── *.json              (Story content files)
```

## Data Flow
1. StoryRepository requests stories via loadStories()
2. StoryLoader reads JSON files from Stories directory
3. JSONDecoder parses JSON to Story models
4. Optional validation runs on each story
5. Valid stories cached in StoryLoader
6. Stories published to StoryRepository.stories
7. UI observes StoryRepository for updates

## Testing Strategy

### StoryLoader Tests
- JSON decoding (valid/invalid format)
- File loading (found/not found)
- Caching behavior
- Validation logic (all rules)
- Segment retrieval
- Error handling

### StoryRepository Tests
- Story loading
- Filtering (tags, age range, culture, purchase status)
- Searching
- Sorting
- Computed properties (allTags, allCultures, etc)
- Observable state changes

### Test Data
- little-red-riding-hood.json (real story file)
- Inline JSON for edge cases (invalid refs, unreachable segments, etc)

## Performance Considerations
- Stories cached after first load
- Validation optional for production loads
- Async loading prevents UI blocking
- Bundle resources loaded synchronously (acceptable for MVP)

## Future Enhancements (Out of Scope)
- Remote story downloads
- Incremental loading for large catalogs
- Story content updates
- Version management
- Localization support
