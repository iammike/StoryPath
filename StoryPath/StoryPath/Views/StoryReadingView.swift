//
//  StoryReadingView.swift
//  StoryPath
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct StoryReadingView: View {
    let storyId: String

    @State private var viewModel = StoryReadingViewModel()
    #if os(iOS)
    @State private var orientation: UIDeviceOrientation = {
        let current = UIDevice.current.orientation
        if current.isValidInterfaceOrientation {
            return current
        }
        let isLandscapeByBounds = UIScreen.main.bounds.width > UIScreen.main.bounds.height
        return isLandscapeByBounds ? .landscapeLeft : .portrait
    }()
    #endif

    private enum LayoutConstants {
        static let iPadLandscapeTopPadding: CGFloat = 20
        static let iPadPortraitTopPadding: CGFloat = 10
        static let iPhoneLandscapeTopPadding: CGFloat = 11
        static let iPhonePortraitTopPadding: CGFloat = 9
        static let defaultTopPadding: CGFloat = 10
        static let contentTopPadding: CGFloat = 12
        static let contentBottomPadding: CGFloat = 100
    }

    private var topPadding: CGFloat {
        #if os(iOS)
        let isLandscape: Bool
        if orientation.isValidInterfaceOrientation {
            isLandscape = orientation.isLandscape
        } else {
            isLandscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            return isLandscape ? LayoutConstants.iPadLandscapeTopPadding : LayoutConstants.iPadPortraitTopPadding
        } else {
            return isLandscape ? LayoutConstants.iPhoneLandscapeTopPadding : LayoutConstants.iPhonePortraitTopPadding
        }
        #else
        return LayoutConstants.defaultTopPadding
        #endif
    }

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
            // Auto-read first segment after loading
            if viewModel.isAudioEnabled {
                viewModel.speakCurrentSegment()
            }
        }
        #if os(iOS)
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientation = UIDevice.current.orientation
        }
        #endif
    }

    private var audioControlButton: some View {
        Button {
            viewModel.togglePlayPause()
        } label: {
            Image(systemName: viewModel.audioService.isCurrentlyPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color(red: 0.83, green: 0.66, blue: 0.29))
        }
        .accessibilityLabel(viewModel.audioService.isCurrentlyPlaying ? "Pause reading" : "Read aloud")
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

    private var resumeBanner: some View {
        HStack {
            Image(systemName: "bookmark.fill")
                .foregroundStyle(Color(red: 0.83, green: 0.66, blue: 0.29))
            Text("Resuming story")
                .font(.subheadline)
            Spacer()
            Button("Start Over") {
                viewModel.restartStory()
                viewModel.dismissBookmarkNotice()
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(Color(red: 0.83, green: 0.66, blue: 0.29))
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 14)
        .background(Color(red: 0.83, green: 0.66, blue: 0.29).opacity(0.15))
        .onTapGesture {
            viewModel.dismissBookmarkNotice()
        }
    }

    private func segmentContentView(_ segment: StorySegment) -> some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // Resume banner outside scroll view for proper positioning
                if viewModel.didResumeFromBookmark {
                    resumeBanner
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .safeAreaPadding(.top, topPadding)
                        .safeAreaPadding(.horizontal)
                }

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Story text
                            Text(segment.text)
                                .font(.custom("Georgia", size: 18))
                                .lineSpacing(6)
                                .padding(.horizontal, 20)
                                .id("top")

                            // Choices or ending
                            if segment.isEnding {
                                endingView
                            } else {
                                choicesView(segment.choices)
                            }
                        }
                        .padding(.bottom, LayoutConstants.contentBottomPadding)
                        .padding(.top, LayoutConstants.contentTopPadding)
                        .safeAreaPadding(.top, viewModel.didResumeFromBookmark ? 0 : topPadding)
                    }
                    .defaultScrollAnchor(.top)
                    .scrollIndicators(.hidden)
                    .onChange(of: viewModel.currentSegmentId) {
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.didResumeFromBookmark)

            // Audio control button
            audioControlButton
                .padding(.trailing, 20)
                .padding(.bottom, 40)
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
            // Single choice = Continue button, multiple choices = full UI
            if choices.count == 1, let choice = choices.first {
                continueButton(choice)
            } else {
                Button {
                    viewModel.speakChoices()
                } label: {
                    Label("Hear choices", systemImage: "speaker.wave.2.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 0.83, green: 0.66, blue: 0.29))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 4)

                ForEach(choices.indices, id: \.self) { index in
                    let choice = choices[index]
                    Button {
                        viewModel.selectChoice(choice)
                    } label: {
                        HStack {
                            if viewModel.hasUsedAudioForSegment {
                                Text("\(index + 1).")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24, alignment: .leading)
                            }
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
        }
        .padding(.horizontal, 20)
    }

    private func continueButton(_ choice: StoryChoice) -> some View {
        Button {
            viewModel.selectChoice(choice)
        } label: {
            Label("Continue", systemImage: "arrow.right.circle.fill")
                .font(.system(size: 16, weight: .medium))
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
        }
        .buttonStyle(.bordered)
        .tint(Color(red: 0.83, green: 0.66, blue: 0.29))
        .accessibilityLabel("Continue the story")
    }
}

#Preview {
    StoryReadingView(storyId: "little-red-riding-hood")
}
