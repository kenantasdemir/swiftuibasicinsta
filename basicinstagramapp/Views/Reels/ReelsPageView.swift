import SwiftUI
import Foundation
import AVKit

struct ReelsPageView: View {
    @StateObject var postViewModel = PostViewModel()
    @State private var scrollPosition: String?
    @State private var player = AVPlayer()
    @State private var isEmptyScreenEnabled: [String: Bool] = [:] // Post ID -> Bool
    
     public var authViewModel:AuthViewModel?
    
  
    
    @State private var isPlaying = true
    @State private var isLoading = false
    @State private var reels: [Post] = []

    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if reels.isEmpty {
                emptyView
            } else {
                reelsListView
            }
        }
        .onAppear {
            loadReels()
        }
        .onDisappear { 
            player.pause() 
        }
        .scrollPosition(id: $scrollPosition)
        .scrollTargetBehavior(.paging)
        .ignoresSafeArea()
        .onChange(of: scrollPosition) { oldValue, newValue in
            if let newValue = newValue {
                handleScrollPositionChange(postId: newValue)
            }
        }
    }

    func handleScrollPositionChange(postId: String) {
        guard let currentPost = reels.first(where: { $0.id == postId }) else { return }
        

        if let videoUrl = currentPost.videoUrl, !videoUrl.isEmpty {
            player.replaceCurrentItem(with: nil)
            let playerItem = AVPlayerItem(url: URL(string: videoUrl)!)
            player.replaceCurrentItem(with: playerItem)
            player.play()
        } else {
 
            player.pause()
        }
        
    
        isEmptyScreenEnabled[postId] = false
    }
    

    
    private var loadingView: some View {
        GeometryReader { geometry in
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                Text("Reeller yükleniyor...")
                    .foregroundColor(.white)
                    .padding(.top)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black)
        }
    }
    
    private var emptyView: some View {
        GeometryReader { geometry in
            VStack {
                Image(systemName: "play.rectangle.on.rectangle")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                Text("Henüz reel yok")
                    .foregroundColor(.gray)
                    .padding(.top)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black)
        }
    }
    
    private var reelsListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(reels) { post in
                  
                    
                    FeedCell(
                        authViewModel: authViewModel!, post: post,
                        player: player,
                        isEmptyScreenEnabled: Binding(
                            get: { isEmptyScreenEnabled[post.id!, default: false] },
                            set: { isEmptyScreenEnabled[post.id!] = $0 }
                        ),
                        postViewModel: postViewModel
                    )
                    .onTapGesture {
                      
                        if let videoUrl = post.videoUrl, !videoUrl.isEmpty {
                            isPlaying.toggle()
                            isPlaying ? player.play() : player.pause()
                        }
                    }
                    .id(post.id)
                }
            }
            .scrollTargetLayout()
        }
    }
    
  
    private func loadReels() {
        isLoading = true
        Task {
            await postViewModel.fetchAllReels()
            await MainActor.run {
           
                self.reels = postViewModel.posts.filter { $0.isReel == true }
                self.isLoading = false
                print("Yüklenen reel sayısı: \(self.reels.count)")
            }
        }
    }
    
   
}
