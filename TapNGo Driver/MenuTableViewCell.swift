//
//  MenuTableViewCell.swift
//  TapNGo Driver
//
//  Created by Spextrum on 09/10/17.
//  Copyright © 2017 nPlus. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell
{

    var layoutDic = [String:AnyObject]()
    @IBOutlet weak var MenuImageView: UIImageView!
    @IBOutlet weak var MenuItemLabel: UILabel!
    @IBOutlet weak var gradientLine: UIImageView!

    
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        MenuItemLabel.font = UIFont.appFont(ofSize: MenuItemLabel.font!.pointSize)


        MenuImageView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["MenuImageView"] = MenuImageView
        MenuItemLabel.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["MenuItemLabel"] = MenuItemLabel
        MenuItemLabel.textAlignment = HelperClass.appTextAlignment

        gradientLine.backgroundColor = .themeColor
        gradientLine.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["gradientLine"] = gradientLine

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(10)-[MenuImageView(25)]-(9)-[gradientLine(1)]|", options: [], metrics: nil, views: layoutDic))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(15)-[gradientLine(220)]", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(15)-[MenuImageView(25)]-(10)-[MenuItemLabel(190)]", options: [HelperClass.appLanguageDirection,.alignAllBottom,.alignAllTop], metrics: nil, views: layoutDic))
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "", options: [], metrics: nil, views: layoutDic))

    }
}
