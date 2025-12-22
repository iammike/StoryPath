# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-12-22-story-reading-ui/spec.md

## Technical Requirements

### Views to Create

#### StoryReadingView
- Main container view that manages story state
- Loads story using existing `StoryLoader.shared`
- Tracks current segment ID as `@State`
- Passes segment data to child views

#### SegmentView
- Displays segment text with proper typography
- Vertically scrollable for long text
- Font: System serif, size suitable for reading (18-20pt)
- Line spacing and padding for readability
- Dark text on light background

#### ChoiceButtonsView
- Displays inline choice buttons below segment text
- Each button shows choice text
- Authentic path indicator: subtle icon or border highlight
- Tappable with visual feedback (button press state)
- Calls parent callback with selected `nextSegmentId`

#### StoryEndingView
- Displayed when segment has no choices (`isEnding == true`)
- Shows "The End" or completion message
- Could include a "Read Again" button (optional)

### Integration with Existing Code

```swift
// Use existing services
StoryLoader.shared.loadStory(withId: "little-red-riding-hood")
StoryLoader.shared.getSegment(withId: segmentId, in: story)
StoryLoader.shared.getStartingSegment(for: story)
```

### State Management

- `@State private var currentSegmentId: String`
- `@State private var story: Story?`
- `@State private var isLoading: Bool`
- Navigation: Update `currentSegmentId` when choice tapped

### UI/UX Specifications

#### Typography
- Story text: SF Serif or Georgia, 18-20pt
- Choice buttons: SF Pro, 16pt, medium weight
- Adequate line height (1.4-1.6x)
- Comfortable margins (20pt horizontal)

#### Choice Button Design
- Full-width buttons with rounded corners
- Vertical stack with 12pt spacing
- Authentic path: Subtle gold/yellow border or small icon
- Non-authentic: Standard button appearance
- Tap state: slight scale or opacity change

#### Colors
- Background: Off-white (#FAFAFA or system background)
- Text: Near-black (#1A1A1A)
- Choice buttons: Light gray background with dark text
- Authentic indicator: Gold/amber accent (#D4A84B)

### Performance Considerations

- Story is already cached by StoryLoader after first load
- Segment lookup is O(n) but segments array is small
- No network calls required (bundled content)
- Animations should be subtle and 60fps

### Accessibility

- Dynamic Type support for all text
- VoiceOver labels for choice buttons
- Sufficient color contrast ratios
- Touch targets minimum 44x44pt
