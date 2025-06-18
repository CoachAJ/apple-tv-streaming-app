import Foundation
import Combine

// MARK: - Data Models
struct VimeoVideo: Codable, Identifiable {
    let id = UUID()
    let uri: String
    let name: String
    let description: String?
    let duration: Int
    let created_time: String
    let pictures: VimeoPictures?
    let files: [VimeoFile]?
    let player_embed_url: String?
    
    var videoId: String {
        uri.components(separatedBy: "/").last ?? ""
    }
    
    var thumbnailURL: String? {
        pictures?.sizes?.last?.link
    }
    
    var playbackURL: String? {
        files?.first(where: { $0.quality == "hd" })?.link ??
        files?.first?.link
    }
}

struct VimeoPictures: Codable {
    let sizes: [VimeoImageSize]?
}

struct VimeoImageSize: Codable {
    let width: Int
    let height: Int
    let link: String
}

struct VimeoFile: Codable {
    let quality: String
    let type: String
    let width: Int?
    let height: Int?
    let link: String
}

struct VimeoShowcase: Codable {
    let uri: String
    let name: String
    let description: String?
    let created_time: String
    let videos: VimeoVideoResponse?
}

struct VimeoVideoResponse: Codable {
    let total: Int
    let page: Int
    let per_page: Int
    let data: [VimeoVideo]
}

// MARK: - Vimeo Service
class VimeoService: ObservableObject {
    @Published var videos: [VimeoVideo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "https://api.vimeo.com"
    private let accessToken = "cb7efe6584eb99e7392f99b98b7d5bf7" // Your OAuth 2 access token
    private let clientId = "13e44187f21b4e1efce3ac1b70d70e9332ee65e0" // Your client identifier
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    /// Test API connection and credentials
    func testAPIConnection() {
        print("🧪 Testing Vimeo API connection...")
        
        let url = URL(string: "\(baseURL)/me")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.vimeo.*+json;version=3.4", forHTTPHeaderField: "Accept")
        request.setValue("StreamingApp/1.0", forHTTPHeaderField: "User-Agent")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network Error: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 HTTP Status: \(httpResponse.statusCode)")
                    
                    switch httpResponse.statusCode {
                    case 200:
                        print("✅ API Connection Successful!")
                        if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                            print("👤 User Info: \(jsonString.prefix(200))...")
                        }
                    case 401:
                        print("❌ Unauthorized - Check your access token")
                    case 403:
                        print("❌ Forbidden - Token may lack required permissions")
                    case 429:
                        print("❌ Rate Limited - Too many requests")
                    default:
                        print("❌ HTTP Error: \(httpResponse.statusCode)")
                    }
                }
            }
        }.resume()
    }
    
    func fetchShowcaseVideos(showcaseId: String) {
        isLoading = true
        errorMessage = nil
        
        let url = URL(string: "\(baseURL)/albums/\(showcaseId)/videos?per_page=25")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.vimeo.*+json;version=3.4", forHTTPHeaderField: "Accept")
        request.setValue("StreamingApp/1.0", forHTTPHeaderField: "User-Agent")
        request.httpMethod = "GET"
        
        print("🔗 Fetching showcase \(showcaseId) from: \(url.absoluteString)")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .handleEvents(receiveOutput: { data in
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 API Response: \(jsonString.prefix(500))...")
                }
            })
            .decode(type: VimeoVideoResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("❌ API Error: \(error.localizedDescription)")
                        self?.errorMessage = "Failed to load videos: \(error.localizedDescription)"
                        // Load sample data for demo purposes when API fails
                        self?.loadSampleData()
                    }
                },
                receiveValue: { [weak self] response in
                    print("✅ Successfully loaded \(response.data.count) videos")
                    self?.videos = response.data
                    if response.data.isEmpty {
                        self?.loadSampleData()
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func searchVideos(query: String) {
        isLoading = true
        errorMessage = nil
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "\(baseURL)/videos?query=\(encodedQuery)&per_page=25")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.vimeo.*+json;version=3.4", forHTTPHeaderField: "Accept")
        request.setValue("StreamingApp/1.0", forHTTPHeaderField: "User-Agent")
        request.httpMethod = "GET"
        
        print("🔍 Searching for: \(query)")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .handleEvents(receiveOutput: { data in
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 Search Response: \(jsonString.prefix(300))...")
                }
            })
            .decode(type: VimeoVideoResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("❌ Search Error: \(error.localizedDescription)")
                        self?.errorMessage = "Search failed: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] response in
                    print("✅ Found \(response.data.count) videos for '\(query)'")
                    self?.videos = response.data
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Sample Data for Demo
    private func loadSampleData() {
        // Sample data for demonstration when API is not configured
        videos = [
            VimeoVideo(
                uri: "/videos/123456789",
                name: "Sample Video 1",
                description: "This is a sample video for demonstration purposes.",
                duration: 300,
                created_time: "2024-01-01T00:00:00+00:00",
                pictures: VimeoPictures(sizes: [
                    VimeoImageSize(width: 1920, height: 1080, link: "https://via.placeholder.com/1920x1080/333333/FFFFFF?text=Sample+Video+1")
                ]),
                files: [
                    VimeoFile(quality: "hd", type: "video/mp4", width: 1920, height: 1080, link: "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4")
                ],
                player_embed_url: "https://player.vimeo.com/video/123456789"
            ),
            VimeoVideo(
                uri: "/videos/123456790",
                name: "Sample Video 2",
                description: "Another sample video for demonstration.",
                duration: 450,
                created_time: "2024-01-02T00:00:00+00:00",
                pictures: VimeoPictures(sizes: [
                    VimeoImageSize(width: 1920, height: 1080, link: "https://via.placeholder.com/1920x1080/666666/FFFFFF?text=Sample+Video+2")
                ]),
                files: [
                    VimeoFile(quality: "hd", type: "video/mp4", width: 1920, height: 1080, link: "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4")
                ],
                player_embed_url: "https://player.vimeo.com/video/123456790"
            ),
            VimeoVideo(
                uri: "/videos/123456791",
                name: "Sample Video 3",
                description: "Third sample video for the showcase.",
                duration: 600,
                created_time: "2024-01-03T00:00:00+00:00",
                pictures: VimeoPictures(sizes: [
                    VimeoImageSize(width: 1920, height: 1080, link: "https://via.placeholder.com/1920x1080/999999/FFFFFF?text=Sample+Video+3")
                ]),
                files: [
                    VimeoFile(quality: "hd", type: "video/mp4", width: 1920, height: 1080, link: "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_5mb.mp4")
                ],
                player_embed_url: "https://player.vimeo.com/video/123456791"
            )
        ]
    }
}
