//
//  BPHLocalCache.swift
//  BPHWebserviceRACSwift
//
//  Created by Balazs Perlaki-Horvath on 15/12/16.
//  Copyright © 2016 perlakidigital. All rights reserved.
//

import CryptoSwift
import Foundation

class BPHLocalCache {

    //prefix
    static public var prefix: String = "CacheGeneral"
    var prefix: String = BPHLocalCache.prefix
    public var validForSec: Int64 = 60 * 60 //1 hour by default

    //diskPath
    lazy public var diskPath: String = {
        var path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path = path.appendingFormat("/%@", prefix)
        var isDir: ObjCBool = true
        if(!FileManager.default.fileExists(atPath: path, isDirectory: &isDir)) {
            try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }()

    init() {
    }

    init(prefixValue: String) {
        prefix = prefixValue
    }

    init(prefixValue: String, validForSecValue: Int64) {
        prefix = prefixValue
        validForSec = validForSecValue
    }

    public func writeData(data: Data, key: String) {
        let filePath = _getFileNameFor(key: key)
        deleteDataFor(key: key) //delete if there was anything there before
        FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
    }

    public func isDataFor(key: String) -> Bool {
        let filePath = _getFileNameFor(key: key)
        let isReadable = FileManager.default.isReadableFile(atPath: filePath)
        if !isReadable {
            return false
        }
        do {
            let attribs = try FileManager.default.attributesOfItem(atPath: filePath)
            let modDate = attribs[FileAttributeKey.modificationDate] as? Date
            if Date().timeIntervalSince(modDate!).isLess(than: Double(validForSec)) {
                return true
            }
        } catch {
            return false
        }
        return false
    }

    public func getDataFor(key: String) -> Data? {
        if !isDataFor(key: key) {
            return nil
        }
        return FileManager.default.contents(atPath: _getFileNameFor(key: key))
    }

    public func deleteDataFor(key: String) {
        try? FileManager.default.removeItem(atPath: _getFileNameFor(key: key))
    }

    private func _getFileNameFor(key: String) -> String {
        return diskPath.appendingFormat("/%@", key.md5())
    }
}
