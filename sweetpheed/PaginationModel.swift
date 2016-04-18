//
//  PaginationModel.swift
//  sweetpheed
//
//  Created by Sergey Bavykin on 4/18/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import Foundation

struct PaginationModel {
    var currentPage: Int {
        mutating get {
            let oldVal = mutablePageID
            mutablePageID += perPage
            return oldVal
        }
    }
    var perPage: Int = 15
    private var mutablePageID = 0
    
    init() {
        
    }
    
    init(perPage: Int) {
        self.perPage = perPage
        mutablePageID = 0
    }
}

extension PaginationModel {
    func toDictionaryRepresentation() -> [String: CustomStringConvertible] {
        return [
            "page": mutablePageID,
            "perpage": perPage
        ]
    }
}