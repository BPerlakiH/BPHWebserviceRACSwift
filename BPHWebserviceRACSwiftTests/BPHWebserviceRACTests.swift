//
//  BPHWebserviceRACTests.swift
//  BPHWebserviceRACSwift
//
//  Created by Balazs Perlaki-Horvath on 09/03/17.
//  Copyright © 2017 perlakidigital. All rights reserved.
//

@testable import BPHWebserviceRACSwift
import Foundation
import RxSwift
import XCTest

class BPHWebserviceRACTests: XCTestCase {

    private var webservice: BPHWebserviceRAC = BPHWebserviceRAC(baseURI: "https://jsonplaceholder.typicode.com")

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func myJust<E>(element: E) -> Observable<E> {
        return Observable.create { observer in
            sleep(1)
            observer.on(.next(element))
            observer.on(.completed)
            return Disposables.create()
        }
    }

    func getObserver<E>(element: E) -> Observable<E> {
        return myJust(element: element)
    }

    func testObservers() {
        let expectation: XCTestExpectation = self.expectation(description: "Async get request")
        let _ = self.getObserver(element: 0)
            .subscribeOn(SerialDispatchQueueScheduler(internalSerialQueueName: "testQueue"))
            .subscribe(onNext: { n in
                XCTAssertEqual(n, 0)
                expectation.fulfill()
            })
        self.waitForExpectations(timeout: 20) { (error: Error?) in
            if error != nil {
                XCTFail(error!.localizedDescription)
            }
        }
    }

    func testGetRequest() {
        let expectation: XCTestExpectation = self.expectation(description: "Async get request")
        let _ = self.webservice.get(method: "comments/1")
                .observeOn(MainScheduler.instance)
                .subscribeOn(SerialDispatchQueueScheduler(internalSerialQueueName: "webservices"))
            .subscribe(onNext: {resultData in
                if let data = resultData as? Dictionary<String, Any> {
                    XCTAssertNotNil(data)
                    XCTAssertEqual(data["postId"] as? Int32, 1)
                    XCTAssertEqual(data["id"] as? Int32, 1)
                    XCTAssertEqual(data["name"] as? String, "id labore ex et quam laborum")
                    XCTAssertEqual(data["email"] as? String, "Eliseo@gardner.biz")
                    XCTAssertEqual(data["body"] as? String,
                                    "laudantium enim quasi est quidem magnam voluptate ipsam eos\n" +
                                    "tempora quo necessitatibus\n" +
                                    "dolor quam autem quasi\nreiciendis et nam sapiente accusantium")
                    expectation.fulfill()
                }
            })
        self.waitForExpectations(timeout: 5) { (error: Error?) in
            if error != nil {
                XCTFail(error!.localizedDescription)
            }
        }
    }

    func testPostRequest() {
        let expectation: XCTestExpectation = self.expectation(description: "Async get request")
        let title = "some title"
        let body = "quasi laudantium quidem enim est magnam voluptate ipsam eos\n\n\tnecessitatibus"
        let _ = self.webservice.post(method: "posts", arguments: ["data": ["title": title, "body": body, "userId": 1]])
            .observeOn(MainScheduler.instance)
            .subscribeOn(SerialDispatchQueueScheduler(internalSerialQueueName: "webservices"))
            .subscribe(onNext: {resultData in
                if let result = resultData as? [String: Any] {
                    print(result)
                    XCTAssertNotNil(result)
                    XCTAssertEqual(result["id"] as? Int32, 101)

                    XCTAssertNotNil(result["data"])
                    if let data: [String: Any] = result["data"] as? [String: Any] {

                        XCTAssertEqual(data["title"] as? String, title)
                        XCTAssertEqual(data["body"] as? String, body)
                        expectation.fulfill()
                    } else {
                        XCTFail("malformed result.data: \n\(result)")
                    }
                } else {
                    XCTFail("no result found")
                }
            })
        self.waitForExpectations(timeout: 5) { (error: Error?) in
            if error != nil {
                XCTFail(error!.localizedDescription)
            }
        }

    }

}
