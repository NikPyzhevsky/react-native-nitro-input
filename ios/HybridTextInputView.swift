import Foundation
import NitroModules
import SwiftUI

// MARK: - SwiftUI TextField View
struct SwiftUITextField: View {
    @Binding var text: String
    var placeholder: String?
    var allowFontScaling: Bool
    var autoCapitalize: UITextAutocapitalizationType
    var autoCorrect: UITextAutocorrectionType

    var backgroundColor: Color
    var textColor: Color
    var cursorColor: UIColor

    var body: some View {
        TextField(placeholder ?? "", text: $text)
            .font(.body)
            .foregroundColor(textColor)
//            .multilineTextAlignment(.center)
            .autocapitalization(autoCapitalize)
            .disableAutocorrection(autoCorrect == .no)
            .padding(0)
            .cornerRadius(0)
            .tint(Color(cursorColor)) // SwiftUI 3+
    }
}

// MARK: - UIKit Wrapper for Nitro
class HybridTextInputView: HybridNitroTextInputViewSpec {
    var value: String?

    var onChangeText: ((String) -> Void)?

    @State private var text: String = ""
    var backgroundColor: String?
    var textColor: String?
    var cursorColor: String?

    private lazy var hostingController: UIHostingController<SwiftUITextField> = {
        let textBinding = Binding(
            get: { self.value ?? "" },
            set: { newValue in
                self.value = newValue
                self.onChangeText?(newValue)
            }
        )

        let bgColor = Color(hex: self.backgroundColor) ?? .white
        let fgColor = Color(hex: self.textColor) ?? .black
        let caretColor = UIColor(hex: self.cursorColor) ?? .blue

        let swiftUIView = SwiftUITextField(
            text: textBinding,
            placeholder: self.placeholder,
            allowFontScaling: self.allowFontScaling ?? true,
            autoCapitalize: .sentences,
            autoCorrect: .default,
            backgroundColor: bgColor,
            textColor: fgColor,
            cursorColor: caretColor
        )

        let controller = UIHostingController(rootView: swiftUIView)
        controller.view.backgroundColor = .clear
        return controller
    }()
//    override init() {
//        let textBinding = Binding(
//            get: { self.value ?? "" },
//            set: { newValue in
//                self.value = newValue
//                self.onChangeText?(newValue)
//            }
//        )
//
//
//        let bgColor = Color(hex: backgroundColor) ?? Color.white
//        let fgColor = Color(hex: textColor) ?? Color.black
//        let caretColor = UIColor(hex: cursorColor) ?? .blue
//
//        let swiftUIView = SwiftUITextField(
//            text: textBinding,
//            placeholder: nil,
//            allowFontScaling: true,
//            autoCapitalize: .sentences,
//            autoCorrect: .default,
//            backgroundColor: bgColor,
//            textColor: fgColor,
//            cursorColor: caretColor
//        )
//
//        self.hostingController = UIHostingController(rootView: swiftUIView)
//        self.hostingController.view.backgroundColor = .clear // 🔥 важно!
//        super.init()
//    }

    var view: UIView {
        return hostingController.view
    }

    // Props
    var allowFontScaling: Bool? = true
    var autoCapitalize: AutoCapitalize?
    var autoCorrect: Bool? = true
    var placeholder: String?
    var multiline: Bool? = false
}

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
