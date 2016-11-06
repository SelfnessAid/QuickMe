//
//  BalanceHistoryTableViewCell.swift
//  QuickMe
//
//  Created by Abdul Wahib on 6/30/16.
//  Copyright © 2016 Quick Me. All rights reserved.
//

import UIKit

class BalanceHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var operationImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
