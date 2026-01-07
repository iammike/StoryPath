//
//  StoryMapView.swift
//  StoryPath
//

import SwiftUI

// Node in the story tree
struct MapNode: Identifiable {
    let id: String
    let segment: StorySegment
    let children: [MapEdge]
    let depth: Int
    let position: Int  // Position among siblings
}

struct MapEdge: Identifiable {
    var id: String { childId }
    let childId: String
    let choice: StoryChoice
}

struct StoryMapView: View {
    let story: Story
    let progress: UserProgress?

    private let nodeSize: CGFloat = 40
    private let levelSpacing: CGFloat = 70
    private let nodeSpacing: CGFloat = 50
    private let accentColor = Color(red: 0.83, green: 0.66, blue: 0.29)

    // Build nodes with positions
    private var nodes: [MapNode] {
        buildTree()
    }

    // Set of explored segment IDs
    private var exploredSegments: Set<String> {
        Set(progress?.pathHistory ?? [])
    }

    // Segment lookup
    private var segmentLookup: [String: StorySegment] {
        Dictionary(uniqueKeysWithValues: story.segments.map { ($0.id, $0) })
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    // Draw edges first (behind nodes)
                    ForEach(nodes) { node in
                        ForEach(Array(node.children.enumerated()), id: \.element.id) { index, edge in
                            if let childNode = nodes.first(where: { $0.id == edge.childId }) {
                                edgeLine(from: node, to: childNode, edge: edge, siblingIndex: index, siblingCount: node.children.count)
                            }
                        }
                    }

                    // Draw nodes
                    ForEach(nodes) { node in
                        nodeView(for: node)
                            .position(nodePosition(for: node))
                    }
                }
                .frame(width: calculateWidth(), height: calculateHeight())
                .padding(40)
            }
        }
        .background(Color(white: 0.98))
    }

    private func buildTree() -> [MapNode] {
        var result: [MapNode] = []
        var visited: Set<String> = []
        var nodeWidths: [String: Int] = [:]  // Width of subtree rooted at each node

        // First pass: calculate subtree widths
        func calculateWidth(segmentId: String) -> Int {
            if visited.contains(segmentId) { return 1 }
            visited.insert(segmentId)

            guard let segment = segmentLookup[segmentId] else { return 1 }

            if segment.choices.isEmpty {
                nodeWidths[segmentId] = 1
                return 1
            }

            let width = segment.choices.reduce(0) { sum, choice in
                sum + calculateWidth(segmentId: choice.nextSegmentId)
            }
            nodeWidths[segmentId] = width
            return width
        }

        if let first = story.segments.first {
            _ = calculateWidth(segmentId: first.id)
        }

        visited.removeAll()

        // Second pass: build nodes with positions
        func buildNode(segmentId: String, depth: Int, leftOffset: Int) {
            if visited.contains(segmentId) { return }
            visited.insert(segmentId)

            guard let segment = segmentLookup[segmentId] else { return }

            let width = nodeWidths[segmentId] ?? 1
            let position = leftOffset + width / 2

            let children = segment.choices.map { choice in
                MapEdge(childId: choice.nextSegmentId, choice: choice)
            }

            result.append(MapNode(
                id: segmentId,
                segment: segment,
                children: children,
                depth: depth,
                position: position
            ))

            var childOffset = leftOffset
            for choice in segment.choices {
                let childWidth = nodeWidths[choice.nextSegmentId] ?? 1
                buildNode(segmentId: choice.nextSegmentId, depth: depth + 1, leftOffset: childOffset)
                childOffset += childWidth
            }
        }

        if let first = story.segments.first {
            buildNode(segmentId: first.id, depth: 0, leftOffset: 0)
        }

        return result
    }

    private func nodePosition(for node: MapNode) -> CGPoint {
        CGPoint(
            x: CGFloat(node.position) * nodeSpacing + nodeSize,
            y: CGFloat(node.depth) * levelSpacing + nodeSize
        )
    }

    private func calculateWidth() -> CGFloat {
        let maxPosition = nodes.map { $0.position }.max() ?? 0
        return CGFloat(maxPosition + 1) * nodeSpacing + nodeSize * 2
    }

    private func calculateHeight() -> CGFloat {
        let maxDepth = nodes.map { $0.depth }.max() ?? 0
        return CGFloat(maxDepth + 1) * levelSpacing + nodeSize * 2
    }

    private func nodeView(for node: MapNode) -> some View {
        let isExplored = exploredSegments.contains(node.id)
        let isEnding = node.segment.isEnding
        let isStart = node.id == story.segments.first?.id

        return ZStack {
            Circle()
                .fill(nodeColor(isEnding: isEnding, isExplored: isExplored))
                .frame(width: nodeSize, height: nodeSize)

            Circle()
                .stroke(nodeBorderColor(isEnding: isEnding, isExplored: isExplored), lineWidth: 2)
                .frame(width: nodeSize, height: nodeSize)

            Image(systemName: nodeIcon(isStart: isStart, isEnding: isEnding))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isExplored ? .white : .gray)
        }
    }

    private func edgeLine(from parent: MapNode, to child: MapNode, edge: MapEdge, siblingIndex: Int, siblingCount: Int) -> some View {
        let isExplored = exploredSegments.contains(child.id)
        let startPos = nodePosition(for: parent)
        let endPos = nodePosition(for: child)

        return Path { path in
            path.move(to: CGPoint(x: startPos.x, y: startPos.y + nodeSize / 2))
            path.addLine(to: CGPoint(x: endPos.x, y: endPos.y - nodeSize / 2))
        }
        .stroke(
            isExplored ? accentColor : Color.gray.opacity(0.3),
            style: StrokeStyle(lineWidth: edge.choice.isAuthenticPath ? 3 : 2)
        )
    }

    private func nodeColor(isEnding: Bool, isExplored: Bool) -> Color {
        if isEnding {
            return isExplored ? Color.green : Color.gray.opacity(0.2)
        }
        return isExplored ? accentColor : Color.gray.opacity(0.2)
    }

    private func nodeBorderColor(isEnding: Bool, isExplored: Bool) -> Color {
        if isEnding {
            return isExplored ? Color.green : Color.gray.opacity(0.4)
        }
        return isExplored ? accentColor : Color.gray.opacity(0.4)
    }

    private func nodeIcon(isStart: Bool, isEnding: Bool) -> String {
        if isEnding {
            return "flag.fill"
        } else if isStart {
            return "play.fill"
        } else {
            return "circle.fill"
        }
    }
}

#Preview {
    StoryMapView(
        story: Story(
            id: "preview",
            title: "Test Story",
            author: "Test",
            originalSource: nil,
            culturalOrigin: nil,
            synopsis: "Test",
            coverImageName: "test",
            estimatedReadingMinutes: 5,
            ageRange: "4-8",
            tags: [],
            segments: [
                StorySegment(id: "start", text: "Start", audioFileName: nil, imageFileName: nil, isAuthenticPath: true, choices: [
                    StoryChoice(id: "c1", text: "Go left", nextSegmentId: "left", isAuthenticPath: true),
                    StoryChoice(id: "c2", text: "Go right", nextSegmentId: "right", isAuthenticPath: false)
                ]),
                StorySegment(id: "left", text: "Left path", audioFileName: nil, imageFileName: nil, isAuthenticPath: true, choices: [
                    StoryChoice(id: "c3", text: "Continue", nextSegmentId: "end1", isAuthenticPath: true)
                ]),
                StorySegment(id: "right", text: "Right path", audioFileName: nil, imageFileName: nil, isAuthenticPath: false, choices: [
                    StoryChoice(id: "c4", text: "Continue", nextSegmentId: "end2", isAuthenticPath: false)
                ]),
                StorySegment(id: "end1", text: "End 1", audioFileName: nil, imageFileName: nil, isAuthenticPath: true, choices: []),
                StorySegment(id: "end2", text: "End 2", audioFileName: nil, imageFileName: nil, isAuthenticPath: false, choices: [])
            ],
            isPurchased: true
        ),
        progress: UserProgress(
            storyId: "preview",
            currentSegmentId: "left",
            pathHistory: ["start", "left"],
            completedPaths: [],
            lastReadDate: Date(),
            completionPercentage: 0
        )
    )
}
