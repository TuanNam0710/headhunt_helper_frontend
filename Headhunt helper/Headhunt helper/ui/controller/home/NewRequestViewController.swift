//
//  NewRequestViewController.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 27/07/2022.
//

import UIKit
import DropDown

class NewRequestViewController: UIViewController {
    @IBOutlet private weak var positionButton: UIButton!
    @IBOutlet private weak var descriptionTextField: UITextField!
    @IBOutlet private weak var noOfJobsTextField: UITextField!
    @IBOutlet private weak var dueDateDatePicker: UIDatePicker!
    
    var currentDate: Date?
    var position: String?
    var noOfJobs: String?
    var jobDescription: String?
    var currentSelectedPosition: String?
    private let positionDropDown = DropDown()
    private var positionDataSource = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindModel()
        setupViews()
    }
    
    private func bindModel() {
        
    }
    
    private func setupViews() {
        if let currentDate = currentDate {
            dueDateDatePicker.date = currentDate
        }
        if let position = position {
            positionButton.setTitle(position, for: .normal)
        }
        if let noOfJobs = noOfJobs {
            noOfJobsTextField.text = noOfJobs
        }
        if let jobDescription = jobDescription {
            descriptionTextField.text = jobDescription
        }
        descriptionTextField.delegate = self
        noOfJobsTextField.delegate = self
        positionDropDown.anchorView = positionButton
        positionDropDown.dataSource = positionDataSource
        positionDropDown.selectionAction = { (index: Int, item: String) in
            self.currentSelectedPosition = "\(index + 1)"
            self.positionButton.setTitle(item, for: .normal)
        }
    }
    
    @IBAction private func onSubmit(_ sender: UIButton) {
        let dueDate = "\(dueDateDatePicker.date.timeIntervalSince1970)"
        if let currentSelectedPosition = currentSelectedPosition,
           let noOfJobs = noOfJobsTextField.text,
           let description = descriptionTextField.text {
            print(dueDate)
            print(currentSelectedPosition)
            print(noOfJobs)
            print(description)
        }
    }
}

extension NewRequestViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
