# Magic Calculator

A sleek iOS calculator app with a hidden trick up its sleeve — triple-tap the clear button to recover your last cleared number.

## Features

**Full-Featured Calculator**
- Addition, subtraction, multiplication, and division
- Decimal input, sign toggle (+/-), and percentage
- Operation chaining (e.g. `5 + 3 × 2` evaluates sequentially)
- Repeat last operation by pressing `=` again
- Smart number formatting with comma separators
- Scientific notation for very large or very small results
- Division by zero error handling

**Magic Mode (The Secret)**
1. Enter any number and perform some calculations
2. Press **AC/C three times quickly** (within 1.5 seconds) to arm magic mode
3. Press **=** to reveal the last number you cleared
4. Press **AC** again to disarm without revealing

A hidden recovery feature disguised as a normal calculator.

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Language | Swift 5 |
| UI Framework | SwiftUI |
| State Management | `@Observable` (Observation framework) |
| Architecture | MVVM |
| Dependencies | None — pure Apple frameworks |

## Requirements

- iOS 17.0+
- Xcode 15.0+

## Project Structure

```
MagicCalculator/
├── MagicCalculatorApp.swift           # App entry point
├── Models/
│   ├── CalculatorButton.swift         # Button definitions, layout grid, and styling
│   ├── ArithmeticOperation.swift      # +, −, ×, ÷ with evaluation logic
│   └── MagicState.swift               # Magic mode state (.idle / .armed)
├── ViewModels/
│   └── CalculatorViewModel.swift      # All calculator logic and magic detection
├── Views/
│   ├── CalculatorView.swift           # Main layout with responsive sizing
│   ├── DisplayView.swift              # Number display with auto-scaling text
│   └── CalculatorButtonView.swift     # Button component with press animation
├── Extensions/
│   └── Color+Hex.swift                # Hex color initializer
└── Assets.xcassets/                   # App icon and accent color
```

## Architecture

The app follows **MVVM** with a single `CalculatorViewModel` driving all state:

- **Models** define the data — button types, operations, and magic state as enums
- **ViewModel** owns the calculator logic: input handling, arithmetic evaluation, number formatting, and triple-tap detection
- **Views** are thin SwiftUI components that read from the `@Observable` view model

State flows one direction: user taps a button → view model processes input → published properties update the UI.

## Building & Running

1. Clone the repository
   ```bash
   git clone https://github.com/onamfc/magic-calculator.git
   ```
2. Open `MagicCalculator.xcodeproj` in Xcode
3. Select an iOS 17+ simulator or device
4. Build and run (`Cmd + R`)

## How It Works

### Calculator Engine

The view model maintains an accumulator, a pending operation, and raw input state. When the user chains operations (e.g. `12 + 8 - 3`), intermediate results are computed as each new operator is pressed. The `=` button finalizes the calculation and stores the last operation/operand for repeat evaluation.

### Number Formatting

- **While typing:** commas are inserted into the integer portion in real time
- **After evaluation:** integers display with commas, decimals show up to 8 digits, and values beyond ±1×10⁹ switch to scientific notation

### Magic Detection

The AC/C button tracks tap timestamps in a sliding 1.5-second window. When three taps land within that window, the last non-zero cleared display value is captured and magic mode arms. The next press of `=` reveals it. Pressing AC while armed disarms silently.

## License

This project is available for personal and educational use.
