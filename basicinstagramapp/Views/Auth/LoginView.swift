import Foundation
import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var switchRegisterPage = false
    
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("Giriş Yap")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            
            VStack(spacing: 20) {
      
                TextField("Email", text: $authViewModel.email)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                (!authViewModel.isEmailValid && !authViewModel.email.isEmpty && !isEmailFocused)
                                ? Color.red : Color.gray.opacity(0.5),
                                lineWidth: 1.5
                            )
                    )
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(10)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .focused($isEmailFocused)
 
                SecureField("Şifre", text: $authViewModel.password)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                (!authViewModel.isPasswordValid && !authViewModel.password.isEmpty && !isPasswordFocused)
                                ? Color.red : Color.gray.opacity(0.5),
                                lineWidth: 1.5
                            )
                    )
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(10)
                    .focused($isPasswordFocused)
            }
            .padding(.horizontal, 24)
            
          
            if let error = authViewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.horizontal, 24)
            }

            Button(action: {
                authViewModel.signIn()
            }) {
                Text("Giriş Yap")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(authViewModel.isFormValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!authViewModel.isFormValid)
            .padding(.horizontal, 24)

            Spacer()
            
           
            HStack {
                Text("Hesabın yok mu?")
                Button(action: {
                    authViewModel.switchToRegister()
                }) {
                    Text("Kaydol")
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }
            }
            .padding(.bottom, 16)
        }
        .padding()
    }
}
