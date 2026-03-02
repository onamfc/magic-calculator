import Foundation
import Observation

@Observable
class CalculatorViewModel {

    // MARK: - Display State

    var displayText: String = "0"
    var showClear: Bool = false
    var highlightedOperator: CalculatorButton? = nil

    // MARK: - Calculator Internal State

    private var accumulator: Double = 0
    private var pendingOperation: ArithmeticOperation? = nil
    private var isTypingNumber: Bool = false
    private var rawInput: String = "0"
    private var justPressedEquals: Bool = false
    private var lastOperation: ArithmeticOperation? = nil
    private var lastOperand: Double? = nil

    // MARK: - Magic Mode

    private var magicState: MagicState = .idle
    private var acTapTimestamps: [Date] = []
    private var lastClearedValue: String? = nil
    private static let tripleTapWindow: TimeInterval = 1.5

    // MARK: - Public Interface

    func buttonPressed(_ button: CalculatorButton) {
        switch button {
        case .ac:
            handleACOrClear()
        case .plusMinus:
            toggleSign()
        case .percent:
            applyPercent()
        case .decimal:
            appendDecimal()
        case .add:
            setOperation(.add, highlight: .add)
        case .subtract:
            setOperation(.subtract, highlight: .subtract)
        case .multiply:
            setOperation(.multiply, highlight: .multiply)
        case .divide:
            setOperation(.divide, highlight: .divide)
        case .equals:
            evaluateEquals()
        default:
            if let digit = button.digitValue {
                appendDigit(digit)
            }
        }
    }

    // MARK: - Digit Input

    private func appendDigit(_ digit: String) {
        if justPressedEquals {
            fullClear()
            justPressedEquals = false
        }

        if isTypingNumber {
            let rawDigits = rawInput.replacingOccurrences(of: ",", with: "")
            guard rawDigits.count < 9 || rawDigits.contains(".") else { return }
            rawInput += digit
        } else {
            rawInput = digit
            isTypingNumber = true
        }

        displayText = formatTypingDisplay(rawInput)
        showClear = true
        highlightedOperator = nil
    }

    private func appendDecimal() {
        if justPressedEquals {
            fullClear()
            justPressedEquals = false
        }

        if !isTypingNumber {
            rawInput = "0."
            isTypingNumber = true
        } else if !rawInput.contains(".") {
            rawInput += "."
        } else {
            return
        }

        displayText = formatTypingDisplay(rawInput)
        showClear = true
        highlightedOperator = nil
    }

    // MARK: - Operations

    private func setOperation(_ operation: ArithmeticOperation, highlight: CalculatorButton) {
        if isTypingNumber && pendingOperation != nil {
            let currentValue = parseDisplay()
            let result = pendingOperation!.perform(accumulator, currentValue)
            accumulator = result
            displayText = formatNumber(result)
        } else {
            accumulator = parseDisplay()
        }

        pendingOperation = operation
        isTypingNumber = false
        justPressedEquals = false
        highlightedOperator = highlight
    }

    private func evaluateEquals() {
        // Magic reveal
        if case .armed(let storedNumber) = magicState {
            displayText = storedNumber
            magicState = .idle
            isTypingNumber = false
            pendingOperation = nil
            accumulator = 0
            highlightedOperator = nil
            showClear = true
            justPressedEquals = true
            lastOperation = nil
            lastOperand = nil
            return
        }

        let currentValue = parseDisplay()

        if let op = pendingOperation {
            let result = op.perform(accumulator, currentValue)
            lastOperation = op
            lastOperand = currentValue
            accumulator = result
            displayText = formatNumber(result)
            pendingOperation = nil
        } else if let op = lastOperation, let operand = lastOperand {
            let result = op.perform(currentValue, operand)
            accumulator = result
            displayText = formatNumber(result)
        }

        isTypingNumber = false
        highlightedOperator = nil
        justPressedEquals = true
        showClear = true
    }

    // MARK: - Function Buttons

    private func toggleSign() {
        if isTypingNumber {
            if rawInput.hasPrefix("-") {
                rawInput = String(rawInput.dropFirst())
            } else if rawInput != "0" {
                rawInput = "-" + rawInput
            }
            displayText = formatTypingDisplay(rawInput)
        } else {
            let value = parseDisplay()
            if value != 0 {
                let toggled = -value
                accumulator = toggled
                displayText = formatNumber(toggled)
            }
        }
    }

    private func applyPercent() {
        let value = parseDisplay()
        let result = value / 100.0
        if isTypingNumber {
            rawInput = String(result)
            isTypingNumber = false
        }
        accumulator = result
        displayText = formatNumber(result)
    }

    // MARK: - AC / Clear + Magic Detection

    private func handleACOrClear() {
        // Capture display value before any clearing (for magic detection)
        if displayText != "0" && displayText != "Error" {
            lastClearedValue = displayText
        }

        if showClear {
            // "C" mode: clear current entry only
            displayText = "0"
            rawInput = "0"
            isTypingNumber = false
            showClear = false
        } else {
            // "AC" mode: full clear
            fullClear()
        }

        // Disarm magic if armed
        if case .armed = magicState {
            magicState = .idle
            acTapTimestamps.removeAll()
            return
        }

        // Triple-tap detection (both C and AC taps count)
        let now = Date()
        acTapTimestamps.append(now)
        acTapTimestamps = acTapTimestamps.filter {
            now.timeIntervalSince($0) <= Self.tripleTapWindow
        }

        if acTapTimestamps.count >= 3 {
            if let stored = lastClearedValue, !stored.isEmpty {
                magicState = .armed(storedNumber: stored)
            }
            acTapTimestamps.removeAll()
            lastClearedValue = nil
        }
    }

    private func fullClear() {
        displayText = "0"
        rawInput = "0"
        accumulator = 0
        pendingOperation = nil
        isTypingNumber = false
        showClear = false
        highlightedOperator = nil
        justPressedEquals = false
        lastOperation = nil
        lastOperand = nil
    }

    // MARK: - Number Formatting

    private func parseDisplay() -> Double {
        let cleaned = displayText
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "\u{2212}", with: "-")
        return Double(cleaned) ?? 0
    }

    private func formatNumber(_ value: Double) -> String {
        if value.isNaN || value.isInfinite {
            return "Error"
        }

        // Check if value is effectively an integer
        if value == value.rounded() && abs(value) < 1e15 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            formatter.usesGroupingSeparator = true
            return formatter.string(from: NSNumber(value: value)) ?? "Error"
        }

        let formatter = NumberFormatter()

        if abs(value) >= 1e9 || (abs(value) < 1e-8 && value != 0) {
            formatter.numberStyle = .scientific
            formatter.maximumSignificantDigits = 6
            formatter.exponentSymbol = "e"
        } else {
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 8
            formatter.minimumFractionDigits = 0
            formatter.usesGroupingSeparator = true
        }

        return formatter.string(from: NSNumber(value: value)) ?? "Error"
    }

    private func formatTypingDisplay(_ raw: String) -> String {
        let isNegative = raw.hasPrefix("-")
        let unsigned = isNegative ? String(raw.dropFirst()) : raw

        let parts = unsigned.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        guard let integerPart = parts.first else { return raw }

        let digits = String(integerPart)
        var result = ""
        for (i, char) in digits.reversed().enumerated() {
            if i > 0 && i % 3 == 0 { result = "," + result }
            result = String(char) + result
        }

        if isNegative { result = "-" + result }

        if parts.count == 2 {
            result += "." + String(parts[1])
        } else if raw.hasSuffix(".") {
            result += "."
        }

        return result
    }
}
