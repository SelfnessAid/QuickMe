/* 
Copyright (c) 2016 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
 
/* For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar */

public class Shipping_address {
	public var recipient_name : String?
	public var line1 : String?
	public var city : String?
	public var state : String?
	public var postal_code : Int?
	public var country_code : String?

/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let shipping_address_list = Shipping_address.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of Shipping_address Instances.
*/
    public class func modelsFromDictionaryArray(array:NSArray) -> [Shipping_address]
    {
        var models:[Shipping_address] = []
        for item in array
        {
            models.append(Shipping_address(dictionary: item as! NSDictionary)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let shipping_address = Shipping_address(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: Shipping_address Instance.
*/
	required public init?(dictionary: NSDictionary) {

		recipient_name = dictionary["recipient_name"] as? String
		line1 = dictionary["line1"] as? String
		city = dictionary["city"] as? String
		state = dictionary["state"] as? String
		postal_code = dictionary["postal_code"] as? Int
		country_code = dictionary["country_code"] as? String
	}

		
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
	public func dictionaryRepresentation() -> NSDictionary {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.recipient_name, forKey: "recipient_name")
		dictionary.setValue(self.line1, forKey: "line1")
		dictionary.setValue(self.city, forKey: "city")
		dictionary.setValue(self.state, forKey: "state")
		dictionary.setValue(self.postal_code, forKey: "postal_code")
		dictionary.setValue(self.country_code, forKey: "country_code")

		return dictionary
	}

}