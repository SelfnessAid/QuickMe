/* 
Copyright (c) 2016 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
 
/* For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar */

public class Sale {
	public var id : String?
	public var state : String?
	public var amount : Amount?
	public var payment_mode : String?
	public var protection_eligibility : String?
	public var protection_eligibility_type : String?
	public var transaction_fee : Transaction_fee?
	public var parent_payment : String?
	public var create_time : String?
	public var update_time : String?
	public var links : Array<Links>?

/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let sale_list = Sale.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of Sale Instances.
*/
    public class func modelsFromDictionaryArray(array:NSArray) -> [Sale]
    {
        var models:[Sale] = []
        for item in array
        {
            models.append(Sale(dictionary: item as! NSDictionary)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let sale = Sale(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: Sale Instance.
*/
	required public init?(dictionary: NSDictionary) {

		id = dictionary["id"] as? String
		state = dictionary["state"] as? String
		if (dictionary["amount"] != nil) { amount = Amount(dictionary: dictionary["amount"] as! NSDictionary) }
		payment_mode = dictionary["payment_mode"] as? String
		protection_eligibility = dictionary["protection_eligibility"] as? String
		protection_eligibility_type = dictionary["protection_eligibility_type"] as? String
		if (dictionary["transaction_fee"] != nil) { transaction_fee = Transaction_fee(dictionary: dictionary["transaction_fee"] as! NSDictionary) }
		parent_payment = dictionary["parent_payment"] as? String
		create_time = dictionary["create_time"] as? String
		update_time = dictionary["update_time"] as? String
		if (dictionary["links"] != nil) { links = Links.modelsFromDictionaryArray(dictionary["links"] as! NSArray) }
	}

		
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
	public func dictionaryRepresentation() -> NSDictionary {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.id, forKey: "id")
		dictionary.setValue(self.state, forKey: "state")
		dictionary.setValue(self.amount?.dictionaryRepresentation(), forKey: "amount")
		dictionary.setValue(self.payment_mode, forKey: "payment_mode")
		dictionary.setValue(self.protection_eligibility, forKey: "protection_eligibility")
		dictionary.setValue(self.protection_eligibility_type, forKey: "protection_eligibility_type")
		dictionary.setValue(self.transaction_fee?.dictionaryRepresentation(), forKey: "transaction_fee")
		dictionary.setValue(self.parent_payment, forKey: "parent_payment")
		dictionary.setValue(self.create_time, forKey: "create_time")
		dictionary.setValue(self.update_time, forKey: "update_time")

		return dictionary
	}

}