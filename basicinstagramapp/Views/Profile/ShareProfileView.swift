import SwiftUI
import CoreImage.CIFilterBuiltins
import Photos

struct ShareProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var backgroundColor: Color = Color(.systemBackground)
    @State private var showSaveAlert = false
    @State private var saveErrorMessage: String?
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    let colors: [Color] = [.red, .green, .blue, .orange, .purple, .pink]
    

    func generateQRCodeImage(from string: String) -> UIImage? {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
            if let cgimg = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return nil
    }
    
 
    func saveToPhotoLibrary(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                showSaveAlert = true
                saveErrorMessage = nil
            } else {
                showSaveAlert = true
                saveErrorMessage = "Fotoğraf kaydetme izni verilmedi."
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        if let username = authViewModel.myUser?.username,
                           let qrImage = generateQRCodeImage(from: username) {
                            Image(uiImage: qrImage)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                            
                            Text(username)
                                .font(.title2)
                                .bold()
                        } else {
                            Text("Kullanıcı bulunamadı")
                        }
                    }
                    .frame(width: 300, height: 300)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(width: 300, height: 200 / 3)
                        .cornerRadius(12)
                        .overlay(
                            HStack {
                                VStack {
                                    Image(systemName: "square.and.arrow.up.on.square")
                                    Text("Paylaş")
                                        .font(.system(size: 10))
                                }
                                
                                VStack {
                                    Image(systemName: "link.circle")
                                    Text("Bağlantıyı kopyala")
                                        .font(.system(size: 10))
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                .frame(width: 120)
                                
                                VStack {
                                    Image(systemName: "arrow.down")
                                        .onTapGesture {
                                            if let username = authViewModel.myUser?.username,
                                               let qrImage = generateQRCodeImage(from: username) {
                                                saveToPhotoLibrary(qrImage)
                                            }
                                        }
                                    Text("İndir")
                                        .font(.system(size: 10))
                                }
                            }
                        )
                    
                    HStack(spacing: 16) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 30, height: 30)
                                .onTapGesture {
                                    withAnimation {
                                        backgroundColor = color
                                    }
                                }
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(backgroundColor == color ? 0.8 : 0), lineWidth: 2)
                                )
                        }
                    }
                    
                    Spacer()
                }
                .navigationTitle("Profil Paylaş")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                },trailing: Button{
                    print("Tıklandı")
                }label:{
                    Image(systemName: "qrcode.viewfinder")
                    
                }
                )
            }
            .alert(isPresented: $showSaveAlert) {
                if let error = saveErrorMessage {
                    return Alert(title: Text("Hata"), message: Text(error), dismissButton: .default(Text("Tamam")))
                } else {
                    return Alert(title: Text("Başarılı"), message: Text("QR kodu fotoğraflara kaydedildi."), dismissButton: .default(Text("Tamam")))
                }
            }
            
        }
    }
}
