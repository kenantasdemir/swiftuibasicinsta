
import Foundation
import FirebaseAuth
import FirebaseFirestore

import Combine

class AuthViewModel: ObservableObject {
    
    @Published var authState: AuthFlowState = .login
    
    
    
 
    @Published var myUser:MyUser?
    @Published var user: User?
    @Published var isSignedIn: Bool = false
    @Published var errorMessage: String?
    
 
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    
    @Published var isUsernameValid: Bool = false
    @Published var isEmailValid: Bool = false
    @Published var isPasswordValid: Bool = false
    @Published var isConfirmPasswordValid = false
    @Published var isFormValid: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    fileprivate var firebaseAuth = Auth.auth()
    let db = Firestore.firestore()
    
    @Published var firstTenUsers:[MyUser] = [MyUser]()
    @Published var isFollowing: Bool = false
    @Published var users: [MyUser] = [MyUser]()
    
    
    
    
    
    
    
    init() {
        self.user = Auth.auth().currentUser
        self.isSignedIn = user != nil
        setupValidation()
        setupValidationForRegister()
    }
    
    /*
     private func setupValidationForRegister() {
     Publishers.CombineLatest3($email, $password, $confirmPassword)
     .map { email, password, confirmPassword in
     let isEmailValid = email.contains("@") && email.contains(".")
     let isPasswordValid = password.count >= 6
     let doPasswordsMatch = password == confirmPassword
     
     return isEmailValid && isPasswordValid && doPasswordsMatch
     }
     .receive(on: RunLoop.main)
     .assign(to: &$isFormValid)
     }
     */
    
    
    public func follow(userId: String) async {
        guard let currentUserId = user?.uid else {
            print("Kullanıcı oturumu yok.")
            return
        }
        
        do {
            try await db.collection("users").document(currentUserId).updateData([
                "followings": FieldValue.arrayUnion([userId])
            ])
            
            try await db.collection("users").document(userId).updateData([
                "followers": FieldValue.arrayUnion([currentUserId])
            ])
            
       
            await checkFollowingStatus(userId: userId)
        } catch {
            print("FOLLOW METODUNDA HATA VAR: \(error)")
        }
    }
    
    public func unfollow(userId: String) async {
        guard let currentUserId = user?.uid else {
            print("Kullanıcı oturumu yok.")
            return
        }
        
        do {
            print("unfollow: currentUserId=\(currentUserId), userId=\(userId)")
            try await db.collection("users").document(currentUserId).updateData([
                "followings": FieldValue.arrayRemove([userId])
            ])
            print("Kendi followings array'inden silindi.")
            
            try await db.collection("users").document(userId).updateData([
                "followers": FieldValue.arrayRemove([currentUserId])
            ])
            print("Karşı tarafın followers array'inden silindi.")
            
        
            await checkFollowingStatus(userId: userId)
        } catch {
            print("UNFOLLOW METODUNDA HATA VAR: \(error)")
        }
    }
    
 
    public func isFollowing(userId: String) async -> Bool {
        guard let currentUserId = user?.uid else {
            print("Oturum açmış kullanıcı yok.")
            return false
        }
        
        do {
            let snapshot = try await db.collection("users").document(currentUserId).getDocument()
            if let data = snapshot.data(),
               let followings = data["followings"] as? [String] {
                return followings.contains(userId)
            } else {
                return false
            }
        } catch {
            print("Takip kontrolünde hata oluştu: \(error)")
            return false
        }
    }
    

    public func checkFollowingStatus(userId: String) async {
        let result = await isFollowing(userId: userId)
        await MainActor.run {
            self.isFollowing = result
        }
    }
    
    
    
    
    private func setupValidation() {
        Publishers.CombineLatest($email, $password)
            .map { email, password in
                return email.contains("@") && password.count >= 6
            }
            .receive(on: RunLoop.main)
            .assign(to: &$isFormValid)
    }
    
    private func setupValidationForRegister() {
 
        $username
            .map { username in
                let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.count >= 3 && trimmed.count <= 20 && 
                trimmed.range(of: "^[a-zA-Z0-9_]+$", options: .regularExpression) != nil
            }
            .assign(to: &$isUsernameValid)
        
 
        $email
            .map { $0.contains("@") && $0.contains(".") }
            .assign(to: &$isEmailValid)
        
       
        $password
            .map { $0.count >= 6 }
            .assign(to: &$isPasswordValid)
        
     
        Publishers.CombineLatest($password, $confirmPassword)
            .map { $0 == $1 && !$1.isEmpty }
            .assign(to: &$isConfirmPasswordValid)
        

        Publishers.CombineLatest4($isUsernameValid, $isEmailValid, $isPasswordValid, $isConfirmPasswordValid)
            .map { $0 && $1 && $2 && $3 }
            .assign(to: &$isFormValid)
    }
    
    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let firebaseUser = result?.user else {
                    self.errorMessage = "Kullanıcı bilgileri alınamadı."
                    return
                }
                
      
                let finalUsername: String = {
                    if !self.username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        return self.username.trimmingCharacters(in: .whitespacesAndNewlines)
                    } else if let email = firebaseUser.email,
                              let atIndex = email.firstIndex(of: "@") {
                        return String(email[..<atIndex])
                    }
                    return "user_\(firebaseUser.uid.prefix(8))"
                }()
                
        
                let myUser = MyUser(dict: [
                    "uid": firebaseUser.uid,
                    "username": finalUsername,
                    "email": firebaseUser.email ?? "",
                    "bio": "",
                    "profilePhotoUrl": firebaseUser.photoURL?.absoluteString ?? "",
                    "followers": [String](),
                    "followings": [String](),
                    "postIds": [String](),
                    "savedPostIds": [String](),
                    "likedPostIds": [String]()
                ])
                
               
                let db = Firestore.firestore()
                db.collection("users").document(firebaseUser.uid).setData(myUser.toDict()) { error in
                    if let error = error {
                        self.errorMessage = "Firestore'a yazılırken hata: \(error.localizedDescription)"
                        return
                    }
                    

                    self.myUser = myUser
                    self.isSignedIn = true
                }
            }
        }
    }
    
    func getAllUsers(completion: (() -> Void)? = nil) {
        db.collection("users").limit(to: 50).addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Belge yok")
                return
            }

            let users = documents.map { doc in
                MyUser(dict: doc.data())
            }

            DispatchQueue.main.async {
                self.users = Array(users)
                completion?()
            }
        }
    }

    
    func fetchUser() {
        guard let currentUser = Auth.auth().currentUser else {
            self.errorMessage = "Giriş yapan kullanıcı bulunamadı."
            return
        }
        
        let uid = currentUser.uid
        let db = Firestore.firestore()
        

        db.collection("users").document(uid).addSnapshotListener { snapshot, error in
            if let error = error {
                self.errorMessage = "Kullanıcı verisi alınamadı: \(error.localizedDescription)"
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "Kullanıcı verisi bulunamadı."
                return
            }
            
            let myUser = MyUser.fromDict(data)
            DispatchQueue.main.async {
                self.myUser = myUser
            }
        }
    }
    func getFirst10Users() {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            print("Mevcut kullanıcı UID alınamadı")
            return
        }
        
        db.collection("users")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Kullanıcılar alınamadı: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("Belge yok")
                    return
                }
                
              
                let users = documents.map { doc in
                    MyUser(dict: doc.data())
                }
                    .filter { user in
                        user.uid != currentUID
                    }
                    .prefix(10)
                
                DispatchQueue.main.async {
                    self.firstTenUsers = Array(users)
                }
            }
    }
    
    
    
    
    
    
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                self.user = result?.user
                self.isSignedIn = true
                self.authState = .signedIn
                
           
                self.fetchUser()
            }
        }
    }
    
    func isThisMyProfile(user:MyUser)->Bool{
        if(user.uid == myUser?.uid){
            return true
        }else{
            return false
        }
    }
    
    
    func getUsername(for userId: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(), let username = data["username"] as? String {
                completion(username)
            } else {
                completion(nil)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isSignedIn = false
            
            
            self.password = ""
            self.confirmPassword = ""
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func switchToRegister() {
        authState = .register
        clearDatas()
        
    }
    
    func switchToLogin() {
        authState = .login
        clearDatas()
    }
    
    func clearDatas(){
        self.username = ""
        self.email = ""
        self.password = ""
        self.confirmPassword = ""
        self.errorMessage = ""
    }
}
