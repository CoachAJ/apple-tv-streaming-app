# Apple TV Streaming App

A native tvOS streaming application built with SwiftUI that integrates with Vimeo Showcases to provide a premium video streaming experience.

## Features

### 🎯 Core Functionality
- **Multi-Showcase Support**: Integrates with three Vimeo showcases
- **Native tvOS Experience**: Built specifically for Apple TV with focus-based navigation
- **Advanced Video Player**: Custom AVPlayer implementation with full controls
- **Dynamic Content Loading**: Real-time sync with Vimeo API
- **Search & Discovery**: Powerful search functionality across all showcases

### 📱 User Interface
- **Focus-Based Navigation**: Optimized for Apple TV remote
- **Responsive Design**: Adapts to different Apple TV screen sizes
- **Dark Theme**: Premium dark interface optimized for TV viewing
- **Smooth Animations**: Fluid transitions and hover effects
- **Grid & Carousel Layouts**: Multiple content presentation formats

### 🎬 Video Features
- **Adaptive Streaming**: Automatic quality adjustment based on connection
- **Custom Controls**: Play/pause, seek, skip forward/backward
- **Progress Tracking**: Resume playback from where you left off
- **Full-Screen Playback**: Immersive viewing experience
- **Duration Display**: Clear time indicators and progress bars

### 🔧 Technical Features
- **Vimeo API Integration**: Secure connection to Vimeo showcases
- **Error Handling**: Graceful error states with retry functionality
- **Loading States**: Smooth loading indicators
- **Memory Management**: Optimized for tvOS performance
- **Offline Fallback**: Sample content when API is unavailable

## Project Structure

```
StreamingApp/
├── StreamingAppApp.swift          # App entry point
├── ContentView.swift              # Main tab navigation
├── HomeView.swift                 # Home screen with featured content
├── ShowcaseView.swift             # Individual showcase display
├── VideoPlayerView.swift          # Custom video player
├── VimeoService.swift             # Vimeo API integration
├── Assets.xcassets/               # App icons and assets
├── Info.plist                     # App configuration
└── Preview Content/               # Development assets
```

## Setup Instructions

### Prerequisites
- Xcode 15.0 or later
- Apple TV Simulator or physical Apple TV (4th generation or later)
- Vimeo API access token (for production use)

### Installation

1. **Clone/Download the Project**
   ```bash
   # The project files are already created in your TV APP directory
   cd "c:\Users\atifj\Documents\TV APP"
   ```

2. **Open in Xcode**
   - Double-click `StreamingApp.xcodeproj` to open in Xcode
   - Select your development team in the project settings

3. **Configure Vimeo API** (Optional for demo)
   - Open `VimeoService.swift`
   - Replace `YOUR_VIMEO_ACCESS_TOKEN` with your actual Vimeo API token
   - For demo purposes, the app includes sample data

4. **Build and Run**
   - Select Apple TV simulator or connected Apple TV device
   - Press Cmd+R to build and run

### Vimeo API Setup

To connect to your actual Vimeo showcases:

1. **Get Vimeo API Access**
   - Go to [Vimeo Developer](https://developer.vimeo.com/)
   - Create a new app
   - Generate an access token with "Public" and "Private" scopes

2. **Update Configuration**
   ```swift
   // In VimeoService.swift
   private let accessToken = "your_actual_token_here"
   ```

3. **Showcase IDs**
   - Your showcases are already configured:
     - Main: `18401281`
     - Secondary: `18401283`
     - Third: `18401278`

## Architecture

### SwiftUI + MVVM Pattern
- **Views**: SwiftUI views for UI components
- **ViewModels**: ObservableObject classes for business logic
- **Services**: API integration and data management
- **Models**: Data structures for Vimeo content

### Key Components

#### VimeoService
```swift
@StateObject private var vimeoService = VimeoService()
```
- Handles all Vimeo API communication
- Manages video data and loading states
- Provides sample data for development

#### VideoPlayerView
```swift
VideoPlayerView(video: selectedVideo) {
    // Dismiss callback
}
```
- Custom AVPlayer implementation
- Full-screen playback experience
- Advanced playback controls

#### ShowcaseView
```swift
ShowcaseView(showcaseId: "18401281", title: "Main Showcase")
```
- Displays videos from specific showcase
- Grid layout with filtering options
- Handles video selection and playback

## Customization

### Branding
- Update app icons in `Assets.xcassets`
- Modify colors and fonts in view files
- Customize app name in `Info.plist`

### Content Organization
- Add more showcases by updating `ContentView.swift`
- Modify category filters in `ShowcaseView.swift`
- Customize home screen layout in `HomeView.swift`

### Video Player
- Adjust control timeout in `VideoPlayerView.swift`
- Add custom playback features
- Implement analytics tracking

## Deployment

### App Store Submission
1. **Prepare Assets**
   - Add app icons (1280x768 for large, 400x240 for small)
   - Create top shelf images (1920x720 and 2320x720)
   - Add screenshots for App Store listing

2. **Configure Project**
   - Set deployment target to tvOS 17.0+
   - Configure signing certificates
   - Update bundle identifier

3. **Submit to App Store**
   - Archive the project
   - Upload via Xcode or Application Loader
   - Complete App Store Connect metadata

### Testing
- Test on multiple Apple TV generations
- Verify remote control navigation
- Test with different network conditions
- Validate accessibility features

## API Integration Details

### Vimeo Showcase API
```
GET https://api.vimeo.com/albums/{showcase_id}/videos
Authorization: Bearer {access_token}
Accept: application/vnd.vimeo.*+json;version=3.4
```

### Response Format
```json
{
  "total": 10,
  "page": 1,
  "per_page": 25,
  "data": [
    {
      "uri": "/videos/123456789",
      "name": "Video Title",
      "description": "Video description",
      "duration": 300,
      "created_time": "2024-01-01T00:00:00+00:00",
      "pictures": {
        "sizes": [
          {
            "width": 1920,
            "height": 1080,
            "link": "https://thumbnail-url.jpg"
          }
        ]
      },
      "files": [
        {
          "quality": "hd",
          "type": "video/mp4",
          "link": "https://video-url.mp4"
        }
      ]
    }
  ]
}
```

## Performance Optimization

### Memory Management
- Proper cleanup of AVPlayer instances
- Lazy loading of video thumbnails
- Efficient image caching

### Network Optimization
- Adaptive streaming quality
- Thumbnail preloading
- Background content updates

### UI Performance
- Smooth scrolling with LazyVGrid
- Optimized animations
- Focus management

## Troubleshooting

### Common Issues

1. **Videos Not Loading**
   - Check Vimeo API token
   - Verify showcase IDs
   - Check network connectivity

2. **Build Errors**
   - Update Xcode to latest version
   - Clean build folder (Cmd+Shift+K)
   - Reset simulator if needed

3. **Focus Navigation Issues**
   - Test with actual Apple TV remote
   - Verify focusable elements
   - Check tab navigation order

### Debug Mode
The app includes sample data that loads automatically when the Vimeo API is not configured, making it easy to test the interface without API setup.

## Next Steps

### Planned Features
- [ ] Watchlist functionality
- [ ] Continue watching persistence
- [ ] User profiles and preferences
- [ ] Advanced search filters
- [ ] Offline video caching
- [ ] Analytics integration
- [ ] Push notifications
- [ ] Parental controls

### Platform Expansion
- Fire TV version (Kotlin)
- Roku version (BrightScript)
- Web version (React)
- Mobile companion app

## Support

For technical support or questions about the implementation:
- Review the code comments for detailed explanations
- Check Apple's tvOS development documentation
- Refer to Vimeo's API documentation
- Test thoroughly on actual Apple TV hardware

---

**Built with ❤️ for Apple TV**

This app demonstrates modern tvOS development practices with SwiftUI, providing a foundation for premium streaming experiences.
