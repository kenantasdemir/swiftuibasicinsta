import SwiftUI


struct FeedsView: View {
    @StateObject private var postViewModel = PostViewModel()
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    if isLoading {
           
                        VStack(spacing: 20) {
                            ForEach(0..<3, id: \.self) { _ in
                                PostSkeletonView()
                            }
                        }
                        .padding(.top, 20)
                    } else if postViewModel.posts.isEmpty {
              
                        VStack(spacing: 20) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("Henüz gönderi yok")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                            
                            Text("İlk gönderiyi paylaşan sen ol!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                    } else {
              
                        ForEach(postViewModel.posts, id: \.id) { post in
                            PostCardView(post: post, postViewModel: postViewModel)
                                .onTapGesture(count: 2) {
                                    Task {
                                        do {
                                            try await postViewModel.toggleLike(postId: post.postId)
                                        } catch {
                                            print("Like toggle error: \(error.localizedDescription)")
                                        }
                                    }
                                }
                        }
                    }
                }
            }
            .background(Color(.systemBackground))
           
            .refreshable {
                loadPosts()
            }
        }
        .onAppear {
            loadPosts()
        }
    }
    
    private func loadPosts() {
        isLoading = true
        Task {
            await postViewModel.fetchAllPosts()
            isLoading = false
        }
    }
}


#Preview {
    FeedsView()
}


