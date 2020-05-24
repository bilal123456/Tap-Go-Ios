//
//  ViewController.swift
//  TapNGo Driver
//
//  Created by Spextrum on 03/10/17.
//  Copyright © 2017 nPlus. All rights reserved.
//

import UIKit
import Localize

class LoginBaseVC: UIViewController
{

    var layoutDic:[String:AnyObject] = [:]
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!

    let AppDelegates = UIApplication.shared.delegate as! AppDelegate
//    let HelperObject = HelperClass()
    var top:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var bottom:NSLayoutAnchor<NSLayoutYAxisAnchor>!
    var topSpace:NSLayoutConstraint!
    var bottomSpace:NSLayoutConstraint!
    var firstLoad = true
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        if ConnectionCheck.isConnectedToNetwork()
        {
            print("Connected")
        }
        else
        {
            print("disConnected")
        }
        // Do any additional setup after loading the view, typically from a nib.
        setupViews()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstLoad
        {
            UIView.animate(withDuration: 0.5) {
                self.view.removeConstraint(self.topSpace)
                self.topSpace = nil
                self.topSpace = self.bgImgView.topAnchor.constraint(equalTo: self.top)
                self.topSpace.isActive = true
                self.bottomSpace.constant = -16
                self.view.layoutIfNeeded()
                self.firstLoad = false
            }
        }
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    func setupViews()
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
        signInBtn.backgroundColor = .black
        signInBtn.setTitleColor(.themeColor, for: .normal)
        signInBtn.layer.borderColor = UIColor.themeColor.cgColor
        signInBtn.layer.borderWidth = 1.0
        signInBtn.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["signInBtn"] = signInBtn
        signUpBtn.backgroundColor = .black
        signUpBtn.setTitleColor(.themeColor, for: .normal)
        signUpBtn.layer.borderColor = UIColor.themeColor.cgColor
        signUpBtn.layer.borderWidth = 1.0
        signUpBtn.translatesAutoresizingMaskIntoConstraints = false
        layoutDic["signUpBtn"] = signUpBtn

            bgImgView.contentMode = .scaleAspectFit
        if #available(iOS 11.0, *) {
            print(self.view.safeAreaLayoutGuide.layoutFrame)
        } else {
            // Fallback on earlier versions
        }
        topSpace = bgImgView.topAnchor.constraint(equalTo: self.view.topAnchor)
        topSpace.isActive = true

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bgImgView]|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bgImgView]|", options: [], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(16)-[signInBtn]-(8)-[signUpBtn(==signInBtn)]-(16)-|", options: [HelperClass.appLanguageDirection,.alignAllTop,.alignAllBottom], metrics: nil, views: layoutDic))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[signInBtn(40)]", options: [], metrics: nil, views: layoutDic))
        bottomSpace = signInBtn.bottomAnchor.constraint(equalTo: self.bottom, constant: 40)
        bottomSpace.isActive = true
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
        signInBtn.layer.cornerRadius = signInBtn.bounds.height/2
        signUpBtn.layer.cornerRadius = signUpBtn.bounds.height/2
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.title = "App Name".localize().uppercased(with: Locale(identifier: HelperClass.currentAppLanguage))
        if firstLoad//topSpace.constant == 0
        {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        SetBackgroundImage()
        customFormat()
    }
    func customFormat()
    {
        self.navigationItem.backBtnString = ""
        

    }
    
    func SetBackgroundImage()
    {
        bgImgView.image = UIImage(named: "Splash")
    }
    @IBAction func signInBtnAction(_ sender: UIButton) {

//        let animation = CATransition()
//        animation.duration = 5.0
//        animation.timingFunction = CAMediaTimingFunction(name : kCAMediaTimingFunctionEaseInEaseOut)
//        animation.type = "rippleEffect"
//        CATransaction.setCompletionBlock {
//            let path1 = CGMutablePath()
//            path1.addArc(center: self.bgImgView.center, radius: 1, startAngle: 0.0, endAngle: 2.0 * CGFloat.pi, clockwise: false)
//
//            let path2 = CGMutablePath()
//            path2.addArc(center: self.bgImgView.center, radius: 1000, startAngle: 0.0, endAngle: 2.0 * CGFloat.pi, clockwise: false)
//            let maskLayer = CAShapeLayer()
//            maskLayer.path = path1
//            maskLayer.fillRule = kCAFillRuleEvenOdd
//
//            let pathAnim = CABasicAnimation(keyPath: "path")
//            pathAnim.fromValue = path1
//            pathAnim.toValue = path2
//            pathAnim.duration = 1.0
//            maskLayer.path = path2
//            self.bgImgView.layer.mask = maskLayer
//            self.bgImgView.clipsToBounds = true
//            maskLayer.add(pathAnim, forKey: "animateRadius")
//        }
//        bgImgView.layer.add(animation, forKey: nil)
//        CATransaction.commit()
//
//
//        return
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @IBAction func signUpBtnAction(_ sender: UIButton) {
        let registerUserDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterUserDetailsVC") as! RegisterUserDetailsVC
        self.navigationController?.pushViewController(registerUserDetailsVC, animated: true)
    }
    
  
   
}

