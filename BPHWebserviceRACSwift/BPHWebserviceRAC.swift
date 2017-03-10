//
//  WebserviceRAC.swift
//  BPHWebserviceRACSwift
//
//  Created by Balazs Perlaki-Horvath on 06/03/17.
//  Copyright © 2017 perlakidigital. All rights reserved.
//

import Foundation
import RxSwift

class BPHWebserviceRAC {

    public static var cookieStorage: HTTPCookieStorage?
    private var baseURI: String = ""
    private var helper: BPHWSHelper

    init(baseURI: String) {
        self.baseURI = baseURI
        self.helper = BPHWSHelper(baseURI: baseURI)
    }

    public func get(method: String) -> Observable<Any> {
        let request = self.helper.get(method: method, arguments: nil)
        print("requesting: ", request.url!.absoluteString)
        return self.getObservableFromRequest(request: request)
    }

    public func post(method: String, arguments: [AnyHashable: Any]?) -> Observable<Any> {
        do {
            let request = try self.helper.post(method: method, arguments: arguments)
            return self.getObservableFromRequest(request: request)
        } catch let error {
            return Observable.error(error)
        }
    }

    private func getObservableFromRequest(request: URLRequest) -> Observable<Any> {
        return Observable.create { observer in
            let session: URLSession = URLSession.shared
            //set the cookie storage if any
            URLSessionConfiguration.default.httpCookieStorage = BPHWebserviceRAC.cookieStorage
            let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                if error != nil {
                    observer.on(.error(error!))
                } else if data == nil {
                    observer.on(.error(NSError(domain:"BPHWebserviceRAC", code: 520, userInfo: ["error": "data nil"])))
                } else if response is HTTPURLResponse {
                    let urlResponse = response as? HTTPURLResponse
                    let httpCode = urlResponse!.statusCode
                    if 200 <= httpCode && httpCode < 300 {
                        do {
                            let returnObj = try JSONSerialization.jsonObject(with: data!, options: [])
                            observer.on(.next(returnObj))
                            observer.on(.completed)
                        } catch let error {
                            observer.on(.error(error))
                        }
                    } else {
                        observer.on(.error(NSError(
                            domain: "BPHWebserviceRAC",
                            code: httpCode,
                            userInfo: ["error": response.debugDescription]))
                        )
                    }
                }
            })
            task.resume()
            return Disposables.create()
        }
    }
}
