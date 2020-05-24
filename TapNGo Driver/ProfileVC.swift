//
//  ProfileVC.swift
//  TapNGo Driver
//
//  Created by Spextrum on 10/11/17.
//  Copyright © 2017 nPlus. All rights reserved.
//

import UIKit
import SWRevealViewController
//import CoreData
import Alamofire
import NVActivityIndicatorView
import Localize
import IQKeyboardManagerSwift
import Kingfisher

class ProfileVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
//    @IBOutlet weak var ImgViewForProfile: UIImageView!
    @IBOutlet weak var BtnProfilePicture: UIButton!
    @IBOutlet weak var BtnEditProfile: UIButton!
    @IBOutlet weak var profbasicsetLbl: UILabel!
    @IBOutlet weak var profbasicsetVw: UIView!
    @IBOutlet weak var firstNameTitleTxtField: UITextField!
    @IBOutlet weak var TxtFirstName: UITextField!
    @IBOutlet weak var lastNameTitleTxtField: UITextField!
    @IBOutlet weak var TxtLastName: UITextField!
    @IBOutlet weak var profchangepwdLbl: UILabel!
    @IBOutlet weak var profchangepwdVw: UIView!
    @IBOutlet weak var passwordTitleTxtField: UITextField!
    @IBOutlet weak var TxtOldPassword: UITextField!
    @IBOutlet weak var newTitleTxtField: UITextField!
    @IBOutlet weak var TxtNewPassword: UITextField!
    @IBOutlet weak var confirmTitleTxtField: UITextField!
    @IBOutlet weak var TxtConfirmPassword: UITextField!
    @IBOutlet weak var profcontsetLbl: UILabel!
    @IBOutlet weak var profcontsetVw: UIView!
    @IBOutlet weak var emailTitleTxtField: UITextField!
    @IBOutlet weak var TxtEmail_ID: UITextField!
    @IBOutlet weak var phoneTitleTxtField: UITextField!
    @IBOutlet weak var TxtMobileNumber: UITextField!
    @IBOutlet weak var BtnUpdateProfile: UIButton!

    var lblVehicleInfo = UILabel()
    var txtVehicleTypeTitle = UILabel()
    var txtVeicleNumberTitle = UILabel()
    var txtVehicleModelTitle = UILabel()
    var txtVehicleType = FormTextField()
    var txtVeicleNumber = FormTextField()
    var txtVehicleModel = FormTextField()

    var ProfileimagePicker = UIImagePickerController()
    var window: UIWindow?
    let AppDelegates = UIApplication.shared.delegate as! AppDelegate
//  let HelperObject = HelperClass()
    var activityView: NVActivityIndicatorView!
    
//    var UserName = String()
//    var User_ID  = String()
//    var User_token = String()

    var ProfilePicURL = String()
    var iSProfileImage = String()

    var layoutDic = [String:AnyObject]()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var bottom:NSLayoutAnchor<NSLayoutYAxisAnchor>!

    var userDetails:UserDetails!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }

        self.ProfilePicURL = HelperClass.shared.userProfilePicture
        self.TxtFirstName.text = HelperClass.shared.userName
        self.TxtLastName.text = HelperClass.shared.userLastName
        self.TxtEmail_ID.text = HelperClass.shared.userEmail
        self.TxtMobileNumber.text = HelperClass.shared.userPhone
        self.txtVehicleType.text = HelperClass.shared.carTypeName
        self.txtVeicleNumber.text = HelperClass.shared.carNumber
        self.txtVehicleModel.text = HelperClass.shared.carModel
        print("User ID =",HelperClass.shared.userID)
        self.loadProfilePicture()

        self.iSProfileImage = "NO"
        ProfileimagePicker.delegate = self
        self.BtnProfilePicture.layer.cornerRadius = self.BtnProfilePicture.frame.height/2
        self.BtnProfilePicture.clipsToBounds = true

        BtnUpdateProfile.backgroundColor = UIColor.themeColor
        BtnUpdateProfile.titleLabel!.font = UIFont.appFont(ofSize: BtnUpdateProfile.titleLabel!.font.pointSize)

        BtnEditProfile.titleLabel!.font = UIFont.appFont(ofSize: BtnEditProfile.titleLabel!.font.pointSize)
        BtnEditProfile.setTitleColor(UIColor.themeColor, for: .normal)

        TxtOldPassword.isSecureTextEntry = true
        TxtNewPassword.isSecureTextEntry = true
        TxtConfirmPassword.isSecureTextEntry = true
        TxtOldPassword.textColor = .themeColor
        TxtNewPassword.textColor = .themeColor
        TxtConfirmPassword.textColor = .themeColor
    
        TxtFirstName.textColor = UIColor.themeColor
        TxtLastName.textColor = UIColor.themeColor
        TxtEmail_ID.textColor = UIColor.themeColor
        TxtMobileNumber.textColor = UIColor.themeColor
        txtVehicleTypeTitle.textColor = UIColor.darkGray
        txtVeicleNumberTitle.textColor = UIColor.darkGray
        txtVehicleModelTitle.textColor = UIColor.darkGray
        txtVehicleType.textColor = UIColor.themeColor
        txtVeicleNumber.textColor = UIColor.themeColor
        txtVehicleModel.textColor = UIColor.themeColor
        
        lblVehicleInfo.textColor = UIColor.darkText
        profbasicsetLbl.textColor = UIColor.darkText
        profchangepwdLbl.textColor = UIColor.darkText
        profcontsetLbl.textColor = UIColor.darkText
        
        
        passwordTitleTxtField.textColor = UIColor.darkGray
        firstNameTitleTxtField.textColor = UIColor.darkGray
        lastNameTitleTxtField.textColor = UIColor.darkGray
        newTitleTxtField.textColor = UIColor.darkGray
        confirmTitleTxtField.textColor = UIColor.darkGray
        phoneTitleTxtField.textColor = UIColor.darkGray
        emailTitleTxtField.textColor = UIColor.darkGray

        firstNameTitleTxtField.font = UIFont.appFont(ofSize: firstNameTitleTxtField.font!.pointSize)
        TxtFirstName.font = UIFont.appFont(ofSize: TxtFirstName.font!.pointSize)
        lastNameTitleTxtField.font = UIFont.appFont(ofSize: lastNameTitleTxtField.font!.pointSize)
        TxtLastName.font = UIFont.appFont(ofSize: TxtLastName.font!.pointSize)
        passwordTitleTxtField.font = UIFont.appFont(ofSize: passwordTitleTxtField.font!.pointSize)
        TxtOldPassword.font = UIFont.appFont(ofSize: TxtOldPassword.font!.pointSize)
        newTitleTxtField.font = UIFont.appFont(ofSize: newTitleTxtField.font!.pointSize)
        TxtNewPassword.font = UIFont.appFont(ofSize: TxtNewPassword.font!.pointSize)
        confirmTitleTxtField.font = UIFont.appFont(ofSize: confirmTitleTxtField.font!.pointSize)
        TxtConfirmPassword.font = UIFont.appFont(ofSize: TxtConfirmPassword.font!.pointSize)
        emailTitleTxtField.font = UIFont.appFont(ofSize: emailTitleTxtField.font!.pointSize)
        TxtEmail_ID.font = UIFont.appFont(ofSize: TxtEmail_ID.font!.pointSize)
        phoneTitleTxtField.font = UIFont.appFont(ofSize: phoneTitleTxtField.font!.pointSize)
        TxtMobileNumber.font = UIFont.appFont(ofSize: TxtMobileNumber.font!.pointSize)
        txtVehicleTypeTitle.font = UIFont.appFont(ofSize: phoneTitleTxtField.font!.pointSize)
        txtVeicleNumberTitle.font = UIFont.appFont(ofSize: phoneTitleTxtField.font!.pointSize)
        txtVehicleModelTitle.font = UIFont.appFont(ofSize: phoneTitleTxtField.font!.pointSize)
        txtVehicleType.font = UIFont.appFont(ofSize: TxtMobileNumber.font!.pointSize)
        txtVeicleNumber.font = UIFont.appFont(ofSize: TxtMobileNumber.font!.pointSize)
        txtVehicleModel.font = UIFont.appFont(ofSize: TxtMobileNumber.font!.pointSize)


        profbasicsetLbl.font = UIFont.appBoldTitleFont(ofSize: profbasicsetLbl.font.pointSize)
        profchangepwdLbl.font = UIFont.appBoldTitleFont(ofSize: profchangepwdLbl.font.pointSize)
        profcontsetLbl.font = UIFont.appBoldTitleFont(ofSize: profcontsetLbl.font.pointSize)
        lblVehicleInfo.font = UIFont.appBoldTitleFont(ofSize: profbasicsetLbl.font.pointSize)

//       getUsers()
        self.loadProfilePicture()
        self.initialsetup()
        SetLocalization()
        customFormat()
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
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["scrollvw"] = scrollView
        containerView.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["containerView"] = containerView
        BtnProfilePicture.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnProfilePicture"] = BtnProfilePicture
        BtnEditProfile.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnEditProfile"] = BtnEditProfile
        profbasicsetLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["profbasicsetLbl"] = profbasicsetLbl
        firstNameTitleTxtField.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["firstNameTitleTxtField"] = firstNameTitleTxtField
        firstNameTitleTxtField.adjustsFontSizeToFitWidth = true
        firstNameTitleTxtField.minimumFontSize = 10
        TxtFirstName.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["TxtFirstName"] = TxtFirstName
        lastNameTitleTxtField.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["lastNameTitleTxtField"] = lastNameTitleTxtField
        TxtLastName.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["TxtLastName"] = TxtLastName
        profchangepwdLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["profchangepwdLbl"] = profchangepwdLbl
//        profchangepwdVw.translatesAutoresizingMaskIntoConstraints = false
//        layoutDic["profchangepwdVw"] = profchangepwdVw
        passwordTitleTxtField.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["passwordTitleTxtField"] = passwordTitleTxtField
        TxtOldPassword.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["TxtOldPassword"] = TxtOldPassword
        newTitleTxtField.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["newTitleTxtField"] = newTitleTxtField
        TxtNewPassword.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["TxtNewPassword"] = TxtNewPassword
        confirmTitleTxtField.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["confirmTitleTxtField"] = confirmTitleTxtField
        TxtConfirmPassword.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["TxtConfirmPassword"] = TxtConfirmPassword
        profcontsetLbl.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["profcontsetLbl"] = profcontsetLbl
//        profcontsetVw.translatesAutoresizingMaskIntoConstraints = false
//        layoutDic["profcontsetVw"] = profcontsetVw
        emailTitleTxtField.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["emailTitleTxtField"] = emailTitleTxtField
        TxtEmail_ID.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["TxtEmail_ID"] = TxtEmail_ID
        phoneTitleTxtField.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["phoneTitleTxtField"] = phoneTitleTxtField
        TxtMobileNumber.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["TxtMobileNumber"] = TxtMobileNumber
        BtnUpdateProfile.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["BtnUpdateProfile"] = BtnUpdateProfile

        lblVehicleInfo.textAlignment = .center
        lblVehicleInfo.text = "Vehicle Info"
        lblVehicleInfo.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["lblVehicleInfo"] = lblVehicleInfo
        self.containerView.addSubview(lblVehicleInfo)


        txtVehicleTypeTitle.backgroundColor = UIColor.white
        txtVehicleTypeTitle.text = "VEHICLE TYPE"
        txtVehicleTypeTitle.numberOfLines = 0
        txtVehicleTypeTitle.lineBreakMode = .byWordWrapping
        txtVehicleTypeTitle.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["txtVehicleTypeTitle"] = txtVehicleTypeTitle
        self.containerView.addSubview(txtVehicleTypeTitle)


        txtVeicleNumberTitle.backgroundColor = UIColor.white
        txtVeicleNumberTitle.text = "VEHICLE NUMBER"
        txtVeicleNumberTitle.numberOfLines = 0
        txtVeicleNumberTitle.lineBreakMode = .byWordWrapping
        txtVeicleNumberTitle.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["txtVeicleNumberTitle"] = txtVeicleNumberTitle
        self.containerView.addSubview(txtVeicleNumberTitle)


        txtVehicleModelTitle.backgroundColor = UIColor.white
        txtVehicleModelTitle.text = "VEHICLE MODEL"
        txtVehicleModelTitle.numberOfLines = 0
        txtVehicleModelTitle.lineBreakMode = .byWordWrapping
        txtVehicleModelTitle.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["txtVehicleModelTitle"] = txtVehicleModelTitle
        self.containerView.addSubview(txtVehicleModelTitle)

        txtVehicleType.inset = 10.0
        txtVehicleType.textAlignment = .center
        txtVehicleType.backgroundColor = UIColor.white
        txtVehicleType.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["txtVehicleType"] = txtVehicleType
        self.containerView.addSubview(txtVehicleType)

        txtVeicleNumber.inset = 10.0
        txtVeicleNumber.textAlignment = .center
        txtVeicleNumber.backgroundColor = UIColor.white
        txtVeicleNumber.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["txtVeicleNumber"] = txtVeicleNumber
        self.containerView.addSubview(txtVeicleNumber)

        txtVehicleModel.inset = 10.0
        txtVehicleModel.textAlignment = .center
        txtVehicleModel.backgroundColor = UIColor.white
        txtVehicleModel.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["txtVehicleModel"] = txtVehicleModel
        self.containerView.addSubview(txtVehicleModel)

        scrollView.topAnchor.constraint(equalTo: self.top, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottom, constant: 0).isActive = true
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[scrollvw]|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollvw]|", options: [], metrics: nil, views: layoutDic))

        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[containerView]|", options: [], metrics: nil, views: layoutDic))
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", options: [], metrics: nil, views: layoutDic))
        containerView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        let containerHgt = containerView.heightAnchor.constraint(equalTo: self.view.heightAnchor)
        containerHgt.priority = UILayoutPriority(rawValue: 250)
        containerHgt.isActive = true

        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(20)-[BtnProfilePicture(100)]-(10)-[BtnEditProfile(30)]-(10)-[profbasicsetLbl(20)]-(15)-[firstNameTitleTxtField(50)]-(1)-[lastNameTitleTxtField(50)]-(10)-[profchangepwdLbl(20)]-(10)-[passwordTitleTxtField(50)]-(1)-[newTitleTxtField(50)]-(1)-[confirmTitleTxtField(50)]-(10)-[profcontsetLbl(20)]-(10)-[emailTitleTxtField(50)]-(1)-[phoneTitleTxtField(50)]-(10)-[lblVehicleInfo(20)]-(10)-[txtVehicleTypeTitle(60)]-(1)-[txtVeicleNumberTitle(60)]-(1)-[txtVehicleModelTitle(60)]-(20)-[BtnUpdateProfile(30)]-(20)-|", options: [], metrics: nil, views: layoutDic))
        BtnProfilePicture.widthAnchor.constraint(equalTo: BtnProfilePicture.heightAnchor).isActive = true
        BtnProfilePicture.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[BtnEditProfile(70)]-(10)-|", options: [HelperClass.appLanguageDirection], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[profbasicsetLbl]-(20)-|", options: [], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[firstNameTitleTxtField(125)]-(1)-[TxtFirstName]-(20)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[lastNameTitleTxtField(125)]-(1)-[TxtLastName]-(20)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[profchangepwdLbl]-(20)-|", options: [], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[passwordTitleTxtField(125)]-(1)-[TxtOldPassword]-(20)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[newTitleTxtField(125)]-(1)-[TxtNewPassword]-(20)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[confirmTitleTxtField(125)]-(1)-[TxtConfirmPassword]-(20)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[profcontsetLbl]-(20)-|", options: [], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[emailTitleTxtField(125)]-(1)-[TxtEmail_ID]-(20)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[phoneTitleTxtField(125)]-(1)-[TxtMobileNumber]-(20)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))

        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[lblVehicleInfo]-(20)-|", options: [], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[txtVehicleTypeTitle(125)]-(1)-[txtVehicleType]-(20)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[txtVeicleNumberTitle(125)]-(1)-[txtVeicleNumber]-(20)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
         containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[txtVehicleModelTitle(125)]-(1)-[txtVehicleModel]-(20)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))

        BtnUpdateProfile.widthAnchor.constraint(equalToConstant: 120).isActive = true
        BtnUpdateProfile.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true


        [firstNameTitleTxtField,TxtFirstName,lastNameTitleTxtField,TxtLastName,
        passwordTitleTxtField,TxtOldPassword,newTitleTxtField,TxtNewPassword,
        confirmTitleTxtField,TxtConfirmPassword,emailTitleTxtField,TxtEmail_ID,
        phoneTitleTxtField,TxtMobileNumber,txtVehicleType,txtVehicleModel,txtVeicleNumber].forEach { $0.textAlignment = HelperClass.appTextAlignment }
        txtVehicleTypeTitle.textAlignment = HelperClass.appTextAlignment
        txtVehicleModelTitle.textAlignment = HelperClass.appTextAlignment
        txtVeicleNumberTitle.textAlignment = HelperClass.appTextAlignment
    }

    func initialsetup()
    {
        self.TxtOldPassword.text = "PLACEHOLDER TEXT"
        self.TxtFirstName.isUserInteractionEnabled=false
        self.TxtLastName.isUserInteractionEnabled=false
        self.TxtOldPassword.isUserInteractionEnabled=false
        self.TxtNewPassword.isUserInteractionEnabled=false
        self.TxtConfirmPassword.isUserInteractionEnabled=false
        self.TxtEmail_ID.isUserInteractionEnabled=false
        self.TxtMobileNumber.isUserInteractionEnabled=false
        self.txtVehicleType.isUserInteractionEnabled = false
        self.txtVeicleNumber.isUserInteractionEnabled = false
        self.txtVehicleModel.isUserInteractionEnabled = false
        self.BtnProfilePicture.isUserInteractionEnabled=false
        self.BtnUpdateProfile.isHidden=true
//        self.scrollvw.contentSize=CGSize(width : self.view.frame.size.width, height : self.profcontsetVw.frame.origin.y+self.profcontsetVw.frame.size.height+50)
    }

    

    override func viewWillAppear(_ animated: Bool)
    {

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func ProfilePicBtn(_ sender: Any)
    {
        let alert = UIAlertController(title: "Title".localize(), message: "Please Select an Option".localize(), preferredStyle: .actionSheet)
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

            self.iSProfileImage = "YES"
        }
        else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            BtnProfilePicture.setImage(image, for: .normal)

            self.iSProfileImage = "YES"
        }
        else
        {
            print("Something went wrong")
            self.iSProfileImage = "NO"
        }
        picker.dismiss(animated: true, completion: nil)
        print("Profile Image Path = ",BtnProfilePicture.imageView!.image!)
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


    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        if(textField==self.TxtFirstName)
        {
            let maxLength = 15
            let currentString: NSString = self.TxtFirstName.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        else if( textField==self.TxtLastName)
        {
            let maxLength = 15
            let currentString: NSString = self.TxtLastName.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
    }
    
    func openGallary()
    {
        ProfileimagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        ProfileimagePicker.allowsEditing = true
        self.present(ProfileimagePicker, animated: true, completion: nil)
    }

    @IBAction func EditProfileBtn(_ sender: Any)
    {
        self.TxtOldPassword.text = ""
        self.BtnEditProfile.isEnabled = false
        self.BtnProfilePicture.isEnabled = true
        self.BtnProfilePicture.isUserInteractionEnabled=true
        self.TxtFirstName.isUserInteractionEnabled = true
        self.TxtLastName.isUserInteractionEnabled = true
        self.TxtOldPassword.isUserInteractionEnabled = true
        self.TxtNewPassword.isUserInteractionEnabled = true
        self.TxtConfirmPassword.isUserInteractionEnabled = true
        self.BtnUpdateProfile.isHidden = false
        self.TxtFirstName.becomeFirstResponder()
    }
    
    @IBAction func UpdateProfileBtn(_ sender: Any)
    {
        var errmsg="" as String
        if(self.TxtFirstName.text! == "")
        {
            errmsg="Please Enter Your First Name".localize()
            self.showToast("Please Enter Your First Name".localize())
            return
        }
        else if(self.TxtLastName.text! == "")
        {
            errmsg="Please Enter Your Last Name".localize()
            self.showToast("Please Enter Your Last Name".localize())
            return
        }
        else if ((self.TxtOldPassword.text?.count)!>0)
        {
            if((self.TxtOldPassword.text?.count)!<8)
            {
                errmsg="Password must be 8 characters long".localize()
            }
            else if(self.TxtNewPassword.text?.count==0)
            {
                errmsg="Please Enter your new password.".localize()
            }
            else if((self.TxtNewPassword.text?.count)!<8)
            {
                errmsg="New Password must be 8 characters long".localize()
            }
            else if(self.TxtConfirmPassword.text?.count==0)
            {
                errmsg="Please Enter your confirm password.".localize()
            }
            else if((self.TxtConfirmPassword.text?.count)!<8)
            {
                errmsg="Confirm Password must be 8 characters long".localize()
            }
            else if(!(self.TxtConfirmPassword.text == self.TxtNewPassword.text))
            {
                errmsg="New password and Confirm password does not match".localize()
            }
        }
        else if ((self.TxtNewPassword.text?.count)!>0)
        {
            if(self.TxtOldPassword.text?.count==0)
            {
                errmsg="Please Enter your password.".localize()
            }
            else if((self.TxtNewPassword.text?.count)!<8)
            {
                errmsg="New Password must be 8 characters long".localize()
            }
            else if((self.TxtOldPassword.text?.count)!<8)
            {
                errmsg="Password must be 8 characters long".localize()
            }
            else if(self.TxtConfirmPassword.text?.count==0)
            {
                errmsg="Please Enter your confirm password.".localize()
            }
            else if((self.TxtConfirmPassword.text?.count)!<8)
            {
                errmsg="Confirm Password must be 8 characters long.".localize()
            }
        }
        else if ((self.TxtConfirmPassword.text?.count)!>0)
        {
            if((self.TxtConfirmPassword.text?.count)!<8)
            {
                errmsg="Confirm Password must be 8 characters long.".localize()
            }
            else if(self.TxtOldPassword.text?.count==0)
            {
                errmsg="Please Enter your password.".localize()
            }
            else if((self.TxtOldPassword.text?.count)!<8)
            {
                errmsg="Password must be 8 characters long".localize()
            }
            else if(self.TxtNewPassword.text?.count==0)
            {
                errmsg="Please Enter your new password.".localize()
            }
            else if((self.TxtNewPassword.text?.count)!<8)
            {
                errmsg="New Password must be 8 characters long".localize()
            }
        }
            if(errmsg.count>0)
            {
                self.showAlert("Alert".localize(), message: errmsg)
            }
            else
            {
                self.MultiPart()
                self.BtnEditProfile.isEnabled = true
                self.TxtFirstName.isUserInteractionEnabled = false
                self.TxtLastName.isUserInteractionEnabled = false
                self.TxtOldPassword.isUserInteractionEnabled = false
                self.TxtNewPassword.isUserInteractionEnabled = false
                self.TxtConfirmPassword.isUserInteractionEnabled = false
                self.BtnUpdateProfile.isHidden = true
            }
    }
    
//    @IBAction func NavigateBackBtn(_ sender: Any)
//    {
//        self.performSegue(withIdentifier: "ProfileVcToHomeVC", sender: self)
//    }

    func MultiPart()
    {
        if ConnectionCheck.isConnectedToNetwork()
        {
            print("Connected")
            self.showLoadingIndicator()
            var ParamDict = Dictionary<String, Any>()
            ParamDict["firstname"] = self.TxtFirstName.text!;
            ParamDict["lastname"] = self.TxtLastName.text!;
            ParamDict["new_password"] = self.TxtNewPassword.text!;
            ParamDict["old_password"] = self.TxtOldPassword.text!;
            ParamDict["id"] = HelperClass.shared.userID
            ParamDict["token"] = HelperClass.shared.userToken

            //http://18.196.238.158:82/v1/driver/profile
            let URL = try! URLRequest(url: HelperClass.BASEURL+HelperClass.DriverUpdateProfileURL, method: .post, headers: HelperClass.Header)
            print("URL & Paremeters for SignUp =",URL,ParamDict)

            let myPicture = self.BtnProfilePicture.imageView!.image!//rjk
            var myThumb1 = myPicture.resized(withPercentage: 0.5)
            let imgdata = myThumb1?.jpegData(compressionQuality: 0.7)
            print([imgdata?.count])
            var myThumb2=UIImage()
            if((imgdata?.count)! > 1999999)
            {
                myThumb2 = (myThumb1?.resized(withPercentage: 0.5))!
                let imgdata1 = myThumb2.pngData()
                print([imgdata1?.count])
                myThumb1=myThumb2
            }

            Alamofire.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imgdata!, withName: "profile_pic", fileName: "picture1.png", mimeType: "image/png")
                for (key, value) in ParamDict
                {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
                
            }, with: URL, encodingCompletion: {
                encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON
                        { response in
                            debugPrint("Registration RESPONSE: \(response)")
                            self.stopLoadingIndicator()
                            print((response.result.value as! [String: Any])["success"] as! Bool)
                            let theSuccess = ((response.result.value as! [String: Any])["success"] as! Bool)
                            self.stopLoadingIndicator()
                            // To get JSON return value
                            if (theSuccess == true)
                            {
                                let JSON = response.result.value as! NSDictionary
                                print(JSON)
                                if let userDetails = JSON.value(forKey: "driver") as? [String:AnyObject]
                                {
                                    HelperClass.shared.updateUserDetails(userDetails)                                    
                                }
                                self.showToast("Profile Updated Successfully".localize())
                                self.TxtOldPassword.text = "PLACEHOLDER TEXT"
                                self.customFormat()
                            }
                            else if(theSuccess == false)
                            {
                                let JSON = response.result.value as! NSDictionary
                                print("Invalid Response",JSON)
                                self.showAlert("Alert".localize(), message: JSON.value(forKey: "error_message") as! String)
                            }
                    }
                case .failure(let encodingError):
                    // hide progressbas here
                    print("ERROR RESPONSE: \(encodingError)")
                }
            })
        }
        else
        {
            print("disConnected")
            self.showAlert("No Internet".localize(), message: "Please Check Your Internet Connection".localize())
        }
    }

    func SetLocalization()
    {
        self.title = "Profile".localize().uppercased(with: Locale(identifier: HelperClass.currentAppLanguage))

    }
    
    func customFormat()
    {
        BtnEditProfile.layer.cornerRadius = 20
        BtnUpdateProfile.layer.cornerRadius = 10
        self.BtnEditProfile.isEnabled = true
        self.TxtFirstName.isUserInteractionEnabled = false
        self.TxtLastName.isUserInteractionEnabled = false
        self.TxtOldPassword.isUserInteractionEnabled = false
        self.TxtNewPassword.isUserInteractionEnabled = false
        self.TxtConfirmPassword.isUserInteractionEnabled = false
        self.txtVehicleModel.isUserInteractionEnabled = false
        self.txtVeicleNumber.isUserInteractionEnabled = false
        self.txtVehicleType.isUserInteractionEnabled = false

        self.BtnUpdateProfile.isHidden = true
    }
    
//    func getContext()->NSManagedObjectContext
//    {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        return appDelegate.persistentContainer.viewContext
//    }
    
//    func getUsers()
//    {
//        let fetchRequest: NSFetchRequest<Login_UserData> = Login_UserData.fetchRequest()
//        do
//        {
//            let array_users = try getContext().fetch(fetchRequest)
//            print ("num of users = \(array_users.count)")
//            for user in array_users as [NSManagedObject]
//            {
//                print("\(String(describing: user.value(forKey: "loginuser_firstname")))")
//                UserName = (String(describing: user.value(forKey: "loginuser_firstname")!))
//                User_ID = (String(describing: user.value(forKey: "loginuser_ID")!))
//                User_token = (String(describing: user.value(forKey: "loginuser_token")!))
//
//            }
//        }
//        catch
//        {
//            print("Error with request: \(error)")
//        }
//    }

    func loadProfilePicture()
    {
        if let url = URL(string: ProfilePicURL)
        {
            let resource = ImageResource(downloadURL: url)
            self.BtnProfilePicture.imageView?.kf.indicatorType = .activity
            self.BtnProfilePicture.kf.setImage(with: resource, for: .normal)
        }
        else
        {
            self.BtnProfilePicture.tintColor = UIColor.themeColor
            let defaultImg = UIImage(named:"profile")?.withRenderingMode(.alwaysTemplate)
            self.BtnProfilePicture.setImage(defaultImg, for: .normal)
//            ImgViewForProfile.image=UIImage(named: "profile")
        }
    }

    //    # pragma mark - NVActivityIndicatorView
    
    func showLoadingIndicator()
    {
        NVActivityIndicatorView.DEFAULT_TYPE = .ballClipRotatePulse
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 180, height: 180)
        NVActivityIndicatorView.DEFAULT_COLOR = UIColor.lightGray
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(HomeVC.activityData)
    }
    
    func stopLoadingIndicator()
    {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
}

extension UIImage
{
    func resized(withPercentage percentage: CGFloat) -> UIImage?
    {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

//extension UIImageView
//{
//    func downloadImageFrome(link:String, contentMode: UIViewContentMode)
//    {
//        URLSession.shared.dataTask( with: URL(string:link)!, completionHandler: {
//            (data, response, error) -> Void in
//            DispatchQueue.main.async()
//                {
//                    self.contentMode =  contentMode
//                    if let data = data {
//                        self.image = UIImage(data: data)
//                        
//                    }
//            }
//        }).resume()
//    }
//}
