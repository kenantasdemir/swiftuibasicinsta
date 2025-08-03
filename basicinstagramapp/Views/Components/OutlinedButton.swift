
import SwiftUI

struct OutlinedButton: View {
    var title: String?
    var iconName: String? = nil

    var action: () -> Void
    var borderColor: Color = .blue
    var textColor: Color = .blue

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .foregroundColor(textColor)
                }
                Text(title ?? "")
                    .font(.subheadline)
                    .foregroundColor(textColor)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: 1.5)
            )
        }
        .padding(.horizontal, 4)
    }
}



