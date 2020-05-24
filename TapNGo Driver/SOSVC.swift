//
//  SOSVC.swift
//  TapNGo Driver
//
//  Created by Spextrum on 14/01/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import UIKit
import Localize

class SOSVC: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    @IBOutlet weak var SOSTable: UITableView!
    @IBOutlet weak var LblSOSText: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    
    var layoutDic = [String:AnyObject]()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var bottom:NSLayoutAnchor<NSLayoutYAxisAnchor>!


    let Pref = UserDefaults.standard
    var SOSData = NSArray()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        SOSTable.estimatedRowHeight = 85
        SOSTable.rowHeight = UITableView.automaticDimension
        SOSData = (Pref.object(forKey: "SOSDetails") as? NSArray)!
        print(SOSData)
        setUpViews()

        titleLbl.font = UIFont.appBoldTitleFont(ofSize: titleLbl.font!.pointSize)
        LblSOSText.font = UIFont.appFont(ofSize: LblSOSText.font!.pointSize)

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
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["titleLbl"] = titleLbl
        LblSOSText.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["LblSOSText"] = LblSOSText
        SOSTable.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["SOSTable"] = SOSTable
        SOSTable.estimatedRowHeight = 85
        SOSTable.rowHeight = UITableView.automaticDimension
        SOSTable.separatorStyle = .none

        titleLbl.topAnchor.constraint(equalTo: self.top, constant: 35).isActive = true
        SOSTable.bottomAnchor.constraint(equalTo: self.bottom).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[titleLbl(25)]-(20)-[LblSOSText(50)]-(20)-[SOSTable]", options: [], metrics: nil, views: layoutDic))
       self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[titleLbl]", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[LblSOSText]-(16)-|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[SOSTable]|", options: [], metrics: nil, views: layoutDic))

        titleLbl.textAlignment = HelperClass.appTextAlignment
        LblSOSText.textAlignment = HelperClass.appTextAlignment

    }
    override func viewWillAppear(_ animated: Bool)
    {
        SetLocalization()
    }


    func SetLocalization()
    {
        self.title = "SOS".localize().uppercased(with: Locale(identifier: HelperClass.currentAppLanguage))
    }

//    @IBAction func NavigateBackBtn(_ sender: Any)
//    {
//        self.performSegue(withIdentifier: "SOSToHomeVC", sender: self)
//    }

    func MakeAphoneCall(phoneNum: String)
    {
        if let url = URL(string: "tel://\(phoneNum)")
        {
            if #available(iOS 10, *)
            {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            else
            {
                UIApplication.shared.openURL(url as URL)
            }
        }
    }

    // ***** Tableview Methods *****

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        return UITableViewAutomaticDimension
//    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return SOSData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SOSTableViewCell", for: indexPath) as! SOSTableViewCell
        cell.selectionStyle = .none
        cell.titleLbl.text = ((SOSData[indexPath.row] as AnyObject).value(forKey: "name") as? String)!
        cell.phNumLbl.text = ((SOSData[indexPath.row] as AnyObject).value(forKey: "number") as? String)!
        if(SOSData.count<=3)
        {
            self.SOSTable.isScrollEnabled=false
        }
        else
        {
            self.SOSTable.isScrollEnabled=true
        }

        cell.callBtn.addTarget(self, action: #selector(callBtnPressed(_ :)), for: .touchUpInside)
        cell.callBtn.tag = indexPath.row

        cell.backgroundColor = .clear
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
//        let cell = tableView.dequeueReusableCell(withIdentifier: "SOSTableViewCell", for: indexPath) as! SOSTableViewCell
//        cell.LblSOSPhoneNumber.text! = ((SOSData[indexPath.row] as AnyObject).value(forKey: "number") as? String)!
        print(((SOSData[indexPath.row] as AnyObject).value(forKey: "number") as? String)!)
        self.MakeAphoneCall(phoneNum: ((SOSData[indexPath.row] as AnyObject).value(forKey: "number") as? String)!)
    }

    @objc func callBtnPressed(_ sender: UIButton) {


        let button = sender.tag
         self.MakeAphoneCall(phoneNum: ((SOSData[(button)] as AnyObject).value(forKey: "number") as? String)!)


    }

}


