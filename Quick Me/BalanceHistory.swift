//
//  BalanceHistory.swift
//  QuickMe
//
//  Created by Abdul Wahib on 6/30/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import Foundation
import RealmSwift

class BalanceHistory: Object {
    
    dynamic var amount: String?
    dynamic var descrip: String?
    dynamic var date: NSDate?
    dynamic var userBalance: String?
    dynamic var isAddtion: Bool = true
    
}