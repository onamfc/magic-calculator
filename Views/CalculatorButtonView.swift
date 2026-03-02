import SwiftUI

struct CalculatorButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

struct CalculatorButtonView: View {
    let button: CalculatorButton
    let size: CGFloat
    let spacing: CGFloat
    let showClear: Bool
    let isHighlighted: Bool
    let action: () -> Void

    private var displayLabel: String {
        if button == .ac {
            return showClear ? "C" : "AC"
        }
        return button.label
    }

    private var bgColor: Color {
        if isHighlighted { return .white }
        return button.backgroundColor
    }

    private var fgColor: Color {
        if isHighlighted { return Color(hex: "FF9500") }
        return button.foregroundColor
    }

    var body: some View {
        Button(action: action) {
            Text(displayLabel)
                .font(.system(size: 33, weight: .medium))
                .foregroundColor(fgColor)
                .frame(
                    width: button.isWide ? size * 2 + spacing : size,
                    height: size
                )
                .background(bgColor)
                .clipShape(Capsule())
        }
        .buttonStyle(CalculatorButtonStyle())
    }
}
