import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            ShowcaseView(showcaseId: "18401281", title: "Main Showcase")
                .tabItem {
                    Image(systemName: "play.rectangle.fill")
                    Text("Main")
                }
                .tag(1)
            
            ShowcaseView(showcaseId: "18401283", title: "Secondary Showcase")
                .tabItem {
                    Image(systemName: "tv.fill")
                    Text("Secondary")
                }
                .tag(2)
            
            ShowcaseView(showcaseId: "18401278", title: "Third Showcase")
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Featured")
                }
                .tag(3)
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(4)
        }
        .background(Color.black)
    }
}

struct SearchView: View {
    @State private var searchText = ""
    @StateObject private var vimeoService = VimeoService()
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding()
                
                if searchText.isEmpty {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Search for videos")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Search results would go here
                    Text("Search results for: \(searchText)")
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .background(Color.black)
            .navigationTitle("Search")
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search videos...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
