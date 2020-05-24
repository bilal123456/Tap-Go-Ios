//
//  RJKPickerTextField.swift
//  TapNGo Driver
//
//  Created by Admin on 04/04/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import UIKit

class RJKPickerTextField: UITextField {

    enum TextfieldType
    {
        case datePicker
        case pickerView
    }
    private var currentTextfieldType:TextfieldType = .datePicker
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    let pickerView = UIPickerView()
    var pickerTitle = "- Select -"
    var itemList = [String]()


    init(_ type:TextfieldType) {
        super.init(frame: .zero)
        self.currentTextfieldType = .datePicker
    }
    internal override init(frame: CGRect) {
        super.init(frame: frame)
    }
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    @objc func textEdited(_ sender:RJKPickerTextField)
    {
        if self.currentTextfieldType == .datePicker
        {
            self.text = dateFormatter.string(from: datePicker.date)
        }
        else
        {
            self.text = pickerView.selectedRow(inComponent: 0) == 0 ? "" : itemList[pickerView.selectedRow(inComponent: 0)-1]
        }
    }
    @objc func editingBegin(_ sender:RJKPickerTextField)
    {
        if self.currentTextfieldType == .pickerView
        {

        }
        else
        {
            if let date = dateFormatter.date(from: self.text!)
            {
                self.datePicker.date = date
            }
            else
            {
                self.datePicker.date = Date()
                self.text = dateFormatter.string(from: self.datePicker.date)
            }
        }
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.addTarget(self, action: #selector(textEdited(_:)), for: .editingChanged)
        self.addTarget(self, action: #selector(editingBegin(_:)), for: .editingDidBegin)
        if currentTextfieldType == .datePicker
        {
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
            self.inputView = datePicker
        }
        else
        {
            pickerView.delegate = self
            pickerView.dataSource = self
            self.inputView = pickerView
        }
    }
    @objc func dateChanged(_ sender:UIDatePicker)
    {
        self.text = dateFormatter.string(from: sender.date)
    }
    func changeTextFieldType(_ type:TextfieldType)
    {
        self.currentTextfieldType = type
        if currentTextfieldType == .datePicker
        {
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
            self.inputView = datePicker
        }
        else
        {
            pickerView.delegate = self
            pickerView.dataSource = self
            self.inputView = pickerView
        }
    }
    func configureDatePicker(_ minDate:Date?,maxDate:Date?,dateFormat:String?)
    {
        if let minDate = minDate
        {
            self.datePicker.minimumDate = minDate
        }
        if let maxDate = maxDate
        {
            self.datePicker.maximumDate = maxDate
        }
        if let dateFormat = dateFormat
        {
            dateFormatter.dateFormat = dateFormat
        }
    }

}
extension RJKPickerTextField:UIPickerViewDelegate,UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return itemList.count + 1
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = row == 0 ?  pickerTitle : itemList[row-1]
        return NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor:row == 0 ? UIColor.gray : UIColor.black])
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.text = row == 0 ? "" : itemList[row-1]
    }
}
