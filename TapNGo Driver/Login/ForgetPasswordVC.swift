//
//  ForgetPasswordVC.swift
//  TapNGo Driver
//
//  Created by Spextrum on 13/10/17.
//  Copyright © 2017 nPlus. All rights reserved.
//

import UIKit
import Alamofire
import Localize
import NVActivityIndicatorView


class ForgetPasswordVC: UIViewController, UITextFieldDelegate
{
    
    var layoutDic = [String:AnyObject]()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var bottom:NSLayoutAnchor<NSLayoutYAxisAnchor>!

//    let countryImgView = UIImageView()
//    let countryCodeLbl = UILabel()
//    var selectedCountry:Country!

    var submitBtnWidth:NSLayoutConstraint!
    var submitBtnBottomSpace:NSLayoutConstraint!
    
    
    @IBOutlet weak var phoneNumLbl: UILabel!
    //    @IBOutlet weak var TxtCountryCode: UITextField!
    @IBOutlet weak var TxtMobileNumber: RJKCountryPickerTextField!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var BGViewForTxtFields: UIView!
    @IBOutlet weak var BGViewForPicker: UIView!
    //    @IBOutlet weak var CountryCodePickerView: CountryPicker!
    @IBOutlet weak var BtnSubmit: UIButton!
    @IBOutlet weak var BtnSelectCountry: UIButton!
    
    let AppDelegates = UIApplication.shared.delegate as! AppDelegate
//    let HelperObject = HelperClass()
    var activityView: NVActivityIndicatorView!
    
    var CountryCode = String()
    var selectedCountryStr = String()
    var TemporaryToken = String()
    
    var loginmthd = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurButton(_:)))
        self.view.addGestureRecognizer(tapGesture)
        //        CountryCodePickerView.countryPickerDelegate = self
        //        CountryCodePickerView.showPhoneNumbers = true
        
        self.GenerateToken()
        // Do any additional setup after loading the view.
        loginmthd = "email"
        self.setUpViews()
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: OperationQueue.main) { (notification) in
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
            if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue?.size
            {
                self.submitBtnWidth.constant = keyBoardSize.width
                self.submitBtnBottomSpace.constant = -keyBoardSize.height
                self.BtnSubmit.layer.cornerRadius = 0
                UIView.animate(withDuration: duration, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { (notification) in
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
            if self.submitBtnWidth.constant != 120
            {
                self.BtnSubmit.layer.cornerRadius = self.BtnSubmit.bounds.height/2.0
                self.submitBtnWidth.constant = 120
                self.submitBtnBottomSpace.constant = -20
                UIView.animate(withDuration: duration, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    func setUpViews()
    {
//        countryCodeLbl.text = "+91"
        if #available(iOS 11.0, *) {
            self.top = self.view.safeAreaLayoutGuide.topAnchor
            self.bottom = self.view.safeAreaLayoutGuide.bottomAnchor
        } else {
            self.top = self.topLayoutGuide.bottomAnchor
            self.bottom = self.bottomLayoutGuide.topAnchor
        }
        
        TxtMobileNumber.delegate = self
        self.TxtMobileNumber.leftViewMode = .never
        self.TxtMobileNumber.rightViewMode = .never
        self.TxtMobileNumber.autocorrectionType = .no
        self.TxtMobileNumber.autocapitalizationType = .none
        self.TxtMobileNumber.keyboardType = .emailAddress
        self.TxtMobileNumber.autocorrectionType = .no
        self.TxtMobileNumber.autocapitalizationType = .none

        
        phoneNumLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["phoneNumLbl"] = phoneNumLbl
        TxtMobileNumber.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["TxtMobileNumber"] = TxtMobileNumber
        TxtMobileNumber.addBorder(edges: .bottom)
        infoLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["infoLbl"] = infoLbl

        BtnSubmit.backgroundColor = .secondaryColor
        BtnSubmit.setTitleColor(.themeColor, for: .normal)
        BtnSubmit.layer.borderColor = UIColor.themeColor.cgColor
        BtnSubmit.layer.borderWidth = 1.0
        BtnSubmit.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnSubmit"] = BtnSubmit
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[phoneNumLbl(30)]-(30)-[TxtMobileNumber(30)]-(15)-[infoLbl(30)]", options: [.alignAllLeading,.alignAllTrailing], metrics: nil, views: layoutDic))
        self.view.addConstraint(NSLayoutConstraint.init(item: TxtMobileNumber, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 0.6, constant: 0))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[TxtMobileNumber]-(16)-|", options: [], metrics: nil, views: layoutDic))
        
        
        BtnSubmit.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        BtnSubmit.heightAnchor.constraint(equalToConstant: 40).isActive = true
        submitBtnWidth = BtnSubmit.widthAnchor.constraint(equalToConstant: 120)
        submitBtnWidth.isActive = true
        submitBtnBottomSpace = BtnSubmit.bottomAnchor.constraint(equalTo: self.bottom, constant: -20)
        submitBtnBottomSpace.isActive = true

        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
        BtnSubmit.layer.cornerRadius = BtnSubmit.bounds.height/2.0

        phoneNumLbl.text = "Email or Phone Number"
        phoneNumLbl.font = UIFont.appTitleFont(ofSize: 16)
        infoLbl.text = "Please verify your registered mail or phone"
        infoLbl.font = UIFont.appTitleFont(ofSize: 16)
        phoneNumLbl.textAlignment = HelperClass.appTextAlignment
        TxtMobileNumber.textAlignment = HelperClass.appTextAlignment
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        
        SetLocalization()
        customFormat()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.TxtMobileNumber {
            if let text = textField.text as NSString? {
                let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
                if txtAfterUpdate.count==0 {
                    if HelperClass.appTextAlignment == .left {
                        self.TxtMobileNumber.leftViewMode = .never
                    } else {
                        self.TxtMobileNumber.rightViewMode = .never
                    }
                    
                }
                if txtAfterUpdate.count>0 {
                    let searchTerm = txtAfterUpdate
                    let characterset = CharacterSet(charactersIn: "0123456789")
                    if searchTerm.rangeOfCharacter(from: characterset.inverted) != nil {
                        print("string contains special characters")
                        loginmthd = "email"
                        if HelperClass.appTextAlignment == .left {
                            self.TxtMobileNumber.leftViewMode = .never
                        } else {
                            self.TxtMobileNumber.rightViewMode = .never
                        }
                    } else {
                        if HelperClass.appTextAlignment == .left {
                            self.TxtMobileNumber.leftViewMode = .always
                        } else {
                            self.TxtMobileNumber.rightViewMode = .always
                        }
                        loginmthd = "mobile"
                    }
                }
            }
        }
        return true
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
    //        BGViewForPicker.isHidden = true
    //    }
    
    
    @IBAction func SelectCountryCodeBtn(_ sender: Any)
    {
        //        self.BGViewForPicker.isHidden = false//rjk
    }
    
    @IBAction func SubmitBtn(_ sender: Any)
    {
        if(self.TxtMobileNumber.selectedCountry.dialCode! == "")
        {
            self.showAlert("", message: "Please Choose Your Country".localize())
            return
        }
        else if(self.TxtMobileNumber.text == "")
        {
            self.showAlert("", message: "Please Enter Your Registered Mobile Number or email".localize())
            return
        }
        else
        {
            ForgetPassword()
        }
        
    }
    
    // ***** Method to Generate Temporary Token *****
    
    func GenerateToken()
    {
        self.showLoadingIndicator()
        if ConnectionCheck.isConnectedToNetwork()
        {
            print("Connected")
            let url = HelperClass.BASEURL + HelperClass.TokenGeneraterURL
            
            print("URL & Parameters =",url)
            
            Alamofire.request(url, method:.post, parameters: nil, encoding: JSONEncoding.default, headers:HelperClass.Header)
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
                                self.TemporaryToken = JSON["token"] as! String
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
//            self.showAlert(, message: )
            self.showAlert("No Internet".localize(), message: "Please Check Your Internet Connection".localize())
        }
        
        
    }
    
    // ***** Method for Forget Password API *****
    
    func ForgetPassword()
    {
        self.showLoadingIndicator()
        if ConnectionCheck.isConnectedToNetwork()
        {
            print("Connected")
            let url = HelperClass.BASEURL + HelperClass.ForgetPasswordURL
            var paramdict = Dictionary<String, Any>()
            
            paramdict["token"] = self.TemporaryToken;
            if loginmthd == "mobile" {
                if let dialCode = self.TxtMobileNumber.selectedCountry.dialCode {
                    var phNumber = self.TxtMobileNumber.text!
                    print(phNumber)
                    while phNumber.starts(with: "0") {
                        phNumber = String(phNumber.dropFirst())
                        print(phNumber)
                    }
                    paramdict["phone_number"] = dialCode + phNumber
                }
            } else {
                paramdict["phone_number"] = self.TxtMobileNumber.text!
            }
            
            print("URL & Parameters for Forget Password =",url,paramdict)
            
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
                                let UserDetails = JSON["user"] as! [String:AnyObject]
                                print(UserDetails)
                                self.navigationController?.view.showToast("password sent to you")
                                self.navigationController?.popViewController(animated: true)
                            }
                            else
                            {
                                print(JSON["error_message"] as! String)
                                let alertController = UIAlertController(title: "Alert", message: JSON["error_message"] as? String, preferredStyle: .alert)
                                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertController.addAction(OKAction)
                                self.present(alertController, animated: true, completion: nil)

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
    
    
//    @IBAction func NavigateBackBtn(_ sender: Any)
//    {
//        self.performSegue(withIdentifier: "ForgetPasswordVCToLoginVC", sender: self)
//    }
    
    
    func SetLocalization()
    {
        self.title = "Forget password".localize().uppercased(with: Locale(identifier: HelperClass.currentAppLanguage))
    }
    
    func customFormat()
    {
//        BtnSubmit.layer.cornerRadius = 5
        //        self.BGViewForPicker.isHidden = true//rjk
    }
    
    
    // ***** Tap Gesture Action *****
    
    @objc func tapBlurButton(_ sender: UITapGestureRecognizer)
    {
        print("Please Hide!")
        //        BGViewForPicker.isHidden = true//rjk
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
