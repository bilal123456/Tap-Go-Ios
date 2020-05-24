//
//  InvoiceTableCell.swift
//  TapNGo Driver
//
//  Created by Spextrum on 10/02/18.
//  Copyright © 2018 nPlus. All rights reserved.
//

import UIKit

class InvoiceTableCell: UITableViewCell
{

    @IBOutlet weak var LblInvoiceContent: UILabel!
    @IBOutlet weak var LblInvoiceContentPrice: UILabel!
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        LblInvoiceContent.font = UIFont.appFont(ofSize: LblInvoiceContent.font!.pointSize)
        LblInvoiceContentPrice.font = UIFont.appFont(ofSize: LblInvoiceContentPrice.font!.pointSize)
        LblInvoiceContent.textAlignment = HelperClass.appTextAlignment
        LblInvoiceContentPrice.textAlignment = HelperClass.appTextAlignment == .left ? .right : .left
    }

}
