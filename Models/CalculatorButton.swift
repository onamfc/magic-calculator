import SwiftUI

enum CalculatorButton: String, Hashable, Identifiable {
    case ac, plusMinus, percent
    case divide, multiply, subtract, add, equals
    case seven, eight, nine
    case four, five, six
    case one, two, three
    case zero, decimal

    var id: String { rawValue }

    var label: String {
        switch self {
        case .ac: return "AC"
        case .plusMinus: return "+/\u{2212}"
        case .percent: return "%"
        case .divide: return "\u{00F7}"
        case .multiply: return "\u{00D7}"
        case .subtract: return "\u{2212}"
        case .add: return "+"
        case .equals: return "="
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        case .zero: return "0"
        case .decimal: return "."
        }
    }

    var digitValue: String? {
        switch self {
        case .zero: return "0"
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        default: return nil
        }
    }

    var buttonType: ButtonType {
        switch self {
        case .ac, .plusMinus, .percent:
            return .function
        case .divide, .multiply, .subtract, .add, .equals:
            return .operation
        default:
            return .number
        }
    }

    var backgroundColor: Color {
        switch buttonType {
        case .function: return Color(hex: "A5A5A5")
        case .operation: return Color(hex: "FF9500")
        case .number: return Color(hex: "333333")
        }
    }

    var foregroundColor: Color {
        switch buttonType {
        case .function: return .black
        case .operation, .number: return .white
        }
    }

    var isWide: Bool { self == .zero }

    enum ButtonType {
        case number, operation, function
    }

    static let layout: [[CalculatorButton]] = [
        [.ac, .plusMinus, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .subtract],
        [.one, .two, .three, .add],
        [.zero, .decimal, .equals],
    ]
}
