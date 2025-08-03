import SwiftUI

struct SearchPageView: View {
    @ObservedObject public var postViewModel: PostViewModel
    @ObservedObject public var authViewModel: AuthViewModel
    @State private var searchText = ""
    
    @State var users:[MyUser]?

    var filteredUsers: [MyUser] {
        if searchText.isEmpty {
            return []
        } else {
            print("USER SAYISI \(self.users?.count)")
            return users!.filter {
                $0.username?.lowercased().contains(searchText.lowercased()) == true
            }
        }
    }


    var patternedRows: [([Post], [[Post]], Bool)] {
        let posts = postViewModel.posts
        print("POST COUNT \(posts.count)")
        var result: [([Post], [[Post]], Bool)] = []
        var i = 0
        var left = true

        while i + 4 < posts.count {
            let group = Array(posts[i...i+4])
            if let reel = group.first(where: { $0.isReel == true }),
               group.filter({ $0.isReel != true }).count == 4 {
                let nonReels = group.filter { $0.isReel != true }
                let vstack1 = Array(nonReels[0...1])
                let vstack2 = Array(nonReels[2...3])
                result.append(([reel], [vstack1, vstack2], left))
                left.toggle()
            }
            i += 5
        }
        return result
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if postViewModel.isLoading {
                    ProgressView("Yükleniyor...")
                        .padding()
                } else if !filteredUsers.isEmpty {
                    userResultsView
                } else {
                    postGridView
                }
            }
            .navigationTitle("Keşfet")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onAppear {
                Task {
                    await postViewModel.fetchAllPosts()
                    authViewModel.getAllUsers {
                        self.users = authViewModel.users
                        print("Kullanıcı sayısı: \(self.users?.count ?? 0)")
                    }
                }
            }

        }
    }

    var userResultsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(filteredUsers) { user in
                HStack {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(user.username?.prefix(1).uppercased() ?? "")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        )
                    

                    VStack(alignment: .leading,spacing: 5) {
                        Text(user.username ?? "")
                            .font(.headline)
                        Text(user.bio ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .contentShape(Rectangle())
                .onTapGesture {
                    print("Tıklandı")
                }
            }
        }
        .padding(.top)
    }

    var postGridView: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 0
            let unitWidth = geo.size.width / 5
            let boxHeight = unitWidth
            let reelHeight = boxHeight * 2

            VStack(spacing: 0) {
              
                ForEach(0..<patternedRows.count, id: \.self) { rowIndex in
                    let (reelArr, vstacks, reelLeft) = patternedRows[rowIndex]
                    let reel = reelArr[0]
                    HStack(spacing: spacing) {
                        if reelLeft {
                            postBox(post: reel, width: unitWidth, height: reelHeight)
                            ForEach(vstacks, id: \.self) { stack in
                                VStack(spacing: spacing) {
                                    postBox(post: stack[0], width: unitWidth, height: boxHeight)
                                    postBox(post: stack[1], width: unitWidth, height: boxHeight)
                                }
                            }
                        } else {
                            ForEach(vstacks, id: \.self) { stack in
                                VStack(spacing: spacing) {
                                    postBox(post: stack[0], width: unitWidth, height: boxHeight)
                                    postBox(post: stack[1], width: unitWidth, height: boxHeight)
                                }
                            }
                            postBox(post: reel, width: unitWidth, height: reelHeight)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
      
                let usedCount = patternedRows.count * 5
                let remaining = Array(postViewModel.posts.dropFirst(usedCount))
                if !remaining.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 3), spacing: 0) {
                        ForEach(remaining, id: \.id) { post in
                            postBox(post: post, width: unitWidth, height: boxHeight)
                        }
                    }
                }
            }
        }
        .frame(height: CGFloat(patternedRows.count) * ((UIScreen.main.bounds.width / 5) * 2) + 200) 
    }

    @ViewBuilder
    func postBox(post: Post, width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure(_):
                            Rectangle().fill(Color.gray)
                        case .empty:
                            ProgressView()
                        @unknown default:
                            Rectangle().fill(Color.gray)
                        }
                    }
                } else {
                    Rectangle().fill(post.isReel == true ? Color.purple : Color.gray)
                }
            }
            .frame(width: width * 1.6, height: height * 1.6)
            .clipped()

            Image(systemName: post.isReel == true ? "play.rectangle.fill" : "square.on.square")
                .foregroundColor(.white)
                .padding(6)
        }
    }
}
