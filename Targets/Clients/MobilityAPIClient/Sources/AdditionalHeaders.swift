import Foundation

enum AdditionalHeaders {
    static var defaultAcceptEncoding: (AnyHashable, Any) {
        return ("Dummy", NSObject())
    }

    static var defaultAcceptLanguage: (AnyHashable, Any) {
        return ("Dummy", NSObject())
    }

    static var defaultUserAgent: (AnyHashable, Any) {
        return ("Dummy", NSObject())
    }
}

extension Collection where Element == String {
    func qualityEncoded() -> String {
        ""
//        enumerated().map { index, encoding in
//            let quality = 1.0 - (Double(index) * 0.1)
//            return "\(encoding);q=\(quality)"
//        }.joined(separator: ", ")
    }
}
