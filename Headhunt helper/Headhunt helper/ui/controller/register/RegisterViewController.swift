//
//  RegisterViewController.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 10/07/2022.
//

import UIKit
import DropDown

class RegisterViewController: UIViewController {
    @IBOutlet private weak var departmentButton: UIButton!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var retypePasswordTextField: UITextField!
    private let viewModel = RegisterViewModel()
    private let departmentDropdown = DropDown()
    private var deptDataSource: [String] = []
    private var currentDepartment: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindModel()
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        retypePasswordTextField.delegate = self
        departmentDropdown.anchorView = departmentButton
        departmentDropdown.selectionAction = { (index: Int, itemName: String) in
            self.departmentButton.setTitle(itemName, for: .normal)
            self.currentDepartment = index + 1
        }
    }
    
    private func bindModel() {
        viewModel.transform()
        viewModel.output.requestRegisterSuccess.addObserver { [weak self] in
            guard let mSelf = self else { return }
            let alert = UIAlertController(title: "Success!", message: "Register successfully, please log in", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel) { _ in
                alert.dismiss(animated: true) {
                    mSelf.dismiss(animated: true)
                }
            }
            alert.addAction(action)
            mSelf.present(alert, animated: true)
        }
        viewModel.output.requestRegisterFailed.addObserver { [weak self] in
            guard let mSelf = self else { return }
            let alert = UIAlertController(title: "Error!", message: "Error occured, please retry", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel) { _ in
                alert.dismiss(animated: true)
            }
            alert.addAction(action)
            mSelf.present(alert, animated: true)
        }
        viewModel.output.requestGetAllDepartmentsSuccess.addObserver { deptList in
            for dept in deptList {
                self.deptDataSource.append(dept.name)
            }
            self.departmentDropdown.dataSource = self.deptDataSource
        }
        viewModel.input.requestGetAllDepartments.value = Void()
    }
    
    private func validateField(_ pass1: String, _ pass2: String) -> Bool {
        return pass1 == pass2 && pass1 != kEmptyStr && pass2 != kEmptyStr
    }
    
    @IBAction private func onRegister(_ sender: UIButton) {
        if let name = nameTextField.text,
           name != kEmptyStr,
           let email = emailTextField.text,
           email != kEmptyStr,
           let password = passwordTextField.text,
           let retypePassword = retypePasswordTextField.text,
           validateField(password, retypePassword),
           let currentDepartment = currentDepartment {
            var role = "Manager"
            if deptDataSource[currentDepartment] == "Human Resources Dept" {
                role = "Recruiter"
            }
            viewModel.input.requestRegister.value = (name, email, password, currentDepartment, role)
        } else {
            let alert = UIAlertController(title: "Error!", message: "Please enter again", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel) { _ in
                alert.dismiss(animated: true)
            }
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
    
    @IBAction private func onLogin(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction private func onSelectDept(_ sender: UIButton) {
        departmentDropdown.show()
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
