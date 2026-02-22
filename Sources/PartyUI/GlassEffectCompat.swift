#if os(iOS)
import SwiftUI

// Compatibility fallback for SDKs where SwiftUI doesn't ship `.glassEffect(...)` (e.g. iOS 18.x SDK).
public enum GlassEffectStyle: Sendable, Equatable {
    case regular
}

public extension GlassEffectStyle {
    @inlinable func interactive() -> GlassEffectStyle { self }
}

public extension View {
    @inlinable
    func glassEffect<S: Shape>(_ style: GlassEffectStyle = .regular, in shape: S) -> some View {
        self
            .background(.ultraThinMaterial)
            .overlay {
                shape.stroke(Color.white.opacity(0.12), lineWidth: 1)
            }
            .clipShape(shape)
    }
}
