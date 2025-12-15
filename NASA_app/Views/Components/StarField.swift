import SwiftUI

struct StarField: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<50) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 1, height: 1)
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .opacity(Double.random(in: 0.2...0.6))
                }
                
                ForEach(0..<20) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 2, height: 2)
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .opacity(Double.random(in: 0.4...0.8))
                }
            }
        }
        .drawingGroup()
    }
}
