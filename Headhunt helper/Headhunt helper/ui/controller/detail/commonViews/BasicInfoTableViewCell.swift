//
//  BasicInfoTableViewCell.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 11/07/2022.
//

import UIKit

class BasicInfoTableViewCell: UITableViewCell {
    @IBOutlet private weak var detailLabel: UILabel!
    
    func setupData(_ text: String?) {
        detailLabel.text = text
    }
}
