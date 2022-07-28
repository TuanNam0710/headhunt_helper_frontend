//
//  JDTableViewCell.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 28/07/2022.
//

import UIKit

class JDTableViewCell: UITableViewCell {
    @IBOutlet private var positionLabel: UILabel!
    @IBOutlet private var noOfJobsLabel: UILabel!
    @IBOutlet private var dueDateLabel: UILabel!
    
    @available(iOS 15.0, *)
    func setupViews(position: String, noOfJobs: Int, dueDate: Int) {
        positionLabel.text = position
        noOfJobsLabel.text = "\(noOfJobs)"
        let date = Date(timeIntervalSince1970: TimeInterval(dueDate))
        dueDateLabel.text = date.formatted(.dateTime
            .day(.twoDigits)
            .month(.twoDigits)
            .year(.twoDigits)
            .locale(.current))
        if Date().timeIntervalSince1970 < TimeInterval(dueDate) {
            self.backgroundColor = .white
        } else {
            self.backgroundColor = .yellow
        }
    }
}
