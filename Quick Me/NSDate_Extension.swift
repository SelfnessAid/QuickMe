//
//  NSDate_Extension.swift
//  Quick Me
//
//  Created by Abdul Wahib on 4/28/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import Foundation

extension NSDate {
    
    var formattedDate: String {
        let formattor = NSDateFormatter()
        formattor.dateFormat = "MMMM dd, YYYY"
        return formattor.stringFromDate(self)
    }
    
    var formattedDateForApi: String {
        let formattor = NSDateFormatter()
        formattor.timeZone = NSTimeZone(abbreviation: "UTC")
        formattor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return formattor.stringFromDate(self)
    }
    
    class func dateFromString(date: String) -> NSDate {
        let formattor = NSDateFormatter()
        formattor.timeZone = NSTimeZone(abbreviation: "UTC")
        formattor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let d = date.stringByReplacingOccurrencesOfString("UTC+00:00", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        print(d)
        if let dd = formattor.dateFromString(d) {
            return dd
        }
        return NSDate()
    }
    
    
}