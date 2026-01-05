//
//  StoryLibraryView.swift
//  StoryPath
//

import SwiftUI

struct StoryLibraryView: View {
    @State private var viewModel = StoryLibraryViewModel()
    @State private var selectedStoryId: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Custom header
                Text("Stories")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if viewModel.isLoading {
                    loadingView
                } else if viewModel.stories.isEmpty {
                    emptyView
                } else {
                    contentView
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .background(Color(white: 0.98))
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
        .navigationDestination(for: String.self) { storyId in
            StoryReadingView(storyId: storyId)
        }
        .task {
            await viewModel.loadStories()
        }
    }

    private var loadingView: some View {
        VStack {
            Spacer(minLength: 100)
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading stories...")
                .font(.custom("Georgia", size: 16))
                .foregroundStyle(.secondary)
                .padding(.top, 16)
            Spacer(minLength: 100)
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 100)
            Image(systemName: "books.vertical")
                .font(.system(size: 48))
                .foregroundStyle(.gray)
            Text("No stories available")
                .font(.custom("Georgia", size: 18))
                .foregroundStyle(.secondary)
            Spacer(minLength: 100)
        }
        .frame(maxWidth: .infinity)
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Featured story
            if let featured = viewModel.featuredStory {
                NavigationLink(value: featured.id) {
                    FeaturedStoryCard(
                        story: featured,
                        progress: viewModel.progress(for: featured.id)
                    )
                }
                .buttonStyle(.plain)
            }

            // More stories carousel (only if there are other stories)
            if !viewModel.carouselStories.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("More Stories")
                        .font(.title2)
                        .fontWeight(.bold)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.carouselStories) { story in
                                NavigationLink(value: story.id) {
                                    StoryThumbnail(
                                        story: story,
                                        progress: viewModel.progress(for: story.id)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        StoryLibraryView()
    }
}
