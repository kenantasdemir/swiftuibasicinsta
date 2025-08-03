import SwiftUI

struct CommentsView: View {
    @State var post: Post
    @ObservedObject var postViewModel: PostViewModel
    @Environment(\.dismiss) var dismiss
    @State private var newComment = ""
    @State private var currentPost: Post

    init(post: Post, postViewModel: PostViewModel) {
        self.post = post
        self.postViewModel = postViewModel
        _currentPost = State(initialValue: post)
    }

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(currentPost.comments ?? [], id: \.id) { comment in
                            CommentRowView(comment: comment)
                        }
                    }
                    .padding()
                }

                HStack {
                    TextField("Yorum ekle...", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Gönder") {
                        addComment()
                    }
                    .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .navigationTitle("Yorumlar")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Kapat") {
                dismiss()
            })
            .onChange(of: postViewModel.posts) { newPosts in
                if let updated = newPosts.first(where: { $0.id == post.id }) {
                    self.currentPost = updated
                }
            }
        }
    }

    private func addComment() {
        guard let postId = post.id,
              !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        Task {
            do {
                try await postViewModel.addComment(to: postId, text: newComment.trimmingCharacters(in: .whitespacesAndNewlines))
                newComment = ""
            } catch {
                print("Comment error: \(error)")
            }
        }
    }
}
