//
//  UIKit Extensions.swift
//  TapNGo Driver
//
//  Created by Admin on 27/03/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import Foundation
import UIKit

extension UIView
{    
    func addBorder(edges: UIRectEdge, colour: UIColor = UIColor.themeColor, thickness: CGFloat = 1, leftPadding: CGFloat = 0, rightPadding: CGFloat = 0) -> Void {
        func border() -> UIView {
            let border = UIView()
            border.backgroundColor = colour
            border.translatesAutoresizingMaskIntoConstraints = false
            return border
        }
        if edges.contains(.top) || edges.contains(.all) {
            let top = border()
            addSubview(top)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[top(==thickness)]",options: [],metrics: ["thickness": thickness],views: ["top": top]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[top]-(0)-|",options: [],metrics: nil,views: ["top": top]))
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            let left = border()
            addSubview(left)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[left(==thickness)]",options: [],metrics: ["thickness": thickness],views: ["left": left]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[left]-(0)-|",options: [],metrics: nil,views: ["left": left]))
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            let right = border()
            addSubview(right)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[right(==thickness)]-(0)-|",options: [],metrics: ["thickness": thickness],views: ["right": right]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[right]-(0)-|",options: [],metrics: nil,views: ["right": right]))
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            let bottom = border()
            addSubview(bottom)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottom(==thickness)]-(0)-|",options: [],metrics: ["thickness": thickness],views: ["bottom": bottom]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(leftPadding)-[bottom]-(rightPadding)-|",options: [],metrics: ["leftPadding":leftPadding,"rightPadding":rightPadding],views: ["bottom": bottom]))
        }
    }
    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 1.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    func addLoader(_ color:UIColor = .black)->CALayer
    {
        self.layoutIfNeeded()
        self.setNeedsLayout()
        let blackLayer = CALayer()
        blackLayer.frame = CGRect(x: 0, y: 0, width: 0, height: 3)
        blackLayer.backgroundColor = UIColor.black.cgColor
        self.layer.addSublayer(blackLayer)
        
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: self.bounds.minX, y: self.bounds.minY))
        path.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.minY))
        
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path.cgPath
        animation.duration = 0.5 //* 10
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        blackLayer.add(animation, forKey: "position")
        
        let anim = CABasicAnimation(keyPath: "bounds")
        anim.duration = 0.25 //* 10
        anim.autoreverses = true
        anim.repeatCount = Float.infinity
        anim.fromValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: 10, height: 3))
        anim.toValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: 150, height: 3))
        blackLayer.add(anim, forKey: "bounds")
        return blackLayer
    }
}
extension UIColor
{
    class var themeColor:UIColor {
        return UIColor(red: 0.0/255.0, green: 90.0/255.0, blue: 107.0/255.0, alpha: 1.0)
//            UIColor(red: 34.0/255.0, green: 135.0/255.0, blue: 153.0/255.0, alpha: 1.0)
    }
    static let secondaryColor = UIColor.white
    static let colorPrimary = UIColor(red: 0/255.0, green: 162.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let colorPrimaryDark = UIColor(red: 0/255.0, green: 131.0/255.0, blue: 197.0/255.0, alpha: 1.0)
}
@IBDesignable
class FormTextField: UITextField {

    @IBInspectable var inset: CGFloat = 0

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: inset)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

}
extension UIImage
{
    static func ==(lhs: UIImage, rhs: UIImage)->Bool {
        if let lhsData = lhs.pngData(), let rhsData = rhs.pngData() {
            return lhsData == rhsData
        }
        return false
    }
}

extension String
{
    var isBlank:Bool {
        get {
            return trimmingCharacters(in: .whitespaces).isEmpty
        }
    }
    var isValidEmail:Bool {
        get {
            return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}").evaluate(with:self)
        }
    }
    var isValidPhoneNumber:Bool {
        get {
            return NSPredicate(format: "SELF MATCHES %@", "^[0-9]{6,14}$").evaluate(with:self)
        }
    }
}

extension UIFont
{
    class func appTitleFont(ofSize:CGFloat)->UIFont
    {
        return UIFont(name: HelperClass.appTilteFontName, size: ofSize) ?? UIFont.systemFont(ofSize:ofSize)
    }
    class func appBoldTitleFont(ofSize:CGFloat)->UIFont
    {
        return UIFont(name: HelperClass.appTilteBoldFontName, size: ofSize) ?? UIFont.boldSystemFont(ofSize:ofSize)
    }
    class func appFont(ofSize:CGFloat)->UIFont
    {
        return UIFont(name: HelperClass.appFontName, size: ofSize) ?? UIFont.systemFont(ofSize:ofSize)
    }
    class func appBoldFont(ofSize:CGFloat)->UIFont
    {
        return UIFont(name: HelperClass.appBoldFontName, size: ofSize) ?? UIFont.boldSystemFont(ofSize:ofSize)
    }
}

extension UIViewController
{
    func showAlert(_ title :String , message: String)
    {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let titleFont = [NSAttributedString.Key.font: UIFont.appBoldTitleFont(ofSize: 18)]
        let messageFont = [NSAttributedString.Key.font: UIFont.appFont(ofSize: 15)]
        let titleAttrString = NSAttributedString(string: title, attributes: titleFont)
        let messageAttrString = NSAttributedString(string: message, attributes: messageFont)
        alert.setValue(titleAttrString, forKey: "attributedTitle")
        alert.setValue(messageAttrString, forKey: "attributedMessage")
        let ok = UIAlertAction(title: "OK".localize(), style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

extension UIViewController
{
    func showToast(_ message:String)
    {
        let toastLabel = UILabel()
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.numberOfLines = 0
        toastLabel.lineBreakMode = .byWordWrapping
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont.appFont(ofSize: 12)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        toastLabel.widthAnchor.constraint(equalToConstant: 250).isActive = true
        toastLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 35).isActive = true
        toastLabel.centerXAnchor.constraint(equalTo: toastLabel.superview!.centerXAnchor).isActive = true
        toastLabel.centerYAnchor.constraint(equalTo: toastLabel.superview!.bottomAnchor, constant: -200).isActive = true
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations:
            {
                toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
extension UIView {
    func showToast(_ message: String) {
        let toastLabel = UILabel()
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.numberOfLines = 0
        toastLabel.lineBreakMode = .byWordWrapping
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.appFont(ofSize: 12)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        self.addSubview(toastLabel)
        toastLabel.widthAnchor.constraint(equalToConstant: 250).isActive = true
        toastLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 35).isActive = true
        toastLabel.centerXAnchor.constraint(equalTo: toastLabel.superview!.centerXAnchor).isActive = true
        toastLabel.centerYAnchor.constraint(equalTo: toastLabel.superview!.bottomAnchor, constant: -200).isActive = true
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
extension UIWindow
{
    func showToast(_ message:String, backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.6), textColor: UIColor = UIColor.white)
    {
        let toastLabel = UILabel()
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.numberOfLines = 0
        toastLabel.lineBreakMode = .byWordWrapping
        toastLabel.backgroundColor = backgroundColor
        toastLabel.textColor = textColor
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont.appFont(ofSize: 12)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.addSubview(toastLabel)
        toastLabel.widthAnchor.constraint(equalToConstant: 250).isActive = true
        toastLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 35).isActive = true
        toastLabel.centerXAnchor.constraint(equalTo: toastLabel.superview!.centerXAnchor).isActive = true
        toastLabel.centerYAnchor.constraint(equalTo: toastLabel.superview!.bottomAnchor, constant: -200).isActive = true
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}


extension UINavigationItem
{
    var backBtnString:String {
        get { return "" }
        set { self.backBarButtonItem = UIBarButtonItem(title: newValue, style: .plain, target: nil, action: nil) }
    }
}
