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
**Status**: Pending
**Priority**: High

### Description
Create the view component that displays story segment text with proper typography and scrolling.

### Subtasks
- [ ] 2.1: Create SegmentView.swift that accepts a StorySegment
- [ ] 2.2: Implement scrollable text display with serif typography (18-20pt)
- [ ] 2.3: Add proper line spacing, padding, and readable layout
- [ ] 2.4: Integrate SegmentView into StoryReadingView
- [ ] 2.5: Verify text displays correctly for current segment

### Acceptance Criteria
- Segment text displays with readable typography
- Long text scrolls properly
- Layout has comfortable margins and spacing

---

## Task 3: Create ChoiceButtonsView
**Status**: Pending
**Priority**: High

### Description
Create inline choice buttons that appear below segment text and handle navigation.

### Subtasks
- [ ] 3.1: Create ChoiceButtonsView.swift that accepts [StoryChoice] and selection callback
- [ ] 3.2: Implement vertical stack of full-width buttons with rounded corners
- [ ] 3.3: Add authentic path indicator (gold border/icon) for isAuthenticPath choices
- [ ] 3.4: Implement button tap handling that calls parent callback with nextSegmentId
- [ ] 3.5: Add visual feedback for button press state
- [ ] 3.6: Integrate into StoryReadingView below SegmentView
- [ ] 3.7: Wire up navigation: update currentSegmentId when choice selected
- [ ] 3.8: Verify tapping choices navigates to correct segments

### Acceptance Criteria
- Choice buttons display below segment text
- Authentic path choices are visually distinguished
- Tapping a choice navigates to the next segment

---

## Task 4: Create StoryEndingView
**Status**: Pending
**Priority**: Medium

### Description
Create the completion state view displayed when reaching an ending segment.

### Subtasks
- [ ] 4.1: Create StoryEndingView.swift with "The End" message
- [ ] 4.2: Add optional "Read Again" button that resets to first segment
- [ ] 4.3: Integrate into StoryReadingView - show when segment.isEnding is true
- [ ] 4.4: Verify ending displays correctly for ending segments

### Acceptance Criteria
- Ending segments show completion message instead of choices
- "Read Again" restarts the story from beginning

---

## Task 5: Integration & Polish
**Status**: Pending
**Priority**: Medium

### Description
Final integration, styling consistency, and verification of complete flow.

### Subtasks
- [ ] 5.1: Ensure consistent styling across all views (colors, fonts, spacing)
- [ ] 5.2: Add basic accessibility labels for VoiceOver
- [ ] 5.3: Test complete story flow from start to multiple endings
- [ ] 5.4: Verify authentic path navigation works correctly
- [ ] 5.5: Run existing tests to ensure no regressions
- [ ] 5.6: Fix any issues discovered during testing

### Acceptance Criteria
- Complete story can be read from start to any ending
- UI is consistent and polished
- All existing tests still pass
- Accessible to VoiceOver users

---

## Notes
- All views use existing StoryLoader and Story models
- No new dependencies required
- Focus on clean SwiftUI patterns with @State management
- Keep views modular for future reuse
