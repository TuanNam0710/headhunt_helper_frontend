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
        let requestRegister = ValueTrigger<(String, String, String, Int, String)>((kEmptyStr, kEmptyStr, kEmptyStr, 0, kEmptyStr))
        let requestGetAllDepartments = ValueTrigger<Void>(Void())
    }
    
    struct Output {
        let requestRegisterSuccess = ValueTrigger<Void>(Void())
        let requestRegisterFailed = ValueTrigger<Void>(Void())
        let requestGetAllDepartmentsSuccess = ValueTrigger<[Department]>(Array())
    }
    
    let input = Input()
    let output = Output()
    
    func transform() {
        input.requestRegister.addObserver { [weak self] (name, email, password, idDept, role) in
            guard let mSelf = self else { return }
            mSelf.requestRegister(name: name,
                                  email: email,
                                  password: password,
                                  idDept: idDept,
                                  role: role)
        }
        input.requestGetAllDepartments.addObserver { [weak self] in
            guard let mSelf = self else { return }
            mSelf.requestGetAllDepartments()
        }
    }
    
    private func requestRegister(name: String, email: String, password: String, idDept: Int, role: String) {
        apiServices.requestRegister(name: name, email: email, password: password, idDept: idDept, role: role) { [weak self] result in
            guard let mSelf = self else { return }
            switch result {
            case .success:
                mSelf.output.requestRegisterSuccess.value = Void()
            case .failure:
                mSelf.output.requestRegisterFailed.value = Void()
            }
        }
    }
    
    private func requestGetAllDepartments() {
        apiServices.requestAllDepts { [weak self] departmentList, error in
            guard let mSelf = self else { return }
            if error == nil, let departmentList = departmentList {
                mSelf.output.requestGetAllDepartmentsSuccess.value = departmentList
            }
        }
    }
}

