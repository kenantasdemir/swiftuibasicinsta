

import SwiftUI
import FirebaseFirestore

struct CommentRowView: View {
    let comment: Comment
    @State private var user: MyUser?
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            AsyncImage(url: URL(string: user?.profilePhotoUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
            }
            .frame(width: 24, height: 24)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user?.username ?? "Loading...")
                    .font(.system(size: 12, weight: .semibold))
                
                Text(comment.text ?? "")
                    .font(.system(size: 12))
            }
            
            Spacer()
            
            Button(action:{
                
            },label:{
                Image(systemName: "heart")
            })
            
        }
        .onAppear {
            loadUser()
        }
    }
    
    private func loadUser() {
        guard let userId = comment.userId else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                user = MyUser(dict: data)
            }
        }
    }
}

