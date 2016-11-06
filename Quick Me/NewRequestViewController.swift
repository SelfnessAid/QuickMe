//
//  NewRequestViewController.swift
//  Quick Me
//
//  Created by Abdul Wahib on 4/28/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit

class NewRequestViewController: UIViewController {

    @IBOutlet weak var descriptionTextArea: UITextView!
    @IBOutlet weak var maxPriceField: UITextField!
    @IBOutlet weak var dueDateButton: UIButton!
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Helper Methods
    func initView() {
    }

    // MARK: IBActions
    @IBAction func priceStepperPressed(sender: UIStepper) {
        
    }
    
    @IBAction func dueDateButtonPressed(sender: UIButton) {
        
    }
    
    @IBAction func postButtonClick(sender: UIBarButtonItem) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func backButtonClick(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
