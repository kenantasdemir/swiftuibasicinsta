

import SwiftUI

struct MainTabView: View {
    
    @ObservedObject public var authViewModel:AuthViewModel
    @StateObject public var postViewModel = PostViewModel()

  
    
    var body: some View {
        TabView{
            Tab("Anasayfa",systemImage: "house"){
                FeedsView()
            }
            Tab("Ara",systemImage: "magnifyingglass"){
                SearchPageView(postViewModel: postViewModel,authViewModel: authViewModel)
            }
            Tab("Gönderi",systemImage: "plus.app"){
                UploadPostView()
            }
            Tab("Reels",systemImage: "play.rectangle"){
                ReelsPageView(authViewModel: authViewModel)
                
            }
            Tab("Profil",systemImage: "person"){
                ProfileView(authViewModel: authViewModel,postViewModel: postViewModel)
            }
            
        }
        
    }
}


#Preview {
    MainTabView(authViewModel: AuthViewModel())
}
