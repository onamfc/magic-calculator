import SwiftUI

struct CalculatorView: View {
    @State private var viewModel = CalculatorViewModel()

    private let spacing: CGFloat = 12

    var body: some View {
        GeometryReader { geometry in
            let buttonSize = (geometry.size.width - spacing * 5) / 4

            VStack(spacing: spacing) {
                Spacer()

                DisplayView(text: viewModel.displayText)
                    .padding(.bottom, 8)

                ForEach(Array(CalculatorButton.layout.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: spacing) {
                        ForEach(row) { button in
                            CalculatorButtonView(
                                button: button,
                                size: buttonSize,
                                spacing: spacing,
                                showClear: viewModel.showClear,
                                isHighlighted: viewModel.highlightedOperator == button
                            ) {
                                viewModel.buttonPressed(button)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, spacing)
            .padding(.bottom, spacing)
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
}

#Preview {
    CalculatorView()
}
