//
//  RJKCountryPickerTextField.swift
//  test
//
//  Created by Admin on 01/04/18.
//  Copyright © 2018 com. All rights reserved.
//

import UIKit
import Kingfisher

class RJKCountryPickerTextField:UITextField
{
    override var textAlignment: NSTextAlignment {
        didSet{
            if self.textAlignment == .left
            {
                self.leftView = leftViewBtn
                self.leftViewMode = .always
                self.rightView = nil
                self.rightViewMode = .never
            }
            else
            {
                self.rightView = leftViewBtn
                self.rightViewMode = .always
                self.leftView = nil
                self.leftViewMode = .never
            }
        }
    }
    let countryPickerView = RJKCountryPickerView()
    var countryPickerDelegate:RJKCountryPickerViewDelegate!
    let leftViewBtn = UIButton()
    var selectedCountry:Country = Country("India",dialCode:"+91",isoCode:"IN")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    func addPickerView()
    {
        let window = self.keyWindow()!

        countryPickerView.delegate = self
        countryPickerView.translatesAutoresizingMaskIntoConstraints = false
        countryPickerView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        window.addSubview(countryPickerView)
        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[countryPickerView]|", options: [], metrics: nil, views: ["countryPickerView":countryPickerView]))
        window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[countryPickerView]|", options: [], metrics: nil, views: ["countryPickerView":countryPickerView]))
    }
//    func removePickerView()
//    {
//        countryPickerView.removeFromSuperview()
//    }
    func setUp() {

        leftViewBtn.imageView?.contentMode = .scaleAspectFit
        leftViewBtn.adjustsImageWhenHighlighted = false
        leftViewBtn.contentEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 8)
        leftViewBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        leftViewBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: -3)
        leftViewBtn.titleLabel?.font = self.font!
        leftViewBtn.setTitleColor(self.textColor, for: .normal)
        leftViewBtn.setImage(UIImage(named:selectedCountry.isoCode!)!, for: .normal)
        leftViewBtn.setTitle(selectedCountry.dialCode!, for: .normal)
        leftViewBtn.sizeToFit()
        leftViewBtn.frame.size.height = self.frame.height
        leftViewBtn.addTarget(self, action: #selector(showCountryPickerView(_:)), for: .touchUpInside)
        self.leftView = leftViewBtn
        self.leftViewMode = .always
    }
    @objc func showCountryPickerView(_ sender:UIButton)
    {
        self.superview?.endEditing(true)
        addPickerView()
        countryPickerView.isHidden = false
    }
    func keyWindow() -> UIWindow? {
        let originalKeyWindow = UIApplication.shared.keyWindow
        return originalKeyWindow
    }
}
extension RJKCountryPickerTextField:RJKCountryPickerViewDelegate
{
    func countrySelected(_ selectedCountry: Country) {
        self.selectedCountry = selectedCountry
        leftViewBtn.setImage(UIImage(named:selectedCountry.isoCode!)!, for: .normal)
        leftViewBtn.setTitle(selectedCountry.dialCode!, for: .normal)
        leftViewBtn.sizeToFit()
        leftViewBtn.frame.size.height = self.frame.height
        self.layoutSubviews()
    }
}
