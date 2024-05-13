//
//  StudentInformationCellTableViewCell.swift
//  OnTheMap
//
//  Created by admin on 8/5/24.
//

import UIKit

class StudentInformationCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    
    override func prepareForReuse() {
        lblTitle.text = nil
        lblDetail.text = nil
    }

}
