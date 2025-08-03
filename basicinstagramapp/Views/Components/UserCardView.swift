import SwiftUI

struct UserCardView: View {
    var imageName: String = "person.circle.fill"
    var user: MyUser
    @StateObject var postViewModel:PostViewModel
    @StateObject var authViewModel:AuthViewModel
    @State private var isFollowingThisUser: Bool = false

    var body: some View {
        NavigationLink(destination: PreviewProfileView(authViewModel: AuthViewModel(), postViewModel:postViewModel, user: user)) {
            VStack(spacing: 12) {
           
                AsyncImage(url: URL(string: user.profilePhotoUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                

                Text(user.username ?? "Kullanıcı")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
     
                Button(action: {
                    Task {
                        if isFollowingThisUser {
                            await authViewModel.unfollow(userId: user.uid ?? "")
                            isFollowingThisUser = false
                        } else {
                            await authViewModel.follow(userId: user.uid ?? "")
                            isFollowingThisUser = true
                            
                        }
                    }
                }) {
                    Text(isFollowingThisUser ? "Takipten çık" : "Takip Et")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 100)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .onAppear {
                Task {
                    if let uid = user.uid {
                        let result = await authViewModel.isFollowing(userId: uid)
                        await MainActor.run {
                            self.isFollowingThisUser = result
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
