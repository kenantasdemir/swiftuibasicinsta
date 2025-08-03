
import SwiftUI

struct PreviewProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State internal var selectedTab: ProfileTab = .uploads
    
    @StateObject var postViewModel:PostViewModel
    
    var user: MyUser

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                  
                    ProfileHeaderView(authViewModel: authViewModel, user: user)
                        .padding(.init(top: 25, leading: 10, bottom: 20, trailing: 10))
                    
                    ProfileSegmentsView(selectedTab: $selectedTab)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                  
                    ProfileTabViews(selectedTab: $selectedTab,postViewModel: postViewModel, authViewModel: authViewModel,user:user)
                        .frame(minHeight: 400)
                     
                }
            }
            .background(Color(.systemBackground))
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                           
                        }) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
    }
}


