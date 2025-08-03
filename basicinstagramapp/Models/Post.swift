

import Foundation
import FirebaseFirestore

/*
class Post: Identifiable {
    
    var id: String?
    var userId: String?
    var imageUrl: String?
    var videoUrl: String? // For video reels
    var additionalImageUrls: [String]? // For reels with multiple images
    var caption: String?
    var likes: [String]? 
    var comments: [Comment]?
    var createdAt: Date?
    var location: String?
    var isReel: Bool?
    

    var postId: String { id ?? UUID().uuidString }
    
    init(dict: [String: Any]) {
        self.id = dict["id"] as? String
        self.userId = dict["userId"] as? String
        self.imageUrl = dict["imageUrl"] as? String
        self.videoUrl = dict["videoUrl"] as? String
        self.additionalImageUrls = dict["additionalImageUrls"] as? [String]
        self.caption = dict["caption"] as? String
        self.likes = dict["likes"] as? [String]
        self.location = dict["location"] as? String
        self.isReel = dict["isReel"] as? Bool ?? false
        
   
        if let timestamp = dict["createdAt"] as? FirebaseFirestore.Timestamp {
            self.createdAt = timestamp.dateValue()
        }
        

        if let commentsData = dict["comments"] as? [[String: Any]] {
            self.comments = commentsData.map { Comment(dict: $0) }
        }
    }
    
    static func fromDict(_ dict: [String: Any]) -> Post {
        return Post(dict: dict)
    }
    
    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id ?? "",
            "userId": userId ?? "",
            "imageUrl": imageUrl ?? "",
            "videoUrl": videoUrl ?? "",
            "additionalImageUrls": additionalImageUrls ?? [],
            "caption": caption ?? "",
            "likes": likes ?? [],
            "location": location ?? "",
            "isReel": isReel ?? false
        ]
        
        if let createdAt = createdAt {
            dict["createdAt"] = FirebaseFirestore.Timestamp(date: createdAt)
        }
        
        if let comments = comments {
            dict["comments"] = comments.map { $0.toDict() }
        }
        
        return dict
    }
}
*/


struct Post: Identifiable, Hashable {
    var id: String?
    var userId: String?
    var imageUrl: String?
    var videoUrl: String?
    var additionalImageUrls: [String]?
    var caption: String?
    var likes: [String]?
    var comments: [Comment]?
    var createdAt: Date?
    var location: String?
    var isReel: Bool?

    var postId: String { id ?? UUID().uuidString }

    init(dict: [String: Any]) {
        self.id = dict["id"] as? String
        self.userId = dict["userId"] as? String
        self.imageUrl = dict["imageUrl"] as? String
        self.videoUrl = dict["videoUrl"] as? String
        self.additionalImageUrls = dict["additionalImageUrls"] as? [String]
        self.caption = dict["caption"] as? String
        self.likes = dict["likes"] as? [String]
        self.location = dict["location"] as? String
        self.isReel = dict["isReel"] as? Bool ?? false

        if let timestamp = dict["createdAt"] as? FirebaseFirestore.Timestamp {
            self.createdAt = timestamp.dateValue()
        }

        if let commentsData = dict["comments"] as? [[String: Any]] {
            self.comments = commentsData.map { Comment(dict: $0) }
        }
    }

    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id ?? "",
            "userId": userId ?? "",
            "imageUrl": imageUrl ?? "",
            "videoUrl": videoUrl ?? "",
            "additionalImageUrls": additionalImageUrls ?? [],
            "caption": caption ?? "",
            "likes": likes ?? [],
            "location": location ?? "",
            "isReel": isReel ?? false
        ]

        if let createdAt = createdAt {
            dict["createdAt"] = FirebaseFirestore.Timestamp(date: createdAt)
        }

        if let comments = comments {
            dict["comments"] = comments.map { $0.toDict() }
        }

        return dict
    }

  
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}



let examplePosts: [Post] = [
    Post(dict: [
        "id": "post1",
        "userId": "1",
        "imageUrl": "https://example.com/image1.jpg",
        "caption": "Harika bir gün! ☀️",
        "likes": ["2", "3"],
        "location": "İstanbul, Türkiye",
        "isReel": false,
        "createdAt": FirebaseFirestore.Timestamp(date: Date())
    ]),
    Post(dict: [
        "id": "post2",
        "userId": "2",
        "imageUrl": "https://example.com/image2.jpg",
        "caption": "Kod yazarken... 💻",
        "likes": ["1"],
        "location": "Ankara, Türkiye",
        "isReel": false,
        "createdAt": FirebaseFirestore.Timestamp(date: Date().addingTimeInterval(-3600))
    ]),
    Post(dict: [
        "id": "reel1",
        "userId": "1",
        "imageUrl": "https://example.com/reel1.mp4",
        "caption": "Günlük vlog! 📱",
        "likes": ["2", "3", "4"],
        "location": "İstanbul, Türkiye",
        "isReel": true,
        "createdAt": FirebaseFirestore.Timestamp(date: Date().addingTimeInterval(-7200))
    ])
] 
