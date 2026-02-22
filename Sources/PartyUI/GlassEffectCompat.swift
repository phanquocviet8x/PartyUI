import SwiftUI

// Fallback `.glassEffect` for SDKs that don't ship it (e.g. iOS 18.x SDK used by Xcode 16.4).
public enum GlassEffectStyle: Sendable, Equatable {
    case regular
    case regularInteractive
}

public extension GlassEffectStyle {
    @inlinable
    func interactive() -> GlassEffectStyle {
        switch self {
        case .regular, .regularInteractive:
            return .regularInteractive
        }
    }
}

public extension View {
    @inlinable
    func glassEffect<S: Shape>(_ style: GlassEffectStyle = .regular, in shape: S) -> some View {
        // style currently only affects API compatibility; both map to the same visual fallback.
        self
            .background(.ultraThinMaterial)
            .overlay {
                shape.stroke(Color.white.opacity(0.12), lineWidth: 1)
            }
            .clipShape(shape)
    }
}
