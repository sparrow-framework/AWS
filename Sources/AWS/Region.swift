public enum Region {
    case usEast1
    case usWest1
    case usWest2
    case euWest1
    case euCentral1
    case apNortheast1
    case apNortheast2
    case apSouth1
    case apSoutheast1
    case apSoutheast2
    case saEast1
}

extension Region {
    public var value: String {
        switch self {
        case .usEast1:
            return "us-east-1"
        case .usWest1:
            return "us-west-1"
        case .usWest2:
            return "us-west-2"
        case .euWest1:
            return "eu-west-1"
        case .euCentral1:
            return "eu-central-1"
        case .apNortheast1:
            return "ap-northeast-1"
        case .apNortheast2:
            return "ap-northeast-2"
        case .apSouth1:
            return "ap-south-1"
        case .apSoutheast1:
            return "ap-southeast-1"
        case .apSoutheast2:
            return "ap-southeast-2"
        case .saEast1:
            return "sa-east-1"
        }
    }
}

extension Region : CustomStringConvertible {
    public var description: String {
        switch self {
        case .usEast1:
            return "US East (Virginia)"
        case .usWest1:
            return "US West (N. California)"
        case .usWest2:
            return "US West (Oregon)"
        case .euWest1:
            return "EU West (Ireland) "
        case .euCentral1:
            return "EU Central (Frankfurt)"
        case .apNortheast1:
            return "Asia Pacific (Tokyo)"
        case .apNortheast2:
            return "Asia Pacific (Seoul)"
        case .apSouth1:
            return "Asia Pacific (Mumbai)"
        case .apSoutheast1:
            return "Asia Pacific (Singapore)"
        case .apSoutheast2:
            return "Asia Pacific (Sydney)"
        case .saEast1:
            return "South America (Sao Paulo)"
        }
    }
}
