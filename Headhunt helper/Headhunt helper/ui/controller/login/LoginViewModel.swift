//
//  LoginViewModel.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 10/07/2022.
//

import UIKit

class LoginViewModel {
    let apiServices = APIServices.shared
    
    struct Input {
        let requestLogin = ValueTrigger<(String, String)>((kEmptyStr, kEmptyStr))
    }
    
    struct Output {
        let requestLoginSuccess = ValueTrigger<Void>(Void())
        let requestLoginFailed = ValueTrigger<Void>(Void())
    }
    
    let input = Input()
    let output = Output()
    
    func transform() {
        input.requestLogin.addObserver { [weak self] (email, password) in
            guard let mSelf = self else { return }
            mSelf.requestLogin(email: email, password: password)
        }
    }
    
    private func requestLogin(email: String, password: String) {
        apiServices.requestLogin(email: email, password: password) { [weak self] result in
            guard let mSelf = self else { return }
            switch result {
            case .success:
                mSelf.output.requestLoginSuccess.value = Void()
            case .failure:
                mSelf.output.requestLoginFailed.value = Void()
            }
        }
    }
}
