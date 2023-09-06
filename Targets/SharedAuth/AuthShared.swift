public enum Credential {
    public typealias IDToken = String
    public typealias AccessToken = String
    public typealias Nonce = String
    public typealias VerificationID = String
    public typealias VerificationCode = String

    case google(IDToken, AccessToken)
    case apple(IDToken, Nonce)
    case phone(VerificationID, VerificationCode)
}
