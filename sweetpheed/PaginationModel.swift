//
//  PaginationModel.swift
//  sweetpheed
//
//  Created by Sergey Bavykin on 4/18/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import Foundation

struct PaginationModel {
    var currentPage = 0
    var perPage = 30
    
    init() {
        
    }
    
    init(perPage: Int) {
        self.perPage = perPage
    }
}

extension PaginationModel {
    func toDictionaryRepresentation() -> [String: CustomStringConvertible] {
        return [
            "page": currentPage,
            "per_page": perPage
        ]
    }
}

func += <K,V> (inout left: Dictionary<K,V>, right: Dictionary<K,V>?) {
    guard let right = right else {
        return
    }
    right.forEach {
        key, value in
        
        left.updateValue(value, forKey: key)
    }
}