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
    @IBOutlet private weak var submitButton: UIButton!
    private let isAllowEditting = SharedPreference.shared.getString(key: kRole) == "Manager"
    var id: Int?
    var currentDate: Date?
    var position: String?
    var noOfJobs: String?
    var jobDescription: String?
    private var currentSelectedPosition: Int?
    private let positionDropDown = DropDown()
    private var positionDataSource = [String]()
    var positionList: [Position] = [] {
        didSet {
            positionDataSource.removeAll()
            for position in positionList {
                positionDataSource.append(position.name)
            }
            positionDropDown.dataSource = positionDataSource
        }
    }
    private let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindModel()
        setupViews()
    }
    
    private func bindModel() {
        viewModel.transform()
        viewModel.output.requestCreateJDSuccess.addObserver { _ in
            let alert = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel) { _ in
                self.dismiss(animated: true)
            }
            alert.addAction(action)
            self.present(alert, animated: true)
        }
        viewModel.output.requestUpdateJDSuccess.addObserver { _ in
            let alert = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel) { _ in
                self.dismiss(animated: true)
            }
            alert.addAction(action)
            self.present(alert, animated: true)
        }
        viewModel.output.requestAllPositionsSuccess.addObserver { positionList in
            if let positionList = positionList {
                self.positionList = positionList
            }
        }
        viewModel.input.requestAllPositions.value = Void()
    }
    
    private func setupViews() {
        descriptionTextField.isEnabled = isAllowEditting
        noOfJobsTextField.isEnabled = isAllowEditting
        dueDateDatePicker.isEnabled = isAllowEditting
        submitButton.setTitle(isAllowEditting ? "Submit" : "Back", for: .normal)
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
        for index in 0 ..< positionList.count {
            if positionList[index].name == position {
                currentSelectedPosition = index
            }
        }
        descriptionTextField.delegate = self
        noOfJobsTextField.delegate = self
        positionDropDown.anchorView = positionButton
        positionDropDown.dataSource = positionDataSource
        positionDropDown.selectionAction = { (index: Int, item: String) in
            self.currentSelectedPosition = index
            self.positionButton.setTitle(item, for: .normal)
        }
    }
    
    @IBAction private func onSelectPosition(_ sender: UIButton) {
        guard isAllowEditting else {
            return
        }
        positionDropDown.show()
    }
    
    @IBAction private func onSubmit(_ sender: UIButton) {
        guard isAllowEditting else {
            self.dismiss(animated: true)
            return
        }
        let dueDate = "\(Int(dueDateDatePicker.date.timeIntervalSince1970))"
        if let currentSelectedPosition = currentSelectedPosition,
           let noOfJobs = Int(noOfJobsTextField.text ?? ""),
           let description = descriptionTextField.text {
            if let id = id {
                viewModel.input.requestUpdateJD.value = (id, positionList[currentSelectedPosition].id!, description, noOfJobs, dueDate)
            } else {
                viewModel.input.requestCreateJD.value = (positionList[currentSelectedPosition].id!, description, noOfJobs, dueDate)
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Error occurred!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
}

extension NewRequestViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
