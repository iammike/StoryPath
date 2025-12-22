//
//  StoryReadingView.swift
//  StoryPath
//

import SwiftUI

struct StoryReadingView: View {
    let storyId: String

    @State private var story: Story?
    @State private var currentSegmentId: String?
    @State private var isLoading = true
    @State private var errorMessage: String?

    private var currentSegment: StorySegment? {
        guard let story = story, let segmentId = currentSegmentId else { return nil }
        return StoryLoader.shared.getSegment(withId: segmentId, in: story)
    }

    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if let error = errorMessage {
                errorView(error)
            } else if let segment = currentSegment {
                segmentContentView(segment)
            } else {
                Text("No content available")
                    .foregroundStyle(.secondary)
            }
        }
        .task {
            await loadStory()
        }
    }

    // MARK: - Subviews

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading story...")
                .foregroundStyle(.secondary)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text("Error loading story")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                Task {
                    await loadStory()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private func segmentContentView(_ segment: StorySegment) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Story text
                Text(segment.text)
                    .font(.custom("Georgia", size: 18))
                    .lineSpacing(6)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                // Choices or ending (placeholder for now)
                if segment.isEnding {
                    endingView
                } else {
                    choicesView(segment.choices)
                }
            }
            .padding(.bottom, 40)
        }
        .background(Color(white: 0.98))
    }

    private var endingView: some View {
        VStack(spacing: 16) {
            Text("The End")
                .font(.custom("Georgia", size: 24))
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    private func choicesView(_ choices: [StoryChoice]) -> some View {
        VStack(spacing: 12) {
            ForEach(choices) { choice in
                Button {
                    selectChoice(choice)
                } label: {
                    HStack {
                        Text(choice.text)
                            .font(.system(size: 16, weight: .medium))
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if choice.isAuthenticPath {
                            Image(systemName: "book.fill")
                                .foregroundStyle(Color(red: 0.83, green: 0.66, blue: 0.29))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color(white: 0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(choice.isAuthenticPath ? Color(red: 0.83, green: 0.66, blue: 0.29) : Color.clear, lineWidth: 2)
                    )
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.primary)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Actions

    private func loadStory() async {
        isLoading = true
        errorMessage = nil

        do {
            let loadedStory = try await StoryLoader.shared.loadStory(withId: storyId)
            story = loadedStory

            if let startingSegment = StoryLoader.shared.getStartingSegment(for: loadedStory) {
                currentSegmentId = startingSegment.id
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func selectChoice(_ choice: StoryChoice) {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentSegmentId = choice.nextSegmentId
        }
    }
}

#Preview {
    StoryReadingView(storyId: "little-red-riding-hood")
}
