//
//  OfferTableViewCell.swift
//  Quick Me
//
//  Created by Abdul Wahib on 4/30/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit

class OfferTableViewCell: UITableViewCell {

    @IBOutlet weak var offerDate: UILabel!
    @IBOutlet weak var offerComments: UILabel!
    @IBOutlet weak var offerPrice: UILabel!
    
    @IBOutlet weak var acceptOfferButton: UIButton!
    @IBOutlet weak var closeOfferButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
