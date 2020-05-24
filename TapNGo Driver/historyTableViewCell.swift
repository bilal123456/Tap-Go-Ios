//
//  historyTableViewCell.swift
//  TapNGo Driver
//
//  Created by Mohammed Arshad on 20/03/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import UIKit

class historyTableViewCell: UITableViewCell {


    @IBOutlet weak var vehicletypelbl: UILabel!
    @IBOutlet weak var tripreqidlbl: UILabel!
    @IBOutlet weak var triptimelbl: UILabel!
    @IBOutlet weak var tripcostlbl: UILabel!
    @IBOutlet weak var fromaddrlbl: UILabel!
    @IBOutlet weak var invoiceImgView: UIImageView!
    @IBOutlet weak var toaddrlbl: UILabel!
    @IBOutlet weak var driverimageIv: UIImageView!
    @IBOutlet weak var vehicleimageIv: UIImageView!
    @IBOutlet weak var tripcancelledimageIv: UIImageView!

     var layoutDic = [String:AnyObject]()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setUpViews()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        setUpViews()
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setUpViews()
    }
    func setUpViews()
    {
        vehicletypelbl.font = UIFont.appFont(ofSize: vehicletypelbl.font!.pointSize)
        tripreqidlbl.font = UIFont.appFont(ofSize: tripreqidlbl.font!.pointSize)
        triptimelbl.font = UIFont.appFont(ofSize: triptimelbl.font!.pointSize)
        tripcostlbl.font = UIFont.appFont(ofSize: tripcostlbl.font!.pointSize)
        fromaddrlbl.font = UIFont.appFont(ofSize: fromaddrlbl.font!.pointSize)
        toaddrlbl.font = UIFont.appFont(ofSize: toaddrlbl.font!.pointSize)

        vehicletypelbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["vehicletypelbl"] = vehicletypelbl
        tripreqidlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["tripreqidlbl"] = tripreqidlbl
        triptimelbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["triptimelbl"] = triptimelbl
        tripcostlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["tripcostlbl"] = tripcostlbl
        fromaddrlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["fromaddrlbl"] = fromaddrlbl
        invoiceImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["invoiceImgView"] = invoiceImgView
        toaddrlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["toaddrlbl"] = toaddrlbl
        driverimageIv.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["driverimageIv"] = driverimageIv
        vehicleimageIv.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["vehicleimageIv"] = vehicleimageIv
        tripcancelledimageIv.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["tripcancelledimageIv"] = tripcancelledimageIv

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(10)-[vehicleimageIv(50)]-(10)-[triptimelbl]-(10)-[tripcostlbl(60)]-(10)-|", options: [HelperClass.appLanguageDirection,.alignAllTop], metrics: nil, views: layoutDic))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(10)-[vehicleimageIv(50)]", options: [HelperClass.appLanguageDirection,.alignAllTop], metrics: nil, views: layoutDic))

        triptimelbl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        tripcostlbl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[vehicleimageIv]-(10)-[vehicletypelbl(70)]-(10)-[tripreqidlbl(80)]", options: [HelperClass.appLanguageDirection,.alignAllBottom], metrics: nil, views: layoutDic))
        vehicletypelbl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        tripreqidlbl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[invoiceImgView(30)][toaddrlbl]-(10)-[driverimageIv(50)]-(10)-|", options: [HelperClass.appLanguageDirection,.alignAllBottom], metrics: nil, views: layoutDic))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[invoiceImgView][fromaddrlbl]-(10)-[driverimageIv]", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        fromaddrlbl.topAnchor.constraint(equalTo: invoiceImgView.topAnchor).isActive = true
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[vehicletypelbl]-(10)-[invoiceImgView(55)]-(10)-|", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        fromaddrlbl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        toaddrlbl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        driverimageIv.heightAnchor.constraint(equalTo: driverimageIv.widthAnchor).isActive = true
        tripcancelledimageIv.heightAnchor.constraint(equalToConstant: 50).isActive = true
        tripcancelledimageIv.widthAnchor.constraint(equalToConstant: 50).isActive = true
        tripcancelledimageIv.centerYAnchor.constraint(equalTo: driverimageIv.topAnchor).isActive = true
        if HelperClass.appLanguageDirection == .directionLeftToRight
        {
            invoiceImgView.leadingAnchor.constraint(equalTo: vehicletypelbl.leadingAnchor, constant: -10).isActive = true
            tripcancelledimageIv.centerXAnchor.constraint(equalTo: driverimageIv.leadingAnchor).isActive = true
        }
        else
        {
            invoiceImgView.trailingAnchor.constraint(equalTo: vehicletypelbl.trailingAnchor, constant: 10).isActive = true
            tripcancelledimageIv.centerXAnchor.constraint(equalTo: driverimageIv.trailingAnchor).isActive = true
        }

        vehicletypelbl.textAlignment = HelperClass.appTextAlignment
        tripreqidlbl.textAlignment = HelperClass.appTextAlignment
        triptimelbl.textAlignment = HelperClass.appTextAlignment
        tripcostlbl.textAlignment = HelperClass.appTextAlignment
        fromaddrlbl.textAlignment = HelperClass.appTextAlignment
        toaddrlbl.textAlignment = HelperClass.appTextAlignment
    }


}
