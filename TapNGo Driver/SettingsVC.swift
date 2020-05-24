//
//  SettingsVC.swift
//  TapNGo Driver
//
//  Created by Spextrum on 10/11/17.
//  Copyright © 2017 nPlus. All rights reserved.
//

import UIKit
import Localize

class SettingsVC: UIViewController
{
    //    @IBOutlet weak var BtnNavigationBack: UIButton!
    @IBOutlet weak var headerlbl: UILabel!
    @IBOutlet weak var notificationlbl: UILabel!
    @IBOutlet weak var languageTitleBtn: UIButton!
    @IBOutlet weak var notificationswitch: UISwitch!
    @IBOutlet weak var changeLanguageBtn: UIButton!
    let languagePopUpView = PopUpTableView()

    var layoutDic = [String:AnyObject]()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var bottom:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var currentLayoutDirection = HelperClass.appLanguageDirection//TO REDRAW VIEWS IF DIRECTION IS CHANGED

    var notswitchstatus = "" as String
    var languagelistarray=[String]()

    override func viewDidLoad()
    {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            self.languagePopUpView.langListTblView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        notswitchstatus = "ON"
        print(languagelistarray)
        // Do any additional setup after loading the view.
        setUpViews()

        notificationswitch.onTintColor = UIColor.themeColor
        headerlbl.font = UIFont.appBoldTitleFont(ofSize: 20)
        notificationlbl.font = UIFont.appFont(ofSize: 17)
        languageTitleBtn.titleLabel?.font = UIFont.appFont(ofSize: 17)
        languageTitleBtn.adjustsImageWhenHighlighted = false


        let img = UIImage(named:"language")?.withRenderingMode(.alwaysTemplate)
        changeLanguageBtn.imageView?.tintColor = UIColor.themeColor
        changeLanguageBtn.setImage(img, for: .normal)
        languageTitleBtn.addTarget(self, action: #selector(languageselbtnAction(_:)), for: .touchUpInside)
    }
    func setUpViews()
    {

        self.languageTitleBtn.setTitle("Language / ".localize() + Localize.shared.displayNameForLanguage(HelperClass.currentAppLanguage), for: .normal)

        if #available(iOS 11.0, *) {
            self.top = self.view.safeAreaLayoutGuide.topAnchor
            self.bottom = self.view.safeAreaLayoutGuide.bottomAnchor
        } else {
            self.top = self.topLayoutGuide.bottomAnchor
            self.bottom = self.bottomLayoutGuide.topAnchor
        }

        headerlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["headerlbl"] = headerlbl
        headerlbl.textAlignment = HelperClass.appTextAlignment
        headerlbl.removeFromSuperview()
        self.view.addSubview(headerlbl)

        notificationlbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["notificationlbl"] = notificationlbl
        notificationlbl.textAlignment = HelperClass.appTextAlignment
        notificationlbl.removeFromSuperview()
        self.view.addSubview(notificationlbl)

        languageTitleBtn.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["languagelbl"] = languageTitleBtn
        languageTitleBtn.titleLabel?.textAlignment = HelperClass.appTextAlignment
        languageTitleBtn.removeFromSuperview()
        self.view.addSubview(languageTitleBtn)

        notificationswitch.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["notificationswitch"] = notificationswitch
        notificationswitch.removeFromSuperview()
        self.view.addSubview(notificationswitch)

        changeLanguageBtn.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["changeLanguageBtn"] = changeLanguageBtn
        changeLanguageBtn.removeFromSuperview()
        self.view.addSubview(changeLanguageBtn)

        headerlbl.topAnchor.constraint(equalTo: self.top, constant: 35).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[headerlbl(30)]-(35)-[notificationlbl(30)]-(25)-[languagelbl(30)]", options: [], metrics: nil, views: layoutDic))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(15)-[headerlbl(150)]", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(25)-[notificationlbl]-(10)-[notificationswitch]-(15)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(25)-[languagelbl]-(10)-[changeLanguageBtn]-(15)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        changeLanguageBtn.widthAnchor.constraint(equalTo: changeLanguageBtn.heightAnchor).isActive = true



        languagePopUpView.optionsList = Localize.shared.availableLanguages.map({
            let locale = NSLocale(localeIdentifier: $0)
            if let name = locale.displayName(forKey: NSLocale.Key.identifier, value: $0) {
                return (text:name,identifier:$0)
            } else {
                return (text:Localize.shared.displayNameForLanguage($0),identifier:$0)
            }
        })
        languagePopUpView.selectedOption = languagePopUpView.optionsList?.first(where: { $1 == HelperClass.currentAppLanguage })
        languagePopUpView.tableTitle = "Select Language".localize().uppercased(with: Locale(identifier: HelperClass.currentAppLanguage))
        languagePopUpView.translatesAutoresizingMaskIntoConstraints = false
        languagePopUpView.delegate = self
        layoutDic["languagePopUpView"] = languagePopUpView
        languagePopUpView.removeFromSuperview()
        self.navigationController?.view.addSubview(languagePopUpView)
        self.navigationController?.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[languagePopUpView]|", options: [], metrics: nil, views: layoutDic))
        self.navigationController?.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[languagePopUpView]|", options: [], metrics: nil, views: layoutDic))

        self.title = "Settings".localize().uppercased(with: Locale(identifier: HelperClass.currentAppLanguage))
        languageTitleBtn.contentHorizontalAlignment = HelperClass.appLanguageDirection == .directionLeftToRight ? .left : .right
        languageTitleBtn.setTitleColor(.black, for: .normal)
    }


    @IBAction func notificationsoundstatuschanged()
    {
        if(notswitchstatus=="ON")
        {
            notswitchstatus="OFf"
            self.notificationlbl.text="Notification Sound / OFF".localize()
        }
        else
        {
            notswitchstatus="ON"
            self.notificationlbl.text="Notification Sound / ON".localize()
        }
    }

    @IBAction func languageselbtnAction(_ sender: Any)
    {
        self.languagePopUpView.langListTblView.semanticContentAttribute = HelperClass.appSemanticContentAttribute
        self.languagePopUpView.tableTitle = "Select Language".localize().uppercased(with: Locale(identifier: HelperClass.currentAppLanguage))
        self.languagePopUpView.isHidden = false
    }
}

extension SettingsVC:PopUpTableViewDelegate
{
    func popUpTableView(_ popUpTableView: PopUpTableView, didSelectOption option: Option, atIndex index:Int)
    {
        HelperClass.currentAppLanguage = option.identifier
        (UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])).textAlignment = HelperClass.appTextAlignment
        self.languageTitleBtn.setTitle("Language / ".localize() + option.text , for: .normal)
        if currentLayoutDirection != HelperClass.appLanguageDirection
        {
            self.setUpViews()
            currentLayoutDirection = HelperClass.appLanguageDirection
        }
    }
}



