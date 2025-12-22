//
//  StoryReadingView.swift
//  StoryPath
//

import SwiftUI

struct StoryReadingView: View {
    let storyId: String

    @State private var viewModel = StoryReadingViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(error)
            } else if let segment = viewModel.currentSegment {
                segmentContentView(segment)
            } else {
                Text("No content available")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.98))
        .ignoresSafeArea()
        .task {
            await viewModel.loadStory(withId: storyId)
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
                    await viewModel.loadStory(withId: storyId)
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private func segmentContentView(_ segment: StorySegment) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Story text
                    Text(segment.text)
                        .font(.custom("Georgia", size: 18))
                        .lineSpacing(6)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .id("top")

                    // Choices or ending
                    if segment.isEnding {
                        endingView
                    } else {
                        choicesView(segment.choices)
                    }
                }
                .padding(.bottom, 40)
            }
            .defaultScrollAnchor(.top)
            .scrollIndicators(.hidden)
            .onChange(of: viewModel.currentSegmentId) {
                proxy.scrollTo("top", anchor: .top)
            }
        }
        .background(Color(white: 0.98))
    }

    private var endingView: some View {
        VStack(spacing: 24) {
            Text("The End")
                .font(.custom("Georgia", size: 24))
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            if viewModel.totalPaths > 0 {
                VStack(spacing: 8) {
                    Text("\(viewModel.completedPathsCount) of \(viewModel.totalPaths) endings discovered")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ProgressView(value: viewModel.completionPercentage)
                        .tint(Color(red: 0.83, green: 0.66, blue: 0.29))
                        .frame(width: 200)
                }
            }

            Button {
                viewModel.restartStory()
            } label: {
                Label("Read Again", systemImage: "arrow.counterclockwise")
                    .font(.system(size: 16, weight: .medium))
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Read the story again from the beginning")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    private func choicesView(_ choices: [StoryChoice]) -> some View {
        VStack(spacing: 12) {
            ForEach(choices) { choice in
                Button {
                    viewModel.selectChoice(choice)
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
                .accessibilityLabel(choice.isAuthenticPath ? "\(choice.text). This follows the original story." : choice.text)
                .accessibilityHint("Tap to continue the story")
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    StoryReadingView(storyId: "little-red-riding-hood")
}
