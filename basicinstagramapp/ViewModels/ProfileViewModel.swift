

import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class ProfileViewModel:ObservableObject{
    
    var firestoredb = Firestore.firestore()
    
    func updateUserBio(currentUserId: String, bioText: String) {
        firestoredb.collection("users").document(currentUserId).updateData([
            "bio": bioText
        ]) { error in
            if let error = error {
                print("Biyografi güncellenirken hata oluştu: \(error.localizedDescription)")
            } else {
                print("Biyografi başarıyla güncellendi.")
            }
        }
    }
    
    func updateProfile(username: String, bio: String, profileImage: UIImage?) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bulunamadı"])
        }
        var dataToUpdate: [String: Any] = ["username": username, "bio": bio]
        
        if let image = profileImage {
            let url = try await uploadProfileImage(image, userId: userId)
            dataToUpdate["profilePhotoUrl"] = url.absoluteString
        }
        
        try await Firestore.firestore().collection("users").document(userId).updateData(dataToUpdate)
    }

    func uploadProfileImage(_ image: UIImage, userId: String) async throws -> URL {
        let storageRef = Storage.storage().reference().child("profile_images").child("\(userId).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Resim verisi oluşturulamadı"])
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        return try await storageRef.downloadURL()
    }



    
}
