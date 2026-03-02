import Foundation

enum MagicState: Equatable {
    case idle
    case armed(storedNumber: String)
}
