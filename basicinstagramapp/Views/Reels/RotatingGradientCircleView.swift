import SwiftUI

struct RotatingGradientCircleView: View {
    let imageURL = URL(string: "https://images.unsplash.com/photo-1527980965255-d3b416303d12")!
    @State private var rotation = 0.0

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.red, .orange, .yellow, .red]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 70, height: 70)
                .rotationEffect(.degrees(rotation))
                .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: rotation)
                .onAppear {
                    rotation = 360
                }

            AsyncImage(url: imageURL) { image in
                image.resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
        }
    }
}

#Preview {
    RotatingGradientCircleView()
}
