//
//  CountryCodesViewController.swift
//  Quick Me
//
//  Created by Abdul Wahib on 8/6/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit
import OCMapper

protocol CountryCodesDelegate {
    func countryCodeSelected(dialCode: String)
}

class CountryCodesViewController: UIViewController {

    var delegate : CountryCodesDelegate!
    var countries = [CountryCode]()
    
    @IBOutlet weak var tableview: UITableView!
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadJsonData()
    }
    
    // MARK: Helper Methods
    func loadJsonData() {
        if let path = NSBundle.mainBundle().pathForResource("countries", ofType: "json") {
            do {
                let json = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                parseJson(json)
            }catch let error as NSError  {
                print(error.localizedDescription)
            }
        }
    }
    
    func parseJson(json: String) {
        do {
            if let countriesArray = try NSJSONSerialization.JSONObjectWithData(json.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as? NSArray {
                for country in countriesArray {
                    if let count = country as? NSDictionary {
                        if let c = ObjectMapper.sharedInstance().objectFromSource(count, toInstanceOfClass: CountryCode.self) as? CountryCode {
                            countries.append(c)
                        }
                        
                    }
                }
            }
        } catch let error as NSError {
            print(error)
        }
        
        self.tableview.reloadData()
        
    }
    
    // MARK: IBActions
    @IBAction func doneButtonClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

// UITableViewDelegate and DataSource Methods
extension CountryCodesViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let country = countries[indexPath.row]
        cell.textLabel?.text = country.name
        cell.detailTextLabel?.text = country.dialCode
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let row = tableview.indexPathForSelectedRow {
            self.tableview.deselectRowAtIndexPath(row, animated: true)
            let country = countries[row.row]
            self.delegate?.countryCodeSelected(country.dialCode!)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
