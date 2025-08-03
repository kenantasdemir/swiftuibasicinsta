

import SwiftUI
import FirebaseAuth
import FirebaseFirestore


struct PostCardView: View {
    @State var post: Post
    @ObservedObject var postViewModel: PostViewModel = PostViewModel()
    
    @State var isSaved:Bool = false
    @State var isLiked:Bool = false
    
    @State  var user: MyUser?


    @State private var showComments = false
    
    var body: some View {
        VStack(spacing: 0) {
       
            postHeader
            
         
            postContent
            
  
            postActions
            
      
            postCaptionAndStats
        }
        .background(Color(.systemBackground))
        .onAppear {
           loadUser()
          setupPostState()
        }
        .sheet(isPresented: $showComments) {
            CommentsView(post: post, postViewModel: postViewModel)
        }
    }
    

    private var postHeader: some View {
        HStack(spacing: 12) {
        
            AsyncImage(url: URL(string: postViewModel.user?.profilePhotoUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())
            
  
            VStack(alignment: .leading, spacing: 1) {
                Text(user?.username ?? "Loading...")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                if let location = post.location, !location.isEmpty {
                    Text(location)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            

            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.primary)
                    .rotationEffect(.degrees(90))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    

    private var postContent: some View {
        VStack(spacing: 0) {
            if post.isReel == true && post.additionalImageUrls?.isEmpty == false {
               
                let allImages = [post.imageUrl ?? ""] + (post.additionalImageUrls ?? [])
                ImageSliderView(images: allImages)
                    .frame(height: 400)
                    .clipped()
            } else {
      
                AsyncImage(url: URL(string: post.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 400)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        )
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
 
    private var postActions: some View {
        HStack(spacing: 16) {
  
            Button(action: {
                handleLike()
            }) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.title2)
                    .foregroundColor(isLiked ? .red : .primary)
            }
            

            Button(action: { showComments = true }) {
                Image(systemName: "message")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            

            Button(action: {}) {
                Image(systemName: "paperplane")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            

            Button(action: {
               handleSave()
            }) {
                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                    .font(.title2)
                    .foregroundColor(isSaved ? .primary : .primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    

    private var postCaptionAndStats: some View {
        VStack(alignment: .leading, spacing: 8) {

            if let likes = post.likes, !likes.isEmpty {
                Text("\(likes.count) beğenme")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
  
            if let caption = post.caption, !caption.isEmpty {
                HStack(alignment: .top, spacing: 4) {
                    Text(user?.username ?? "Loading...")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(caption)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
           
            
     
            if let comments = post.comments, !comments.isEmpty {
                Button(action: { showComments = true }) {
                    Text("\(comments.count) yorumun tümünü gör")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
  
            if let createdAt = post.createdAt {
                Text(timeAgoString(from: createdAt))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    
   
    private func loadUser() {
        guard let userId = post.userId else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                user = MyUser(dict: data)
            }
        }
    }
    


    private func setupPostState() {
        if let currentUserId = Auth.auth().currentUser?.uid {
            isLiked = post.likes?.contains(currentUserId) ?? false

   
            let db = Firestore.firestore()
            db.collection("users").document(currentUserId).getDocument { snapshot, error in
                if let data = snapshot?.data(),
                   let savedPostIds = data["savedPostIds"] as? [String] {
                    DispatchQueue.main.async {
                        isSaved = savedPostIds.contains(post.id ?? "")
                    }
                }
            }
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
    
    
   
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}




