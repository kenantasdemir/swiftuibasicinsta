

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        switch authViewModel.authState {
        case .login:
            NavigationStack {
                LoginView(authViewModel: authViewModel)
            }
        case .register:
            NavigationStack {
                RegisterView(authViewModel: authViewModel)
            }
        case .signedIn:
            MainTabView(authViewModel: authViewModel) 
        }
    }
}

#Preview {
    ContentView()
}

