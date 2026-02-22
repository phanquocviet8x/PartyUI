#if os(iOS)
import SwiftUI

// Minimal types to match the call sites: .glassEffect(.regular, in: .rect/.capsule/.circular)
public enum GlassEffectStyle {
    case regular
}

public enum GlassEffectShape {
    case rect
    case capsule
    case circular
}

private struct AnyShape: Shape {
    private let _path: (CGRect) -> Path
    init<S: Shape>(_ shape: S) { self._path = { shape.path(in: $0) } }
    func path(in rect: CGRect) -> Path { _path(rect) }
}

private extension GlassEffectShape {
    var clip: AnyShape {
        switch self {
        case .rect:
            return AnyShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        case .capsule:
            return AnyShape(Capsule())
        case .circular:
            return AnyShape(Circle())
        }
    }
}

public extension View {
    /// iOS fallback implementation (since SwiftUI iOS doesn't have `.glassEffect`).
    @MainActor
    func glassEffect(_ style: GlassEffectStyle = .regular, in shape: GlassEffectShape = .rect) -> some View {
        // "Glass" fallback: material background + clipping.
        self
            .background(.ultraThinMaterial)
            .clipShape(shape.clip)
    }
}
#endif
