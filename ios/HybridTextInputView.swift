import Foundation
import NitroModules
import SwiftUI

// MARK: - SwiftUI TextField View
final class TextFieldState: ObservableObject {
    @Published var text: String = ""
    @Published var isSecure: Bool = false

    @Published var placeholder: String? = nil
    @Published var allowFontScaling: Bool = true
    @Published var autoCapitalize: UITextAutocapitalizationType = .sentences
    @Published var autoCorrect: UITextAutocorrectionType = .default

    @Published var backgroundColor: Color = .clear
    @Published var textColor: Color = .primary
    @Published var cursorColor: UIColor = {
        if #available(iOS 15.0, *) { return .tintColor }
        return .systemBlue
    }()
}

// MARK: - SwiftUI view (подписан на state)
private struct SwiftUITextFieldView: View {
    @ObservedObject var state: TextFieldState
    var onChangeText: (String) -> Void

    var body: some View {
        ZStack { state.backgroundColor
            HStack(spacing: 8) {
                if state.isSecure {
                    SecureField(state.placeholder ?? "", text: Binding(
                        get: { state.text },
                        set: { newVal in
                            state.text = newVal
                            onChangeText(newVal)
                        }
                    ))
                    .textInputAutocapitalization(state.autoCapitalize.swiftUI)
                    .disableAutocorrection(state.autoCorrect == .no)
                    .foregroundColor(state.textColor)
                    .tint(Color(state.cursorColor))
                } else {
                    TextField(state.placeholder ?? "", text: Binding(
                        get: { state.text },
                        set: { newVal in
                            state.text = newVal
                            onChangeText(newVal)
                        }
                    ))
                    .textInputAutocapitalization(state.autoCapitalize.swiftUI)
                    .disableAutocorrection(state.autoCorrect == .no)
                    .foregroundColor(state.textColor)
                    .tint(Color(state.cursorColor))
                }
            }
            .padding(.horizontal, 0)
            .padding(.vertical, 0)
        }
        .allowsTightening(state.allowFontScaling)
    }
}

// MARK: - Nitro wrapper
final class HybridTextInputView: HybridNitroTextInputViewSpec {

    var allowFontScaling: Bool?        { didSet { Task { @MainActor in state.allowFontScaling = allowFontScaling ?? true } } }
    var autoCapitalize: AutoCapitalize?{ didSet { Task { @MainActor in state.autoCapitalize = (autoCapitalize ?? .sentences).uiKit } } }
    var autoCorrect: Bool?             { didSet { Task { @MainActor in state.autoCorrect = (autoCorrect ?? true) ? .yes : .no } } }
    var placeholder: String?           { didSet { Task { @MainActor in state.placeholder = placeholder } } }
    var multiline: Bool? = false

    var backgroundColor: String?       { didSet { Task { @MainActor in state.backgroundColor = Color(hex: backgroundColor) ?? .clear } } }
    var textColor: String?             { didSet { Task { @MainActor in state.textColor = Color(hex: textColor) ?? .primary } } }
    var cursorColor: String?           { didSet { Task { @MainActor in state.cursorColor = UIColor(hex: cursorColor) ?? .blue } } }

    var secureTextEntry: Bool?         { didSet { Task { @MainActor in state.isSecure = secureTextEntry ?? false } } }

    var value: String? {
        didSet {
            Task { @MainActor in
                let newVal = value ?? ""
                if state.text != newVal { state.text = newVal } // без зацикливания
            }
        }
    }
    var onChangeText: ((String) -> Void)?

    private var state = TextFieldState()
    private let hostingController: UIHostingController<SwiftUITextFieldView>

    override init() {
        let state = TextFieldState()

        let tempView = SwiftUITextFieldView(state: state, onChangeText: { _ in })

        self.state = state
        self.hostingController = UIHostingController(rootView: tempView)
        self.hostingController.view.backgroundColor = .clear

        super.init()

        self.hostingController.rootView = SwiftUITextFieldView(
            state: self.state,
            onChangeText: { [weak self] newVal in
                guard let self else { return }
                self.onChangeText?(newVal)
                if self.value != newVal {
                    self.value = newVal
                }
            }
        )
    }
    var view: UIView { hostingController.view }

    @objc func setPlaceholder(_ text: String?)            { self.placeholder = text }
    @objc func setAllowFontScaling(_ allow: NSNumber?)    { self.allowFontScaling = allow?.boolValue }
    @objc func setAutoCapitalize(_ cap: AutoCapitalize)   { self.autoCapitalize = cap }
    @objc func setAutoCorrect(_ enabled: NSNumber?)       { self.autoCorrect = enabled?.boolValue }
    @objc func setBackgroundColor(_ hex: String?)         { self.backgroundColor = hex }
    @objc func setTextColor(_ hex: String?)               { self.textColor = hex }
    @objc func setCursorColor(_ hex: String?)             { self.cursorColor = hex }
    @objc func setSecureTextEntry(_ secure: NSNumber?)    { self.secureTextEntry = secure?.boolValue }
}
// MARK: - Helpers / Mappings

extension UIColor {
    convenience init?(hex: String?) {
        guard let hex = hex else { return nil }
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}


extension Color {
    init?(hex: String?) {
        guard let hex = hex else { return nil }
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b)
    }
}

private extension AutoCapitalize {
    var uiKit: UITextAutocapitalizationType {
        switch self {
        case .none: return .none
        case .words: return .words
        case .sentences: return .sentences
        case .characters: return .allCharacters
        @unknown default: return .sentences
        }
    }
}

private extension UITextAutocapitalizationType {
    var swiftUI: TextInputAutocapitalization {
        switch self {
        case .none: return .never
        case .words: return .words
        case .sentences: return .sentences
        case .allCharacters: return .characters
        @unknown default: return .sentences
        }
    }
}

private final class WeakBox<T> {
    let getter: () -> T?
    init(_ getter: @escaping () -> T?) { self.getter = getter }
}
