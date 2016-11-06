/* 
Copyright (c) 2016 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
 
/* For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar */

public class Payer_info {
	public var email : String?
	public var first_name : String?
	public var last_name : String?
	public var payer_id : String?
	public var shipping_address : Shipping_address?
	public var phone : Int?
	public var country_code : String?

/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let payer_info_list = Payer_info.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of Payer_info Instances.
*/
    public class func modelsFromDictionaryArray(array:NSArray) -> [Payer_info]
    {
        var models:[Payer_info] = []
        for item in array
        {
            models.append(Payer_info(dictionary: item as! NSDictionary)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let payer_info = Payer_info(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: Payer_info Instance.
*/
	required public init?(dictionary: NSDictionary) {

		email = dictionary["email"] as? String
		first_name = dictionary["first_name"] as? String
		last_name = dictionary["last_name"] as? String
		payer_id = dictionary["payer_id"] as? String
		if (dictionary["shipping_address"] != nil) { shipping_address = Shipping_address(dictionary: dictionary["shipping_address"] as! NSDictionary) }
		phone = dictionary["phone"] as? Int
		country_code = dictionary["country_code"] as? String
	}

		
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
	public func dictionaryRepresentation() -> NSDictionary {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.email, forKey: "email")
		dictionary.setValue(self.first_name, forKey: "first_name")
		dictionary.setValue(self.last_name, forKey: "last_name")
		dictionary.setValue(self.payer_id, forKey: "payer_id")
		dictionary.setValue(self.shipping_address?.dictionaryRepresentation(), forKey: "shipping_address")
		dictionary.setValue(self.phone, forKey: "phone")
		dictionary.setValue(self.country_code, forKey: "country_code")

		return dictionary
	}

}