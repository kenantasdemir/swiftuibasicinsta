

import SwiftUI

struct ProfileTabViews: View {
    @Binding var selectedTab: ProfileTab
    @ObservedObject var postViewModel: PostViewModel
    @ObservedObject var authViewModel: AuthViewModel
    
    var user:MyUser?
    
   

    
    var body: some View {
        TabView(selection: $selectedTab) {
            PostGridView(posts: postViewModel.posts)
                .tag(ProfileTab.uploads)
       
                PostGridView(posts: postViewModel.savedPosts)
                    .tag(ProfileTab.saved)
                PostGridView(posts: postViewModel.likedPosts)
                    .tag(ProfileTab.liked)
            
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onAppear {
            Task {
                print("USER ID : \(user?.uid)")
                if user?.uid != nil && user?.uid != authViewModel.myUser?.uid {
                    await postViewModel.fetchUserPosts(userId: user!.uid!)
                    
                        await postViewModel.fetchSavedPosts(userId: user!.uid!)
                        await postViewModel.fetchLikedPosts(userId: user!.uid!)
                }else{
                    await postViewModel.fetchUserPosts(userId: authViewModel.myUser!.uid!)
                    
                        await postViewModel.fetchSavedPosts(userId: authViewModel.myUser!.uid!)
                        await postViewModel.fetchLikedPosts(userId: authViewModel.myUser!.uid!)
                }
           
            }
        }
    }
}
