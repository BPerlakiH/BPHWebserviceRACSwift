//
//  BPHWebServiceHelperTests.swift
//  BPHWebserviceRACSwift
//
//  Created by Balazs Perlaki-Horvath on 02/03/17.
//  Copyright © 2017 perlakidigital. All rights reserved.
//

@testable import BPHWebserviceRACSwift
import XCTest

class WSHelperTest: XCTestCase {

    let method = "posts"
    let helper = WSHelper(baseURI: "https://jsonplaceholder.typicode.com")

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetKeys() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let argument = ["page": 1]
        let arguments = ["page": 1, "limit": 10]

        let methodOnlyKey = helper.getKeyFor(method: method)
        let methodAndParamKey = helper.getKeyFor(method: method, arguments: argument)
        let methodAndParamsKey = helper.getKeyFor(method: method, arguments: arguments)
        XCTAssertNotNil(methodOnlyKey)
        XCTAssertEqual(methodOnlyKey, method) //pure method calls should have the method as the key
        XCTAssertNotNil(methodAndParamKey)
        XCTAssertNotNil(methodAndParamsKey)
        XCTAssertNotEqual(methodOnlyKey, methodAndParamKey)
        XCTAssertNotEqual(methodOnlyKey, methodAndParamsKey)
        XCTAssertNotEqual(methodAndParamKey, methodAndParamsKey)

        //ensure difference in params or values creates different results
        let staticValue = "startValue"
        let dynamicValues = [("page", "rage")]
        dynamicValues.forEach { dValue1, dValue2 in
            let result1 = helper.getKeyFor(method: method, arguments: [dValue1: staticValue])
            let result2 = helper.getKeyFor(method: method, arguments: [dValue2: staticValue])
            let result3 = helper.getKeyFor(method: method, arguments: [staticValue: dValue1])
            let result4 = helper.getKeyFor(method: method, arguments: [staticValue: dValue2])
            XCTAssertNotEqual(result1, result2)
            XCTAssertNotEqual(result1, result3)
            XCTAssertNotEqual(result1, result4)

            XCTAssertNotEqual(result2, result3)
            XCTAssertNotEqual(result2, result4)

            XCTAssertNotEqual(result3, result4)
        }
    }

    func testQueryBuilding() {
        let testValues = [
            (["page": 1], "?page=1"),
            (["page": 2], "?page=2"),
            (["page": 1, "limit": 2], "?page=1&limit=2"),
            (["testing": false, "limit": "2", "pages": "All"], "?testing=false&limit=2&pages=All"),
            (["lat": 54.1199, "lon": 51.1399], "?lat=54.1199&lon=51.1399")
        ]
        testValues.forEach { (arguments, expValue) in
            XCTAssertEqual(helper.toQueryString(arguments: arguments), expValue)
        }
    }

    func testRequestCreation() {
        helper.baseURI = "https://test.com"
        //GET
        let getRequest: URLRequest = helper.get(method: method, arguments: nil)
        XCTAssertEqual(getRequest.httpMethod, "GET")

        do {
            let args = ["title": "foo", "body": "bar", "userId": 1] as [String : Any]
            let postRequest: URLRequest = try helper.post(method: method, arguments: args)
            XCTAssertEqual(postRequest.httpMethod, "POST")
        } catch {
            XCTFail("invalid post request")
        }
    }

}
