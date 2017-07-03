import Media

extension CodingUserInfoKey {
    static var resultKey = CodingUserInfoKey(rawValue: "resultKey")!
}

struct XMLResult<Result : MediaDecodable> : MediaDecodable {
    let result: Result
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)
        
        guard let key = decoder.userInfo[.resultKey] as? String else {
            throw DecodingError.keyNotFound(CodingUserInfoKey.resultKey.rawValue, DecodingError.Context())
        }
        
        result = try container.decode(Result.self, forKey: key)
    }
}
