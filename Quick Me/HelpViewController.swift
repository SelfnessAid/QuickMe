//
//  HelpViewController.swift
//  QuickMe
//
//  Created by Abdul Wahib on 8/2/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var url: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if url != nil {
            PreferenceUtils.saveBoolToPrefs(url!, value: true)
            webView.loadRequest(NSURLRequest(URL: NSURL(string: url!)!))
        }
        
    }

}
