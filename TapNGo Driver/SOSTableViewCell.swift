//
//  SOSTableViewCell.swift
//  TapNGo Driver
//
//  Created by Spextrum on 16/01/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import UIKit

//class SOSTableViewCell: UITableViewCell
//{
//
//    @IBOutlet weak var titleBgView: UIView!
//    @IBOutlet weak var LblSOSTitle: UILabel!
//    @IBOutlet weak var phNumBgView: UIView!
//    @IBOutlet weak var LblSOSPhoneNumber: UILabel!
//    @IBOutlet weak var callBtn: UIButton!
//    var layoutDic = [String:AnyObject]()
//
//    override func awakeFromNib()
//    {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool)
//    {
//        super.setSelected(selected, animated: animated)
//
//    }
//    override func draw(_ rect: CGRect) {
//        titleBgView.translatesAutoresizingMaskIntoConstraints = false
//        layoutDic["titleBgView"] = titleBgView
//        LblSOSTitle.translatesAutoresizingMaskIntoConstraints = false
//        layoutDic["LblSOSTitle"] = LblSOSTitle
//        phNumBgView.translatesAutoresizingMaskIntoConstraints = false
//        layoutDic["phNumBgView"] = phNumBgView
//        LblSOSPhoneNumber.translatesAutoresizingMaskIntoConstraints = false
//        layoutDic["LblSOSPhoneNumber"] = LblSOSPhoneNumber
//        callBtn.translatesAutoresizingMaskIntoConstraints = false
//        layoutDic["callBtn"] = callBtn
//
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[titleBgView]-(20)-|", options: [], metrics: nil, views: layoutDic))
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(1)-[titleBgView(30)]-(1)-[phNumBgView(50)]-(5)-|", options: [.alignAllLeading,.alignAllTrailing], metrics: nil, views: layoutDic))
////        phNumBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(10)-[LblSOSPhoneNumber]-(10)-[callBtn(30)]-(10)-|", options: [.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
////        phNumBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(10)-[LblSOSPhoneNumber(30)]-(10)-|", options: [], metrics: nil, views: layoutDic))
//    }
//
//
//}

class SOSTableViewCell:UITableViewCell
{
    var containerView = UIView()
    var titleBgView = UIView()
    var titleLbl = UILabel()
    var phNumBgView = UIView()
    var phNumLbl = UILabel()
    var callBtn = UIButton()
    var layoutDic = [String:AnyObject]()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpViews()
    }
    func setUpViews()
    {

        titleLbl.font = UIFont.appFont(ofSize: titleLbl.font!.pointSize)
        phNumLbl.font = UIFont.appFont(ofSize: phNumLbl.font!.pointSize)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["containerView"] = containerView
        addSubview(containerView)

        titleBgView.backgroundColor = .lightGray
        containerView.addSubview(titleBgView)
        titleLbl.textColor = .white
        titleBgView.addSubview(titleLbl)
        phNumBgView.backgroundColor = .white
        containerView.addSubview(phNumBgView)
        phNumBgView.addSubview(phNumLbl)
        callBtn.imageView?.contentMode = .scaleAspectFit
        callBtn.contentHorizontalAlignment = .fill
        callBtn.contentVerticalAlignment = .fill
        callBtn.imageView?.tintColor = UIColor.themeColor
        callBtn.setImage(UIImage(named:"Callsosimage")?.withRenderingMode(.alwaysTemplate), for: .normal)
        phNumBgView.addSubview(callBtn)
        titleBgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["titleBgView"] = titleBgView
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["titleLbl"] = titleLbl
        phNumBgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["phNumBgView"] = phNumBgView
        phNumLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["phNumLbl"] = phNumLbl
        callBtn.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["callBtn"] = callBtn

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[containerView]-(20)-|", options: [], metrics: nil, views: layoutDic))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[containerView]-(20)-|", options: [], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleBgView]|", options: [], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleBgView(30)][phNumBgView(50)]|", options: [.alignAllLeading,.alignAllTrailing], metrics: nil, views: layoutDic))
        titleBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(5)-[titleLbl]-(5)-|", options: [], metrics: nil, views: layoutDic))
        titleBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleLbl]|", options: [], metrics: nil, views: layoutDic))
        phNumBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(10)-[phNumLbl]-(10)-[callBtn(30)]-(10)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        phNumBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(10)-[phNumLbl(30)]-(10)-|", options: [], metrics: nil, views: layoutDic))

        titleLbl.textAlignment = HelperClass.appTextAlignment
        phNumLbl.textAlignment = HelperClass.appTextAlignment
    }
}
