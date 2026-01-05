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
        #if os(iOS)
        .navigationBarHidden(true)
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
        VStack(spacing: 0) {
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
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Collapse button
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showNavBar = false
                }
            } label: {
                Image(systemName: "chevron.compact.up")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(Color(red: 0.83, green: 0.66, blue: 0.29).opacity(0.6))
            }
            .accessibilityLabel("Hide menu")
            .padding(.bottom, 4)
        }
        .background(Color(white: 0.98))
    }

    private var pullHint: some View {
        Image(systemName: "chevron.compact.down")
            .font(.system(size: 28, weight: .medium))
            .foregroundStyle(Color(red: 0.83, green: 0.66, blue: 0.29).opacity(0.6))
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
                                .background(
                                    GeometryReader { innerGeometry in
                                        Color.clear.onChange(of: innerGeometry.frame(in: .global).minY) { _, newValue in
                                            let offset = newValue - outerGeometry.safeAreaInsets.top
                                            // Show pull hint when starting to pull, show nav bar when pulled enough
                                            if offset > 20 && offset <= 50 && !showNavBar {
                                                if !showPullHint {
                                                    withAnimation(.easeInOut(duration: 0.15)) {
                                                        showPullHint = true
                                                    }
                                                }
                                            } else if offset > 50 && !showNavBar {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    showPullHint = false
                                                    showNavBar = true
                                                }
                                            } else if offset < -100 && showNavBar {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    showNavBar = false
                                                }
                                            } else if offset <= 20 && showPullHint {
                                                withAnimation(.easeInOut(duration: 0.15)) {
                                                    showPullHint = false
                                                }
                                            }
                                        }
                                    }
                                )
                        } else {
                            Color.clear.frame(height: topPadding)
                                .id("top")
                                .background(
                                    GeometryReader { innerGeometry in
                                        Color.clear.onChange(of: innerGeometry.frame(in: .global).minY) { _, newValue in
                                            let offset = newValue - outerGeometry.safeAreaInsets.top
                                            // Show pull hint when starting to pull, show nav bar when pulled enough
                                            if offset > 20 && offset <= 50 && !showNavBar {
                                                if !showPullHint {
                                                    withAnimation(.easeInOut(duration: 0.15)) {
                                                        showPullHint = true
                                                    }
                                                }
                                            } else if offset > 50 && !showNavBar {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    showPullHint = false
                                                    showNavBar = true
                                                }
                                            } else if offset < -100 && showNavBar {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    showNavBar = false
                                                }
                                            } else if offset <= 20 && showPullHint {
                                                withAnimation(.easeInOut(duration: 0.15)) {
                                                    showPullHint = false
                                                }
                                            }
                                        }
                                    }
                                )
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
                .ignoresSafeArea(.container, edges: .top)
                .onAppear {
                    proxy.scrollTo("top", anchor: .top)
                    // Show resume indicator if resuming from saved position (only once per session)
                    if viewModel.shouldShowResumeBanner && !hasShownResumeIndicator {
                        hasShownResumeIndicator = true
                        viewModel.dismissBookmarkNotice()
                        withAnimation(.easeIn(duration: 0.3)) {
                            showResumeIndicator = true
                        }
                        // Fade out after 1.5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                showResumeIndicator = false
                            }
                        }
                    }
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
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .overlay {
            if showResumeIndicator {
                resumeIndicator
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
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
