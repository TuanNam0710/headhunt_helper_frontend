//
//  CVTableViewCell.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 11/07/2022.
//

import UIKit

class CVTableViewCell: UITableViewCell {
    @IBOutlet private weak var rowView: UIView!
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var positionLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    
    func setupData(info: CVInfo) {
        idLabel.text = "\(info.id)"
        nameLabel.text = info.name
        positionLabel.text = info.position
        switch info.status {
        case 0:
            statusLabel.text = "Waiting"
            rowView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case 1:
            statusLabel.text = "Processing"
            rowView.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        case 2:
            statusLabel.text = "Passed"
            rowView.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        case 3:
            statusLabel.text = "Failed"
            rowView.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        default:
            return
        }
    }
}
