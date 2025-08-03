import SwiftUI

struct PostGridView: View {
    var posts: [Post]
    private let items = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible())
    ]
    private let width = (UIScreen.main.bounds.width / 3) - 2

    var body: some View {
        VStack {
            Text("Post count: \(posts.count)")
                .foregroundColor(.red)
                .font(.caption)
            ScrollView {
                LazyVGrid(columns: items, spacing: 2) {
                    ForEach(posts.indices, id: \.self) { index in
                        let post = posts[index]
                        ZStack {
                            if let imageUrl = post.imageUrl, imageUrl.hasPrefix("http") {
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color.gray
                                }
                            } else if let videoUrl = post.videoUrl, !videoUrl.isEmpty {
                                ZStack {
                                    Color.black.opacity(0.7)
                                    Image(systemName: "play.rectangle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .padding(24)
                                }
                            } else {
                                Color.gray
                            }
                        }
                        .frame(width: width, height: 120)
                        .clipped()
                    }
                }
            }
        }
    }
}
