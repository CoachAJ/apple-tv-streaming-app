import SwiftUI
import AVKit
import AVFoundation

struct VideoPlayerView: View {
    let video: VimeoVideo
    let onDismiss: () -> Void
    
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var showControls = true
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var isLoading = true
    @State private var controlsTimer: Timer?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .onTapGesture {
                        toggleControls()
                    }
            } else {
                LoadingPlayerView()
            }
            
            // Custom Controls Overlay
            if showControls {
                VStack {
                    // Top bar
                    TopControlsBar(
                        videoTitle: video.name,
                        onDismiss: onDismiss
                    )
                    
                    Spacer()
                    
                    // Bottom controls
                    BottomControlsBar(
                        isPlaying: isPlaying,
                        currentTime: currentTime,
                        duration: duration,
                        onPlayPause: togglePlayPause,
                        onSeek: seekTo
                    )
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.black.opacity(0.7), location: 0),
                            .init(color: Color.clear, location: 0.3),
                            .init(color: Color.clear, location: 0.7),
                            .init(color: Color.black.opacity(0.7), location: 1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .onAppear {
            setupPlayer()
            startControlsTimer()
        }
        .onDisappear {
            cleanupPlayer()
        }
    }
    
    private func setupPlayer() {
        guard let urlString = video.playbackURL ?? video.player_embed_url,
              let url = URL(string: urlString) else {
            // Use sample video URL for demo
            let sampleURL = URL(string: "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4")!
            player = AVPlayer(url: sampleURL)
            setupPlayerObservers()
            return
        }
        
        player = AVPlayer(url: url)
        setupPlayerObservers()
    }
    
    private func setupPlayerObservers() {
        guard let player = player else { return }
        
        // Time observer
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            currentTime = time.seconds
        }
        
        // Duration observer
        player.currentItem?.publisher(for: \.duration)
            .sink { duration in
                if duration.isNumeric {
                    self.duration = duration.seconds
                    self.isLoading = false
                }
            }
            .store(in: &cancellables)
        
        // Status observer
        player.currentItem?.publisher(for: \.status)
            .sink { status in
                if status == .readyToPlay {
                    self.isLoading = false
                }
            }
            .store(in: &cancellables)
        
        // Auto-play
        player.play()
        isPlaying = true
    }
    
    @State private var cancellables = Set<AnyCancellable>()
    
    private func togglePlayPause() {
        guard let player = player else { return }
        
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
        startControlsTimer()
    }
    
    private func seekTo(_ time: Double) {
        guard let player = player else { return }
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: cmTime)
        startControlsTimer()
    }
    
    private func toggleControls() {
        showControls.toggle()
        if showControls {
            startControlsTimer()
        }
    }
    
    private func startControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            withAnimation(.easeOut(duration: 0.3)) {
                showControls = false
            }
        }
    }
    
    private func cleanupPlayer() {
        controlsTimer?.invalidate()
        player?.pause()
        player = nil
    }
}

struct TopControlsBar: View {
    let videoTitle: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .font(.title)
                    .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(videoTitle)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Spacer()
            
            // Additional controls can go here
            Button(action: {
                // More options
            }) {
                Image(systemName: "ellipsis")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 50)
        .padding(.top, 20)
    }
}

struct BottomControlsBar: View {
    let isPlaying: Bool
    let currentTime: Double
    let duration: Double
    let onPlayPause: () -> Void
    let onSeek: (Double) -> Void
    
    @State private var isDragging = false
    @State private var dragValue: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text(formatTime(isDragging ? dragValue : currentTime))
                        .font(.caption)
                        .foregroundColor(.white)
                        .monospacedDigit()
                    
                    Spacer()
                    
                    Text(formatTime(duration))
                        .font(.caption)
                        .foregroundColor(.white)
                        .monospacedDigit()
                }
                
                Slider(
                    value: isDragging ? $dragValue : .constant(currentTime),
                    in: 0...max(duration, 1),
                    onEditingChanged: { editing in
                        isDragging = editing
                        if !editing {
                            onSeek(dragValue)
                        }
                    }
                )
                .accentColor(.white)
                .onAppear {
                    dragValue = currentTime
                }
                .onChange(of: currentTime) { newValue in
                    if !isDragging {
                        dragValue = newValue
                    }
                }
            }
            
            // Control buttons
            HStack(spacing: 40) {
                Button(action: {
                    onSeek(max(0, currentTime - 10))
                }) {
                    Image(systemName: "gobackward.10")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onPlayPause) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    onSeek(min(duration, currentTime + 10))
                }) {
                    Image(systemName: "goforward.10")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 50)
        .padding(.bottom, 50)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN && !seconds.isInfinite else { return "0:00" }
        
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return String(format: "%d:%02d:%02d", hours, remainingMinutes, remainingSeconds)
        } else {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        }
    }
}

struct LoadingPlayerView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(2)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            
            Text("Loading video...")
                .font(.title2)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Combine Import
import Combine

#Preview {
    VideoPlayerView(
        video: VimeoVideo(
            uri: "/videos/123456789",
            name: "Sample Video",
            description: "A sample video for preview",
            duration: 300,
            created_time: "2024-01-01T00:00:00+00:00",
            pictures: nil,
            files: nil,
            player_embed_url: nil
        )
    ) {
        // Dismiss action
    }
}
