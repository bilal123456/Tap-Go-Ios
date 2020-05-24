//
//  historycomdetailsViewController.swift
//  TapNGo Driver
//
//  Created by Mohammed Arshad on 20/03/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import UIKit
import GoogleMaps
//import CoreData
import NVActivityIndicatorView
import Alamofire
import Localize
import Kingfisher


class HistoryComDetailsViewController: UIViewController, GMSMapViewDelegate
{

    var historyrequestid = String()

    var layoutDic = [String:AnyObject]()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var bottom:NSLayoutAnchor<NSLayoutYAxisAnchor>!

    @IBOutlet var scrollview: UIScrollView!
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var mapview: GMSMapView!

    @IBOutlet var starratingBtn1: UIButton!
    @IBOutlet var starratingBtn2: UIButton!
    @IBOutlet var starratingBtn3: UIButton!
    @IBOutlet var starratingBtn4: UIButton!
    @IBOutlet var starratingBtn5: UIButton!

    @IBOutlet var userprofilepicture: UIImageView!
    @IBOutlet var tripstatusimageview: UIImageView!
    @IBOutlet var triptypeiconiv: UIImageView!
    @IBOutlet var usernamelbl: UILabel!

    @IBOutlet var totalamtlbl: UILabel!
    @IBOutlet var distancelbl: UILabel!
    @IBOutlet var timelbl: UILabel!

    @IBOutlet var pickupaddrlbl: UILabel!
    @IBOutlet var dropupaddrlbl: UILabel!

    @IBOutlet weak var bpheaderlbl: UILabel!
    @IBOutlet weak var bpLbl: UILabel!

    @IBOutlet weak var dcheaderlbl: UILabel!
    @IBOutlet weak var dcLbl: UILabel!
    @IBOutlet weak var dchintLbl: UILabel!

    @IBOutlet weak var tcheaderlbl: UILabel!
    @IBOutlet weak var tcLbl: UILabel!
    @IBOutlet weak var tchintLbl: UILabel!

    @IBOutlet weak var wpheaderlbl: UILabel!
    @IBOutlet weak var wpLbl: UILabel!

    @IBOutlet weak var rbheaderlbl: UILabel!
    @IBOutlet weak var rbLbl: UILabel!

    @IBOutlet weak var pbheaderlbl: UILabel!
    @IBOutlet weak var pbLbl: UILabel!

    @IBOutlet weak var stheaderlbl: UILabel!
    @IBOutlet weak var stLbl: UILabel!

    var additionalAmntHeader = UILabel()
    var additionalAmount = UILabel()


    @IBOutlet weak var totheaderlbl: UILabel!
    @IBOutlet weak var totLbl: UILabel!

    @IBOutlet weak var paymentamtlbl: UILabel!
    @IBOutlet weak var paymenttypeheaderLbl: UILabel!
    @IBOutlet weak var paymenttypeLbl: UILabel!

    @IBOutlet weak var separtor1: UIView!
    @IBOutlet weak var separator2: UIView!
    @IBOutlet weak var separator3: UIView!
    @IBOutlet weak var separator4: UIView!
    @IBOutlet weak var separator5: UIView!
    @IBOutlet weak var historyImgView: UIImageView!
    @IBOutlet weak var invoiceImgView: UIImageView!
    @IBOutlet weak var billDetailsLbl: UILabel!
    @IBOutlet weak var listBgView: UIView!
    @IBOutlet weak var zigzagImgView: UIImageView!

    var currency:String=""
    var historydict = [String:AnyObject]()
    var billdict = [String:AnyObject]()


    var activityView: NVActivityIndicatorView!

    let appdel=UIApplication.shared.delegate as!AppDelegate

    var marker = GMSMarker()
    var desmarker = GMSMarker()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        usernamelbl.font = UIFont.appFont(ofSize: usernamelbl.font!.pointSize)
        totalamtlbl.font = UIFont.appFont(ofSize: totalamtlbl.font!.pointSize)
        distancelbl.font = UIFont.appFont(ofSize: distancelbl.font!.pointSize)
        timelbl.font = UIFont.appFont(ofSize: timelbl.font!.pointSize)
        pickupaddrlbl.font = UIFont.appFont(ofSize: pickupaddrlbl.font!.pointSize)
        dropupaddrlbl.font = UIFont.appFont(ofSize: dropupaddrlbl.font!.pointSize)
        bpheaderlbl.font = UIFont.appFont(ofSize: bpheaderlbl.font!.pointSize)
        bpLbl.font = UIFont.appFont(ofSize: bpLbl.font!.pointSize)
        dcheaderlbl.font = UIFont.appFont(ofSize: dcheaderlbl.font!.pointSize)
        dcLbl.font = UIFont.appFont(ofSize: dcLbl.font!.pointSize)
        dchintLbl.font = UIFont.appFont(ofSize: dchintLbl.font!.pointSize)
        tcheaderlbl.font = UIFont.appFont(ofSize: tcheaderlbl.font!.pointSize)
        tcLbl.font = UIFont.appFont(ofSize: tcLbl.font!.pointSize)
        tchintLbl.font = UIFont.appFont(ofSize: tchintLbl.font!.pointSize)
        wpheaderlbl.font = UIFont.appFont(ofSize: wpheaderlbl.font!.pointSize)
        wpLbl.font = UIFont.appFont(ofSize: wpLbl.font!.pointSize)
        rbheaderlbl.font = UIFont.appFont(ofSize: rbheaderlbl.font!.pointSize)
        rbLbl.font = UIFont.appFont(ofSize: rbLbl.font!.pointSize)
        pbheaderlbl.font = UIFont.appFont(ofSize: pbheaderlbl.font!.pointSize)
        pbLbl.font = UIFont.appFont(ofSize: pbLbl.font!.pointSize)
        stheaderlbl.font = UIFont.appFont(ofSize: stheaderlbl.font!.pointSize)
        stLbl.font = UIFont.appFont(ofSize: stLbl.font!.pointSize)
        additionalAmntHeader.font = UIFont.appFont(ofSize: stheaderlbl.font!.pointSize)
        additionalAmount.font = UIFont.appFont(ofSize: stLbl.font!.pointSize)
        totheaderlbl.font = UIFont.appFont(ofSize: totheaderlbl.font!.pointSize)
        totLbl.font = UIFont.appFont(ofSize: totLbl.font!.pointSize)
        paymentamtlbl.font = UIFont.appFont(ofSize: paymentamtlbl.font!.pointSize)
        paymenttypeheaderLbl.font = UIFont.appFont(ofSize: paymenttypeheaderLbl.font!.pointSize)
        paymenttypeLbl.font = UIFont.appFont(ofSize: paymenttypeLbl.font!.pointSize)
        billDetailsLbl.font = UIFont.appFont(ofSize: billDetailsLbl.font!.pointSize)

        billDetailsLbl.text = "Bill Details".localize()

        self.title = "History Details".localize().uppercased(with: Locale(identifier: HelperClass.currentAppLanguage))
        scrollview.contentSize = CGSize(width :320, height : 1000)
        self.gethistorydetails()

        // Set the map style by passing the URL of the local file.
//        if let styleURL = Bundle.main.url(forResource: "mapStyle", withExtension: "json") {
//            self.mapview.mapStyle = try? GMSMapStyle(contentsOfFileURL: styleURL)
//        } else {
//            print("Unable to find mapStyle.json")
//        }
        setUpViews()
    }
    func setUpViews()
    {
        if #available(iOS 11.0, *) {
            self.top = self.view.safeAreaLayoutGuide.topAnchor
            self.bottom = self.view.safeAreaLayoutGuide.bottomAnchor
        } else {
            self.top = self.topLayoutGuide.bottomAnchor
            self.bottom = self.bottomLayoutGuide.topAnchor
        }

        self.view.insertSubview(mapview, belowSubview: scrollview)

        [userprofilepicture,separtor1,triptypeiconiv,separator2,historyImgView,separator3,pickupaddrlbl,dropupaddrlbl,separator4,billDetailsLbl,listBgView,zigzagImgView,paymenttypeheaderLbl,paymenttypeLbl,paymentamtlbl,starratingBtn1,starratingBtn2,starratingBtn3,starratingBtn4,starratingBtn5,tripstatusimageview,usernamelbl,invoiceImgView,totalamtlbl,timelbl,distancelbl].forEach { $0!.removeFromSuperview();containerView.addSubview($0!) }

        [bpheaderlbl,bpLbl,dcheaderlbl,dcLbl,dchintLbl,tcheaderlbl,tcLbl,tchintLbl,wpheaderlbl,wpLbl,rbheaderlbl,rbLbl,pbheaderlbl,pbLbl,stheaderlbl,stLbl,additionalAmntHeader,additionalAmount,totheaderlbl,totLbl].forEach { $0!.removeFromSuperview();listBgView.addSubview($0!) }


        scrollview.backgroundColor = .clear
        scrollview.contentInset = UIEdgeInsets(top: 250, left: 0, bottom: 0, right: 0)
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["scrollview"] = scrollview
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["containerView"] = containerView
        mapview.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["mapview"] = mapview
        starratingBtn1.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["starratingBtn1"] = starratingBtn1
        starratingBtn1.imageView?.contentMode = .scaleAspectFit
        starratingBtn2.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["starratingBtn2"] = starratingBtn2
        starratingBtn2.imageView?.contentMode = .scaleAspectFit
        starratingBtn3.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["starratingBtn3"] = starratingBtn3
        starratingBtn3.imageView?.contentMode = .scaleAspectFit
        starratingBtn4.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["starratingBtn4"] = starratingBtn4
        starratingBtn4.imageView?.contentMode = .scaleAspectFit
        starratingBtn5.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["starratingBtn5"] = starratingBtn5
        starratingBtn5.imageView?.contentMode = .scaleAspectFit
        userprofilepicture.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["userprofilepicture"] = userprofilepicture
        tripstatusimageview.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["tripstatusimageview"] = tripstatusimageview
        triptypeiconiv.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["triptypeiconiv"] = triptypeiconiv
        usernamelbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["usernamelbl"] = usernamelbl
        totalamtlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["totalamtlbl"] = totalamtlbl
        distancelbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["distancelbl"] = distancelbl
        timelbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["timelbl"] = timelbl
        pickupaddrlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["pickupaddrlbl"] = pickupaddrlbl
        dropupaddrlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["dropupaddrlbl"] = dropupaddrlbl
        bpheaderlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["bpheaderlbl"] = bpheaderlbl
        bpLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["bpLbl"] = bpLbl
        dcheaderlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["dcheaderlbl"] = dcheaderlbl
        dcLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["dcLbl"] = dcLbl
        dchintLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["dchintLbl"] = dchintLbl
        tcheaderlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["tcheaderlbl"] = tcheaderlbl
        tcLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["tcLbl"] = tcLbl
        tchintLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["tchintLbl"] = tchintLbl
        wpheaderlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["wpheaderlbl"] = wpheaderlbl
        wpLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["wpLbl"] = wpLbl
        rbheaderlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["rbheaderlbl"] = rbheaderlbl
        rbLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["rbLbl"] = rbLbl
        pbheaderlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["pbheaderlbl"] = pbheaderlbl
        pbLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["pbLbl"] = pbLbl
        stheaderlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["stheaderlbl"] = stheaderlbl
        stLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["stLbl"] = stLbl

        additionalAmntHeader.textColor = UIColor(red: 184.0/255.0, green: 184.0/255.0, blue: 184.0/255.0, alpha: 1.0)
        additionalAmntHeader.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["additionalAmntHeader"] = additionalAmntHeader
        listBgView.addSubview(additionalAmntHeader)
        additionalAmount.textColor = UIColor(red: 184.0/255.0, green: 184.0/255.0, blue: 184.0/255.0, alpha: 1.0)
        additionalAmount.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["additionalAmount"] = additionalAmount
        listBgView.addSubview(additionalAmount)


        totheaderlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["totheaderlbl"] = totheaderlbl
        totLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["totLbl"] = totLbl
        paymentamtlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["paymentamtlbl"] = paymentamtlbl
        paymenttypeheaderLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["paymenttypeheaderLbl"] = paymenttypeheaderLbl
        paymenttypeLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["paymenttypeLbl"] = paymenttypeLbl
        separtor1.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["separtor1"] = separtor1
        separator2.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["separator2"] = separator2
        separator3.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["separator3"] = separator3
        separator4.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["separator4"] = separator4
        separator5.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["separator5"] = separator5
        historyImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["historyImgView"] = historyImgView
        invoiceImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["invoiceImgView"] = invoiceImgView
        billDetailsLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["billDetailsLbl"] = billDetailsLbl
        listBgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["listBgView"] = listBgView
        zigzagImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["zigzagImgView"] = zigzagImgView

        mapview.topAnchor.constraint(equalTo: self.top).isActive = true
        mapview.heightAnchor.constraint(equalToConstant: 250).isActive = true
        scrollview.topAnchor.constraint(equalTo: self.top).isActive = true
        scrollview.bottomAnchor.constraint(equalTo: self.bottom).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[scrollview]", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: [], metrics: nil, views: layoutDic))
        scrollview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[containerView]|", options: [], metrics: nil, views: layoutDic))
        scrollview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", options: [], metrics: nil, views: layoutDic))
        containerView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        let containerViewHgt = containerView.heightAnchor.constraint(equalTo: self.view.heightAnchor)
        containerViewHgt.priority = UILayoutPriority(rawValue: 250)
        containerViewHgt.isActive = true


        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(20)-[userprofilepicture(50)]-(10)-[separtor1(1)]-(10)-[triptypeiconiv(40)]-(10)-[separator2(1)]-(10)-[historyImgView(40)]-(10)-[separator3(1)]-(15)-[pickupaddrlbl(40)]-(5)-[dropupaddrlbl(40)]-(10)-[separator4(1)]-(15)-[billDetailsLbl(20)]-(5)-[listBgView][zigzagImgView(10)]-(10)-[paymenttypeheaderLbl(25)]-(10)-[paymenttypeLbl(20)]-(20)-|", options: [], metrics: nil, views: layoutDic))//(355)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[mapview]|", options: [], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[userprofilepicture(50)]-(15)-[usernamelbl]", options: [HelperClass.appLanguageDirection,.alignAllTop], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[usernamelbl]-(15)-[tripstatusimageview(40)]-(30)-|", options: [HelperClass.appLanguageDirection,], metrics: nil, views: layoutDic))
        usernamelbl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        tripstatusimageview.heightAnchor.constraint(equalTo: tripstatusimageview.widthAnchor).isActive = true
        tripstatusimageview.centerYAnchor.constraint(equalTo: userprofilepicture.centerYAnchor).isActive = true
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[userprofilepicture]-(15)-[starratingBtn1(17)]", options: [HelperClass.appLanguageDirection,.alignAllBottom], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[starratingBtn1][starratingBtn2(17)][starratingBtn3(17)][starratingBtn4(17)][starratingBtn5(17)]", options: [HelperClass.appLanguageDirection,.alignAllBottom,.alignAllTop], metrics: nil, views: layoutDic))
        starratingBtn1.heightAnchor.constraint(lessThanOrEqualTo: starratingBtn1.widthAnchor).isActive = true
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[userprofilepicture(50)]-(15)-[usernamelbl]", options: [HelperClass.appLanguageDirection,.alignAllTop], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[separtor1]|", options: [], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[triptypeiconiv(40)]", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[separator2]|", options: [], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[historyImgView(40)]-(15)-[totalamtlbl(==timelbl)]-(15)-[distancelbl(==timelbl)]-(15)-[timelbl]-(20)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[separator3]|", options: [], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(15)-[invoiceImgView(30)]-(10)-[pickupaddrlbl]-(10)-|", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(15)-[invoiceImgView(30)]-(10)-[dropupaddrlbl]-(10)-|", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        invoiceImgView.topAnchor.constraint(equalTo: pickupaddrlbl.centerYAnchor).isActive = true
        invoiceImgView.bottomAnchor.constraint(equalTo: dropupaddrlbl.centerYAnchor).isActive = true
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[separator4]|", options: [], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[billDetailsLbl(150)]", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[listBgView]|", options: [], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[zigzagImgView]|", options: [], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[paymenttypeheaderLbl(150)]", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(24)-[paymenttypeLbl(100)]-(>=20)-[paymentamtlbl(90)]-(50)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))


        listBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(10)-[bpheaderlbl(20)]-(10)-[dcheaderlbl(20)]-(5)-[dchintLbl(20)]-(10)-[tcheaderlbl(20)]-(5)-[tchintLbl(20)]-(10)-[wpheaderlbl(20)]-(10)-[rbheaderlbl(20)]-(10)-[pbheaderlbl(20)]-(10)-[stheaderlbl(20)]-10-[additionalAmntHeader(20)]-(15)-[separator5(1)]-(15)-[totheaderlbl(20)]-(15)-|", options: [], metrics: nil, views: layoutDic))

        listBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[bpheaderlbl]-(10)-[bpLbl(90)]-(50)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        listBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[dcheaderlbl]-(10)-[dcLbl(90)]-(50)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        listBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[dchintLbl]-(50)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        listBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[tcheaderlbl]-(10)-[tcLbl(90)]-(50)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        listBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[tchintLbl]-(50)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        listBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[wpheaderlbl]-(10)-[wpLbl(90)]-(50)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        listBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[rbheaderlbl]-(10)-[rbLbl(90)]-(50)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        listBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[pbheaderlbl]-(10)-[pbLbl(90)]-(50)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        listBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[stheaderlbl]-(10)-[stLbl(90)]-(50)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))

        listBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[additionalAmntHeader]-(10)-[additionalAmount(90)]-(50)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))

        listBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[separator5]|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        listBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[totheaderlbl]-(10)-[totLbl(90)]-(50)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))


        bpheaderlbl.text = "Base Price".localize()
        dcheaderlbl.text = "Distance Cost".localize()
        tcheaderlbl.text = "Time Cost".localize()
        wpheaderlbl.text = "Waiting Cost".localize()
        rbheaderlbl.text = "Referral Bonus".localize()
        pbheaderlbl.text = "Promo Bonus".localize()
        stheaderlbl.text = "Service Tax".localize()
        additionalAmntHeader.text = "Additional charge".localize()
        totheaderlbl.text = "Total".localize()
        paymenttypeheaderLbl.text = "Payment".localize()

        usernamelbl.textAlignment = HelperClass.appTextAlignment
        totalamtlbl.textAlignment = HelperClass.appTextAlignment
        distancelbl.textAlignment = HelperClass.appTextAlignment
        timelbl.textAlignment = HelperClass.appTextAlignment
        pickupaddrlbl.textAlignment = HelperClass.appTextAlignment
        dropupaddrlbl.textAlignment = HelperClass.appTextAlignment
        billDetailsLbl.textAlignment = HelperClass.appTextAlignment
        bpheaderlbl.textAlignment = HelperClass.appTextAlignment
        bpLbl.textAlignment = HelperClass.appTextAlignment == .left ? .right : .left
        dcheaderlbl.textAlignment = HelperClass.appTextAlignment
        dcLbl.textAlignment = HelperClass.appTextAlignment == .left ? .right : .left
        dchintLbl.textAlignment = HelperClass.appTextAlignment
        tcheaderlbl.textAlignment = HelperClass.appTextAlignment
        tcLbl.textAlignment = HelperClass.appTextAlignment == .left ? .right : .left
        tchintLbl.textAlignment = HelperClass.appTextAlignment
        wpheaderlbl.textAlignment = HelperClass.appTextAlignment
        wpLbl.textAlignment = HelperClass.appTextAlignment == .left ? .right : .left
        rbheaderlbl.textAlignment = HelperClass.appTextAlignment
        rbLbl.textAlignment = HelperClass.appTextAlignment == .left ? .right : .left
        pbheaderlbl.textAlignment = HelperClass.appTextAlignment
        pbLbl.textAlignment = HelperClass.appTextAlignment == .left ? .right : .left
        stheaderlbl.textAlignment = HelperClass.appTextAlignment
        stLbl.textAlignment = HelperClass.appTextAlignment == .left ? .right : .left
        additionalAmntHeader.textAlignment = HelperClass.appTextAlignment
        additionalAmount.textAlignment = HelperClass.appTextAlignment == .left ? .right : .left
        totheaderlbl.textAlignment = HelperClass.appTextAlignment
        totLbl.textAlignment = HelperClass.appTextAlignment == .left ? .right : .left
        paymentamtlbl.textAlignment = HelperClass.appTextAlignment == .left ? .right : .left
        paymenttypeheaderLbl.textAlignment = HelperClass.appTextAlignment
        paymenttypeLbl.textAlignment = HelperClass.appTextAlignment
    }

//    func getContext () -> NSManagedObjectContext
//    {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        return appDelegate.persistentContainer.viewContext
//    }

//    func getUsers ()
//    {
//        let fetchRequest: NSFetchRequest<Login_UserData> = Login_UserData.fetchRequest()
//        do
//        {
//            let array_users = try getContext().fetch(fetchRequest)
//            print ("num of users = \(array_users.count)")
//            for user in array_users as [NSManagedObject]
//            {
//                userId = (String(describing: user.value(forKey: "loginuser_ID")!))
//                userTokenstr = (String(describing: user.value(forKey: "loginuser_token")!))
//            }
//        }
//        catch
//        {
//            print("Error with request: \(error)")
//        }
//    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    @IBAction func NavigateBackBtn(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }

    //--------------------------------------
    // MARK: - Getting history details
    //--------------------------------------

    func gethistorydetails()
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            print("Connected")
            // NVActivityIndicatorPresenter.sharedInstance.startAnimating(HelperClass.shared.activityData, nil)
            var ParamDict = Dictionary<String, Any>()
            //            if let id = APIHelper.shared.loginUserData?.id {
            //                ParamDict["id"] = Int(id)
            //            }
            //            ParamDict["token"] = APIHelper.shared.loginUserData?.token
            ParamDict["id"] = HelperClass.shared.userID
            ParamDict["token"] = HelperClass.shared.userToken
            ParamDict["request_id"]=self.historyrequestid
            let url = HelperClass.BASEURL + HelperClass.gethistorydetails
            print(url, ParamDict)
            Alamofire.request(url, method:.post, parameters: ParamDict, headers: ["Accept":"application/json"])
                .responseJSON
                { response in

                    if case .failure(let error) = response.result
                    {
                        print(error.localizedDescription)
                    }
                    else if case .success = response.result
                    {
                        if let JSON = response.result.value as? [String:AnyObject], let status = JSON["success"] as? Bool
                        {
                            if status
                            {
                                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                                if let historydict = JSON["request"] as? [String:AnyObject] {
                                    self.historydict = historydict
                                    print(self.historydict)
                                    self.setupmap()
                                    self.setupdata()
                                }
                            }
                            else
                            {
                                if let errcodestr = JSON["error_code"] as? String, errcodestr == "606" {
                                    HelperClass.shared.deleteUserDetails()
                                } else {
                                    print(JSON["error_message"] as? String)
                                    print("Response Fail")
                                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                                    self.showToast("text_fetch_history".localize())
                                }

                            }
                        }
                    }

                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }
        }
        else
        {
            print("disConnected")
            self.showAlert("txt_NoInternet_title".localize(), message: "txt_NoInternet".localize())
            //            alert(message: , title: )
        }
    }

    func setupmap ()
    {
        if let latdouble=self.historydict["pick_latitude"] as? CLLocationDegrees, let longdouble=self.historydict["pick_longitude"] as? CLLocationDegrees
        {
            let camera = GMSCameraPosition.camera(withLatitude: latdouble, longitude: longdouble , zoom: 14)
            mapview.camera=camera

            marker.position = CLLocationCoordinate2D(latitude: (mapview.camera.target.latitude), longitude: (mapview.camera.target.longitude))
            marker.icon = UIImage(named:"PickupMarker")
            marker.map = mapview
        }


        if let destlatdouble=self.historydict["drop_latitude"] as? CLLocationDegrees, let destlondouble=self.historydict["drop_longitude"] as? CLLocationDegrees
        {
            desmarker.position = CLLocationCoordinate2D(latitude: destlatdouble, longitude: destlondouble)
            desmarker.icon = UIImage(named:"DropMarker")
            desmarker.map = mapview
            let path = GMSMutablePath()
            path.add(CLLocationCoordinate2D(latitude: mapview.camera.target.latitude, longitude: mapview.camera.target.longitude))
            path.add(CLLocationCoordinate2D(latitude: destlatdouble, longitude: destlondouble))

            var bounds = GMSCoordinateBounds()

            for index in 0...path.count()
            {
                bounds = bounds.includingCoordinate(path.coordinate(at: index))
            }
            self.mapview.animate(with: GMSCameraUpdate.fit(bounds))
        }
    }

    func setupdata()
    {
        if let isCompleted = historydict["is_completed"] as? Bool, isCompleted
        {
            self.tripstatusimageview.isHidden=false
        }
        else
        {
            self.tripstatusimageview.isHidden=true
        }
        if let driverdict = self.historydict["user"] as? [String:AnyObject] {
            self.userprofilepicture.layer.masksToBounds=true
            self.userprofilepicture.layer.cornerRadius=self.userprofilepicture.layer.frame.width/2
            if let urlStr = driverdict["profile_pic"] as? String, let url = URL(string:urlStr)
            {
                let resource = ImageResource(downloadURL: url)
                self.userprofilepicture.kf.setImage(with: resource)
            }

            if let firstName = driverdict["firstname"] as? String, let lastName = driverdict["lastname"] as? String {
                self.usernamelbl.text = firstName + " " + lastName
            }


            var driverreview : Double = 0.0
            if let review = driverdict["review"] as? String
            {
                driverreview = Double(review) ?? 0.0
            }
            //        let driverreview : Double = 2.0
            let strr: String=String(format:"%0f", driverreview)
            //let strr : String=driverreview as! String

            let strint = Int(Float(strr)!)

            [starratingBtn1,starratingBtn2,starratingBtn3,starratingBtn4,starratingBtn5].enumerated().forEach {
                if $0+1 <= strint
                {
                    $1!.setImage(UIImage(named: "FilledStar"), for: .normal)
                }
                else
                {
                    $1!.setImage(UIImage(named: "blank_stare"), for: .normal)
                }
            }
        }


        if let urlStr = historydict["type_icon"] as? String, let url = URL(string:urlStr)
        {
            self.triptypeiconiv.kf.setImage(with: ImageResource(downloadURL: url))
        }
        //total
        guard let billDetails = self.historydict["bill"] as? [String : AnyObject],
            let currency = billDetails["currency"] as? String,
            let isCancelled = historydict["is_cancelled"] as? Bool else {
                return
        }


        billdict = billDetails
        self.currency = currency

        if !isCancelled
        {
            if let total = billdict["total"] as? Double {
                self.totalamtlbl.text = self.currency + " " + String(format:"%.2f", total)
            }



            //pickup and drop address

            self.pickupaddrlbl.text = historydict["pick_location"] as? String

            self.dropupaddrlbl.text = historydict["drop_location"] as? String

            //time
            if let time = historydict["time"] as? Double {
                self.timelbl.text = String(time) + " " + "txt_min".localize()
            }



            //distance

            if let distance=historydict["distance"] as? Double {
                if distance > 0
                {
                    self.distancelbl.text = String(format:"%.2f %@", distance,"kms".localize())
                }
                else
                {
                    self.distancelbl.text = String(distance) + " " + "kms".localize()
                }
            }


            // bill details

            if let baseprice = billdict["base_price"] as? Double {
                self.bpLbl.text = self.currency + String(format:"%.2f", baseprice)
            }
            if let distancecost = billdict["distance_price"] as? Double {
                self.dcLbl.text = self.currency + String(format:"%.2f", distancecost)
            }
            if let priceperdistance=billdict["price_per_distance"] as? Double {
                self.dchintLbl.text = self.currency + " " + String(format:"%.2f", priceperdistance) + " / Km"
            }
            if let timecost = billdict["time_price"] as? Double {
                self.tcLbl.text = self.currency + String(format:"%.2f", timecost)
            }
            if let pricepertime = billdict["price_per_time"] as? Double {
                self.tchintLbl.text=self.currency + String(format:"%.1f", pricepertime) + " / Min"
            }
            if let waitingprice=billdict["waiting_price"] as? Double {
                self.wpLbl.text = self.currency + String(format:"%.2f", waitingprice)
            }
            if let referralbonus = billdict["referral_amount"] as? Double {
                self.rbLbl.text = self.currency + String(format:"%.2f", referralbonus)
            }
            if let promobonus = billdict["promo_amount"] as? Double {
                self.pbLbl.text = self.currency + String(format:"%.2f", promobonus)
            }
            if let servicetax = billdict["service_tax"] as? Double {
                self.stLbl.text = self.currency + String(format:"%.2f", servicetax)
            }
            if let extraamnt = billdict["extra_amount"] as? Double {
                self.additionalAmount.text = self.currency + String(format:"%.2f", extraamnt)
            }
            if let total = billdict["total"] as? Double {
                self.totLbl.text = self.currency + String(format:"%.2f", total)
                self.paymentamtlbl.text = self.currency + String(format:"%.2f", total)
            }

            if let paymenttype = historydict["payment_opt"] as? Int{
                switch paymenttype {
                case 0:
                    self.paymenttypeLbl.text = "Card".localize()
                    if let total = billdict["total"] as? Double {
                        self.paymentamtlbl.text = self.currency + String(format: "%.2f", total)
                        self.totLbl.text = self.currency + String(format: "%.2f", total)
                    }
                case 1:self.paymenttypeLbl.text = "Cash".localize()
                if let total = billdict["total"] as? Double {
                    self.paymentamtlbl.text = self.currency + String(format: "%.2f", total)
                    self.totLbl.text = self.currency + String(format: "%.2f", total)
                    }
                case 2:self.paymenttypeLbl.text = "Wallet".localize()
                if let total = billdict["total"] as? Double {
                    self.totLbl.text = self.currency + String(format: "%.2f", total)
                }
                if let walletAmount = billdict["wallet_amount"] as? Double {
                    self.paymentamtlbl.text = self.currency + String(format: "%.2f", walletAmount)
                    }
                default:
                    break
                }
            }
        }
    }

    //------------------------------------------
    // MARK: - NVActivityIndicatorview
    //------------------------------------------

    func showLoadingIndicator()
    {
        if activityView == nil
        {
            activityView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100.0, height: 100.0), type: NVActivityIndicatorType.ballClipRotate, color: UIColor.black, padding: 0.0)
            // add subview
            view.addSubview(activityView)
            // autoresizing mask
            activityView.translatesAutoresizingMaskIntoConstraints = false
            // constraints
            view.addConstraint(NSLayoutConstraint(item: activityView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: activityView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0))
        }
        activityView.startAnimating()
    }

    func stopLoadingIndicator()
    {
        activityView.stopAnimating()
    }


}
//
//extension UIImageView {
//    func downloadImageFrom11(link:String, contentMode: UIViewContentMode) {
//        URLSession.shared.dataTask( with: NSURL(string:link)! as URL, completionHandler: {
//            (data, response, error) -> Void in
//            DispatchQueue.main.async()
//                {
//                    self.contentMode =  contentMode
//                    if let data = data { self.image = UIImage(data: data) }
//            }
//        }).resume()
//    }
//}
//
