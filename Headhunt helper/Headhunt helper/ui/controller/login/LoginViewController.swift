//
//  LoginViewController.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 09/07/2022.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    private let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.transform()
        bindModel()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func bindModel() {
        viewModel.transform()
        viewModel.output.requestLoginSuccess.addObserver { [weak self] in
            guard let mSelf = self else { return }
            let alert = UIAlertController(title: "Success!", message: "Login success", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel) { _ in
                alert.dismiss(animated: true) {
                    let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
                    guard let homeViewController = homeStoryboard.instantiateViewController(withIdentifier: "homeViewController") as? HomeViewController else {
                        return
                    }
                    homeViewController.userEmail = mSelf.emailTextField.text ?? kEmptyStr
                    homeViewController.modalPresentationStyle = .fullScreen
                    mSelf.present(homeViewController, animated: true)
                }
            }
            alert.addAction(action)
            mSelf.present(alert, animated: true)
        }
        viewModel.output.requestLoginFailed.addObserver { [weak self] in
            guard let mSelf = self else { return }
            let alert = UIAlertController(title: "Error!", message: "Login failed", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel) { _ in
                alert.dismiss(animated: true)
            }
            alert.addAction(action)
            mSelf.present(alert, animated: true)
        }
    }
    
    @IBAction private func onLogin(_ sender: UIButton) {
        if let email = emailTextField.text,
            email != kEmptyStr,
            let password = passwordTextField.text,
            password != kEmptyStr {
            viewModel.input.requestLogin.value = (email, password)
        } else {
            let alert = UIAlertController(title: "Error!", message: "Please enter again", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel) { _ in
                alert.dismiss(animated: true)
            }
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
    
    @IBAction private func onRegister(_ sender: UIButton) {
        let registerStoryboard = UIStoryboard(name: "Register", bundle: nil)
        guard let registerViewController = registerStoryboard
            .instantiateViewController(withIdentifier: "registerViewController") as? RegisterViewController else {
            return
        }
        registerViewController.modalPresentationStyle = .fullScreen
        self.present(registerViewController, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
