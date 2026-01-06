//
//  StoryThumbnail.swift
//  StoryPath
//

import SwiftUI

struct StoryThumbnail: View {
    let story: Story
    let progress: UserProgress?
    var onInfoTapped: (() -> Void)?

    private var thumbnailImage: String? {
        // Try cover image first, then fall back to first segment's image
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

    private var isComplete: Bool {
        completedPaths == story.pathCount && story.pathCount > 0
    }

    private var isInProgress: Bool {
        guard let progress = progress else { return false }
        // Has been read but not all paths completed
        return progress.pathHistory.count > 1 && completedPaths < story.pathCount
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Thumbnail image
            ZStack {
                if let imageName = thumbnailImage {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 160)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120, height: 160)
                        .overlay {
                            Image(systemName: "book.closed")
                                .font(.largeTitle)
                                .foregroundStyle(.gray)
                        }
                }

                // Overlay indicators
                VStack {
                    HStack {
                        // Info button
                        if let onInfoTapped {
                            Button {
                                onInfoTapped()
                            } label: {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            }
                            .padding(6)
                        }

                        Spacer()

                        // Progress indicator
                        if isComplete {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                                .background(Circle().fill(Color.green).padding(-2))
                                .padding(6)
                        } else if isInProgress {
                            Image(systemName: "bookmark.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(Color(red: 0.83, green: 0.66, blue: 0.29))
                                .padding(6)
                        }
                    }
                    Spacer()
                }
            }
            .frame(width: 120, height: 160)

            // Title
            Text(story.title)
                .font(.custom("Georgia", size: 14))
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: 120, alignment: .leading)
                .padding(.bottom, 4)
        }
    }

    private func hasValidImage(_ imageName: String) -> Bool {
        #if os(iOS)
        return UIImage(named: imageName) != nil
        #else
        return NSImage(named: imageName) != nil
        #endif
    }
}
