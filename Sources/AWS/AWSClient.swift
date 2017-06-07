import Venice
import Core
import COpenSSL
import Foundation
import Crypto
@testable import HTTP

final class AWSClient {
//    let client: Client
    
    let accessKeyID: String
    let secretAcessKey: String
    let service: Service
    
    let buffer = UnsafeMutableRawBufferPointer.allocate(count: Int(EVP_MAX_MD_SIZE))
    
    lazy var dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd'T'HHmmssXXXXX"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    init(
        accessKeyID: String,
        secretAcessKey: String,
        service: Service
    ) throws {
        self.accessKeyID = accessKeyID
        self.secretAcessKey = secretAcessKey
        self.service = service
//        client = try Client(uri: "https://" + service.value + ".us-east-1.amazonaws.com/")
    }
    
    deinit {
        buffer.deallocate()
    }
    
    func getCanonicalURI(request: Request) -> String {
        return request.uri.path ?? "/"
    }
    
    func getCanonicalQueryString(request: Request) -> String {
        var string = ""
        var url = URLComponents()
        url.percentEncodedQuery = request.uri.query
        
        let items = (url.queryItems ?? []).sorted {
            ($0.name.utf8.first ?? 0) < ($1.name.utf8.first ?? 0)
        }
        
        for (index, item) in items.enumerated() {
            string += item.name
            string += "="
            string += item.value?.addingPercentEncoding(withAllowedCharacters: .urlAllowed) ?? ""
            
            if index < items.count - 1 {
                string += "&"
            }
        }
        
        return string
    }
    
    func getCanonicalHeaders(request: Request) -> String {
        var string = ""
        
        let headers = request.headers.map({ ($0.0.original.lowercased(), $0.1) }).sorted {
            $0.0 < $1.0
        }
        
        for (key, value) in headers {
            string += key
            string += ":"
            string += value.trimmed()
            string += "\n"
        }
        
        return string
    }
    
    func getSignedHeaders(headers: [Headers.Field]) -> String {
        let headers = headers.map({ $0.original.lowercased() }).sorted {
            $0 < $1
        }
        
        return headers.joined(separator: ";")
    }
    
    func getHashedRequestPayload() -> String {
        let hashedRequestPayload = Crypto.sha256("", buffer: buffer)
        return hashedRequestPayload.hexString
    }
    
    func getCanonicalRequest(request: Request, signedHeaders: [Headers.Field]) -> String {
        var string = request.method.description
        string += "\n"
        string += getCanonicalURI(request: request)
        string += "\n"
        string += getCanonicalQueryString(request: request)
        string += "\n"
        string += getCanonicalHeaders(request: request)
        string += "\n"
        string += getSignedHeaders(headers: signedHeaders)
        string += "\n"
        string += getHashedRequestPayload()
        return string
    }
    
    func getHashedCanonicalRequest(request: Request, signedHeaders: [Headers.Field]) -> String {
        let canonicalRequest = getCanonicalRequest(request: request, signedHeaders: signedHeaders)
        let hashedCanonicalRequest = Crypto.sha256(canonicalRequest, buffer: buffer)
        return hashedCanonicalRequest.hexString
    }
    
    func getCredentialScope(date: String, region: Region) -> String {
        var string = date
        string += "/"
        string += region.value
        string += "/"
        string += service.value
        string += "/aws4_request"
        return string
    }
    
    func getStringToSign(
        dateTime: String,
        date: String,
        region: Region,
        request: Request,
        signedHeaders: [Headers.Field]
    ) -> String {
        var string = "AWS4-HMAC-SHA256\n"
        string += dateTime
        string += "\n"
        string += getCredentialScope(date: date, region: region)
        string += "\n"
        string += getHashedCanonicalRequest(request: request, signedHeaders: signedHeaders)
        return string
    }
    
    func getSignatureKey(
        date: String,
        region: Region
    ) -> UnsafeRawBufferPointer {
        let dateKey = Crypto.hs256(date, key: "AWS4" + secretAcessKey, buffer: buffer)
        let regionKey = Crypto.hs256(region.value, key: dateKey, buffer: buffer)
        let serviceKey = Crypto.hs256(service.value, key: regionKey, buffer: buffer)
        return Crypto.hs256("aws4_request", key: serviceKey, buffer: buffer)
    }
    
    func sign(date: String, region: Region, stringToSign: String) -> String {
        let signatureKey = getSignatureKey(date: date, region: region)
        let signature = Crypto.hs256(stringToSign, key: signatureKey, buffer: buffer)
        return signature.hexString
    }
    
    func getSignature(
        dateTime: String,
        date: String,
        region: Region,
        request: Request,
        signedHeaders: [Headers.Field]
    ) -> String {
        let stringToSign = getStringToSign(
            dateTime: dateTime,
            date: date,
            region: region,
            request: request,
            signedHeaders: request.headers.fields
        )
        
        return sign(date: date, region: region, stringToSign: stringToSign)
    }
    
    func getAuthorizationHeader(
        dateTime: String,
        date: String,
        region: Region,
        request: Request,
        signedHeaders: [Headers.Field]
    ) -> String {
        var string = ""
        
        string += "AWS4-HMAC-SHA256 "
        string += "Credential=" + accessKeyID + "/" + getCredentialScope(date: date, region: region) + ", "
        string += "SignedHeaders=" + getSignedHeaders(headers: signedHeaders) + ", "
        
        string += "Signature=" + getSignature(
            dateTime: dateTime,
            date: date,
            region: region,
            request: request,
            signedHeaders: signedHeaders
        )
        
        return string
    }
    
    func authorize(_ request: Request, region: Region) {
        let today = Date()
        
        let dateTime = dateTimeFormatter.string(from: today)
        let date = String(dateTime.characters.prefix(8))
        
        request.headers["X-Amz-Date"] = dateTime
        
        let auth = getAuthorizationHeader(
            dateTime: dateTime,
            date: date,
            region: region,
            request: request,
            signedHeaders: request.headers.fields
        )
        
        request.authorization = auth
    }
    
    /// Adds the X-Amz-Date and Authorization headers and sends the request to AWS service.
    func send(_ request: Request, region: Region) throws -> Response {
        authorize(request, region: region)
        return try Client.send(request)
    }
}
