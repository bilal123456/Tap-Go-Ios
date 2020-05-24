//
//  VehicleCollectionViewCell.swift
//  TapNGo Driver
//
//  Created by Spextrum on 09/10/17.
//  Copyright © 2017 nPlus. All rights reserved.
//

import UIKit

class VehicleCollectionViewCell: UICollectionViewCell
{
    var layoutDic = [String:AnyObject]()
    @IBOutlet weak var vehicleImgView: UIImageView!
    @IBOutlet weak var vehicleSelectImgView: UIImageView!
    @IBOutlet weak var vehicleName: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)

    }
    func setupViews()
    {
        vehicleImgView.contentMode = .scaleAspectFit
        vehicleImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["VehicleImage"] = vehicleImgView
        vehicleSelectImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["VehicleselectImage"] = vehicleSelectImgView
        vehicleName.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["VehicleName"] = vehicleName
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[VehicleImage][VehicleName(21)]|", options: [.alignAllLeading,.alignAllTrailing], metrics: nil, views: layoutDic))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[VehicleImage]|", options: [], metrics: nil, views: layoutDic))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[VehicleselectImage(30)]-(8)-|", options: [], metrics: nil, views: layoutDic))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[VehicleselectImage(30)]-(8)-|", options: [], metrics: nil, views: layoutDic))
    }
}
