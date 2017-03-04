//
//  BPHWebServiceHelper.swift
//  BPHWebserviceRACSwift
//
//  Created by Anna Perlaki-Horvath on 02/03/17.
//  Copyright © 2017 perlakidigital. All rights reserved.
//

import Foundation

class WSHelper {

    public var cachePolicy: NSURLRequest.CachePolicy = URLRequest.CachePolicy.reloadRevalidatingCacheData
    public var baseURI: String = ""
    public var timeout: Double = 5.0

    init(baseURI: String) {
        self.baseURI = baseURI
    }

    public func getKeyFor(method: String) -> String {
        return getKeyFor(method: method, arguments: nil)
    }

    public func getKeyFor(method: String, arguments: [AnyHashable: AnyHashable]? ) -> String {
        let reducedToString = arguments?.reduce(method, { (key, value) -> String in
            return String(key).appendingFormat("_%@", String(describing: value))
        })
        return reducedToString ?? method
    }

    public func get(method: String, arguments: [AnyHashable: AnyHashable]? ) -> URLRequest {
        var request = _getRequest(method: method)
        request.httpMethod = "GET"
        request.url?.appendPathComponent(toQueryString(arguments: arguments))
        return request
    }

    public func post(method: String, arguments: [AnyHashable: AnyHashable]? ) throws -> URLRequest {
        var request = _getRequest(method: method)
        request.httpMethod = "POST"
        try request.httpBody = JSONSerialization.data(withJSONObject: arguments!, options: [])
        return request
    }

    private func _getRequest(method: String) -> URLRequest {
        var url = URL(string: baseURI)!
        url.appendPathComponent(method)
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    public func toQueryString(arguments: [AnyHashable: AnyHashable]?) -> String {
        if arguments == nil {
            return ""
        }
        return arguments!.reduce("?", { (key, value) -> String in
            return String(key).appendingFormat("=%@", String(describing: value))
        })
    }
}
