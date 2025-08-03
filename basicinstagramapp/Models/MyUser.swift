

import Foundation

class MyUser: Identifiable {
    var uid: String?
    var username: String?
    var email: String?
    var bio: String?
    var profilePhotoUrl: String?
    var followers: [String]?
    var followings: [String]?
    

    var postIds: [String]?
    var savedPostIds: [String]?
    var likedPostIds: [String]?
    
  
    var id: String { uid ?? UUID().uuidString }
    
    init(dict: [String: Any]) {
        self.uid = dict["uid"] as? String
        self.username = dict["username"] as? String
        self.email = dict["email"] as? String
        self.bio = dict["bio"] as? String
        self.profilePhotoUrl = dict["profilePhotoUrl"] as? String
        self.followers = dict["followers"] as? [String]
        self.followings = dict["followings"] as? [String]
        

        self.postIds = dict["postIds"] as? [String]
        self.savedPostIds = dict["savedPostIds"] as? [String]
        self.likedPostIds = dict["likedPostIds"] as? [String]
    }
    
    static func fromDict(_ dict: [String: Any]) -> MyUser {
        return MyUser(dict: dict)
    }
    
    func toDict() -> [String: Any] {
        return [
            "uid": uid ?? "",
            "username": username ?? "",
            "email": email ?? "",
            "bio": bio ?? "",
            "profilePhotoUrl": profilePhotoUrl ?? "",
            "followers": followers ?? [],
            "followings": followings ?? [],
            "postIds": postIds ?? [],
            "savedPostIds": savedPostIds ?? [],
            "likedPostIds": likedPostIds ?? []
        ]
    }
    

    

    var postCount: Int {
        return postIds?.count ?? 0
    }
    

    var savedPostCount: Int {
        return savedPostIds?.count ?? 0
    }
    
   
    var likedPostCount: Int {
        return likedPostIds?.count ?? 0
    }
    

    func addPost(_ postId: String) {
        if postIds == nil {
            postIds = []
        }
        postIds?.append(postId)
    }
    

    func savePost(_ postId: String) {
        if savedPostIds == nil {
            savedPostIds = []
        }
        if !(savedPostIds?.contains(postId) ?? false) {
            savedPostIds?.append(postId)
        }
    }
    

    func unsavePost(_ postId: String) {
        savedPostIds?.removeAll { $0 == postId }
    }
    

    func likePost(_ postId: String) {
        if likedPostIds == nil {
            likedPostIds = []
        }
        if !(likedPostIds?.contains(postId) ?? false) {
            likedPostIds?.append(postId)
        }
    }
    

    func unlikePost(_ postId: String) {
        likedPostIds?.removeAll { $0 == postId }
    }
    

    func isPostSaved(_ postId: String) -> Bool {
        return savedPostIds?.contains(postId) ?? false
    }
    

    func isPostLiked(_ postId: String) -> Bool {
        return likedPostIds?.contains(postId) ?? false
    }
}



let exampleUsers: [MyUser] = [
    MyUser(dict: [
        "uid": "1",
        "username": "kenan",
        "email": "kenan@example.com",
        "bio": "Swift developer",
        "profilePhotoUrl": "",
        "followers": ["2", "3"],
        "followings": ["2"],
        "postIds": ["post1", "post3"],
        "savedPostIds": ["post2"],
        "likedPostIds": ["post1", "post2"]
    ]),
    MyUser(dict: [
        "uid": "2",
        "username": "ayse",
        "email": "ayse@example.com",
        "bio": "iOS lover",
        "profilePhotoUrl": "",
        "followers": ["1"],
        "followings": ["1", "3"],
        "postIds": ["post2"],
        "savedPostIds": ["post1"],
        "likedPostIds": ["post1"]
    ]),
    MyUser(dict: [
        "uid": "3",
        "username": "mehmet",
        "email": "mehmet@example.com",
        "bio": "Mobile engineer",
        "profilePhotoUrl": "",
        "followers": ["1", "2"],
        "followings": [],
        "postIds": [],
        "savedPostIds": ["post1", "post2"],
        "likedPostIds": ["post1"]
    ])
]
