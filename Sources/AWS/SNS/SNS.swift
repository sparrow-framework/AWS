import HTTP
import Core
import Content
import Foundation

public struct PublishResult : JSONInitializable {
    let messageID: UUID
    
    public init(json: JSON) throws {
        messageID = try json.get("MessageId")
    }
}

public struct ResponseMetadata : JSONInitializable {
    let requestID: UUID
    
    public init(json: JSON) throws {
        requestID = try json.get("RequestId")
    }
}

public struct PublishResponse : JSONInitializable {
    let publishResult: PublishResult
    let responseMetadata: ResponseMetadata
    
    public init(json: JSON) throws {
        publishResult = try json.get("PublishResponse", "PublishResult")
        responseMetadata = try json.get("PublishResponse", "ResponseMetadata")
    }
}

public final class SNS {
    private let client: AWSClient
    public var defaultRegion: Region = .usEast1
    
    public init(accessKeyID: String, secretAcessKey: String) throws {
        client = try AWSClient(
            accessKeyID: accessKeyID,
            secretAcessKey: secretAcessKey,
            service: .sns
        )
    }
    
    @discardableResult
    public func sendSMS(
        phoneNumber: String,
        message: String,
        region: Region = .usEast1
    ) throws -> PublishResponse {
        let phoneNumber = phoneNumber.addingPercentEncoding(withAllowedCharacters: .urlAllowed) ?? ""
        let message = message.addingPercentEncoding(withAllowedCharacters: .urlAllowed) ?? ""
        
        let request = try Request(
            method: .post,
            uri: "https://sns.\(region.value).amazonaws.com/?Action=Publish&PhoneNumber=\(phoneNumber)&Message=\(message)",
            headers: [
                "Host": "sns.\(region.value).amazonaws.com",
                "Accept": "application/json",
                "x-amz-content-sha256": client.getHashedRequestPayload()
            ]
        )
        
        let response = try client.send(request, region: region)
        let json: JSON = try response.content()
        return try PublishResponse(json: json)
    }
}
