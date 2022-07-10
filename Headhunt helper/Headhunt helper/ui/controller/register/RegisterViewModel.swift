//
//  RegisterViewModel.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 10/07/2022.
//

import UIKit

class RegisterViewModel {
    let apiServices = APIServices.shared
    
    struct Input {
        let requestRegister = ValueTrigger<(String, String, String)>((kEmptyStr, kEmptyStr, kEmptyStr))
    }
    
    struct Output {
        let requestRegisterSuccess = ValueTrigger<Void>(Void())
        let requestRegisterFailed = ValueTrigger<Void>(Void())
    }
    
    let input = Input()
    let output = Output()
    
    func transform() {
        input.requestRegister.addObserver { [weak self] (name, email, password) in
            guard let mSelf = self else { return }
            mSelf.requestRegister(name: name, email: email, password: password)
        }
    }
    
    private func requestRegister(name: String, email: String, password: String) {
        apiServices.requestRegister(name: name, email: email, password: password) { [weak self] result in
            guard let mSelf = self else { return }
            switch result {
            case .success:
                mSelf.output.requestRegisterSuccess.value = Void()
            case .failure:
                mSelf.output.requestRegisterFailed.value = Void()
            }
        }
    }
}

