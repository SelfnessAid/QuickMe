/* 
Copyright (c) 2016 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
 
/* For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar */

public class SaleModel {
	public var id : String?
	public var intent : String?
	public var state : String?
	public var cart : String?
	public var payer : Payer?
	public var transactions : Array<Transactions>?
	public var create_time : String?
	public var update_time : String?
	public var links : Array<Links>?

/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let json4Swift_Base_list = Json4Swift_Base.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of Json4Swift_Base Instances.
*/
    public class func modelsFromDictionaryArray(array:NSArray) -> [SaleModel]
    {
        var models:[SaleModel] = []
        for item in array
        {
            models.append(SaleModel(dictionary: item as! NSDictionary)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let json4Swift_Base = Json4Swift_Base(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: Json4Swift_Base Instance.
*/
	required public init?(dictionary: NSDictionary) {

		id = dictionary["id"] as? String
		intent = dictionary["intent"] as? String
		state = dictionary["state"] as? String
		cart = dictionary["cart"] as? String
		if (dictionary["payer"] != nil) { payer = Payer(dictionary: dictionary["payer"] as! NSDictionary) }
		if (dictionary["transactions"] != nil) { transactions = Transactions.modelsFromDictionaryArray(dictionary["transactions"] as! NSArray) }
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
		dictionary.setValue(self.intent, forKey: "intent")
		dictionary.setValue(self.state, forKey: "state")
		dictionary.setValue(self.cart, forKey: "cart")
		dictionary.setValue(self.payer?.dictionaryRepresentation(), forKey: "payer")
		dictionary.setValue(self.create_time, forKey: "create_time")
		dictionary.setValue(self.update_time, forKey: "update_time")

		return dictionary
	}

}