//
//  ManageDocumentTableViewCell.swift
//  TapNGo Driver
//
//  Created by Mohammed Arshad on 15/11/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import UIKit

class ManageDocumentTableViewCell: UITableViewCell {

    var viewContent = UIView ()
    var lblDocName = UILabel()
    var lblDocFile = UILabel()
    var btnDelete = UIButton()
    var ImgDocFile = UIImageView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
    super.init(style: style, reuseIdentifier: "ManageDocumentCell")


        viewContent.backgroundColor = UIColor.white
        viewContent.addShadow()

        self.addSubview(viewContent)

        viewContent.addSubview(lblDocName)
        viewContent.addSubview(lblDocFile)
        viewContent.addSubview(btnDelete)
        viewContent.addSubview(ImgDocFile)

        
        lblDocFile.textColor = UIColor.gray
        lblDocName.textColor = UIColor.black

        btnDelete.setImage(UIImage(named: "del"), for: .normal)
        ImgDocFile.image = UIImage(named: "cloud")

        self.viewContent.translatesAutoresizingMaskIntoConstraints = false
        self.lblDocName.translatesAutoresizingMaskIntoConstraints = false
        self.lblDocFile.translatesAutoresizingMaskIntoConstraints = false
        self.btnDelete.translatesAutoresizingMaskIntoConstraints = false
        self.ImgDocFile.translatesAutoresizingMaskIntoConstraints = false


    let viewDict = ["viewContent": viewContent, "lblDocName": lblDocName, "lblDocFile": lblDocFile,"btnDelete": btnDelete,"ImgDocFile": ImgDocFile]

    self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[viewContent]-16-|", options: [], metrics: nil, views: viewDict))

    self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[viewContent(80)]|", options: [], metrics: nil, views: viewDict))

    viewContent.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[lblDocName]|", options: [], metrics: nil, views: viewDict))

    viewContent.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[lblDocName(30)]", options: [], metrics: nil, views: viewDict))

    viewContent.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lblDocFile(30)]-8-|", options: [], metrics: nil, views: viewDict))

    viewContent.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[ImgDocFile(30)]-8-[lblDocFile]", options: [], metrics: nil, views: viewDict))
        viewContent.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[btnDelete(30)]-8-|", options: [], metrics: nil, views: viewDict))
         viewContent.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[btnDelete(30)]-20-|", options: [], metrics: nil, views: viewDict))
        viewContent.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[ImgDocFile(30)]-8-|", options: [], metrics: nil, views: viewDict))


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
