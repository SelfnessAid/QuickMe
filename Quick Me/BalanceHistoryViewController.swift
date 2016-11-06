//
//  BalanceHistoryViewController.swift
//  QuickMe
//
//  Created by Abdul Wahib on 6/30/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit

class BalanceHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var helpBarButton: UIBarButtonItem!
    var mTimer: NSTimer!
    let SHOW_BROWSER = "SHOW_BROWSER"
    
    var mBalanceItems = [BalanceHistory]()
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    // MARK: Helper Methods
    func initViews() {
        mBalanceItems = RealmUtils.BalanceHistoryTable.readAll().reverse()
        
        UIUtils.removeBackButtonTitleOfNavigationBar(self.navigationItem)
        
        if mBalanceItems.count == 0 {
            UIUtils.showMessage("No Record", message: "Currently there's no payment history to show", controller: self, okHandler: { 
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
        
        self.tableView.reloadData()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        if !PreferenceUtils.getBoolFromPrefs(URLConstant.PAYMENT_HISTORY_PAGE) {
            mTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(MainMenuTableViewController.animateHelpButton), userInfo: nil, repeats: true)
        }
    }
    
    func animateHelpButton() {
        if helpBarButton.tintColor == UIColor.whiteColor() {
            helpBarButton.tintColor = UIColor.clearColor()
        }else {
            helpBarButton.tintColor = UIColor.whiteColor()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == SHOW_BROWSER {
                if let dvc = segue.destinationViewController as? HelpViewController {
                    mTimer?.invalidate()
                    helpBarButton.tintColor = UIColor.whiteColor()
                    dvc.url = URLConstant.PAYMENT_HISTORY_PAGE
                }
            }
        }
    }

    // MARK: UITableViewDelegate & Datasource Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mBalanceItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! BalanceHistoryTableViewCell
        
        let item = mBalanceItems[indexPath.row]
        
        if let amount = item.amount {
            cell.amountLabel.text = "$\(Double(amount)!.roundToPlaces(2)) AUD"
        }else {
            cell.amountLabel.text = "$0 AUD"
        }
        
        if let balance = item.userBalance {
            cell.balanceLabel.text = "Balance: $\(Double(balance)!.roundToPlaces(2)) AUD"
        }else {
            cell.balanceLabel.text = "Balance: $0 AUD"
        }
        
        if item.isAddtion {
            cell.operationImageView.image = UIImage(named: "add_button")
        }else {
            cell.operationImageView.image = UIImage(named: "remove_button")
        }

        cell.descriptionLabel.text = item.descrip
        cell.dateLabel.text = item.date?.formattedDate
        
        return cell
    }
    
}
