//
//  ComplaintsVC.swift
//  TapNGo Driver
//
//  Created by Spextrum on 10/11/17.
//  Copyright © 2017 nPlus. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
//import CoreData
import Localize

class ComplaintsVC: UIViewController, UITextViewDelegate
{

    var layoutDic = [String:AnyObject]()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var bottom:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    let languagePopUpView = PopUpTableView()

    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var formImgView: UIImageView!
    @IBOutlet weak var complaintslbl: UILabel!

    @IBOutlet weak var complaintsview: UIView!
    @IBOutlet weak var complaintsTfd: UITextField!
//    @IBOutlet weak var complaintsdownarrowIv: UIImageView!
    @IBOutlet weak var complaintsBtn: UIButton!

    @IBOutlet weak var complaintlistTbv: UITableView!

    @IBOutlet weak var commentslbl: UILabel!
    @IBOutlet weak var commentsTxtView: UITextView!

    @IBOutlet weak var BtnSend: UIButton!

    let AppDelegates = UIApplication.shared.delegate as! AppDelegate
//    let HelperObject = HelperClass()
    var activityView: NVActivityIndicatorView!

//    var userTokenstr:String=""
//    var userId:String=""
    var selcomplaintid = Int()

    override func viewDidLoad()
    {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
//            self.complaintlistTbv.contentInsetAdjustmentBehavior = .never
            self.languagePopUpView.langListTblView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

        complaintslbl.font = UIFont.appFont(ofSize: complaintslbl.font!.pointSize)
        complaintsTfd.font = UIFont.appFont(ofSize: complaintsTfd.font!.pointSize)
        complaintsBtn.titleLabel!.font = UIFont.appFont(ofSize: complaintsBtn.titleLabel!.font!.pointSize)
        commentslbl.font = UIFont.appFont(ofSize: commentslbl.font!.pointSize)
        commentsTxtView.font = UIFont.appFont(ofSize: commentsTxtView.font!.pointSize)
        BtnSend.titleLabel!.font = UIFont.appFont(ofSize: BtnSend.titleLabel!.font!.pointSize)

//        self.GetUsersDetails()
        GetListofComplaints()
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
        bgImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["bgImgView"] = bgImgView
        formImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["formImgView"] = formImgView
        formImgView.contentMode = .scaleAspectFit
        
        complaintslbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["complaintslbl"] = complaintslbl
        complaintslbl.textAlignment = HelperClass.appTextAlignment
        complaintsview.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["complaintsview"] = complaintsview
        complaintsTfd.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["complaintsTfd"] = complaintsTfd
        complaintsTfd.textAlignment = HelperClass.appTextAlignment
        complaintsBtn.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["complaintsBtn"] = complaintsBtn
        complaintlistTbv.removeFromSuperview()
//        complaintlistTbv.translatesAutoresizingMaskIntoConstraints = false
//        layoutDic["complaintlistTbv"] = complaintlistTbv
        commentslbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["commentslbl"] = commentslbl
        commentslbl.textAlignment = HelperClass.appTextAlignment
        commentsTxtView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["CommentsTxtView"] = commentsTxtView
        commentsTxtView.textAlignment = HelperClass.appTextAlignment
        BtnSend.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnSend"] = BtnSend

        bgImgView.topAnchor.constraint(equalTo: self.top, constant: 0).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bgImgView(100)]", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bgImgView]|", options: [], metrics: nil, views: layoutDic))
        formImgView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        formImgView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        formImgView.centerXAnchor.constraint(equalTo: bgImgView.centerXAnchor).isActive = true
        formImgView.centerYAnchor.constraint(equalTo: bgImgView.bottomAnchor).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[formImgView]-(20)-[complaintslbl(30)]-(10)-[complaintsview(30)]-(20)-[commentslbl(30)]-(15)-[CommentsTxtView(100)]-(>=20)-[BtnSend(40)]", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[complaintslbl(180)]", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[complaintsview]-(20)-|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[commentslbl(180)]", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[complaintsTfd]-(20)-|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[CommentsTxtView]-(20)-|", options: [], metrics: nil, views: layoutDic))
        BtnSend.widthAnchor.constraint(equalToConstant: 150).isActive = true
        BtnSend.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

        complaintsview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(8)-[complaintsTfd]-(8)-[complaintsBtn]-(8)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        complaintsview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[complaintsTfd]|", options: [], metrics: nil, views: layoutDic))
        complaintsBtn.widthAnchor.constraint(equalTo: complaintsBtn.heightAnchor).isActive = true
//        complaintlistTbv.leadingAnchor.constraint(equalTo: complaintsview.leadingAnchor).isActive = true
//        complaintlistTbv.trailingAnchor.constraint(equalTo: complaintsview.trailingAnchor).isActive = true
//        complaintlistTbv.heightAnchor.constraint(equalToConstant: 150).isActive = true
//        complaintlistTbv.topAnchor.constraint(equalTo: complaintsview.bottomAnchor).isActive = true
        BtnSend.bottomAnchor.constraint(equalTo: self.bottom, constant: -20).isActive = true

        languagePopUpView.translatesAutoresizingMaskIntoConstraints = false
        languagePopUpView.delegate = self
        layoutDic["languagePopUpView"] = languagePopUpView
        languagePopUpView.removeFromSuperview()
        self.navigationController?.view.addSubview(languagePopUpView)
        self.navigationController?.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[languagePopUpView]|", options: [], metrics: nil, views: layoutDic))
        self.navigationController?.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[languagePopUpView]|", options: [], metrics: nil, views: layoutDic))
    }
    override func viewWillAppear(_ animated: Bool)
    {
        SetLocalization()
        customFormat()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    @IBAction func SendBtn(_ sender: Any)
    {
        var errmsg="" as String
        if(self.complaintsTfd.text!.isBlank)
        {
            errmsg="Please choose complaint type".localize()
        }
        else if(self.commentsTxtView.text!.isBlank)
        {
            errmsg="Please enter complaint description".localize()
        }
        if(errmsg.count>0)
        {
            self.showAlert("", message: errmsg)
//            alert(message: errmsg)
        }
        else
        {
            if ConnectionCheck.isConnectedToNetwork()
            {
                self.showLoadingIndicator()
                print("Connected")
                var paramDict = Dictionary<String, Any>()
                paramDict["id"] = HelperClass.shared.userID
                paramDict["token"] = HelperClass.shared.userToken
                paramDict["title"] = selcomplaintid
                paramDict["description"] = self.commentsTxtView.text
                print(paramDict)
                let url = HelperClass.BASEURL + HelperClass.savecomplaint
                print(url)
                Alamofire.request(url, method:.post, parameters: paramDict, headers: ["Accept":"application/json", "Content-Language":"en"])
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
                                    self.complaintsTfd.text=""
                                    self.commentsTxtView.text=""
//                                    self.stopLoadingIndicator()
                                    self.showToast(JSON["success_message"] as! String)

                                }
                                else
                                {
                                    print(JSON["error_message"] as! String)
                                    self.showToast(JSON["error_message"] as! String)

                                }
                            }
                        }
                        self.stopLoadingIndicator()
                }
            }
            else
            {
                self.showAlert("", message: "Internet not connected".localize())
//                (message: )
            }
        }
    }

//    @IBAction func NavigateBackBtn(_ sender: Any)
//    {
//        self.performSegue(withIdentifier: "ComplaintsVCToHomeVC", sender: self)
//    }

    func SetLocalization()
    {
        self.title = "Complaints".localize().uppercased(with: Locale(identifier: HelperClass.currentAppLanguage))
    }
    
    func customFormat()
    {
        self.commentsTxtView.layer.borderColor = UIColor.black.cgColor
        self.commentsTxtView.layer.borderWidth = 0.5
        self.commentsTxtView.layer.cornerRadius = 5
        self.commentsTxtView.layer.masksToBounds = false
        self.commentsTxtView.clipsToBounds = true

        self.complaintsview.layer.cornerRadius=5
        self.complaintsview.layer.borderWidth=0.5

         BtnSend.layer.cornerRadius = 5
    }

    // ***** Method To Get List of Complaints From API *****
    
    func GetListofComplaints()
    {
        self.showLoadingIndicator()
        if ConnectionCheck.isConnectedToNetwork()
        {
            guard let currentLocation = AppLocationManager.shared.locationManager.location else
            {
                return
            }
            print("Connected")
            let url = HelperClass.BASEURL + HelperClass.DriverComplaintsListURL
            var paramdict = Dictionary<String, Any>()
            paramdict["type"] = 1//Driver || Passenger
            paramdict["latitude"] = currentLocation.coordinate.latitude
            paramdict["longitude"] = currentLocation.coordinate.longitude
            paramdict["id"] = HelperClass.shared.userID
            paramdict["token"] = HelperClass.shared.userToken

            print("URL & Parameters for Complaints =",url,paramdict)
            Alamofire.request(url, method:.post, parameters: paramdict, encoding: JSONEncoding.default, headers:HelperClass.Header)
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
                                if let complaintsList = JSON["complaint_list"] as? [[String:AnyObject]], !complaintsList.isEmpty
                                {
                                    self.languagePopUpView.optionsList = complaintsList.map({
                                        (text:$0["title"] as! String,identifier:String($0["id"] as! Int))
                                    })
                                    self.languagePopUpView.tableTitle = "Select Complaint Type".localize().uppercased(with: Locale(identifier: HelperClass.currentAppLanguage))
                                    self.languagePopUpView.isHidden = false
                                } else {
                                    self.showAlert("Alert".localize(), message: "No Complaint Types Available")
                                }
                            }
                            else
                            {
                                print(JSON["error_message"] as! String)
                                self.showAlert("Alert".localize(), message: JSON["error_message"] as! String)                                
                            }
                        }
                    }
                    self.stopLoadingIndicator()
            }
        }
        else
        {
            print("disConnected")
            stopLoadingIndicator()
            self.showAlert("No Internet".localize(), message: "Please Check Your Internet Connection".localize())
        }
    }

//    func getContext () -> NSManagedObjectContext
//    {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        return appDelegate.persistentContainer.viewContext
//    }
//
//    func GetUsersDetails ()
//    {
//        let fetchRequest: NSFetchRequest<Login_UserData> = Login_UserData.fetchRequest()
//        do
//        {
//            let array_users = try getContext().fetch(fetchRequest)
//            print ("num of users = \(array_users.count)")
//            for user in array_users as [NSManagedObject]
//            {
//                print("\(String(describing: user.value(forKey: "loginuser_firstname")))")
//                HelperClass.shared.userName = (String(describing: user.value(forKey: "loginuser_firstname")!))
//                HelperClass.shared.userLastName = (String(describing: user.value(forKey: "loginuser_lastname")!))
//                HelperClass.shared.userID = (String(describing: user.value(forKey: "loginuser_ID")!))
//                HelperClass.shared.userToken = (String(describing: user.value(forKey: "loginuser_token")!))
//                HelperClass.shared.isUserActive = (String(describing: user.value(forKey: "loginuser_is_active")!))
//                HelperClass.shared.isUserApproved = (String(describing: user.value(forKey: "loginuser_is_approve")!))
//                HelperClass.shared.isUserAvailable  = (String(describing: user.value(forKey: "loginuser_is_available")!))
//                print("User ID =",HelperClass.shared.userID)
//                userId = (String(describing: user.value(forKey: "loginuser_ID")!))
//                userTokenstr = (String(describing: user.value(forKey: "loginuser_token")!))
//            }
//        }
//        catch
//        {
//            print("Error with request: \(error)")
//        }
//    }

    //    # pragma mark - NVActivityIndicatorView
    
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



    @IBAction func downbtnAction()
    {
        if let list = self.languagePopUpView.optionsList, !list.isEmpty
        {
            self.languagePopUpView.isHidden = false
            //self.complaintlistTbv.isHidden = !self.complaintlistTbv.isHidden
        }
        else
        {
            self.showAlert("", message: "There are no items in complaint list.".localize())
        }
    }

    //--------------------------------------
    // MARK: - Textview delegates
    //--------------------------------------

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if(text == "\n")
        {
            textView.resignFirstResponder()
            return false
        }
        let newText = (self.commentsTxtView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count // for Swift use count(newText)
        return numberOfChars < 200;
    }
}
extension ComplaintsVC:PopUpTableViewDelegate
{
    func popUpTableView(_ popUpTableView: PopUpTableView, didSelectOption option: Option, atIndex index: Int) {
        self.complaintsTfd.text = option.text
        selcomplaintid = Int(option.identifier)!
    }
}
