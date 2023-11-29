//
//  Method.swift
//  UIKitViewer
//
//  Created by chamsol kim on 11/26/23.
//  Copyright © 2023 cskim. All rights reserved.
//

import Foundation

struct Method {
    let name: String
    let parameters: [Any]
    
    init(name: String, parameters: [Any] = []) {
        self.name = name
        self.parameters = parameters
    }
}
