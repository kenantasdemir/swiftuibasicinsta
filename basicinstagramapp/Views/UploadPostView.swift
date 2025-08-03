

import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

struct UploadPostView: View {
    @StateObject private var postViewModel = PostViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedImage: UIImage?
    @State private var selectedImages: [UIImage] = []
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var caption: String = ""
    @State private var location: String = ""
    @State private var isReel: Bool = false
    @State private var isUploading = false
    @State private var showImagePicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
 
                uploadHeader
                
     
                ScrollView {
                    VStack(spacing: 20) {
              
                        imageSelectionSection
                        
              
                        postDetailsSection
                        
                      
                        postTypeSection
                        
             
                        uploadButton
                    }
                    .padding()
                }
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
            .sheet(isPresented: $showImagePicker) {
                SimpleImagePicker(selectedImage: $selectedImage)
            }
            .alert("Bilgi", isPresented: $showAlert) {
                Button("Tamam") { }
            } message: {
                Text(alertMessage)
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                    }
                }
            }
            .onChange(of: selectedItems) { newItems in
                Task {
                    selectedImages.removeAll()
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            selectedImages.append(image)
                        }
                    }
                }
            }
        }
    }
    
   
    private var uploadHeader: some View {
        HStack {
            Button("İptal") {
                dismiss()
            }
            .foregroundColor(.primary)
            
            Spacer()
            
            Text("Yeni Gönderi")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button("Paylaş") {
                uploadPost()
            }
            .fontWeight(.semibold)
            .foregroundColor((isReel ? !selectedImages.isEmpty : selectedImage != nil) ? .blue : .gray)
            .disabled((isReel ? selectedImages.isEmpty : selectedImage == nil) || isUploading)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .bottom
        )
    }
    

    private var imageSelectionSection: some View {
        VStack(spacing: 16) {
            if isReel {
          
                if !selectedImages.isEmpty {
                
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                        ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 120)
                                .clipped()
                                .cornerRadius(8)
                                .overlay(
                                    Button(action: {
                                        selectedImages.remove(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                    .padding(4),
                                    alignment: .topTrailing
                                )
                        }
                    }
                    .padding(.horizontal)
                    
          
                    PhotosPicker(selection: $selectedItems, matching: .images, photoLibrary: .shared()) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Daha Fazla Fotoğraf Ekle")
                                .font(.subheadline)
                        }
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                } else {
             
                    PhotosPicker(selection: $selectedItems, matching: .images, photoLibrary: .shared()) {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.stack")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            
                            Text("Reel Fotoğrafları Seç")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Birden fazla fotoğraf seçebilirsiniz")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
            } else {
    
                if let selectedImage = selectedImage {
               
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 400)
                        .cornerRadius(12)
                        .overlay(
                            Button(action: {
                                self.selectedImage = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                            .padding(8),
                            alignment: .topTrailing
                        )
                } else {
            
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            
                            Text("Fotoğraf veya Video Seç")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Galeriden bir medya seçin")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
   
    private var postDetailsSection: some View {
        VStack(spacing: 16) {
    
            VStack(alignment: .leading, spacing: 8) {
                Text("Açıklama")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("Ne düşünüyorsun?", text: $caption, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Konum")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("Konum ekle (isteğe bağlı)", text: $location)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
 
    private var postTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gönderi Türü")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
               
                Button(action: {
                    isReel = false
               
                    selectedImages.removeAll()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundColor(isReel ? .gray : .blue)
                        
                        Text("Post")
                            .font(.subheadline)
                            .foregroundColor(isReel ? .gray : .primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isReel ? Color.gray.opacity(0.3) : Color.blue, lineWidth: 2)
                    )
                }
                
  
                Button(action: {
                    isReel = true
          
                    selectedImage = nil
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "play.rectangle")
                            .font(.title2)
                            .foregroundColor(isReel ? .blue : .gray)
                        
                        Text("Reel")
                            .font(.subheadline)
                            .foregroundColor(isReel ? .primary : .gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isReel ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                    )
                }
            }
        }
    }

    private var uploadButton: some View {
        Button(action: uploadPost) {
            HStack {
                if isUploading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "paperplane")
                }
                
                Text(isUploading ? "Yükleniyor..." : "Paylaş")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill((isReel ? !selectedImages.isEmpty : selectedImage != nil) && !isUploading ? Color.blue : Color.gray)
            )
        }
        .disabled((isReel ? selectedImages.isEmpty : selectedImage == nil) || isUploading)
        .padding(.top, 20)
    }
    

    private func uploadPost() {
        if isReel {
            guard !selectedImages.isEmpty else {
                showAlert(message: "Lütfen en az bir fotoğraf seçin")
                return
            }
        } else {
            guard selectedImage != nil else {
                showAlert(message: "Lütfen bir fotoğraf seçin")
                return
            }
        }
        
        guard !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(message: "Lütfen bir açıklama yazın")
            return
        }
        
        isUploading = true
        
        Task {
            do {
                if isReel {

                    try await uploadReelWithMultipleImages()
                } else {
        
                    try await postViewModel.createPost(
                        image: selectedImage!,
                        caption: caption.trimmingCharacters(in: .whitespacesAndNewlines),
                        location: location.trimmingCharacters(in: .whitespacesAndNewlines),
                        isReel: isReel
                    )
                }
                
                DispatchQueue.main.async {
                    isUploading = false
                    showAlert(message: "\(isReel ? "Reel" : "Post") başarıyla paylaşıldı!")
                    
            
                    self.selectedImage = nil
                    self.selectedImages.removeAll()
                    self.caption = ""
                    self.location = ""
                    self.isReel = false
                    
            
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isUploading = false
                    showAlert(message: "Hata: \(error.localizedDescription)")
                }
            }
        }
    }
    
  
    private func uploadReelWithMultipleImages() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bulunamadı"])
        }
        

        var imageUrls: [String] = []
        
        for (index, image) in selectedImages.enumerated() {
            let imageUrl = try await uploadReelImage(image, userId: userId, index: index)
            imageUrls.append(imageUrl.absoluteString)
        }
        

        let postId = UUID().uuidString
        let mainImageUrl = imageUrls.first ?? ""
        
        let post = Post(dict: [
            "id": postId,
            "userId": userId,
            "imageUrl": mainImageUrl,
            "additionalImageUrls": imageUrls.dropFirst().map { $0 }, // Additional images
            "caption": caption.trimmingCharacters(in: .whitespacesAndNewlines),
            "likes": [],
            "location": location.trimmingCharacters(in: .whitespacesAndNewlines),
            "isReel": true,
            "createdAt": FirebaseFirestore.Timestamp(date: Date())
        ])
        

        try await Firestore.firestore().collection("posts").document(postId).setData(post.toDict())
      
        try await addPostToUser(userId: userId, postId: postId)
    }
    

    private func uploadReelImage(_ image: UIImage, userId: String, index: Int) async throws -> URL {
        let postId = UUID().uuidString
        let storageRef = Storage.storage().reference().child("reel_images").child("\(userId)_\(postId)_\(index).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Resim verisi oluşturulamadı"])
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        return try await storageRef.downloadURL()
    }
    

    private func addPostToUser(userId: String, postId: String) async throws {
        let userRef = Firestore.firestore().collection("users").document(userId)
        
        try await userRef.updateData([
            "postIds": FieldValue.arrayUnion([postId])
        ])
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}


#Preview {
    UploadPostView()
}
