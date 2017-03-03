//
//  BPHWebServiceHelper.swift
//  BPHWebserviceRACSwift
//
//  Created by Anna Perlaki-Horvath on 02/03/17.
//  Copyright © 2017 perlakidigital. All rights reserved.
//

import Foundation

class WSHelper {

    public func getKeyFor(method: String) -> String {
        return getKeyFor(method: method, arguments: nil)
    }

    public func getKeyFor(method: String, arguments: [AnyHashable: AnyHashable]? ) -> String {
        let reducedToString = arguments?.reduce(method, { (key, value) -> String in
            return String(key).appendingFormat("_%@", String(describing: value))
        })
        return reducedToString ?? method
    }
}
