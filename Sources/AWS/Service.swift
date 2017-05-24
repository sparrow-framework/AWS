public enum Service {
    case s3
}

extension Service {
    public var value: String {
        switch self {
        case .s3:
            return "s3"
        }
    }
}
