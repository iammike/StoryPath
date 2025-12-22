# Tasks - Story Reading UI

## Task 1: Create StoryReadingView Container
**Status**: ✅ Completed
**Priority**: High

### Description
Create the main container view that loads a story and manages navigation state between segments.

### Subtasks
- [x] 1.1: Create StoryReadingView.swift with @State for currentSegmentId and story
- [x] 1.2: Implement async story loading using StoryLoader.shared on appear
- [x] 1.3: Add loading state UI while story loads
- [x] 1.4: Update ContentView to display StoryReadingView with "little-red-riding-hood"
- [x] 1.5: Verify story loads and first segment ID is set correctly

### Acceptance Criteria
- StoryReadingView loads story on appear ✅
- Current segment state is properly managed ✅
- Loading indicator shows during fetch ✅

### Files Modified
- `StoryPath/StoryPath/Views/StoryReadingView.swift` (created)
- `StoryPath/StoryPath/ContentView.swift` (updated)

---

## Task 2: Create SegmentView for Text Display
**Status**: ✅ Completed
**Priority**: High

### Description
Create the view component that displays story segment text with proper typography and scrolling.

### Subtasks
- [x] 2.1: Create SegmentView.swift that accepts a StorySegment
- [x] 2.2: Implement scrollable text display with serif typography (18-20pt)
- [x] 2.3: Add proper line spacing, padding, and readable layout
- [x] 2.4: Integrate SegmentView into StoryReadingView
- [x] 2.5: Verify text displays correctly for current segment

### Acceptance Criteria
- Segment text displays with readable typography ✅
- Long text scrolls properly ✅
- Layout has comfortable margins and spacing ✅

### Implementation Notes
Implemented as `segmentContentView` function within StoryReadingView using Georgia font at 18pt with line spacing of 6.

---

## Task 3: Create ChoiceButtonsView
**Status**: ✅ Completed
**Priority**: High

### Description
Create inline choice buttons that appear below segment text and handle navigation.

### Subtasks
- [x] 3.1: Create ChoiceButtonsView.swift that accepts [StoryChoice] and selection callback
- [x] 3.2: Implement vertical stack of full-width buttons with rounded corners
- [x] 3.3: Add authentic path indicator (gold border/icon) for isAuthenticPath choices
- [x] 3.4: Implement button tap handling that calls parent callback with nextSegmentId
- [x] 3.5: Add visual feedback for button press state
- [x] 3.6: Integrate into StoryReadingView below SegmentView
- [x] 3.7: Wire up navigation: update currentSegmentId when choice selected
- [x] 3.8: Verify tapping choices navigates to correct segments

### Acceptance Criteria
- Choice buttons display below segment text ✅
- Authentic path choices are visually distinguished (gold border + book icon) ✅
- Tapping a choice navigates to the next segment ✅

### Implementation Notes
Implemented as `choicesView` function within StoryReadingView. Authentic path indicator uses gold color (RGB: 0.83, 0.66, 0.29) with book.fill system image.

---

## Task 4: Create StoryEndingView
**Status**: ✅ Completed
**Priority**: Medium

### Description
Create the completion state view displayed when reaching an ending segment.

### Subtasks
- [x] 4.1: Create StoryEndingView.swift with "The End" message
- [x] 4.2: Add optional "Read Again" button that resets to first segment
- [x] 4.3: Integrate into StoryReadingView - show when segment.isEnding is true
- [x] 4.4: Verify ending displays correctly for ending segments

### Acceptance Criteria
- Ending segments show completion message instead of choices ✅
- "Read Again" restarts the story from beginning ✅

### Implementation Notes
Implemented as `endingView` computed property within StoryReadingView. Uses Georgia font and bordered button style.

---

## Task 5: Integration & Polish
**Status**: ✅ Completed
**Priority**: Medium

### Description
Final integration, styling consistency, and verification of complete flow.

### Subtasks
- [x] 5.1: Ensure consistent styling across all views (colors, fonts, spacing)
- [x] 5.2: Add basic accessibility labels for VoiceOver
- [x] 5.3: Test complete story flow from start to multiple endings
- [x] 5.4: Verify authentic path navigation works correctly
- [x] 5.5: Run existing tests to ensure no regressions
- [x] 5.6: Fix any issues discovered during testing

### Acceptance Criteria
- Complete story can be read from start to any ending ✅
- UI is consistent and polished ✅
- All existing tests still pass ✅
- Accessible to VoiceOver users ✅

### Implementation Notes
- Extracted navigation logic to StoryReadingViewModel for testability
- Added 5 unit tests for ViewModel (load, select, restart, ending detection, error handling)
- All 16 tests pass

---

## Bonus: ViewModel Extraction
**Status**: ✅ Completed

### Description
Extracted navigation logic into StoryReadingViewModel for better testability.

### Files Created
- `StoryPath/StoryPath/ViewModels/StoryReadingViewModel.swift`

### Tests Added
- `testViewModelLoadStory` - Story loading and initial state
- `testViewModelSelectChoice` - Navigation via choice selection
- `testViewModelRestartStory` - Restart functionality
- `testViewModelIsAtEnding` - Ending detection
- `testViewModelLoadInvalidStory` - Error handling

---

## Notes
- All views use existing StoryLoader and Story models
- No new dependencies required
- Focus on clean SwiftUI patterns with @Observable ViewModel
- Keep views modular for future reuse
