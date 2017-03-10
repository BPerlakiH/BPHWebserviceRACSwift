//
//  BPHWebserviceRACSwiftTests.swift
//  BPHWebserviceRACSwiftTests
//
//  Created by Balazs Perlaki-Horvath on 15/12/16.
//  Copyright © 2016 perlakidigital. All rights reserved.
//

@testable import BPHWebserviceRACSwift
import XCTest

class BPHLocalCacheTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPrefixes() {
        //general ones
        XCTAssertNotNil(BPHLocalCache.prefix)

        //specific general ones
        let prefix = "tester.prefix.for.cache"
        BPHLocalCache.prefix = prefix
        XCTAssertEqual(BPHLocalCache.prefix, prefix)
        let specCache = BPHLocalCache()
        XCTAssertEqual(specCache.prefix, prefix)

        //individual one
        let indivPrefix = "individual.cache.prefix.test"
        let indivCache = BPHLocalCache(prefixValue: indivPrefix)
        XCTAssertEqual(indivCache.prefix, indivPrefix)
    }

    func testCachePaths() {
        let cache = BPHLocalCache()
        XCTAssertNotNil(cache.diskPath)

        let stringData = "test data".data(using: String.Encoding.utf8)!
        let path = cache.diskPath.appending("test_file.txt")
        let canTouch = FileManager.default.createFile(atPath: path, contents: stringData, attributes: nil)
        XCTAssertTrue(canTouch)
    }

    func testCacheTime() {
        XCTAssertEqual(BPHLocalCache().validForSec, 3600)
    }

    func testCacheWriteAndRead() {
        let cache: BPHLocalCache = BPHLocalCache(prefixValue: "test_prefix_1")

        let cacheKey1 = "newCacheKey_1"
        let data1 = "testing some data no: 1".data(using: String.Encoding.utf8)!

        let cacheKey2 = "newCacheKey_2"
        let data2 = "testing some data no: 2".data(using: String.Encoding.utf8)!

        //read
        XCTAssertFalse(cache.isDataFor(key: cacheKey1))
        XCTAssertFalse(cache.isDataFor(key: cacheKey2))

        //write
        cache.writeData(data: data1, key: cacheKey1)
        //read
        XCTAssertTrue(cache.isDataFor(key: cacheKey1))
        XCTAssertEqual(cache.getDataFor(key: cacheKey1), data1)
        XCTAssertNotEqual(cache.getDataFor(key: cacheKey1), data2)

        //overwrite
        cache.writeData(data: data2, key: cacheKey1)

        //read
        XCTAssertTrue(cache.isDataFor(key: cacheKey1))
        XCTAssertEqual(cache.getDataFor(key: cacheKey1), data2)
        XCTAssertNotEqual(cache.getDataFor(key: cacheKey1), data1)

        //delete
        cache.deleteDataFor(key: cacheKey1)
        cache.deleteDataFor(key: cacheKey2)

        //read
        XCTAssertFalse(cache.isDataFor(key: cacheKey1))
        XCTAssertFalse(cache.isDataFor(key: cacheKey2))
    }

    func testCacheValidTime() {
        let cache: BPHLocalCache = BPHLocalCache(prefixValue: "test_prefix_1", validForSecValue: 3)
        let testData = "yrdfhjfj6786t".data(using: String.Encoding.unicode)
        let testKey = "my custom key"
        cache.writeData(data: testData!, key: testKey)

        XCTAssertTrue(cache.isDataFor(key: testKey))

        sleep(2)
        XCTAssertTrue(cache.isDataFor(key: testKey))

        sleep(2)
        //should be invalid after 2sec
        XCTAssertFalse(cache.isDataFor(key: testKey))
        cache.deleteDataFor(key: testKey)
        XCTAssertFalse(cache.isDataFor(key: testKey))
    }
}
