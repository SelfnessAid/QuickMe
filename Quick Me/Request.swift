//
//  Request.swift
//  Quick Me
//
//  Created by Abdul Wahib on 4/30/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import Foundation
import RealmSwift

class Request: Object {
    
    dynamic var clientId: String!
    dynamic var desc: String!
    dynamic var expectedDate: String! {
        didSet {
            date = NSDate.dateFromString(expectedDate)
        }
    }
    dynamic var location: String!
    dynamic var msgType: String!
    dynamic var name: String!
    dynamic var phoneNumber: String!
    dynamic var price: String! {
        didSet {
            doublePrice = Double(price)!
        }
    }
    dynamic var requestId: String!
    
    dynamic var doublePrice: Double = 0.0
    
    dynamic var date: NSDate!
    
    dynamic var isCancelled = false
    dynamic var isFromPush = false
    
    override static func primaryKey() -> String? {
        return "requestId"
    }
    
}
