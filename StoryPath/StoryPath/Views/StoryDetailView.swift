//
//  StoryDetailView.swift
//  StoryPath
//

import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif

struct StoryDetailView: View {
    let story: Story
    let progress: UserProgress?
    var onStartReading: ((String) -> Void)?
    var showActionButton: Bool = true

    @State private var audioService = AudioService()
    @State private var showStoryMap = false

    // MARK: - Computed Properties

    private var coverImage: String? {
        if hasValidImage(story.coverImageName) {
            return story.coverImageName
        }
        if let firstImage = story.segments.first?.imageFileName, hasValidImage(firstImage) {
            return firstImage
        }
        return nil
    }

    private var completedPaths: Int {
        progress?.completedPaths.count ?? 0
    }

    private var hasStarted: Bool {
        progress != nil && (progress?.pathHistory.count ?? 0) > 1
    }

    private var isComplete: Bool {
        completedPaths == story.pathCount && story.pathCount > 0
    }

    private var buttonText: String {
        if hasStarted {
            return "Continue Reading"
        } else if isComplete {
            return "Read Again"
        } else {
            return "Start Reading"
        }
    }

    private var hasProvenance: Bool {
        story.culturalOrigin != nil || story.originalSource != nil
    }

    private var showProgress: Bool {
        completedPaths > 0 || hasStarted
    }

    private var fullPageText: String {
        var text = "\(story.title), by \(story.author). "
        text += "\(story.estimatedReadingMinutes) minutes to read, \(story.pathCount) paths to discover, for ages \(story.ageRange). "
        if showProgress {
            text += "\(completedPaths) of \(story.pathCount) paths discovered. "
        }
        text += story.synopsis
        if let origin = story.culturalOrigin {
            text += " This is a \(origin)."
        }
        if let source = story.originalSource {
            text += " From \(source)."
        }
        return text
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heroImage
                titleSection
                statsRow
                if showProgress {
                    progressSection
                    storyMapSection
                }
                synopsisSection
                if hasProvenance {
                    provenanceSection
                }
                if showActionButton {
                    actionButton
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color(white: 0.98))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onDisappear {
            audioService.stop()
        }
        .sheet(isPresented: $showStoryMap) {
            NavigationStack {
                StoryMapView(story: story, progress: progress)
                    .navigationTitle("Story Map")
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                showStoryMap = false
                            }
                        }
                    }
            }
        }
    }

    // MARK: - Hero Image

    private var heroImage: some View {
        Group {
            if let imageName = coverImage {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(16)
                    .accessibilityLabel("Cover image for \(story.title)")
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay {
                        Image(systemName: "book.closed")
                            .font(.system(size: 64))
                            .foregroundStyle(.gray)
                    }
                    .accessibilityLabel("No cover image available")
            }
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(story.title)
                    .font(.custom("Georgia", size: 28))
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("by \(story.author)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                if audioService.isSpeaking {
                    audioService.stop()
                } else {
                    audioService.speak(fullPageText)
                }
            } label: {
                Image(systemName: audioService.isSpeaking ? "stop.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color(red: 0.83, green: 0.66, blue: 0.29))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(audioService.isSpeaking ? "Stop reading" : "Hear about this story")
            .accessibilityHint("Reads all story details aloud")
        }
        .accessibilityElement(children: .contain)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 16) {
            Label("\(story.estimatedReadingMinutes) min", systemImage: "clock")
            Label("\(story.pathCount) paths", systemImage: "arrow.triangle.branch")
            Label(story.ageRange, systemImage: "person.2")
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(story.estimatedReadingMinutes) minutes, \(story.pathCount) paths, ages \(story.ageRange)")
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        HStack(spacing: 6) {
            ForEach(0..<story.pathCount, id: \.self) { index in
                Circle()
                    .fill(index < completedPaths
                        ? Color(red: 0.83, green: 0.66, blue: 0.29)
                        : Color.gray.opacity(0.3))
                    .frame(width: 12, height: 12)
            }
            Text("\(completedPaths) of \(story.pathCount) paths discovered")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(completedPaths) of \(story.pathCount) paths discovered")
    }

    // MARK: - Synopsis Section

    private var synopsisSection: some View {
        Text(story.synopsis)
            .font(.body)
            .lineSpacing(6)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Provenance Section

    private var provenanceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Story Origins", systemImage: "book.closed")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            if let origin = story.culturalOrigin {
                Text(origin)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let source = story.originalSource {
                Text("From: \(source)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Story origins: \(story.culturalOrigin ?? "") \(story.originalSource.map { "from \($0)" } ?? "")")
    }

    // MARK: - Story Map Section

    private var storyMapSection: some View {
        Button {
            showStoryMap = true
        } label: {
            HStack {
                Label("View Story Map", systemImage: "map")
                    .font(.subheadline.weight(.medium))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .foregroundStyle(.primary)
            .padding(16)
            .background(Color.gray.opacity(0.08))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("View story map showing all paths")
    }

    // MARK: - Action Button

    @ViewBuilder
    private var actionButton: some View {
        if let onStartReading {
            Button {
                onStartReading(story.id)
            } label: {
                actionButtonLabel
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink(value: story.id) {
                actionButtonLabel
            }
        }
    }

    private var actionButtonLabel: some View {
        Text(buttonText)
            .font(.custom("Georgia", size: 18))
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(red: 0.83, green: 0.66, blue: 0.29))
            .cornerRadius(12)
            .accessibilityLabel(buttonText)
            .accessibilityHint("Opens the story for reading")
    }

    // MARK: - Helpers

    private func hasValidImage(_ imageName: String) -> Bool {
        #if os(iOS)
        return UIImage(named: imageName) != nil
        #else
        return NSImage(named: imageName) != nil
        #endif
    }
}

#Preview {
    NavigationStack {
        StoryDetailView(
            story: Story(
                id: "preview",
                title: "Little Red Riding Hood",
                author: "Brothers Grimm",
                originalSource: "Grimm's Fairy Tales, 1812",
                culturalOrigin: "German fairy tale",
                synopsis: "A young girl ventures through the forest to visit her grandmother, encountering a cunning wolf along the way. This classic tale teaches children about the importance of listening to their parents and being cautious of strangers.",
                coverImageName: "lrrh-mother-basket",
                estimatedReadingMinutes: 8,
                ageRange: "4-8",
                tags: ["classic", "adventure"],
                segments: [],
                isPurchased: true
            ),
            progress: nil
        )
    }
}
