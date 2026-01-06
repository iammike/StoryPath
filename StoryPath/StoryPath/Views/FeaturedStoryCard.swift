//
//  FeaturedStoryCard.swift
//  StoryPath
//

import SwiftUI

struct FeaturedStoryCard: View {
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

    private var hasStarted: Bool {
        progress != nil && (progress?.pathHistory.count ?? 0) > 1
    }

    private var buttonText: String {
        if hasStarted {
            return "Continue"
        } else if completedPaths == story.pathCount {
            return "Read Again"
        } else {
            return "Start Reading"
        }
    }

    private var isComplete: Bool {
        completedPaths == story.pathCount && story.pathCount > 0
    }

    var body: some View {
        VStack(spacing: 0) {
            // Featured image
            ZStack {
                GeometryReader { geometry in
                    if let imageName = thumbnailImage {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay {
                                Image(systemName: "book.closed")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.gray)
                            }
                    }
                }
                .aspectRatio(16/9, contentMode: .fit)

                // Overlay indicators
                VStack {
                    HStack {
                        // Info button
                        if let onInfoTapped {
                            Button {
                                onInfoTapped()
                            } label: {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 26))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            }
                            .padding(12)
                        }

                        Spacer()

                        // Completion checkmark
                        if isComplete {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white)
                                .background(Circle().fill(Color.green).padding(-2))
                                .padding(12)
                        }
                    }
                    Spacer()
                }
            }

            // Info section
            VStack(alignment: .leading, spacing: 12) {
                Text(story.title)
                    .font(.custom("Georgia", size: 24))
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                // Progress dots
                HStack(spacing: 6) {
                    ForEach(0..<story.pathCount, id: \.self) { index in
                        Circle()
                            .fill(index < completedPaths
                                ? Color(red: 0.83, green: 0.66, blue: 0.29)
                                : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                    Text("\(completedPaths) of \(story.pathCount) paths")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                }

                // Action button
                Text(buttonText)
                    .font(.custom("Georgia", size: 16))
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.83, green: 0.66, blue: 0.29))
                    .cornerRadius(12)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private func hasValidImage(_ imageName: String) -> Bool {
        #if os(iOS)
        return UIImage(named: imageName) != nil
        #else
        return NSImage(named: imageName) != nil
        #endif
    }
}
