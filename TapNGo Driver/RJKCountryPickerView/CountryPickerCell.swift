//
//  CountryPickerCell.swift
//  test
//
//  Created by Admin on 01/04/18.
//  Copyright © 2018 com. All rights reserved.
//

import UIKit

class CountryPickerCell:UITableViewCell
{
    let flagImgView = UIImageView()
    let countryNameLbl = UILabel()
    let isoCodeLbl = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        flagImgView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(flagImgView)
        countryNameLbl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(countryNameLbl)
        isoCodeLbl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(isoCodeLbl)

        flagImgView.contentMode = .scaleAspectFit
        countryNameLbl.numberOfLines = 0
        countryNameLbl.lineBreakMode = .byWordWrapping
        isoCodeLbl.textColor = .gray
        isoCodeLbl.textAlignment = .right

        isoCodeLbl.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
        countryNameLbl.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
//        isoCodeLbl.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
//        setContentHuggingResistancePriority(UILayoutPriorityRequired, forAxis: .horizontal)


        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8)-[flagImgView(30)]-(>=8)-|", options: [], metrics: nil, views: ["flagImgView":flagImgView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8)-[countryNameLbl(>=30)]-(8)-|", options: [], metrics: nil, views: ["countryNameLbl":countryNameLbl]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8)-[isoCodeLbl(30)]-(>=8)-|", options: [], metrics: nil, views: ["isoCodeLbl":isoCodeLbl]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(10)-[flagImgView(30)]-(5)-[countryNameLbl]-(5)-[isoCodeLbl]-(20)-|", options: [], metrics: nil, views: ["flagImgView":flagImgView,"countryNameLbl":countryNameLbl,"isoCodeLbl":isoCodeLbl]))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
