/* 
Copyright (c) 2016 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import Foundation
 
/* For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar */

public class Transactions {
	public var amount : Amount?
	public var description : String?
	public var item_list : Item_list?
	public var related_resources : Array<Related_resources>?

/**
    Returns an array of models based on given dictionary.
    
    Sample usage:
    let transactions_list = Transactions.modelsFromDictionaryArray(someDictionaryArrayFromJSON)

    - parameter array:  NSArray from JSON dictionary.

    - returns: Array of Transactions Instances.
*/
    public class func modelsFromDictionaryArray(array:NSArray) -> [Transactions]
    {
        var models:[Transactions] = []
        for item in array
        {
            models.append(Transactions(dictionary: item as! NSDictionary)!)
        }
        return models
    }

/**
    Constructs the object based on the given dictionary.
    
    Sample usage:
    let transactions = Transactions(someDictionaryFromJSON)

    - parameter dictionary:  NSDictionary from JSON.

    - returns: Transactions Instance.
*/
	required public init?(dictionary: NSDictionary) {

		if (dictionary["amount"] != nil) { amount = Amount(dictionary: dictionary["amount"] as! NSDictionary) }
		description = dictionary["description"] as? String
		if (dictionary["item_list"] != nil) { item_list = Item_list(dictionary: dictionary["item_list"] as! NSDictionary) }
		if (dictionary["related_resources"] != nil) { related_resources = Related_resources.modelsFromDictionaryArray(dictionary["related_resources"] as! NSArray) }
	}

		
/**
    Returns the dictionary representation for the current instance.
    
    - returns: NSDictionary.
*/
	public func dictionaryRepresentation() -> NSDictionary {

		let dictionary = NSMutableDictionary()

		dictionary.setValue(self.amount?.dictionaryRepresentation(), forKey: "amount")
		dictionary.setValue(self.description, forKey: "description")
		dictionary.setValue(self.item_list?.dictionaryRepresentation(), forKey: "item_list")

		return dictionary
	}

}