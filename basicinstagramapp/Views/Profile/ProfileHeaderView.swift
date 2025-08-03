

import SwiftUI

struct ProfileHeaderView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var profileViewModel:ProfileViewModel = ProfileViewModel()
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var showShareProfile = false
    @State private var editProfilePage = false
    @State private var isFollowingThisUser: Bool = false

    
    @State private var showBioSheet: Bool = false
    @State private var bioText: String = ""
    
    var user:MyUser?
    
    var isThisMyProfile: Bool {
        guard let user = user else { 
            print("ProfileHeaderView: user is nil")
            return false 
        }
        let result = authViewModel.isThisMyProfile(user: user)
        
        return result
    }
    
    var body: some View {
        VStack(spacing: 12) {
          
        
            HStack(alignment: .center, spacing: 24) {
            
                ZStack(alignment: .bottomTrailing) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 86, height: 86)
                            .clipShape(Circle())
                    } else if let urlString = user?.profilePhotoUrl,
                              let url = URL(string: urlString),
                              !urlString.isEmpty {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 86, height: 86)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 86, height: 86)
                                    .clipShape(Circle())
                            case .failure(_):
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.gray)
                                    .frame(width: 86, height: 86)
                                    .clipShape(Circle())
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                            .frame(width: 86, height: 86)
                            .clipShape(Circle())
                    }
                    if isThisMyProfile {
                        Button(action: {
                            showImagePicker = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 24, height: 24)
                                .background(Circle().fill(Color.blue))
                        }
                        .offset(x: 2, y: 2)
                    }
                }
                
       
                VStack(alignment: .leading, spacing: 12) {
         
                    Text(user?.username ?? "")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
     
                    HStack(spacing: 40) {
                        VStack(spacing: 10) {
                            Text("\(user?.postIds?.count ?? 0)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            Text("Gönderi")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        VStack(spacing:10) {
                            Text("\(user?.followers?.count ?? 0)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            Text("Takipçi")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        VStack(spacing: 10) {
                            Text("\(user?.followings?.count ?? 0)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            Text("Takip")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                Spacer()
            }
 
            VStack(alignment: .leading, spacing: 8) {
                if isThisMyProfile {
             
                    Button(action: {
                        showBioSheet = true
                    }) {
                        HStack {
                            if let bio = user?.bio?.trimmingCharacters(in: .whitespacesAndNewlines), !bio.isEmpty {
                                Text(bio)
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                            } else {
                                Text("Biyografi ekle")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                        }
                    }
                } else {
           
                    if let bio = user?.bio?.trimmingCharacters(in: .whitespacesAndNewlines), !bio.isEmpty {
                        Text(bio)
                            .font(.system(size: 14))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if isThisMyProfile {
                HStack(spacing: 8) {
                    Button(action: {
                        editProfilePage = true
                    }) {
                        Text("Profili düzenle")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .fullScreenCover(isPresented: $editProfilePage) {
                        EditProfileView(authViewModel: authViewModel, profileViewModel: profileViewModel)
                    }
                    Button(action: {
                        showShareProfile = true
                    }) {
                        Text("Profili paylaş")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .fullScreenCover(isPresented: $showShareProfile) {
                        ShareProfileView(authViewModel: authViewModel)
                    }
                    Button(action: {
                 
                    }) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 36)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
            } else {
                HStack(spacing: 8) {
                    Button(action: {
                        
                        Task {
                            if isFollowingThisUser {
                                await authViewModel.unfollow(userId: user?.uid ?? "")
                                isFollowingThisUser = false
                            } else {
                                await authViewModel.follow(userId: user?.uid ?? "")
                                isFollowingThisUser = true
                                
                            }
                        }
                    }) {
                        Text(isFollowingThisUser ? "Takipten çık" : "Takip Et")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    Button(action: {
                     
                    }) {
                        Text("Mesaj")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    Button(action: {
        
                    }) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 36)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .sheet(isPresented: $showBioSheet) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Biyografinizi girin")
                    .font(.headline)
                    .padding(.top)
                TextEditor(text: $bioText)
                    .frame(height: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                    .padding(.horizontal)
                Spacer()
                Button(action: {
                    if let uid = user?.uid {
                        profileViewModel.updateUserBio(currentUserId: uid, bioText: bioText)
                        print("Girilen bio:", bioText)
                        showBioSheet = false
                    }
                }) {
                    Text("Kaydet")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding()
            .onAppear {
                bioText = user?.bio ?? ""
            }
        }
        .sheet(isPresented: $showImagePicker) {
            SimpleImagePicker( selectedImage: $selectedImage)
        }.onAppear {
            Task {
                if let uid = user?.uid {
                    let result = await authViewModel.isFollowing(userId: uid)
                    await MainActor.run {
                        self.isFollowingThisUser = result
                    }
                }
            }
        }
    }

}


