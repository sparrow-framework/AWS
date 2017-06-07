public enum Service {
    case s3
    case sns
}

extension Service {
    public var value: String {
        switch self {
        case .s3:
            return "s3"
        case .sns:
            return "sns"
        }
    }
}
