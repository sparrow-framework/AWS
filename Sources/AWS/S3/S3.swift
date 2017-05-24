import HTTP
import Core
import Content

public struct ListBucketsResult : XMLInitializable {
    let owner: Owner
    let buckets: [Bucket]
    
    public init(xml: XML) throws {
        owner = try xml.get("Owner")
        buckets = try xml.get("Buckets", "Bucket")
    }
}

public struct Bucket : XMLInitializable {
    let name: String
    let creationDate: String
    
    public init(xml: XML) throws {
        name = try xml.get("Name")
        creationDate = try xml.get("CreationDate")
    }
}

public struct Owner : XMLInitializable {
    let id: String
    let displayName: String
    
    public init(xml: XML) throws {
        id = try xml.get("ID")
        displayName = try xml.get("DisplayName")
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
            uri: "/",
            headers: [
                "Accept": "application/json",
                "x-amz-content-sha256": client.getHashedRequestPayload()
            ]
        )
        
        let response = try client.send(request, region: .usEast1)
        let xml: XML = try response.content()
        print(xml)
        return try ListBucketsResult(xml: xml)
    }
}