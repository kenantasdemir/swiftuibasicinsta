import SwiftUI

struct RegisterView: View {
    @StateObject internal var authViewModel: AuthViewModel
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    @FocusState private var isConfirmPasswordFocused: Bool

    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer().frame(height: 32)

                Text("Kayıt Ol")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)

                ZStack(alignment: .bottomTrailing) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Text("🙂")
                                    .font(.system(size: 40))
                            )
                    }

                    Button(action: {
                        showImagePicker = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Circle().fill(Color.blue))
                    }
                    .offset(x: 5, y: 5)
                }
                .padding(.bottom, 12)
                .sheet(isPresented: $showImagePicker) {
                    SimpleImagePicker(selectedImage: $selectedImage)
                }

                VStack(spacing: 20) {
               
                    TextField("Kullanıcı Adı", text: $authViewModel.username)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1.2)
                        )
                        .autocapitalization(.none)

                    TextField("Email", text: $authViewModel.email)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    (!authViewModel.isEmailValid &&
                                     !authViewModel.email.isEmpty &&
                                     !isEmailFocused)
                                    ? Color.red : Color.gray.opacity(0.4),
                                    lineWidth: 1.2
                                )
                        )
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .focused($isEmailFocused)

               
                    SecureField("Şifre", text: $authViewModel.password)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    (!authViewModel.isPasswordValid &&
                                     !authViewModel.password.isEmpty &&
                                     !isPasswordFocused)
                                    ? Color.red : Color.gray.opacity(0.4),
                                    lineWidth: 1.2
                                )
                        )
                        .focused($isPasswordFocused)

              
                    SecureField("Şifrenizi onaylayın", text: $authViewModel.confirmPassword)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    (!authViewModel.isConfirmPasswordValid &&
                                     !authViewModel.confirmPassword.isEmpty &&
                                     !isConfirmPasswordFocused)
                                    ? Color.red : Color.gray.opacity(0.4),
                                    lineWidth: 1.2
                                )
                        )
                        .focused($isConfirmPasswordFocused)
                }
                .padding(.horizontal, 24)

            
                if let error = authViewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.horizontal, 24)
                }

            
                Button(action: {
                    authViewModel.signUp()
                    authViewModel.switchToLogin()
                }) {
                    Text("Kayıt Ol")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(authViewModel.isFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!authViewModel.isFormValid)
                .padding(.horizontal, 24)

     
                HStack {
                    Text("Zaten hesabın var mı?")
                    Button(action: {
                        authViewModel.switchToLogin()
                    }) {
                        Text("Giriş Yap")
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.bottom, 16)

                Spacer()
            }
            .padding()
        }
    }
}
