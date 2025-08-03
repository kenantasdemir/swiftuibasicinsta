

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit
import FirebaseAuth

@MainActor
class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var savedPosts: [Post] = []
    @Published var likedPosts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    

    
    @Published  var user: MyUser?
    
 
    private let firebaseAuth = Auth.auth()
    private let firestore = Firestore.firestore()
    private let storage = Storage.storage()
    
   
    

    func createPost(image: UIImage, caption: String, location: String? = nil, isReel: Bool = false) async throws {
        guard let userId = firebaseAuth.currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bulunamadı"])
        }
        

        let imageUrl = try await uploadPostImage(image, userId: userId)
        

        let postId = UUID().uuidString
        let post = Post(dict: [
            "id": postId,
            "userId": userId,
            "imageUrl": imageUrl.absoluteString,
            "caption": caption,
            "likes": [],
            "location": location ?? "",
            "isReel": isReel,
            "createdAt": FirebaseFirestore.Timestamp(date: Date())
        ])
        

        try await firestore.collection("posts").document(postId).setData(post.toDict())
        

        try await addPostToUser(userId: userId, postId: postId)
        
      
        DispatchQueue.main.async {
            self.posts.insert(post, at: 0)
        }
    }
    

    nonisolated func fetchUserPosts(userId: String) async {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
     
            let userDoc = try await firestore.collection("users").document(userId).getDocument()
            guard let userData = userDoc.data(),
                  let postIds = userData["postIds"] as? [String],
                  !postIds.isEmpty else {
                await MainActor.run {
                    self.posts = []
                    self.isLoading = false
                }
                return
            }
            
         
            let snapshot = try await firestore.collection("posts")
                .whereField(FieldPath.documentID(), in: postIds)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let fetchedPosts = snapshot.documents.map { document in
                Post(dict: document.data())
            }
            
            await MainActor.run {
                self.posts = fetchedPosts
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    

    nonisolated func fetchAllPosts() async {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let snapshot = try await firestore.collection("posts")
                .order(by: "createdAt", descending: true)
                .limit(to: 50)
                .getDocuments()
            
            let fetchedPosts = snapshot.documents.map { document in
                Post(dict: document.data())
            }
            
            await MainActor.run {
                self.posts = fetchedPosts
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    

    nonisolated func fetchSavedPosts(userId: String) async {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
     
            let userDoc = try await firestore.collection("users").document(userId).getDocument()
            guard let userData = userDoc.data(),
                  let savedPostIds = userData["savedPostIds"] as? [String],
                  !savedPostIds.isEmpty else {
                await MainActor.run {
                    self.savedPosts = []
                    self.isLoading = false
                }
                return
            }
            
    
            let snapshot = try await firestore.collection("posts")
                .whereField(FieldPath.documentID(), in: savedPostIds)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let fetchedPosts = snapshot.documents.map { document in
                Post(dict: document.data())
            }
            
            await MainActor.run {
                self.savedPosts = fetchedPosts
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    nonisolated func fetchLikedPosts(userId: String) async {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {

            let userDoc = try await firestore.collection("users").document(userId).getDocument()
            guard let userData = userDoc.data(),
                  let likedPostIds = userData["likedPostIds"] as? [String],
                  !likedPostIds.isEmpty else {
                await MainActor.run {
                    self.likedPosts = []
                    self.isLoading = false
                }
                return
            }
            

            let snapshot = try await firestore.collection("posts")
                .whereField(FieldPath.documentID(), in: likedPostIds)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let fetchedPosts = snapshot.documents.map { document in
                Post(dict: document.data())
            }
            
            await MainActor.run {
                self.likedPosts = fetchedPosts
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    

    

    nonisolated func fetchAllReels() async {
        await MainActor.run {
            self.isLoading = true
        }

        do {
            let snapshot = try await firestore.collection("posts")
                .whereField("isReel", isEqualTo: true)
                .order(by: "createdAt", descending: true)
                .limit(to: 50)
                .getDocuments()

            let fetchedPosts = snapshot.documents.map { document in
                Post(dict: document.data())
            }

            await MainActor.run {
                self.posts = fetchedPosts
                self.isLoading = false
                print("PostViewModel: \(fetchedPosts.count) reel yüklendi")
                for post in fetchedPosts {
                    print("Reel ID: \(post.id ?? "nil"), isReel: \(post.isReel ?? false)")
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                print("PostViewModel: Hata - \(error.localizedDescription)")
            }
        }
    }
    

    nonisolated func fetchUserById(_ userId: String) async throws -> [String: Any] {
        let document = try await firestore.collection("users").document(userId).getDocument()
        guard let data = document.data() else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bulunamadı"])
        }
        return data
    }
    

    func toggleLike(postId: String) async throws {
        guard let userId = firebaseAuth.currentUser?.uid else { return }
        let db = Firestore.firestore()
        let postRef = db.collection("posts").document(postId)
        let userRef = db.collection("users").document(userId)

 
        let postSnapshot = try await postRef.getDocument()
        var likes = postSnapshot.data()?["likes"] as? [String] ?? []


        let userSnapshot = try await userRef.getDocument()
        var likedPostIds = userSnapshot.data()?["likedPostIds"] as? [String] ?? []

        if likes.contains(userId) {
          
            likes.removeAll { $0 == userId }
            likedPostIds.removeAll { $0 == postId }
        } else {
         
            likes.append(userId)
            likedPostIds.append(postId)
        }


        try await postRef.updateData(["likes": likes])
        try await userRef.updateData(["likedPostIds": likedPostIds])
    }
    

    func toggleSave(postId: String) async throws {
        guard let userId = firebaseAuth.currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bulunamadı"])
        }
        
        let userRef = firestore.collection("users").document(userId)
        
        try await firestore.runTransaction { transaction, errorPointer in
            let userDocument: DocumentSnapshot
            do {
                userDocument = try transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldData = userDocument.data() else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Kullanıcı bulunamadı"
                ])
                errorPointer?.pointee = error
                return nil
            }
            
            var savedPostIds = oldData["savedPostIds"] as? [String] ?? []
            
            if savedPostIds.contains(postId) {
       
                savedPostIds.removeAll { $0 == postId }
            } else {
          
                savedPostIds.append(postId)
            }
            
            transaction.updateData(["savedPostIds": savedPostIds], forDocument: userRef)
            return nil
        }
    }
    

    private func uploadPostImage(_ image: UIImage, userId: String) async throws -> URL {
        let postId = UUID().uuidString
        let storageRef = storage.reference().child("post_images").child("\(userId)_\(postId).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Resim verisi oluşturulamadı"])
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        return try await storageRef.downloadURL()
    }
    
 
    private func addPostToUser(userId: String, postId: String) async throws {
        let userRef = firestore.collection("users").document(userId)
        
        try await userRef.updateData([
            "postIds": FieldValue.arrayUnion([postId])
        ])
    }
    

    func deletePost(postId: String) async throws {
        guard let userId = firebaseAuth.currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bulunamadı"])
        }
        

        try await firestore.collection("posts").document(postId).delete()
        

        let userRef = firestore.collection("users").document(userId)
        try await userRef.updateData([
            "postIds": FieldValue.arrayRemove([postId])
        ])
        

        DispatchQueue.main.async {
            self.posts.removeAll { $0.id == postId }
        }
    }
    func addComment(to postId: String, text: String) async throws {
        guard let userId = firebaseAuth.currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bulunamadı"])
        }

        let commentId = UUID().uuidString
        let comment = Comment(dict: [
            "id": commentId,
            "userId": userId,
            "text": text,
            "likes": [],
            "createdAt": FirebaseFirestore.Timestamp(date: Date())
        ])

        let postRef = firestore.collection("posts").document(postId)

        try await postRef.updateData([
            "comments": FieldValue.arrayUnion([comment.toDict()])
        ])

        await MainActor.run {
            if let index = posts.firstIndex(where: { $0.id == postId }) {
                if posts[index].comments == nil {
                    posts[index].comments = []
                }
                posts[index].comments?.append(comment)

               
                posts = posts
            }
        }
    }

    func toggleCommentLike(postId: String, commentId: String) async throws {
        guard let userId = firebaseAuth.currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bulunamadı"])
        }
        
        let postRef = firestore.collection("posts").document(postId)
        
        try await firestore.runTransaction { transaction, errorPointer in
            let postDocument: DocumentSnapshot
            do {
                postDocument = try transaction.getDocument(postRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldData = postDocument.data() else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Post bulunamadı"
                ])
                errorPointer?.pointee = error
                return nil
            }
            
            var comments = oldData["comments"] as? [[String: Any]] ?? []
            

            for i in 0..<comments.count {
                if comments[i]["id"] as? String == commentId {
                    var likes = comments[i]["likes"] as? [String] ?? []
                    
                    if likes.contains(userId) {
                 
                        likes.removeAll { $0 == userId }
                    } else {
                
                        likes.append(userId)
                    }
                    
                    comments[i]["likes"] = likes
                    break
                }
            }
            
            transaction.updateData(["comments": comments], forDocument: postRef)
            return nil
        }
        

        if let postIndex = posts.firstIndex(where: { $0.id == postId }),
           let commentIndex = posts[postIndex].comments?.firstIndex(where: { $0.id == commentId }) {
            DispatchQueue.main.async {
                if self.posts[postIndex].comments?[commentIndex].likes?.contains(userId) == true {
                    self.posts[postIndex].comments?[commentIndex].likes?.removeAll { $0 == userId }
                } else {
                    if self.posts[postIndex].comments?[commentIndex].likes == nil {
                        self.posts[postIndex].comments?[commentIndex].likes = []
                    }
                    self.posts[postIndex].comments?[commentIndex].likes?.append(userId)
                }
            }
        }
    }
    
   
    func deleteComment(postId: String, commentId: String) async throws {
        guard (firebaseAuth.currentUser?.uid) != nil else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bulunamadı"])
        }
        
        let postRef = firestore.collection("posts").document(postId)
        
        try await firestore.runTransaction { transaction, errorPointer in
            let postDocument: DocumentSnapshot
            do {
                postDocument = try transaction.getDocument(postRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldData = postDocument.data() else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Post bulunamadı"
                ])
                errorPointer?.pointee = error
                return nil
            }
            
            var comments = oldData["comments"] as? [[String: Any]] ?? []
            
        
            comments.removeAll { $0["id"] as? String == commentId }
            
            transaction.updateData(["comments": comments], forDocument: postRef)
            return nil
        }
        
   
        if let postIndex = posts.firstIndex(where: { $0.id == postId }) {
            DispatchQueue.main.async {
                self.posts[postIndex].comments?.removeAll { $0.id == commentId }
            }
        }
    }
    

    func isReelLiked(_ postId: String) -> Bool {
        guard let userId = firebaseAuth.currentUser?.uid,
              let post = posts.first(where: { $0.id == postId }) else {
            return false
        }
        return post.likes?.contains(userId) ?? false
    }
    

    func isReelSaved(_ postId: String) -> Bool {

        return false
    }
    

    var reelCount: Int {
        return posts.filter { $0.isReel == true }.count
    }
    

    func reel(at index: Int) -> Post? {
        let reels = posts.filter { $0.isReel == true }
        guard index >= 0 && index < reels.count else { return nil }
        return reels[index]
    }
    
    
     

    func loadUser(post:Post) {
        guard let userId = post.userId else { return }
        
      
        firestore.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.user = MyUser(dict: data)
            }
        }
    }
    
    
    
    
    
    

}
