//
//  RequestTableViewCell.swift
//  Quick Me
//
//  Created by Abdul Wahib on 4/28/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit

class RequestTableViewCell: UITableViewCell {

    @IBOutlet weak var requestDate: UILabel!
    @IBOutlet weak var requestPrice: UILabel!
    @IBOutlet weak var requestDescription: UILabel!
    @IBOutlet weak var requestShowOfferButton: UIButton!
    @IBOutlet weak var requestMakeOfferButton: UIButton!
    @IBOutlet weak var requestcancelButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
