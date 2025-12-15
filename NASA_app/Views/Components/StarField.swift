import SwiftUI

struct StarField: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<80, id: \.self) { index in
                    let isLarge = index % 5 == 0
                    Circle()
                        .fill(colorScheme == .dark ? Color.white : Color.black.opacity(0.18))
                        .frame(width: isLarge ? 2.0 : 1.2, height: isLarge ? 2.0 : 1.2)
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .opacity(isLarge ? 0.7 : 0.4)
                }
            }
        }
        .drawingGroup()
    }
}
