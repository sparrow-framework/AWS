import XCTest
import AWS
import Foundation

public class AWSTests: XCTestCase {
    func testListBuckets() throws {
        let s3 = try S3(
            accessKeyID: "insert your access key id",
            secretAcessKey: "insert your secret access key here"
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
