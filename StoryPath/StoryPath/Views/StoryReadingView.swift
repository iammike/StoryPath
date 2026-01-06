//
//  StoryReadingView.swift
//  StoryPath
//

import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif

struct StoryReadingView: View {
    let storyId: String

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = StoryReadingViewModel()
    @State private var fullscreenImage: String?
    @State private var showNavBar = false
    @State private var showPullHint = false
    @State private var showResumeIndicator = false
    @State private var hasShownResumeIndicator = false
    @State private var resumeIndicatorTask: Task<Void, Never>?
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
        // Safe area top padding by device/orientation
        static let iPadLandscapeTopPadding: CGFloat = 20
        static let iPadPortraitTopPadding: CGFloat = 10
        static let iPhoneLandscapeTopPadding: CGFloat = 11
        static let iPhonePortraitTopPadding: CGFloat = 9
        static let defaultTopPadding: CGFloat = 10

        // Content padding
        static let contentHorizontalPadding: CGFloat = 16
        static let contentTopPadding: CGFloat = 12
        static let contentBottomPadding: CGFloat = 60

        // Pull-to-reveal thresholds
        static let pullHintThreshold: CGFloat = 20
        static let navBarRevealThreshold: CGFloat = 50
        static let navBarHideThreshold: CGFloat = -100
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
        ZStack {
            Color(white: 0.98)
                .ignoresSafeArea()

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
        }
        #if os(iOS)
        .navigationBarHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        #endif
        .overlay {
            if fullscreenImage != nil {
                fullscreenImageOverlay
                    .transition(.opacity)
            }
        }
        .task {
            await viewModel.loadStory(withId: storyId)
            // Auto-read first segment after loading
            if viewModel.isAudioEnabled {
                viewModel.speakCurrentSegment()
            }
        }
        #if os(iOS)
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            let newOrientation = UIDevice.current.orientation
            if newOrientation.isValidInterfaceOrientation {
                orientation = newOrientation
            }
        }
        #endif
    }

    private var audioControlButton: some View {
        Button {
            viewModel.togglePlayPause()
        } label: {
            Image(systemName: viewModel.audioService.isCurrentlyPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(Color(red: 0.83, green: 0.66, blue: 0.29))
        }
        .accessibilityLabel(viewModel.audioService.isCurrentlyPlaying ? "Pause reading" : "Read aloud")
    }

    private var storyNavigationBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "house.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color(red: 0.83, green: 0.66, blue: 0.29))
            }
            .accessibilityLabel("Return to library")

            if !viewModel.isAtStart {
                Button {
                    viewModel.restartStory()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showNavBar = false
                    }
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 20))
                        .foregroundStyle(Color(red: 0.83, green: 0.66, blue: 0.29))
                }
                .accessibilityLabel("Start over")
                .padding(.leading, 16)
            }

            Spacer()

            audioControlButton

            // Hide menu button
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showNavBar = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(red: 0.83, green: 0.66, blue: 0.29))
            }
            .accessibilityLabel("Hide menu")
            .padding(.leading, 16)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(Color(white: 0.98))
    }

    private var pullHint: some View {
        Image(systemName: "chevron.compact.down")
            .font(.system(size: 28, weight: .medium))
            .foregroundStyle(Color(red: 0.83, green: 0.66, blue: 0.29).opacity(0.6))
    }

    // MARK: - Pull-to-reveal conditions

    private func shouldShowPullHint(at offset: CGFloat) -> Bool {
        offset > LayoutConstants.pullHintThreshold &&
        offset <= LayoutConstants.navBarRevealThreshold &&
        !showNavBar &&
        !showPullHint
    }

    private func shouldRevealNavBar(at offset: CGFloat) -> Bool {
        offset > LayoutConstants.navBarRevealThreshold && !showNavBar
    }

    private func shouldHideNavBar(at offset: CGFloat) -> Bool {
        offset < LayoutConstants.navBarHideThreshold && showNavBar
    }

    private func shouldHidePullHint(at offset: CGFloat) -> Bool {
        offset <= LayoutConstants.pullHintThreshold && showPullHint
    }

    private func handleScrollOffset(_ offset: CGFloat) {
        if shouldShowPullHint(at: offset) {
            withAnimation(.easeInOut(duration: 0.15)) {
                showPullHint = true
            }
        } else if shouldRevealNavBar(at: offset) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showPullHint = false
                showNavBar = true
            }
        } else if shouldHideNavBar(at: offset) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showNavBar = false
            }
        } else if shouldHidePullHint(at: offset) {
            withAnimation(.easeInOut(duration: 0.15)) {
                showPullHint = false
            }
        }
    }

    private func scrollTracker(safeAreaTop: CGFloat) -> some View {
        GeometryReader { geometry in
            Color.clear.onChange(of: geometry.frame(in: .global).minY) { _, newValue in
                handleScrollOffset(newValue - safeAreaTop)
            }
        }
    }

    private var resumeIndicator: some View {
        Image(systemName: "bookmark.fill")
            .font(.system(size: 32))
            .foregroundStyle(Color(red: 0.83, green: 0.66, blue: 0.29))
            .padding(16)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
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

    private func hasValidImage(for segment: StorySegment) -> Bool {
        guard let imageName = segment.imageFileName else { return false }
        #if os(iOS)
        return UIImage(named: imageName) != nil
        #else
        return NSImage(named: imageName) != nil
        #endif
    }

    @ViewBuilder
    private func illustrationView(for segment: StorySegment) -> some View {
        if hasValidImage(for: segment), let imageName = segment.imageFileName {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding(.top, -1) // Extend into safe area to cover gap
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        fullscreenImage = imageName
                    }
                }
                .accessibilityHint("Tap to view full screen")
        }
    }

    private var fullscreenImageOverlay: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        fullscreenImage = nil
                    }
                }

            if let imageName = fullscreenImage {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(20)
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            fullscreenImage = nil
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(Color(red: 0.83, green: 0.66, blue: 0.29))
                    }
                    .padding(20)
                    .accessibilityLabel("Close full screen image")
                }
                Spacer()
            }
        }
    }

    private func segmentContentView(_ segment: StorySegment) -> some View {
        GeometryReader { outerGeometry in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Illustration (or spacer for safe area on pages without images)
                        if hasValidImage(for: segment) {
                            illustrationView(for: segment)
                                .id("top")
                                .background(scrollTracker(safeAreaTop: outerGeometry.safeAreaInsets.top))
                        } else {
                            Color.clear.frame(height: topPadding)
                                .id("top")
                                .background(scrollTracker(safeAreaTop: outerGeometry.safeAreaInsets.top))
                        }

                        // Story text (trailing newline prevents descender clipping with lineSpacing)
                        Text(segment.text + "\n")
                            .font(.custom("Georgia", size: 18))
                            .lineSpacing(6)
                            .padding(.horizontal, LayoutConstants.contentHorizontalPadding)
                            .padding(.top, 16)

                        // Choices or ending
                        if segment.isEnding {
                            endingView
                                .padding(.top, 24)
                        } else {
                            choicesView(segment.choices)
                                .padding(.top, 24)
                        }
                    }
                    .padding(.bottom, LayoutConstants.contentBottomPadding)
                }
                .defaultScrollAnchor(.top)
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .onAppear {
                    proxy.scrollTo("top", anchor: .top)
                    // Show resume indicator if resuming from saved position (only once per session)
                    if viewModel.isResumingFromSavedPosition && !hasShownResumeIndicator {
                        hasShownResumeIndicator = true
                        viewModel.dismissBookmarkNotice()
                        withAnimation(.easeIn(duration: 0.3)) {
                            showResumeIndicator = true
                        }
                        // Fade out after 1.5 seconds (cancellable task)
                        resumeIndicatorTask = Task {
                            try? await Task.sleep(for: .seconds(1.5))
                            guard !Task.isCancelled else { return }
                            withAnimation(.easeOut(duration: 0.5)) {
                                showResumeIndicator = false
                            }
                        }
                    }
                }
                .onDisappear {
                    resumeIndicatorTask?.cancel()
                }
                .onChange(of: viewModel.currentSegmentId) {
                    proxy.scrollTo("top", anchor: .top)
                }
            }
        }
        .overlay(alignment: .top) {
            if showPullHint && !showNavBar {
                pullHint
                    .padding(.top, 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .overlay(alignment: .top) {
            if showNavBar {
                storyNavigationBar
                    .transition(.opacity)
            }
        }
        .overlay {
            if showResumeIndicator {
                resumeIndicator
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
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
                        withAnimation(nil) {
                            viewModel.selectChoice(choice)
                        }
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
        .padding(.horizontal, LayoutConstants.contentHorizontalPadding)
    }

    private func continueButton(_ choice: StoryChoice) -> some View {
        Button {
            withAnimation(nil) {
                viewModel.selectChoice(choice)
            }
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
