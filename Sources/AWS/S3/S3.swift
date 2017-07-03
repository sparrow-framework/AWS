import HTTP
import Core
import Media

public struct Bucket : MediaDecodable {
    let name: String
    let creationDate: String
    
    enum Key : String, CodingKey {
        case name = "Name"
        case creationDate = "CreationDate"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        name = try container.decode(String.self, forKey: .name)
        creationDate = try container.decode(String.self, forKey: .creationDate)
    }
}

public struct Buckets : MediaDecodable {
    let buckets: [Bucket]
    
    enum Key : String, CodingKey {
        case buckets = "Bucket"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        buckets = try container.decode([Bucket].self, forKey: .buckets)
    }
}

public struct Owner : MediaDecodable {
    let id: String
    let displayName: String
    
    enum Key : String, CodingKey {
        case id = "ID"
        case displayName = "DisplayName"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        id = try container.decode(String.self, forKey: .id)
        displayName = try container.decode(String.self, forKey: .displayName)
    }
}

public struct ListBucketsResult : MediaDecodable {
    let owner: Owner
    let buckets: Buckets
    
    enum Key : String, CodingKey {
        case owner = "Owner"
        case buckets = "Buckets"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        owner = try container.decode(Owner.self, forKey: .owner)
        buckets = try container.decode(Buckets.self, forKey: .buckets)
    }
}

public final class S3 {
    private let client: AWSClient
    public var defaultRegion: Region = .usEast1
    
    public init(accessKeyID: String, secretAcessKey: String) throws {
        client = try AWSClient(
            accessKeyID: accessKeyID,
            secretAcessKey: secretAcessKey,
            service: .s3
        )
    }
    
    public func listBuckets() throws -> ListBucketsResult {
        let request = try Request(
            method: .get,
            uri: "https://s3.amazonaws.com/",
            headers: [
                "Host": "s3.amazonaws.com",
                "Accept": "application/json",
                "x-amz-content-sha256": client.getHashedRequestPayload()
            ]
        )
        
        let response = try client.send(request, region: .usEast1)
        let listBuckets: XMLResult<ListBucketsResult> = try response.content(userInfo: [.resultKey: "ListAllMyBucketsResult"])
        return listBuckets.result
    }
}
