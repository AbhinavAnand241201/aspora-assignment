import SwiftUI
import UIKit

struct GlassCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                colorScheme == .dark
                ? Color.white.opacity(0.08)
                : Color(.systemBackground).opacity(0.95)
            )
            .cornerRadius(Constants.UI.cornerRadius)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

struct GlassCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            GlassCard {
                Text("Glassmorphism")
                    .foregroundColor(.white)
            }
            .padding()
        }
    }
}
