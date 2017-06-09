import XCTest
import AWS
import Foundation
import Core

public class AWSTests: XCTestCase {
    func testListBuckets() throws {
        let s3 = try S3(
            accessKeyID: try Environment.variable("AWS_ACCESS_KEY_ID"),
            secretAcessKey: try Environment.variable("AWS_SECRET_ACCESS_KEY")
        )
        
        s3.defaultRegion = .saEast1
        let list = try s3.listBuckets()
        print(list)
    }
}

extension AWSTests {
    public static var allTests: [(String, (AWSTests) -> () throws -> Void)] {
        return [
            ("testListBuckets", testListBuckets),
        ]
    }
}
