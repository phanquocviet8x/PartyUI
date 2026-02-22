//
//  PartyStyles.swift
//  Created by lunginspector for jailbreak.party.
//
//  PartyUI: a collection of reusable UI elements used by jailbreak.party.
//  Licensed under the MIT License.
//  https://github.com/jailbreakdotparty/PartyUI
//  https://jailbreak.party/
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - glassEffect compatibility (Xcode 16.4 / iOS 18.x SDK)
// SwiftUI's `.glassEffect(...)` is not available in the iOS 18.x SDK,
// so PartyUI's calls fail to compile. We provide a fallback with the
// same call shape used in PartyUI.
// If Apple later ships a real `.glassEffect` with the same signature,
// this overload is marked disfavored so the system one wins.

// MARK: - Styles

@MainActor
public struct GlassyPlatter: ViewModifier {
    var color: Color = platterBackgroundColor()
    var shape: AnyShape = AnyShape(.rect(cornerRadius: platterCornerRadius()))
    var isInteractive: Bool = true
    var useCustomPadding: Bool = false
    var paddingAmount: CGFloat = 12

    public init(
        color: Color = platterBackgroundColor(),
        shape: AnyShape = AnyShape(.rect(cornerRadius: platterCornerRadius())),
        isInteractive: Bool = true,
        useCustomPadding: Bool = false,
        paddingAmount: CGFloat = 12
    ) {
        self.color = color
        self.shape = shape
        self.isInteractive = isInteractive
        self.useCustomPadding = useCustomPadding
        self.paddingAmount = paddingAmount
    }

    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .if(useCustomPadding) { view in
                view.padding(paddingAmount)
            } else: { view in
                view.padding()
            }
            .background(color)
            .clipShape(shape)
            .glassEffect(isInteractive ? .regularInteractive : .regular, in: shape)
    }
}

@MainActor
public struct GlassyButtonStyle: PrimitiveButtonStyle {
    var isDisabled: Bool = false
    var color: Color = .accentColor
    var useFullWidth: Bool = true
    var cornerRadius: CGFloat = conditionalCornerRadius()
    var capsuleButton: Bool = false
    var isInteractive: Bool = true
    var width: CGFloat? = nil
    var isMaterialButton: Bool = false
    var materialOpacity: CGFloat = 0.4

    public init(
        isDisabled: Bool = false,
        color: Color = .accentColor,
        useFullWidth: Bool = true,
        cornerRadius: CGFloat = conditionalCornerRadius(),
        capsuleButton: Bool = false,
        isInteractive: Bool = true,
        width: CGFloat? = nil,
        isMaterialButton: Bool = false,
        materialOpacity: CGFloat = 0.4
    ) {
        self.isDisabled = isDisabled
        self.color = color
        self.useFullWidth = useFullWidth
        self.cornerRadius = cornerRadius
        self.capsuleButton = capsuleButton
        self.isInteractive = isInteractive
        self.width = width
        self.isMaterialButton = isMaterialButton
        self.materialOpacity = materialOpacity
    }

    public func makeBody(configuration: Configuration) -> some View {
        GlassyButtonContents(
            configuration: configuration,
            isDisabled: isDisabled,
            color: color,
            useFullWidth: useFullWidth,
            cornerRadius: cornerRadius,
            capsuleButton: capsuleButton,
            isInteractive: isInteractive,
            width: width,
            isMaterialButton: isMaterialButton,
            materialOpacity: materialOpacity
        )
    }

    private struct GlassyButtonContents: View {
        @State private var isPressed: Bool = false
        let configuration: Configuration

        var isDisabled: Bool = false
        var color: Color = .accentColor
        var useFullWidth: Bool = true
        var cornerRadius: CGFloat = conditionalCornerRadius()
        var capsuleButton: Bool = false
        var isInteractive: Bool = true
        var width: CGFloat? = nil
        var isMaterialButton: Bool = false
        var materialOpacity: CGFloat = 0.4

        var body: some View {
            let effectiveColor: Color = isDisabled ? .gray : color
            let shape: AnyShape = capsuleButton ? AnyShape(.capsule) : AnyShape(.rect(cornerRadius: cornerRadius))
            let effectiveInteractive: Bool = isDisabled ? false : isInteractive

            configuration.label
                .buttonStyle(.plain)
                .frame(maxWidth: useFullWidth ? .infinity : nil)
                .foregroundStyle(effectiveColor)
                .padding()
                .frame(width: width)
                .background(effectiveColor.opacity(0.2))
                .background {
                    if isMaterialButton {
                        // Material with custom opacity.
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .opacity(materialOpacity)
                    }
                }
                .clipShape(shape)
                .glassEffect(effectiveInteractive ? .regularInteractive : .regular, in: shape)
                .opacity(isPressed ? 0.8 : 1.0)
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .animation(isPressed ? nil : .spring(response: 0.4, dampingFraction: 0.6), value: isPressed)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isDisabled && !isPressed {
                                isPressed = true
                            }
                        }
                        .onEnded { _ in
                            guard !isDisabled else { return }
                            isPressed = false
                            configuration.trigger()
                        }
                )
        }
    }
}

@MainActor
public struct GlassyTextFieldStyle: TextFieldStyle {
    var isDisabled: Bool = false
    var useAutoCorrection: Bool = true
    var useAutoCaptialization: Bool = true
    var color: Color = secondaryBackgroundColor()
    var cornerRadius: CGFloat = conditionalCornerRadius()
    var capsuleField: Bool = false
    var isInteractive: Bool = true

    public init(
        isDisabled: Bool = false,
        useAutoCorrection: Bool = true,
        useAutoCaptialization: Bool = true,
        color: Color = secondaryBackgroundColor(),
        cornerRadius: CGFloat = conditionalCornerRadius(),
        capsuleField: Bool = false,
        isInteractive: Bool = true
    ) {
        self.isDisabled = isDisabled
        self.useAutoCorrection = useAutoCorrection
        self.useAutoCaptialization = useAutoCaptialization
        self.color = color
        self.cornerRadius = cornerRadius
        self.capsuleField = capsuleField
        self.isInteractive = isInteractive
    }

    public func _body(configuration: TextField<Self._Label>) -> some View {
        let bgColor: Color = isDisabled ? .gray.opacity(0.2) : color
        let fontColor: Color = isDisabled ? .gray : .primary
        let shape: AnyShape = capsuleField ? AnyShape(.capsule) : AnyShape(.rect(cornerRadius: cornerRadius))
        let effectiveInteractive: Bool = isDisabled ? false : isInteractive

        return configuration
            .textFieldStyle(.plain)
            .autocorrectionDisabled(!useAutoCorrection)
            .autocapitalization(useAutoCaptialization ? .sentences : .none)
            .frame(maxWidth: .infinity)
            .foregroundStyle(fontColor)
            .padding()
            .clipShape(shape)
            .modifier(DynamicGlassEffect(color: bgColor, shape: shape, isInteractive: effectiveInteractive))
            .allowsHitTesting(!isDisabled)
    }
}

@MainActor
public struct GlassyListRowBackground: ViewModifier {
    var color: Color = .accentColor
    var cornerRadius: CGFloat = conditionalCornerRadius()
    var isInteractive: Bool = true

    public init(color: Color = .accentColor, cornerRadius: CGFloat = conditionalCornerRadius(), isInteractive: Bool = true) {
        self.color = color
        self.cornerRadius = cornerRadius
        self.isInteractive = isInteractive
    }

    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(color)
            .padding()
            .background(color.opacity(0.2))
            .clipShape(.rect(cornerRadius: cornerRadius))
            .glassEffect(isInteractive ? .regularInteractive : .regular, in: .rect(cornerRadius: cornerRadius))
    }
}

@MainActor
public struct DynamicGlassEffect: ViewModifier {
    var color: Color = Color(.quaternarySystemFill)
    var shape: AnyShape = AnyShape(.rect(cornerRadius: conditionalCornerRadius()))
    var useFullWidth: Bool = true
    var glassEffect: Bool = true
    var isInteractive: Bool = true
    var useBackground: Bool = true
    var opacity: CGFloat = 1.0

    public init(
        color: Color = Color(.quaternarySystemFill),
        shape: AnyShape = AnyShape(.rect(cornerRadius: conditionalCornerRadius())),
        useFullWidth: Bool = true,
        glassEffect: Bool = true,
        isInteractive: Bool = true,
        useBackground: Bool = true,
        opacity: CGFloat = 1.0
    ) {
        self.color = color
        self.shape = shape
        self.useFullWidth = useFullWidth
        self.glassEffect = glassEffect
        self.isInteractive = isInteractive
        self.useBackground = useBackground
        self.opacity = opacity
    }

    public func body(content: Content) -> some View {
        let base = content
            .background(useBackground ? color.opacity(opacity) : .clear)
            .clipShape(shape)

        if glassEffect {
            return AnyView(base.glassEffect(isInteractive ? .regularInteractive : .regular, in: shape))
        } else {
            return AnyView(base)
        }
    }
}

@MainActor
public struct OverlayBackground: ViewModifier {
    @State private var keyboardShown: Bool
    var blurRadius: CGFloat = 8
    var useDimming: Bool = true
    var stickBottomPadding: Bool = false

    public init(
        keyboardShown: Bool = false,
        blurRadius: CGFloat = 8,
        useDimming: Bool = true,
        stickBottomPadding: Bool = false
    ) {
        self._keyboardShown = State(initialValue: keyboardShown)
        self.blurRadius = blurRadius
        self.useDimming = useDimming
        self.stickBottomPadding = stickBottomPadding
    }

    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, 25)
            .padding(.top, 30)
            .padding(.bottom, keyboardShown || stickBottomPadding ? 20 : 0)
            .background {
                ZStack {
                    VariableBlurView(maxBlurRadius: blurRadius, direction: .blurredBottomClearTop)
                    if useDimming {
                        Rectangle()
                            .fill(Gradient(colors: [.clear, Color(.systemBackground)]))
                            .opacity(0.8)
                    }
                }
                .ignoresSafeArea()
            }
#if canImport(UIKit)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                keyboardShown = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardShown = false
            }
#endif
    }
}
