//
//  RegisterUserDetailsVC.swift
//  TapNGo Driver
//
//  Created by Spextrum on 09/10/17.
//  Copyright © 2017 nPlus. All rights reserved.
//

import UIKit
import Alamofire
import Localize
import SocketIO

class RegisterUserDetailsVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    
    
    struct Area
    {
        var adminName:String!
        var areaName:String!
        var id:Int!
        init(_ dict:[String:AnyObject]) {
            self.adminName = dict["admin_name"] as? String
            self.areaName = dict["area_name"] as? String
            self.id = dict["id"] as? Int
        }
    }
    var userDetails = UserDetails()

    
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var registrationLbl: UILabel!
    @IBOutlet weak var firstNameTxtField: UITextField!
    @IBOutlet weak var lastNameTxtField: UITextField!
    @IBOutlet weak var emailIDTxtField: UITextField!
    @IBOutlet weak var mobileNumberTxtField: RJKCountryPickerTextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    
    @IBOutlet weak var areaTxtField: RJKPickerTextField!

    var txtAddress = UITextField()
    var btnAgree = UIButton()
    var btnCheck = UIButton()
    
    @IBOutlet weak var BtnNext: UIButton!
    @IBOutlet weak var BtnProfilePicture: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    

    var areaList = [Area]()
    
    

//    @IBOutlet weak var BGViewForPickerView: UIView!
//    @IBOutlet weak var CountryCodePickerView: CountryPicker!
    
    
    let AppDelegates = UIApplication.shared.delegate as! AppDelegate
//    let HelperObject = HelperClass()

    var ProfileimagePicker = UIImagePickerController()
    var iSProfileImage = String()
    
    var CountryCode = String()
    var selectedCountryStr = String()
    
    var layoutDic = [String:AnyObject]()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var bottom:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        registrationLbl.font = UIFont.appBoldTitleFont(ofSize: registrationLbl.font!.pointSize)
        firstNameTxtField.font = UIFont.appFont(ofSize: firstNameTxtField.font!.pointSize)
        lastNameTxtField.font = UIFont.appFont(ofSize: lastNameTxtField.font!.pointSize)
        emailIDTxtField.font = UIFont.appFont(ofSize: emailIDTxtField.font!.pointSize)
        mobileNumberTxtField.font = UIFont.appFont(ofSize: mobileNumberTxtField.font!.pointSize)
        passwordTxtField.font = UIFont.appFont(ofSize: passwordTxtField.font!.pointSize)

        areaTxtField.font = UIFont.appFont(ofSize: areaTxtField.font!.pointSize)
        BtnNext.titleLabel!.font = UIFont.appFont(ofSize: BtnNext.titleLabel!.font!.pointSize)


        self.iSProfileImage = "NO"
        ProfileimagePicker.delegate = self
        
//        CountryCodePickerView.countryPickerDelegate = self
//        CountryCodePickerView.showPhoneNumbers = true
        // Do any additional setup after loading the view.
        firstNameTxtField.delegate = self
        firstNameTxtField.returnKeyType = .next
        lastNameTxtField.delegate = self
        lastNameTxtField.returnKeyType = .next
        emailIDTxtField.delegate = self
        emailIDTxtField.returnKeyType = .next
        passwordTxtField.delegate = self
        passwordTxtField.returnKeyType = .next
        txtAddress.delegate = self
        txtAddress.returnKeyType = .next
        mobileNumberTxtField.delegate = self
        areaTxtField.changeTextFieldType(.pickerView)

        if ConnectionCheck.isConnectedToNetwork()
        {
            let url = HelperClass.BASEURL+HelperClass.getAreaList
            Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: HelperClass.Header).responseJSON { (response) in

                if case .failure(let error) = response.result
                {
                    print(error.localizedDescription)
                }
                else if case .success = response.result
                {
                    if let JSON = response.result.value as? [String:AnyObject], let status = JSON["success"] as? Bool
                    {
                        print(response.result.value)
                        if status
                        {
                            self.areaList = (JSON["admins"] as! [[String:AnyObject]]).map({ Area($0) })
                            self.areaTxtField.itemList = self.areaList.map({ $0.areaName })
                        }
                        else
                        {
                            print(JSON["error_message"] as! String)
                        }
                    }
                }
                
            }
        }
        else
        {
            self.showAlert("No Internet".localize(), message: "Please Check Your Internet Connection".localize())
        }
        setupViews()
    }
    
    

    //Setting constraints
    func setupViews()
    {
        if #available(iOS 11.0, *) {
            self.top = self.view.safeAreaLayoutGuide.topAnchor
            self.bottom = self.view.safeAreaLayoutGuide.bottomAnchor
        } else {
            self.top = self.topLayoutGuide.bottomAnchor
            self.bottom = self.bottomLayoutGuide.topAnchor
        }
        bgImgView.backgroundColor = .secondaryColor
        bgImgView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["bgImgView"] = bgImgView

        BtnProfilePicture.imageView?.tintColor = .themeColor
        BtnProfilePicture.setImage(BtnProfilePicture.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        BtnProfilePicture.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnProfilePicture"] = BtnProfilePicture

        registrationLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["registrationLbl"] = registrationLbl
        
        firstNameTxtField.addBorder(edges: .bottom)
        firstNameTxtField.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["firstNameTxtField"] = firstNameTxtField
        lastNameTxtField.addBorder(edges: .bottom)
        lastNameTxtField.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["lastNameTxtField"] = lastNameTxtField
        emailIDTxtField.addBorder(edges: .bottom)
        emailIDTxtField.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["emailIDTxtField"] = emailIDTxtField
        passwordTxtField.addBorder(edges: .bottom)
        passwordTxtField.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["passwordTxtField"] = passwordTxtField

        mobileNumberTxtField.addBorder(edges: .bottom)
        mobileNumberTxtField.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["mobileNumberTxtField"] = mobileNumberTxtField
        mobileNumberTxtField.countryPickerView.countrySearchBar.placeholder = "Search here...".localize()
        
        areaTxtField.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["areaTxtField"] = areaTxtField
        areaTxtField.addBorder(edges: .bottom)

        txtAddress.placeholder = "Address"
        txtAddress.font = areaTxtField.font!
        txtAddress.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["txtAddress"] = txtAddress
        txtAddress.addBorder(edges: .bottom)
        self.view.addSubview(txtAddress)

        btnAgree.titleLabel?.numberOfLines = 0
        btnAgree.titleLabel?.lineBreakMode = .byWordWrapping
        btnAgree.setTitle("Accept Terms and Conditions and Privacy Policy", for: .normal)
        btnAgree.setTitleColor(UIColor.gray, for: .normal)
        btnAgree.addTarget(self, action: #selector(btnAgreePressed(_ :)), for: .touchUpInside)
        btnAgree.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["btnAgree"] = btnAgree
        self.view.addSubview(btnAgree)

        btnCheck.setImage(UIImage(named: "unselectbox"), for: .normal)
        btnCheck.isSelected = false
        btnCheck.addTarget(self, action: #selector(btnCheckPressed), for: .touchUpInside)
        btnCheck.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["btnCheck"] = btnCheck
        self.view.addSubview(btnCheck)

        pageControl.pageIndicatorTintColor = .yellow
        pageControl.currentPageIndicatorTintColor = .themeColor
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["pageControl"] = pageControl

        BtnNext.backgroundColor = .secondaryColor
        BtnNext.setTitleColor(.themeColor, for: .normal)
        BtnNext.layer.borderColor = UIColor.themeColor.cgColor
        BtnNext.layer.borderWidth = 1.0
        BtnNext.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnNext"] = BtnNext

        bgImgView.topAnchor.constraint(equalTo: self.top, constant: 0).isActive = true
        self.bgImgView.heightAnchor.constraint(equalToConstant: self.view.frame.height / 6.0).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bgImgView]|", options: [], metrics: nil, views: layoutDic))
        self.BtnProfilePicture.widthAnchor.constraint(equalToConstant: self.view.frame.height / 7.0).isActive = true
        self.BtnProfilePicture.heightAnchor.constraint(equalToConstant: self.view.frame.height / 7.0).isActive = true
        self.BtnProfilePicture.centerXAnchor.constraint(equalTo: bgImgView.centerXAnchor).isActive = true
        self.BtnProfilePicture.centerYAnchor.constraint(equalTo: bgImgView.bottomAnchor).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[BtnProfilePicture]-(8)-[registrationLbl(20)]-(10)-[firstNameTxtField(30)]-(8)-[emailIDTxtField]", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[areaTxtField]-10-[btnAgree(50)]", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[btnAgree]-(>=8)-[pageControl(20)]-(4)-[BtnNext(40)]", options: [.alignAllCenterX], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[areaTxtField]-20-[btnCheck(20)]", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[emailIDTxtField(30)]-(8)-[passwordTxtField(30)]-(8)-[mobileNumberTxtField(30)]-(8)-[txtAddress(30)]-(8)-[areaTxtField(30)]", options: [.alignAllLeading,.alignAllTrailing], metrics: nil, views: layoutDic))
         self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[txtAddress]-(16)-|", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[registrationLbl(150)]", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[firstNameTxtField]-(8)-[lastNameTxtField(==firstNameTxtField)]-(16)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[emailIDTxtField]-(16)-|", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[btnCheck(20)]-(8)-[btnAgree]-16-|", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        self.pageControl.widthAnchor.constraint(equalToConstant: 60).isActive = true
        self.BtnNext.widthAnchor.constraint(equalToConstant: 120).isActive = true
        BtnNext.bottomAnchor.constraint(equalTo: self.bottom, constant: -20).isActive = true        
        

        let areaLbl = UILabel()
        areaLbl.translatesAutoresizingMaskIntoConstraints = false
        areaLbl.text = "Area".localize()
        areaLbl.font = areaTxtField.font!
        areaLbl.textColor = .gray
        areaLbl.sizeToFit()
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: areaLbl.bounds.width + 10, height: areaTxtField.bounds.height))
        
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        paddingView.addSubview(areaLbl)
        paddingView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(5)-[areaLbl]-(5)-|", options: [], metrics: nil, views: ["areaLbl":areaLbl]))
        paddingView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[areaLbl]-(0)-|", options: [], metrics: nil, views: ["areaLbl":areaLbl]))
        if HelperClass.appTextAlignment == .left
        {
            areaTxtField.leftViewMode = .always
            areaTxtField.leftView = paddingView
        }
        else
        {
            areaTxtField.rightViewMode = .always
            areaTxtField.rightView = paddingView
        }
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
        BtnNext.layer.cornerRadius = BtnNext.bounds.height/2
        self.BtnProfilePicture.layer.cornerRadius = self.BtnProfilePicture.frame.height/2
        self.BtnProfilePicture.clipsToBounds = true

        registrationLbl.textAlignment = HelperClass.appTextAlignment
        firstNameTxtField.textAlignment = HelperClass.appTextAlignment
        lastNameTxtField.textAlignment = HelperClass.appTextAlignment
        emailIDTxtField.textAlignment = HelperClass.appTextAlignment
        passwordTxtField.textAlignment = HelperClass.appTextAlignment
        txtAddress.textAlignment = HelperClass.appTextAlignment
        mobileNumberTxtField.textAlignment = HelperClass.appTextAlignment
        areaTxtField.textAlignment = HelperClass.appTextAlignment



    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.title = "Register".localize().uppercased(with: Locale(identifier: HelperClass.currentAppLanguage))
        customFormat()

    }

    @objc func btnAgreePressed(_ sender: UIButton) {

        let vc = TermsNConditionsVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func btnCheckPressed() {
        if(btnCheck.isSelected == false) {
            btnCheck.setImage(UIImage(named: "selectbox"), for: .normal)
            btnCheck.isSelected = true
        }
        else {
            btnCheck.setImage(UIImage(named: "unselectbox"), for: .normal)
            btnCheck.isSelected = false
        }
    }

    @IBAction func ProfilePictureBtn(_ sender: Any)
    {
        let alert = UIAlertController(title: "Choose Image".localize(), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera".localize(), style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery".localize(), style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel".localize(), style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            {
                BtnProfilePicture.setImage(image, for: .normal)
//                ProfileImageView.image = image
                self.iSProfileImage = "YES"
    }
            else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            {
                BtnProfilePicture.setImage(image, for: .normal)
//                ProfileImageView.image = image
                self.iSProfileImage = "YES"
            }
            else
            {
                print("Something went wrong")
                self.iSProfileImage = "NO"
            }
            picker.dismiss(animated: true, completion: nil)
        if let imgView = BtnProfilePicture.imageView, let img = imgView.image
        {
            print("Profile Image Path = ",img)
        }
        
        
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            ProfileimagePicker.sourceType = UIImagePickerController.SourceType.camera
            ProfileimagePicker.allowsEditing = true
            self.present(ProfileimagePicker, animated: true, completion: nil)
        }
        else
        {
            self.showAlert("Warning".localize(), message: "You don't have camera".localize())
        }
    }
    
    func openGallary()
    {
        ProfileimagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        ProfileimagePicker.allowsEditing = true
        self.present(ProfileimagePicker, animated: true, completion: nil)
    }


    
    @IBAction func NextBtn(_ sender: Any)
    {
        self.CheckEmptyFields_Naviagte()
    }


    func customFormat()
    {
        self.navigationItem.backBtnString = ""


    }
    
    func CheckEmptyFields_Naviagte()
    {
        if(self.iSProfileImage == "NO")
        {
            self.showAlert("Alert".localize(), message: "Please Upload Your Profile Picture".localize())
            return
        }
        else if firstNameTxtField.text!.isBlank
        {
            self.showAlert("Alert".localize(), message: "Please Enter Your Firstname".localize())
            return
        }
        else if lastNameTxtField.text!.isBlank
        {
            self.showAlert("Alert".localize(), message: "Please Enter Your Lastname".localize())
            return
        }
        else if emailIDTxtField.text!.isBlank || !emailIDTxtField.text!.isValidEmail
        {
            self.showAlert("Alert".localize(), message: "Please Enter A Valid Email ID".localize())
            return
        }
        else if mobileNumberTxtField.selectedCountry.dialCode == nil
        {
            self.showAlert("Alert".localize(), message: "Please Choose Your Country".localize())
            return
        }
        else if mobileNumberTxtField.text!.isBlank || !mobileNumberTxtField.text!.isValidPhoneNumber
        {
            self.showAlert("Alert".localize(), message: "Please Enter A Valid Mobile Number".localize())
            return
        }
        else if passwordTxtField.text!.isBlank
        {
            self.showAlert("Alert".localize(), message: "Please Enter Your Password".localize())
            return
        }
        else if txtAddress.text!.isBlank
        {
            self.showAlert("Alert".localize(), message: "Please Enter Your Address".localize())
            return
        }
        else if areaTxtField.text!.isBlank
        {
            self.showAlert("Alert".localize(), message: "Please Select Your Area".localize())
            return
        }
        else if btnCheck.isSelected == false
        {
            self.showAlert("Alert".localize(), message: "Please Agree our policies to continue ".localize())
            return
        }
        else
        {
            let registerVehicleDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVehicleDetailsVC") as! RegisterVehicleDetailsVC
            self.userDetails.firstname = self.firstNameTxtField.text!
            self.userDetails.lastname = self.lastNameTxtField.text!
            self.userDetails.email = self.emailIDTxtField.text!
            self.userDetails.phone = self.mobileNumberTxtField.selectedCountry.dialCode! + self.mobileNumberTxtField.text!
            self.userDetails.country = self.mobileNumberTxtField.selectedCountry.isoCode!
            self.userDetails.countryCode = self.mobileNumberTxtField.selectedCountry.dialCode!
            self.userDetails.password = self.passwordTxtField.text!
            self.userDetails.address = self.txtAddress.text!
            self.userDetails.profileImage = self.BtnProfilePicture.imageView!.image!
            self.userDetails.adminId = "\(self.areaList.first(where: { $0.areaName == self.areaTxtField.text! })!.id!)"
            registerVehicleDetailsVC.userDetails = self.userDetails
            registerVehicleDetailsVC.callback = { [unowned self] userDetails in
                self.userDetails = userDetails
                print(userDetails)
            }
             self.navigationController?.pushViewController(registerVehicleDetailsVC, animated: true)
        }
    }

    


}
extension RegisterUserDetailsVC:UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        let currentString = textField.text! as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)

        if(textField==self.firstNameTxtField)
        {
            let maxLength = 15
            return newString.count <= maxLength
        }
        else if( textField==self.lastNameTxtField)
        {
            let maxLength = 15
            return newString.count <= maxLength
        }
        return true
    }

}

