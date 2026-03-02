import SwiftUI

struct DisplayView: View {
    let text: String

    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .font(.system(size: 80, weight: .thin))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .padding(.trailing, 24)
        }
    }
}
