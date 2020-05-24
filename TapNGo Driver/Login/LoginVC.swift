//
//  LoginVC.swift
//  TapNGo Driver
//
//  Created by Spextrum on 07/10/17.
//  Copyright © 2017 nPlus. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField
import Alamofire
import NVActivityIndicatorView
//import CoreData
import SWRevealViewController
import Localize



class LoginVC: UIViewController,UITextFieldDelegate
{
    var layoutDic = [String:AnyObject]()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var bottom:NSLayoutAnchor<NSLayoutYAxisAnchor>!


    let countryPickerView = RJKCountryPickerView()
//    var countryPickerDelegate:RJKCountryPickerViewDelegate!
    let leftViewBtn = UIButton()
    var selectedCountry:Country = Country("India",dialCode:"+91",isoCode:"IN")


    var loginBtnWidth:NSLayoutConstraint!
    var loginBtnBottomSpace:NSLayoutConstraint!
    var bgImgViewHeight:NSLayoutConstraint!
    var logoImgViewYPos:NSLayoutConstraint!
    var logoImgViewYPosNew:NSLayoutConstraint!

    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var logoImgView: UIImageView!
    @IBOutlet weak var appNameImgView: UIImageView!
    @IBOutlet weak var TxtPhone_Email: JVFloatLabeledTextField!
    @IBOutlet weak var TxtPassword: JVFloatLabeledTextField!
    @IBOutlet weak var BtnForgetPassword: UIButton!
    @IBOutlet weak var BtnLogin: UIButton!
//    @IBOutlet weak var TxtCountryCode: UITextField!
//    @IBOutlet weak var BtnPickCounty: UIButton!
//    @IBOutlet weak var BGViewforPickerView: UIView!
    //@IBOutlet weak var CountryCodePickerView: CountryPicker!
    
    
    let AppDelegates = UIApplication.shared.delegate as! AppDelegate
//    let HelperObject = HelperClass()
    let Pref = UserDefaults.standard
    
    var CountryCode = String()
    var selectedCountryStr = String()

    var activityView: NVActivityIndicatorView!
    
    var loginmthd=""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        setUpViews()
        setupCountryPicker()
        keyBoardAppearnceAnimation()
        loginmthd = "email"
    }
    func keyBoardAppearnceAnimation()
    {
        //Login Btn Animation on keyboard appearance

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { (notification) in
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
//            if let keyBoardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue?.size
//            {
                //
//                self.loginBtnWidth.constant = keyBoardSize.width
//                self.loginBtnBottomSpace.constant = -keyBoardSize.height
                self.BtnLogin.layer.cornerRadius = 0
                self.bgImgViewHeight.constant = 120
//                self.bgImgView.image = UIImage()
                self.logoImgViewYPos.isActive = false
                self.logoImgViewYPosNew.isActive = true
                self.appNameImgView.alpha = 0.0
                UIView.animate(withDuration: duration, animations: {
                    self.view.layoutIfNeeded()
                })
//            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { (notification) in
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
            if self.bgImgViewHeight.constant != 240
            {
                self.BtnLogin.layer.cornerRadius = self.BtnLogin.bounds.height/2.0
                self.loginBtnWidth.constant = 120
                self.loginBtnBottomSpace.constant = -20
                self.bgImgViewHeight.constant = 240
//                self.bgImgView.image = UIImage(named: "Building_Background")
                self.logoImgViewYPos.isActive = true
                self.logoImgViewYPosNew.isActive = false
                self.appNameImgView.alpha = 1.0
                UIView.animate(withDuration: duration, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    func setupCountryPicker()
    {
        self.addPickerView()
        leftViewBtn.imageView?.contentMode = .scaleAspectFit
        leftViewBtn.adjustsImageWhenHighlighted = false
        leftViewBtn.contentEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 8)
        leftViewBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        leftViewBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: -3)
        leftViewBtn.titleLabel?.font = TxtPhone_Email.font!
        leftViewBtn.setTitleColor(TxtPhone_Email.textColor, for: .normal)
        leftViewBtn.setImage(UIImage(named:selectedCountry.isoCode!)!, for: .normal)
        leftViewBtn.setTitle(selectedCountry.dialCode!, for: .normal)
        leftViewBtn.sizeToFit()
        leftViewBtn.frame.size.height = TxtPhone_Email.frame.height
        leftViewBtn.addTarget(self, action: #selector(showCountryPickerView(_:)), for: .touchUpInside)
        if HelperClass.appTextAlignment == .left
        {
            TxtPhone_Email.leftView = leftViewBtn
//            TxtPhone_Email.leftViewMode = .always
        }
        else
        {
            TxtPhone_Email.rightView = leftViewBtn
//            TxtPhone_Email.rightViewMode = .always
        }
    }
    func addPickerView()
    {
        let window = AppDelegates.window!

        countryPickerView.delegate = self
        countryPickerView.translatesAutoresizingMaskIntoConstraints = false
        countryPickerView.isHidden = true
        countryPickerView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        window.addSubview(countryPickerView)
        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[countryPickerView]|", options: [], metrics: nil, views: ["countryPickerView":countryPickerView]))
        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[countryPickerView]|", options: [], metrics: nil, views: ["countryPickerView":countryPickerView]))

    }
    @objc func showCountryPickerView(_ sender:UIButton)
    {
        addPickerView()
        countryPickerView.isHidden = false
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
        bgImgView.contentMode = .center
        bgImgView.backgroundColor = .secondaryColor
        bgImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["bgImgView"] = bgImgView
        logoImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["logoImgView"] = logoImgView
        appNameImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["appNameImgView"] = appNameImgView
        TxtPhone_Email.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["TxtPhone_Email"] = TxtPhone_Email
        TxtPhone_Email.delegate = self
        TxtPhone_Email.addBorder(edges: .bottom)
        TxtPassword.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["TxtPassword"] = TxtPassword
        TxtPassword.addBorder(edges: .bottom)
        BtnForgetPassword.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnForgetPassword"] = BtnForgetPassword

        BtnLogin.backgroundColor = .secondaryColor
        BtnLogin.setTitleColor(.themeColor, for: .normal)
        BtnLogin.layer.borderColor = UIColor.themeColor.cgColor
        BtnLogin.layer.borderWidth = 1.0
        BtnLogin.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnLogin"] = BtnLogin

        logoImgView.isHidden = true
        appNameImgView.isHidden = true
        bgImgView.topAnchor.constraint(equalTo: self.top, constant: 0).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bgImgView]|", options: [], metrics: nil, views: layoutDic))
        bgImgViewHeight = bgImgView.heightAnchor.constraint(equalToConstant: 240)
        bgImgView.clipsToBounds = true
        bgImgViewHeight.isActive = true
        
        
        logoImgView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        logoImgView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        logoImgView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        logoImgViewYPosNew = NSLayoutConstraint.init(item: logoImgView, attribute: .centerY, relatedBy: .equal, toItem: bgImgView, attribute: .centerY, multiplier: 1, constant: 0)
        logoImgViewYPosNew.isActive = false
        logoImgViewYPosNew.priority = UILayoutPriority(rawValue: 0.400)
        self.view.addConstraint(logoImgViewYPosNew)
        
        logoImgViewYPos = NSLayoutConstraint.init(item: logoImgView, attribute: .centerY, relatedBy: .equal, toItem: bgImgView, attribute: .centerY, multiplier: 0.7, constant: 0)
        logoImgViewYPos.isActive = true
        self.view.addConstraint(logoImgViewYPos)
        
        
        appNameImgView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        appNameImgView.widthAnchor.constraint(equalToConstant: 240).isActive = true
        appNameImgView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.view.addConstraint(NSLayoutConstraint.init(item: appNameImgView, attribute: .centerY, relatedBy: .equal, toItem: bgImgView, attribute: .centerY, multiplier: 1.1, constant: 0))

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bgImgView]-(50)-[TxtPhone_Email(30)]-(25)-[TxtPassword(30)]-(25)-[BtnForgetPassword(30)]", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(30)-[TxtPhone_Email]-(30)-|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(30)-[TxtPassword]-(30)-|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[BtnForgetPassword]-(30)-|", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        
        BtnLogin.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        BtnLogin.heightAnchor.constraint(equalToConstant: 40).isActive = true
        loginBtnWidth = BtnLogin.widthAnchor.constraint(equalToConstant: 120)
        loginBtnWidth.isActive = true
        loginBtnBottomSpace = BtnLogin.bottomAnchor.constraint(equalTo: self.bottom, constant: -20)
        loginBtnBottomSpace.isActive = true

        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
        self.BtnLogin.layer.cornerRadius = self.BtnLogin.bounds.height/2.0

        BtnForgetPassword.contentHorizontalAlignment = HelperClass.appTextAlignment == .left ? .left : .right
        TxtPhone_Email.textAlignment = HelperClass.appTextAlignment
        TxtPassword.textAlignment = HelperClass.appTextAlignment
    }

    
    override func viewWillAppear(_ animated: Bool)
    {
       
        SetBackgroundImage()
        SetLocalization()
        customFormat()
        //loginmthd="mobile"
    }

   
    @IBAction func LoginBtn(_ sender: Any)
    {

        // self.performSegue(withIdentifier: "LoginVCToHomeVC", sender: self)

        if(loginmthd=="email")
        {
            if(self.TxtPhone_Email.text == "")
            {
                self.showAlert("Alert".localize(), message: "Please Enter your Registered Email ID".localize())
            }
            else if(self.TxtPassword.text == "")
            {
                self.showAlert("Alert".localize(), message: "Please Enter your Password".localize())
            }
            else
            {
                showLoadingIndicator()
                LoginAPI()
            }
        }
        else if(loginmthd=="mobile")
        {
            if(self.selectedCountry.dialCode! == "")
            {
                self.showAlert("Alert".localize(), message: "Please Choose your Country".localize())
            }
            else if(self.TxtPhone_Email.text == "")
            {
                self.showAlert("Alert".localize(), message: "Please Enter your Registered Mobile Number".localize())
            }
            else if(self.TxtPassword.text == "")
            {
                self.showAlert("Alert".localize(), message: "Please Enter your Password".localize())
            }
            else
            {
                showLoadingIndicator()
                LoginAPI()
            }
        }
    }
    
    @IBAction func ForgetPasswordBtn(_ sender: Any)
    {
        self.view.endEditing(true)
        let forgetPasswordVC = self.storyboard?.instantiateViewController(withIdentifier: "ForgetPasswordVC") as! ForgetPasswordVC
        self.navigationController?.pushViewController(forgetPasswordVC, animated: true)
    }
    
    @IBAction func PickCountryBtn(_ sender: Any)
    {
//        self.BGViewforPickerView.isHidden = false//rjk
    }

    // a picker item was selected
//    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage)
//    {
//        print("Coutry Code = ",phoneCode)
//        //pick up anythink
//        CountryCode = phoneCode
//        SelectedCountry = name
//        TxtCountryCode.text = CountryCode //+ "    " + name
//        TxtCountryCode.leftViewMode = UITextFieldViewMode.always
//        let imageView = UIImageView(frame: CGRect(x: 238, y: 0, width: 25, height: 15))
//        let image = flag
//        imageView.image = image
//        TxtCountryCode.leftView = imageView
//
//        BGViewforPickerView.isHidden = true
//    }
    
//    @IBAction func BackBtnNavigate(_ sender: Any)
//    {
//        self.performSegue(withIdentifier: "LoginVCToLoginBaseVC", sender: self)
//    }
    
    func LoginAPI()
    {
//        self.showLoadingIndicator()
        
        if ConnectionCheck.isConnectedToNetwork()
        {
            print("Connected")
            let url = HelperClass.BASEURL + HelperClass.LoginURL
            var paramdict = Dictionary<String, Any>()
            
            if !"0123456789".contains(self.TxtPhone_Email.text!.first!)
            {
                paramdict["username"] = self.TxtPhone_Email.text
            }
            else
            {
                paramdict["username"] =  self.selectedCountry.dialCode! + self.TxtPhone_Email.text!
            }
            
            paramdict["password"] = self.TxtPassword.text!
            paramdict["device_token"] = AppDelegates.DeviceToken == "" ? "1231422525252323" : AppDelegates.DeviceToken
            paramdict["login_by"] = "ios"
            paramdict["login_method"] = "manual"
            paramdict["social_unique_id"] = ""
            
            print("URL & Parameters =",url,paramdict)
            
            Alamofire.request(url, method:.post, parameters: paramdict, encoding: JSONEncoding.default, headers:HelperClass.Header)
                .responseJSON
                { response in
                    if case .failure(let error) = response.result
                    {
                        print(error.localizedDescription)
                    }
                    else if case .success = response.result
                    {
                        print(response.result.value)
                        if let JSON = response.result.value as? [String:AnyObject], let status = JSON["success"] as? Bool
                        {
                            if status
                            {
                                let UserDetails = JSON["driver"] as! [String:AnyObject]

                                //                        ios - Gopi - vignesh@erdster.co.uk

                                self.Pref.set(JSON["sos"], forKey: "SOSDetails")  //setObject as! NSArray
                                self.Pref.set(UserDetails["is_available"], forKey: "IsDriverAvailable")
                                self.Pref.set(UserDetails["is_active"], forKey: "IsDriverActive")
                                self.Pref.set(UserDetails["is_approve"], forKey: "IsDriverApprove")
                                self.Pref.synchronize()
                                print(UserDetails)
                                print(UserDetails["firstname"] as! String)
                                HelperClass.shared.storeUserDetails(UserDetails, currentUser: nil)
                                self.stopLoadingIndicator()
                                AppLocationManager.shared.startTracking()
                                AppSocketManager.shared.establishConnection()
                                let swRevealViewController = SWRevealViewController()
                                swRevealViewController.navigationItem.hidesBackButton = true
                                let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                                swRevealViewController.frontViewController = UINavigationController(rootViewController: homeVC)
                                swRevealViewController.rearViewController = self.storyboard?.instantiateViewController(withIdentifier: "LeftSideSliderVC") as! LeftSideSliderVC
                                swRevealViewController.rightViewController = self.storyboard?.instantiateViewController(withIdentifier: "LeftSideSliderVC") as! LeftSideSliderVC
                                self.navigationController?.present(swRevealViewController, animated: true, completion: nil)

                            }
                            else
                            {
                                print(JSON["error_message"] as! String)
                                self.stopLoadingIndicator()
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

//    func storeUserDetails(_ userDetails: [String:AnyObject])
//    {
//        let context = HelperClass.shared.persistentContainer.viewContext
//        print("userDictionary is: ",User_Details)
//
//        let z : Int = Int((User_Details["id"] as? NSNumber)!)
//        let myIDString = String(z)
//        print("My New ID",myIDString)
//
//        let w : Int = Int((User_Details["is_available"] as? NSNumber)!)
//        let isavailableString = String(w)
//        print("My New ID",isavailableString)
//
//        let x : Int = Int((User_Details["is_active"] as? NSNumber)!)
//        let isactiveString = String(x)
//        print("My New ID",isactiveString)
//
//        let y : Int = Int((User_Details["is_approve"] as? NSNumber)!)
//        let isapproveString = String(y)
//        print("My New ID",isapproveString)
//
//        //retrieve the entity that we just created
//        //        let entity =  NSEntityDescription.entity(forEntityName: "Login_UserData", in: context)
//        //        let user = NSManagedObject(entity: entity!, insertInto: context)
//        //set the entity values
//        let user = Login_UserData(context: HelperClass.shared.persistentContainer.viewContext)
//        user.loginuser_firstname = (User_Details["firstname"] as! String)
//        user.loginuser_ID = myIDString
//        user.loginuser_token = (User_Details["token"] as! String)
//        user.loginuser_is_approve = isapproveString
//        user.loginuser_is_active = isactiveString
//        user.loginuser_is_available = isavailableString
//        user.loginuser_lastname = (User_Details["lastname"] as! String)
//        user.loginuser_email = (User_Details["email"] as! String)
//        user.loginuser_phone = (User_Details["phone"] as! String)
//        user.loginuser_profilepicture = (User_Details["profile_pic"] as! String)
//        print("Hello ID",myIDString)
//        print("Hello UserToken",User_Details["token"] as! String)
//
//
//        //save the object
//        do
//        {
//            try context.save()
//            print("saved!")
//        }
//        catch let error as NSError
//        {
//            print("Could not save \(error), \(error.userInfo)")
//        }
//        catch
//        {
//
//        }
//
//    }


    
    func SetLocalization()
    {
        self.title = "Login".localize().uppercased(with: Locale(identifier: HelperClass.currentAppLanguage))
    }
    
    func customFormat()
    {
        self.navigationItem.backBtnString = ""
//        BtnLogin.layer.cornerRadius = 10
//        self.BGViewforPickerView.isHidden = true//rjk
    }
    
    func SetBackgroundImage()
    {
//        self.bgImgView.image = UIImage(named: "Building_Background")
//        UIGraphicsBeginImageContext(self.bgImgView.frame.size)
//        UIImage(named: "Building_Background")?.draw(in: self.bgImgView.bounds)
//
//        if let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
//        {
//            UIGraphicsEndImageContext()
//            self.bgImgView.backgroundColor = UIColor(patternImage: image)
//        }
//        else
//        {
//            UIGraphicsEndImageContext()
//            debugPrint("Image not available")
//        }
        
    }

    // ***** Tap Gesture Action *****

    

    // ***** Method to Detect Numbers in a String *****
    
   
    

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if(textField==self.TxtPhone_Email)
        {
            if let text = textField.text as NSString?
            {
                let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
                if(txtAfterUpdate.count==0)
                {
//                    self.BtnPickCounty.isHidden=true
//                    self.TxtCountryCode.isHidden=true
                    if HelperClass.appTextAlignment == .left
                    {
                        self.TxtPhone_Email.leftViewMode = .never
                    }
                    else
                    {
                        self.TxtPhone_Email.rightViewMode = .never
                    }
                }
                else //(txtAfterUpdate.count>5)
                {
                    if "0123456789".contains(txtAfterUpdate.first!)
                    {
                        print("mobile")
                        loginmthd="mobile"
//                        self.BtnPickCounty.isHidden=true
//                        self.TxtCountryCode.isHidden=true
                        if HelperClass.appTextAlignment == .left
                        {
                            self.TxtPhone_Email.leftViewMode = .always
                        }
                        else
                        {
                            self.TxtPhone_Email.rightViewMode = .always
                        }
                    }
                    else
                    {
                        print("email")
//                        self.BtnPickCounty.isHidden=false
//                        self.TxtCountryCode.isHidden=false
                        if HelperClass.appTextAlignment == .left
                        {
                            self.TxtPhone_Email.leftViewMode = .never
                        }
                        else
                        {
                            self.TxtPhone_Email.rightViewMode = .never
                        }
                        loginmthd="email"
                    }
                }
            }
        }
        return true
    }
    
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
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension LoginVC:RJKCountryPickerViewDelegate
{
    func countrySelected(_ selectedCountry: Country) {
        self.selectedCountry = selectedCountry
        leftViewBtn.setImage(UIImage(named:selectedCountry.isoCode!)!, for: .normal)
        leftViewBtn.setTitle(selectedCountry.dialCode!, for: .normal)
        leftViewBtn.sizeToFit()
        leftViewBtn.frame.size.height = TxtPhone_Email.frame.height
        TxtPhone_Email.layoutSubviews()
    }
}

