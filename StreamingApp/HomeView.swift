import SwiftUI

struct HomeView: View {
    @StateObject private var vimeoService = VimeoService()
    @State private var featuredVideos: [VimeoVideo] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    // Hero Section
                    HeroSection()
                    
                    // Featured Content
                    FeaturedSection(videos: featuredVideos)
                    
                    // Continue Watching
                    ContinueWatchingSection()
                    
                    // Recently Added
                    RecentlyAddedSection(videos: Array(featuredVideos.prefix(6)))
                }
                .padding(.horizontal, 50)
            }
            .background(Color.black)
            .navigationTitle("Home")
            .onAppear {
                loadFeaturedContent()
                // Test API connection
                vimeoService.testAPIConnection()
            }
        }
    }
    
    private func loadFeaturedContent() {
        // Load sample featured content
        vimeoService.fetchShowcaseVideos(showcaseId: "18401281")
        featuredVideos = vimeoService.videos
    }
}

struct HeroSection: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 400)
            .cornerRadius(20)
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Welcome to Your Streaming Experience")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Discover amazing content from our curated showcases")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                
                HStack {
                    Button(action: {
                        // Play featured content
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Watch Now")
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(25)
                        .font(.headline)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        // More info
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("More Info")
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .font(.headline)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct FeaturedSection: View {
    let videos: [VimeoVideo]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Featured Content")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(videos.prefix(8)) { video in
                        VideoCard(video: video, size: .large)
                    }
                }
                .padding(.horizontal, 50)
            }
        }
    }
}

struct ContinueWatchingSection: View {
    @State private var continueWatchingVideos: [VimeoVideo] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Continue Watching")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if continueWatchingVideos.isEmpty {
                Text("No videos in progress")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 50)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(continueWatchingVideos) { video in
                            VideoCard(video: video, size: .medium, showProgress: true)
                        }
                    }
                    .padding(.horizontal, 50)
                }
            }
        }
    }
}

struct RecentlyAddedSection: View {
    let videos: [VimeoVideo]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Recently Added")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(videos) { video in
                        VideoCard(video: video, size: .medium)
                    }
                }
                .padding(.horizontal, 50)
            }
        }
    }
}

enum VideoCardSize {
    case small, medium, large
    
    var dimensions: (width: CGFloat, height: CGFloat) {
        switch self {
        case .small:
            return (200, 112)
        case .medium:
            return (300, 169)
        case .large:
            return (400, 225)
        }
    }
}

struct VideoCard: View {
    let video: VimeoVideo
    let size: VideoCardSize
    let showProgress: Bool
    
    init(video: VimeoVideo, size: VideoCardSize, showProgress: Bool = false) {
        self.video = video
        self.size = size
        self.showProgress = showProgress
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                // Thumbnail
                AsyncImage(url: URL(string: video.thumbnailURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "play.rectangle")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.7))
                        )
                }
                .frame(width: size.dimensions.width, height: size.dimensions.height)
                .cornerRadius(12)
                .clipped()
                
                // Play button overlay
                Circle()
                    .fill(Color.black.opacity(0.7))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "play.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                    )
                
                // Progress bar if needed
                if showProgress {
                    VStack {
                        Spacer()
                        ProgressView(value: 0.3) // Sample progress
                            .progressViewStyle(LinearProgressViewStyle(tint: .red))
                            .frame(height: 4)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 8)
                    }
                }
            }
            
            // Video info
            VStack(alignment: .leading, spacing: 4) {
                Text(video.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(formatDuration(video.duration))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(width: size.dimensions.width, alignment: .leading)
        }
        .onTapGesture {
            // Navigate to video player
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    HomeView()
}
