# Tasks - Story Content Parser

## Task 1: Implement StoryLoader Service
**Status**: ✅ Completed
**Priority**: High
**Assignee**: Agent

### Description
Create the core StoryLoader service that handles loading, parsing, and validating JSON story files from the app bundle.

### Subtasks
- [x] 1.1: Create StoryLoader.swift with singleton pattern
- [x] 1.2: Implement loadStory(withId:validate:) method
- [x] 1.3: Implement loadAllStories(validate:) method
- [x] 1.4: Add story caching mechanism
- [x] 1.5: Implement validateStory(_:) with all validation rules
- [x] 1.6: Add segment lookup utilities (getSegment, getStartingSegment)
- [x] 1.7: Define StoryLoaderError enum
- [x] 1.8: Add cache management methods (clearCache, preloadStory)

### Acceptance Criteria
- StoryLoader successfully loads JSON files from bundle
- Validation catches all structural issues (broken refs, unreachable segments, missing authentic paths)
- Caching improves repeat load performance
- Error handling covers all failure cases

### Files Modified
- `StoryPath/StoryPath/Services/StoryLoader.swift` (created)

---

## Task 2: Implement StoryRepository Service
**Status**: ✅ Completed
**Priority**: High
**Assignee**: Agent

### Description
Create the high-level StoryRepository service that manages story collections with filtering, searching, and sorting capabilities.

### Subtasks
- [x] 2.1: Create StoryRepository.swift as ObservableObject
- [x] 2.2: Implement loadStories() and refreshStories() methods
- [x] 2.3: Add filtering methods (by tag, age range, culture, purchase status)
- [x] 2.4: Implement searchStories(query:) method
- [x] 2.5: Add sorting functionality with StorySortOption enum
- [x] 2.6: Implement computed properties (allTags, allCultures, allAgeRanges)
- [x] 2.7: Add @Published properties for UI observation

### Acceptance Criteria
- Repository loads all stories successfully
- All filtering methods work correctly
- Search functionality matches title and synopsis
- Sorting works for all sort options
- Observable properties trigger UI updates

### Files Modified
- `StoryPath/StoryPath/Services/StoryRepository.swift` (created)

---

## Task 3: Add Comprehensive Unit Tests
**Status**: ✅ Completed
**Priority**: High
**Assignee**: Agent

### Description
Create comprehensive unit tests for both StoryLoader and StoryRepository to ensure reliability.

### Subtasks
- [x] 3.1: Test StoryLoader JSON decoding
- [x] 3.2: Test StoryLoader caching behavior
- [x] 3.3: Test StoryLoader validation logic
- [x] 3.4: Test StoryLoader segment retrieval
- [x] 3.5: Test validation error detection (invalid refs, unreachable segments)
- [x] 3.6: Test StoryRepository loading
- [x] 3.7: Test StoryRepository filtering methods
- [x] 3.8: Test StoryRepository search functionality
- [x] 3.9: Test StoryRepository sorting
- [x] 3.10: Test path counting in Story model

### Acceptance Criteria
- All tests pass successfully
- Edge cases covered (invalid JSON, missing files, broken references)
- Test coverage for all public methods
- Tests use both real story files and inline JSON

### Files Modified
- `StoryPath/StoryPathTests/StoryPathTests.swift` (updated)

---

## Task 4: Create Sample Story Content
**Status**: ✅ Completed
**Priority**: Medium
**Assignee**: Agent

### Description
Create the Little Red Riding Hood story JSON file to test the parser with real content.

### Subtasks
- [x] 4.1: Create Stories directory in app bundle resources
- [x] 4.2: Write little-red-riding-hood.json with complete story structure
- [x] 4.3: Include authentic path through original story
- [x] 4.4: Add 2-3 alternative branching paths
- [x] 4.5: Validate JSON structure against schema

### Acceptance Criteria
- Story JSON matches Story model structure
- Story has complete authentic path
- Alternative paths provide meaningful choices
- Story metadata properly filled out
- File loads successfully in tests

### Files Created
- `StoryPath/StoryPath/Resources/Stories/little-red-riding-hood.json` (created)

---

## Task 5: Integration & Testing
**Status**: 🔄 In Progress
**Priority**: High
**Assignee**: Agent

### Description
Verify all components work together and tests pass.

### Subtasks
- [x] 5.1: Run full test suite
- [x] 5.2: Fix missing Combine import in StoryRepository
- [ ] 5.3: Add Stories folder to Xcode project as folder reference
- [ ] 5.4: Verify StoryLoader loads little-red-riding-hood.json
- [ ] 5.5: Verify validation passes for real story content
- [ ] 5.6: Address any remaining test failures or warnings

### Acceptance Criteria
- All unit tests pass
- No Swift compiler warnings
- StoryLoader successfully loads real story content
- Performance acceptable for expected story count

### Files Verified
- All test files
- StoryLoader.swift (✅ compiles)
- StoryRepository.swift (✅ fixed - added Combine import)

### Notes
- Tests compile successfully after adding Combine import
- Story JSON file exists but needs to be added to Xcode project
- Tests that load stories from bundle are failing because Resources/Stories folder isn't in the bundle yet
- This requires manual Xcode project configuration (File > Add Files to "StoryPath" > Add folder reference)

---

## Notes
- Tasks 1-3 have been completed with existing code
- Task 4 (sample story content) is the next priority
- Task 5 (integration testing) should be run after Task 4
- All code uses Swift 6 with async/await
- Tests use Swift Testing framework
