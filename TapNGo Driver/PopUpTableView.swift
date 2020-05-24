//
//  PopUpTableView.swift
//  TapNGo Driver
//
//  Created by Admin on 12/04/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import Foundation
import UIKit

typealias Option = (text:String,identifier:String)
protocol PopUpTableViewDelegate
{
//    @objc func popUpTableView(_ popUpTableView: PopUpTableView, didSelectRowAt index: Int)
    func popUpTableView(_ popUpTableView: PopUpTableView, didSelectOption option: Option, atIndex index:Int)
}
class PopUpTableView:UIView
{
    var delegate:PopUpTableViewDelegate!
    let langListTblView = UITableView()
    var langListTblViewHgt:NSLayoutConstraint!

    var optionsList:[Option]? {
        didSet {
            langListTblView.reloadData()
            langListTblView.layoutIfNeeded()
            langListTblViewHgt.constant = min(UIScreen.main.bounds.height-50, (langListTblView.contentSize.height))            
        }
    }
    var selectedIndex:Int?
    var selectedOption:Option? {
        didSet {
            if selectedOption != nil
            {
                selectedIndex = optionsList?.index(where: { $0 == selectedOption! })
            }
        }
    }
    var tableTitle:String? {
        didSet {
            langListTblView.reloadData()
            langListTblView.layoutIfNeeded()
            langListTblViewHgt.constant = min(UIScreen.main.bounds.height-50, (langListTblView.contentSize.height))
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpViews()
    }
    func setUpViews()
    {
        if #available(iOS 11.0, *) {
            langListTblView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        self.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        self.isHidden = true

        langListTblView.backgroundColor = .clear
        langListTblView.delegate = self
        langListTblView.dataSource = self
        langListTblView.translatesAutoresizingMaskIntoConstraints = false
        langListTblView.tintColor = UIColor.themeColor
        addSubview(langListTblView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(30)-[langListTblView]-(30)-|", options: [], metrics: nil, views: ["langListTblView":langListTblView]))
        langListTblView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        langListTblView.reloadData()//After Tableviews datasource methods are loaded add height constraint to tableview
        langListTblView.layoutIfNeeded()
        langListTblViewHgt = langListTblView.heightAnchor.constraint(equalToConstant: min(UIScreen.main.bounds.height-50, (langListTblView.contentSize.height)) )
        langListTblViewHgt.isActive = true
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self
        {
            self.isHidden = true
        }
        return hitView
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
extension PopUpTableView:UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsList == nil ? 0 : optionsList!.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let tableTitle = tableTitle else {
            return nil
        }
        let header = UIView()
        header.backgroundColor = UIColor.themeColor
        let title = UILabel()
        title.textAlignment = .center
        title.font = UIFont.appBoldTitleFont(ofSize: 18)
        title.textColor = .white
        title.text = tableTitle 
        title.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(title)
        header.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[title]|", options: [], metrics: nil, views: ["title":title]))
        header.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(5)-[title]-(5)-|", options: [], metrics: nil, views: ["title":title]))

        return header
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        print(CGFloat.leastNonzeroMagnitude)
        guard tableTitle != nil else {
            return CGFloat.leastNonzeroMagnitude
        }
        return 40
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        if let selectedIndex = selectedIndex, selectedIndex == indexPath.row
        {
            cell?.accessoryType = .checkmark
        }
        else
        {
            cell?.accessoryType = .none
        }
        cell?.selectionStyle = .none
        cell?.textLabel?.font = UIFont.appFont(ofSize: 17)
        cell?.textLabel?.textAlignment = HelperClass.appTextAlignment
        cell?.textLabel?.text = optionsList![indexPath.row].text

        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        selectedOption = optionsList![indexPath.row]
        delegate.popUpTableView(self, didSelectOption: optionsList![indexPath.row], atIndex: indexPath.row)
        self.isHidden = true
        tableView.reloadData()
    }
}
