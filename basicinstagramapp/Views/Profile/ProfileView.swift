import SwiftUI

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State internal var selectedTab: ProfileTab = .uploads
    @StateObject var postViewModel: PostViewModel
    var imageName: String = "person.circle.fill"
    @State private var selectedUserId: String? = nil
    @State private var isLoggedOut = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ProfileHeaderView(authViewModel: authViewModel, user: authViewModel.myUser)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    suggestionsSection()

                    ProfileSegmentsView(selectedTab: $selectedTab)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)

                    ProfileTabViews(
                        selectedTab: $selectedTab,
                        postViewModel: postViewModel,
                        authViewModel: authViewModel
                    )
                    .frame(minHeight: 400)
                }
            }
            .background(Color(.systemBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                       
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        Button(action: {
                           
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $isLoggedOut) {
                LoginView(authViewModel: authViewModel)
            }
        }
        .onAppear {
            authViewModel.getFirst10Users()
            Task {
                await postViewModel.fetchUserPosts(userId: authViewModel.myUser?.uid ?? "")
            }
        }
    }

    private func suggestionsSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Senin için öneriler")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Button("Tümünü gör") {
                    authViewModel.signOut()
                    isLoggedOut = true 
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(authViewModel.firstTenUsers, id: \.id) { user in
                        Button(action: {
                            selectedUserId = user.uid
                            print(selectedUserId!)
                        }) {
                            UserCardView(user: user, postViewModel: postViewModel, authViewModel: authViewModel)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
    }
}
