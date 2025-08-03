
import SwiftUI

struct EditProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var username: String = ""
    @State private var bio: String = ""
    
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false       
    
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profil Fotoğrafı")) {
                    HStack {
                        Spacer()
                        Button {
                            showImagePicker = true
                        } label: {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            } else if let imageURL = authViewModel.myUser?.profilePhotoUrl,
                                      let url = URL(string: imageURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Kullanıcı Adı")) {
                    TextField("Kullanıcı adınız", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Biyografi")) {
                    TextEditor(text: $bio)
                        .frame(height: 100)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: {
                        isSaving = true
                        Task {
                            try await profileViewModel.updateProfile(username: username, bio: bio, profileImage: selectedImage)
                            isSaving = false
                            dismiss()
                        }
                    }) {
                        HStack {
                            Spacer()
                            if isSaving {
                                ProgressView()
                            } else {
                                Text("Kaydet")
                                    .bold()
                            }
                            Spacer()
                        }
                    }
                    .disabled(isSaving || username.isEmpty)

                    .disabled(isSaving || username.isEmpty)
                }
            }
            .navigationTitle("Profili Düzenle")
            .navigationBarItems(leading: Button("İptal") {
                dismiss()
            })
            .sheet(isPresented: $showImagePicker) {
                //ImagePicker(selectedImage: $selectedImage)
            }
            .onAppear {
                if let user = authViewModel.myUser {
                    username = user.username ?? ""
                    bio = user.bio ?? ""
                }
            }
        }
    }
}
