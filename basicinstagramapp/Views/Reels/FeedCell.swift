

import SwiftUI
import AVKit
import FirebaseAuth



struct FeedCell: View {
    //View struct'ları içinde doğrudan var ile tanımlanmış değerleri değiştiremezsin. bu yüzden @State kullan.

    @State private var username: String = "Yükleniyor..."
    @State private var navigate = false
    @State private var showActionSheet = false

    @State var isPlaying:Bool = true
    
    @State var isSaved:Bool = false
    @State var isLiked:Bool = false
    public var authViewModel:AuthViewModel?
    

    
    let post: Post
 
    var player: AVPlayer
    @Binding var isEmptyScreenEnabled: Bool // Dışarıdan gelen bağlama
    @StateObject var postViewModel:PostViewModel
    
    var body: some View {
        ZStack {
           
            if hasMultipleImages {
            
                ReelImageSliderView(images: getAllImageUrls())
                    .containerRelativeFrame([.horizontal, .vertical])
                  
            } else if hasVideo {
              
                CustomVideoPlayer(player: player)
                    .containerRelativeFrame([.horizontal, .vertical])
                    .onTapGesture {
                        isPlaying.toggle()
                        isPlaying ? player.play() : player.pause()
                    }
            } else if hasSingleImage {
         
                AsyncImage(url: URL(string: post.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        )
                }
                .containerRelativeFrame([.horizontal, .vertical])
            }
            
            if !isEmptyScreenEnabled {
                VStack {
                    Spacer()
                    
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 12) {
                     
                            Text(username)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                     
                            if let caption = post.caption, !caption.isEmpty {
                                Text(caption)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .lineLimit(3)
                            }
                            
                  
                            if let location = post.location, !location.isEmpty {
                                Text(location)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                       
                            if let likes = post.likes, !likes.isEmpty {
                                Text("\(likes.count) beğenme")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                   
                        VStack(spacing: 20) {
                       
                            Button(action: {}) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            }
                            
                    
                            Button(action: {
                                handleSave()
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: isLiked ? "heart.fill" : "heart")
                                        .font(.title2)
                                        .foregroundColor(isLiked ? .red : .white)
                                    
                                    if let likes = post.likes {
                                        Text("\(likes.count)")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            
              
                            Button(action: {
                                navigate = true
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "bubble.right")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                    
                                    if let comments = post.comments {
                                        Text("\(comments.count)")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .sheet(isPresented: $navigate) {
                     
                                CommentsView(post: post, postViewModel: postViewModel)
                            }
                   
                            Button(action: {}) {
                                Image(systemName: "paperplane")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
              
                            Button(action: {
                               handleSave()
                            }) {
                                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            
                            RotatingGradientCircleView()
                        }
                        .padding(.trailing, 16)
                    }
                    .padding(.bottom, 100)
                    .padding(.horizontal, 16)
                }
            }
        }
        .onTapGesture(count: 2) { 
            handleSave()
        }
        .onLongPressGesture { 
            showActionSheet = true 
        }
        .confirmationDialog("İşlem Seç", isPresented: $showActionSheet) {
            Button(isEmptyScreenEnabled ? "Temiz ekrandan çık" : "Temiz ekran") {
                isEmptyScreenEnabled.toggle()
            }
            Button("İptal", role: .cancel) { }
        }
        .onAppear {
         setupPostState()
            isPlaying = true
            if hasVideo {
                player.play()
            }
            fetchUsername()
        }
        .onDisappear {
            if hasVideo {
                player.pause()
            }
        }
    }
    
   
    private func fetchUsername() {
        guard let userId = post.userId else { return }
        authViewModel!.getUsername(for: userId) { name in
            DispatchQueue.main.async {
                self.username = name ?? "Bilinmiyor"
            }
        }
    }
    
    private func setupPostState() {
       
        if let currentUserId = Auth.auth().currentUser?.uid {
            isLiked = post.likes?.contains(currentUserId) ?? false
        }
    }
  
    private func handleLike() {
        guard let postId = post.id else { return }
        
        Task {
            do {
                try await postViewModel.toggleLike(postId: postId)
                DispatchQueue.main.async {
                    isLiked.toggle()
                }
            } catch {
                print("Like error: \(error)")
            }
        }
    }
  
    private func handleSave() {
        guard let postId = post.id else { return }
        
        Task {
            do {
                try await postViewModel.toggleSave(postId: postId)
                DispatchQueue.main.async {
                    isSaved.toggle()
                }
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    

    

    private var hasMultipleImages: Bool {
        guard let additionalImages = post.additionalImageUrls, !additionalImages.isEmpty else {
            return false
        }
        return true
    }
    

    private var hasVideo: Bool {
        return post.videoUrl != nil && !post.videoUrl!.isEmpty
    }

    private var hasSingleImage: Bool {
        return post.imageUrl != nil && !post.imageUrl!.isEmpty
    }
    

    private func getAllImageUrls() -> [String] {
        var urls: [String] = []
        

        if let imageUrl = post.imageUrl, !imageUrl.isEmpty {
            urls.append(imageUrl)
        }
        

        if let additionalImages = post.additionalImageUrls {
            urls.append(contentsOf: additionalImages)
        }
        
        return urls
    }
}



