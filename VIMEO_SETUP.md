# Vimeo API Setup Guide

This guide will help you connect your Apple TV app to your actual Vimeo showcases.

## Your Vimeo Showcases

Based on the URLs you provided, here are your showcase configurations:

- **Main Showcase**: `18401281` - https://vimeo.com/user/210503445/folder/18401281
- **Secondary Showcase**: `18401283` - https://vimeo.com/user/210503445/folder/18401283  
- **Third Showcase**: `18401278` - https://vimeo.com/user/210503445/folder/18401278

## Step 1: Create Vimeo Developer Account

1. Go to [developer.vimeo.com](https://developer.vimeo.com/)
2. Sign in with your Vimeo account (the same one that owns the showcases)
3. Click "Create an App"

## Step 2: Create Your App

Fill out the app creation form:

```
App Name: [Your App Name] Apple TV Streaming App
App Description: Native Apple TV streaming application for showcases
App URL: https://yourwebsite.com (or leave blank)
```

## Step 3: Generate Access Token

1. After creating your app, go to the "Authentication" tab
2. Scroll down to "Generate an Access Token"
3. Select these scopes:
   - ✅ **Public** (to access public videos)
   - ✅ **Private** (to access private videos in your showcases)
   - ✅ **Video Files** (to get direct video URLs)

4. Click "Generate Token"
5. **IMPORTANT**: Copy and save this token immediately - you won't see it again!

## Step 4: Update Your App Code

Open `VimeoService.swift` and replace the placeholder token:

```swift
// Replace this line:
private let accessToken = "YOUR_VIMEO_ACCESS_TOKEN"

// With your actual token:
private let accessToken = "your_actual_token_here"
```

## Step 5: Test API Connection

You can test your API connection using curl:

```bash
# Test Main Showcase
curl -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Accept: application/vnd.vimeo.*+json;version=3.4" \
     "https://api.vimeo.com/albums/18401281/videos"

# Test Secondary Showcase  
curl -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Accept: application/vnd.vimeo.*+json;version=3.4" \
     "https://api.vimeo.com/albums/18401283/videos"

# Test Third Showcase
curl -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Accept: application/vnd.vimeo.*+json;version=3.4" \
     "https://api.vimeo.com/albums/18401278/videos"
```

## Step 6: Verify Showcase Access

Make sure your showcases are properly configured:

1. **Check Privacy Settings**:
   - Go to each showcase on Vimeo
   - Ensure privacy is set to allow API access
   - If private, make sure your token has "Private" scope

2. **Verify Video Access**:
   - Ensure videos in showcases are not password-protected
   - Check that videos allow embedding/API access

## Troubleshooting

### Common Issues

**401 Unauthorized Error**
- Token is invalid or expired
- Token doesn't have required scopes
- Regenerate token with correct scopes

**403 Forbidden Error**  
- Showcase is private and token lacks "Private" scope
- Videos have restricted access
- Check showcase privacy settings

**404 Not Found Error**
- Showcase ID is incorrect
- Showcase doesn't exist or was deleted
- Verify showcase URLs and extract correct IDs

**Empty Response**
- Showcase exists but has no videos
- Videos are private/restricted
- Check video privacy settings

### Debug Mode

The app includes sample data that loads when API calls fail, so you can:
1. Test the UI without API setup
2. Verify the app works before connecting to Vimeo
3. Debug API issues without breaking the user experience

### API Rate Limits

Vimeo API has rate limits:
- **Authenticated requests**: 1000 per hour
- **Unauthenticated requests**: 1000 per day

For production apps, consider:
- Caching API responses
- Implementing request throttling
- Using webhooks for real-time updates

## Security Best Practices

### Token Security
```swift
// DON'T hardcode in production:
private let accessToken = "actual_token_here"

// DO use secure storage:
private let accessToken = KeychainHelper.getVimeoToken()
```

### Environment Configuration
```swift
#if DEBUG
private let accessToken = "development_token"
#else
private let accessToken = "production_token"  
#endif
```

## Production Considerations

### Token Management
- Store tokens securely (Keychain)
- Implement token refresh if needed
- Handle token expiration gracefully

### Error Handling
- Implement retry logic for network failures
- Cache content for offline viewing
- Provide meaningful error messages to users

### Performance
- Cache thumbnail images
- Preload video metadata
- Implement pagination for large showcases

## API Response Examples

### Successful Showcase Response
```json
{
  "total": 5,
  "page": 1,
  "per_page": 25,
  "data": [
    {
      "uri": "/videos/123456789",
      "name": "Your Video Title",
      "description": "Video description here",
      "duration": 300,
      "created_time": "2024-01-01T00:00:00+00:00",
      "pictures": {
        "sizes": [
          {
            "width": 1920,
            "height": 1080,
            "link": "https://i.vimeocdn.com/video/123456789_1920x1080.jpg"
          }
        ]
      },
      "files": [
        {
          "quality": "hd",
          "type": "video/mp4",
          "width": 1920,
          "height": 1080,
          "link": "https://player.vimeo.com/external/123456789.hd.mp4"
        }
      ],
      "player_embed_url": "https://player.vimeo.com/video/123456789"
    }
  ]
}
```

### Error Response
```json
{
  "error": "The requested video could not be found.",
  "link": null,
  "developer_message": "The requested video could not be found.",
  "error_code": 5000
}
```

## Next Steps

Once your API is connected:

1. **Test on Device**: Run the app on Apple TV simulator
2. **Verify Content**: Ensure all showcases load correctly
3. **Test Playback**: Verify videos play properly
4. **Check Performance**: Monitor loading times and responsiveness
5. **Deploy**: Build for App Store submission

## Support Resources

- [Vimeo API Documentation](https://developer.vimeo.com/api)
- [Vimeo API Reference](https://developer.vimeo.com/api/reference)
- [Apple tvOS Development](https://developer.apple.com/tvos/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)

---

**Need Help?** 
Check the app's debug console for detailed error messages when API calls fail.
