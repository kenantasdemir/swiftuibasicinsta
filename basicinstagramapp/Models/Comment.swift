


import Foundation
import FirebaseFirestore


class Comment: Identifiable {
    var id: String?
    var userId: String?
    var text: String?
    var likes: [String]?
    var createdAt: Date?
    
    var commentId: String { id ?? UUID().uuidString }
    
    init(dict: [String: Any]) {
        self.id = dict["id"] as? String
        self.userId = dict["userId"] as? String
        self.text = dict["text"] as? String
        self.likes = dict["likes"] as? [String]
        
        if let timestamp = dict["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        }
    }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id ?? "",
            "userId": userId ?? "",
            "text": text ?? "",
            "likes": likes ?? []
        ]
        
        if let createdAt = createdAt {
            dict["createdAt"] = Timestamp(date: createdAt)
        }
        
        return dict
    }
    
    
    

    var likeCount: Int {
        return likes?.count ?? 0
    }
    
 
    func like(userId: String) {
        if likes == nil {
            likes = []
        }
        if !(likes?.contains(userId) ?? false) {
            likes?.append(userId)
        }
    }
    
   
    func unlike(userId: String) {
        likes?.removeAll { $0 == userId }
    }
    
    
    func isLikedBy(userId: String) -> Bool {
        return likes?.contains(userId) ?? false
    }
}

