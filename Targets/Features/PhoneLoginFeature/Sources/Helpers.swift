import Foundation

extension Optional where Wrapped == String {
    var isNonEmpty: Bool {
        switch self {
        case .none: return false
        case let .some(wrapped): return !wrapped.isEmpty
        }
    }
}
