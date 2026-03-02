import Foundation

enum ArithmeticOperation {
    case add, subtract, multiply, divide

    func perform(_ a: Double, _ b: Double) -> Double {
        switch self {
        case .add: return a + b
        case .subtract: return a - b
        case .multiply: return a * b
        case .divide: return b == 0 ? .infinity : a / b
        }
    }
}
