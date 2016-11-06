/* 
Copyright (c) 2016 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
 
/* For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar */

public class Items {
	public var name : String?
	public var sku : String?
	public var price : Double?
	public var currency : String?
	public var tax : Double?
	public var quantity : Int?

/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let items_list = Items.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of Items Instances.
*/
    public class func modelsFromDictionaryArray(array:NSArray) -> [Items]
    {
        var models:[Items] = []
        for item in array
        {
            models.append(Items(dictionary: item as! NSDictionary)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let items = Items(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: Items Instance.
*/
	required public init?(dictionary: NSDictionary) {

		name = dictionary["name"] as? String
		sku = dictionary["sku"] as? String
		price = dictionary["price"] as? Double
		currency = dictionary["currency"] as? String
		tax = dictionary["tax"] as? Double
		quantity = dictionary["quantity"] as? Int
	}

		
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
	public func dictionaryRepresentation() -> NSDictionary {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.name, forKey: "name")
		dictionary.setValue(self.sku, forKey: "sku")
		dictionary.setValue(self.price, forKey: "price")
		dictionary.setValue(self.currency, forKey: "currency")
		dictionary.setValue(self.tax, forKey: "tax")
		dictionary.setValue(self.quantity, forKey: "quantity")

		return dictionary
	}

}