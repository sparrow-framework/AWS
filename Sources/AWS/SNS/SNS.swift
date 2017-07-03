import HTTP
import Core
import Media
import Foundation

public struct PublishResult : MediaDecodable {
    let messageID: UUID
    
    enum Key : String, CodingKey {
        case messageID = "MessageId"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        messageID = try container.decode(UUID.self, forKey: .messageID)
    }
}

public struct ResponseMetadata : MediaDecodable {
    let requestID: UUID
    
    enum Key : String, CodingKey {
        case requestID = "RequestId"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        requestID = try container.decode(UUID.self, forKey: .requestID)
    }
    
}

public struct PublishResponse : MediaDecodable {
    let publishResult: PublishResult
    let responseMetadata: ResponseMetadata
    
    enum Key : String, CodingKey {
        case publishResult = "PublishResult"
        case responseMetadata = "ResponseMetadata"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        publishResult = try container.decode(PublishResult.self, forKey: .publishResult)
        responseMetadata = try container.decode(ResponseMetadata.self, forKey: .responseMetadata)
    }
}

public struct SendSMSResponse : MediaDecodable {
    let publishResponse: PublishResponse
    
    enum Key : String, CodingKey {
        case publishResponse = "PublishResponse"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        publishResponse = try container.decode(PublishResponse.self, forKey: .publishResponse)
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
    ) throws -> SendSMSResponse {
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
        return try response.content()
    }
}
