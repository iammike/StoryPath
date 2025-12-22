# Spec Requirements Document

> Spec: Story Reading UI
> Created: 2025-12-22

## Overview

Implement the core story reading interface that displays story text, handles segment navigation, and presents interactive choice buttons for branching paths. This is the primary user-facing feature that transforms the existing StoryLoader/StoryRepository backend into a usable interactive story experience.

## User Stories

### Reading a Story

As a parent reading with my child, I want to see the story text clearly displayed with easy-to-read formatting, so that we can enjoy the narrative together.

The user selects a story and is presented with the first segment's text. The text is displayed in a scrollable view with comfortable reading typography. When they finish reading, choice buttons appear inline below the text, allowing them to select the next path in the story.

### Making Choices

As a reader, I want to tap on choice buttons to navigate through the story's branching paths, so that I can explore different narrative outcomes.

When a segment has choices, each choice is displayed as a tappable button below the story text. Tapping a choice loads the corresponding next segment, replacing the current view with the new story content. When a segment has no choices (ending), a completion state is shown.

### Following the Authentic Path

As a parent who wants to read the original story, I want to easily identify which choices follow the authentic/original narrative, so that I can experience the classic tale as intended.

Choices that follow the authentic path are visually distinguished (subtle indicator) from alternative branches, allowing readers to follow the original story if they prefer.

## Spec Scope

1. **Story Reading View** - A SwiftUI view that displays the current segment's text with proper typography and scrolling
2. **Choice Buttons** - Inline tappable buttons below segment text that navigate to the next segment
3. **Segment Navigation** - Logic to load and display segments based on choice selection
4. **Authentic Path Indicator** - Visual distinction for choices that follow the original story
5. **Story Ending State** - Display completion message when reaching an ending segment

## Out of Scope

- Story library/selection screen (separate spec)
- Audio playback integration
- Progress tracking and persistence
- Bookmarking functionality
- Illustrations/images display
- Story map visualization
- Back navigation / history

## Expected Deliverable

1. App launches and displays the first segment of "Little Red Riding Hood" story
2. User can tap choice buttons to navigate through the story to different segments
3. Authentic path choices are visually distinguishable from alternative choices
4. Story endings display a completion state
