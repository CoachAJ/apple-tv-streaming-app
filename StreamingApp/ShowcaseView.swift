import SwiftUI

struct ShowcaseView: View {
    let showcaseId: String
    let title: String
    
    @StateObject private var vimeoService = VimeoService()
    @State private var selectedVideo: VimeoVideo?
    @State private var showingPlayer = false
    
    var body: some View {
        NavigationView {
            VStack {
                if vimeoService.isLoading {
                    LoadingView()
                } else if let errorMessage = vimeoService.errorMessage {
                    ErrorView(message: errorMessage) {
                        vimeoService.fetchShowcaseVideos(showcaseId: showcaseId)
                    }
                } else {
                    ShowcaseContentView(
                        videos: vimeoService.videos,
                        title: title,
                        onVideoSelected: { video in
                            selectedVideo = video
                            showingPlayer = true
                        }
                    )
                }
            }
            .background(Color.black)
            .navigationTitle(title)
            .onAppear {
                vimeoService.fetchShowcaseVideos(showcaseId: showcaseId)
            }
            .fullScreenCover(isPresented: $showingPlayer) {
                if let video = selectedVideo {
                    VideoPlayerView(video: video) {
                        showingPlayer = false
                        selectedVideo = nil
                    }
                }
            }
        }
    }
}

struct ShowcaseContentView: View {
    let videos: [VimeoVideo]
    let title: String
    let onVideoSelected: (VimeoVideo) -> Void
    
    @State private var selectedCategory = "All"
    private let categories = ["All", "Recent", "Popular", "Duration"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // Showcase Header
                ShowcaseHeader(title: title, videoCount: videos.count)
                
                // Category Filter
                CategoryFilter(
                    categories: categories,
                    selectedCategory: $selectedCategory
                )
                
                // Video Grid
                VideoGrid(
                    videos: filteredVideos,
                    onVideoSelected: onVideoSelected
                )
            }
            .padding(.horizontal, 50)
        }
    }
    
    private var filteredVideos: [VimeoVideo] {
        switch selectedCategory {
        case "Recent":
            return videos.sorted { $0.created_time > $1.created_time }
        case "Popular":
            return videos.shuffled() // Placeholder for popularity sorting
        case "Duration":
            return videos.sorted { $0.duration < $1.duration }
        default:
            return videos
        }
    }
}

struct ShowcaseHeader: View {
    let title: String
    let videoCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("\(videoCount) videos")
                .font(.title2)
                .foregroundColor(.gray)
        }
    }
}

struct CategoryFilter: View {
    let categories: [String]
    @Binding var selectedCategory: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                selectedCategory == category ? Color.white : Color.clear
                            )
                            .foregroundColor(
                                selectedCategory == category ? .black : .white
                            )
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 50)
        }
    }
}

struct VideoGrid: View {
    let videos: [VimeoVideo]
    let onVideoSelected: (VimeoVideo) -> Void
    
    private let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 30) {
            ForEach(videos) { video in
                VideoGridCard(video: video) {
                    onVideoSelected(video)
                }
            }
        }
    }
}

struct VideoGridCard: View {
    let video: VimeoVideo
    let onTap: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                // Thumbnail
                AsyncImage(url: URL(string: video.thumbnailURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(16/9, contentMode: .fit)
                        .overlay(
                            Image(systemName: "play.rectangle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.7))
                        )
                }
                .cornerRadius(12)
                .clipped()
                
                // Hover overlay
                if isHovered {
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                        .cornerRadius(12)
                    
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "play.fill")
                                .foregroundColor(.black)
                                .font(.title)
                        )
                }
                
                // Duration badge
                VStack {
                    HStack {
                        Spacer()
                        Text(formatDuration(video.duration))
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                            .padding(.trailing, 8)
                            .padding(.top, 8)
                    }
                    Spacer()
                }
            }
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            
            // Video info
            VStack(alignment: .leading, spacing: 8) {
                Text(video.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if let description = video.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                Text(formatDate(video.created_time))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onTap()
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(2)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            
            Text("Loading videos...")
                .font(.title2)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Error Loading Content")
                .font(.title)
                .foregroundColor(.white)
            
            Text(message)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: onRetry) {
                Text("Try Again")
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ShowcaseView(showcaseId: "18401281", title: "Main Showcase")
}
