//
//  settingsTableViewCell.swift
//  TapNGo Driver
//
//  Created by Mohammed Arshad on 21/03/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import UIKit

class settingsTableViewCell: UITableViewCell {


@IBOutlet weak var langlbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        langlbl.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[langlbl]-(20)-|", options: [], metrics: nil, views: ["langlbl":langlbl]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(5)-[langlbl(30)]-(5)-|", options: [], metrics: nil, views: ["langlbl":langlbl]))
    }

}
