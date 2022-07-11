//
//  HomeViewModel.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 10/07/2022.
//

import UIKit

class HomeViewModel {
    let apiServices = APIServices.shared
    
    struct Input {
        let getUserInfo = ValueTrigger<String>(kEmptyStr)
        let getAllCV = ValueTrigger<Void>(Void())
        let getMyCV = ValueTrigger<Void>(Void())
        let requestLogout = ValueTrigger<String>(kEmptyStr)
        let requestAllRecruiters = ValueTrigger<Void>(Void())
        let requestAllDepts = ValueTrigger<Void>(Void())
    }
    
    struct Output {
        let getUserInfoSuccess = ValueTrigger<RecruiterInfo?>(nil)
        let getUserInfoFailed = ValueTrigger<Error?>(nil)
        let getAllCVSuccess = ValueTrigger<[CVInfo]?>(nil)
        let getAllCVFailed = ValueTrigger<Error?>(nil)
        let getMyCVSuccess = ValueTrigger<Void>(Void())
        let requestLogoutSuccess = ValueTrigger<Void>(Void())
        let requestLogoutFailed = ValueTrigger<Void>(Void())
        let requestAllRecruitersSuccess = ValueTrigger<[RecruiterInfo]?>(nil)
        let requestAllDeptsSuccess = ValueTrigger<[Department]?>(nil)
    }
    
    let input = Input()
    let output = Output()
    
    func transform() {
        input.getUserInfo.addObserver { [weak self] email in
            guard let mSelf = self else { return }
            mSelf.getUserInfo(email: email)
        }
        input.getAllCV.addObserver { [weak self] in
            guard let mSelf = self else { return }
            mSelf.getAllCV()
        }
        input.getMyCV.addObserver { [weak self] in
            guard let mSelf = self else { return }
            mSelf.getMyCV()
        }
        input.requestLogout.addObserver { [weak self] id in
            guard let mSelf = self else { return }
            mSelf.logout(id: id)
        }
        input.requestAllRecruiters.addObserver { [weak self] in
            guard let mSelf = self else { return }
            mSelf.getAllRecruiters()
        }
        input.requestAllDepts.addObserver { [weak self] in
            guard let mSelf = self else { return }
            mSelf.getAllDepts()
        }
    }
    
    private func getUserInfo(email: String) {
        apiServices.requestUserInfo(email: email) { [weak self] recruiterInfo, error in
            guard let mSelf = self else { return }
            if error != nil {
                mSelf.output.getUserInfoFailed.value = error
            } else {
                mSelf.output.getUserInfoSuccess.value = recruiterInfo
            }
        }
    }
    
    private func getAllCV() {
        apiServices.requestGetAllCV { [weak self] cvList, error in
            guard let mSelf = self else { return }
            if error != nil {
                mSelf.output.getAllCVFailed.value = error
            } else {
                mSelf.output.getAllCVSuccess.value = cvList
            }
        }
    }
    
    private func getMyCV() {
        output.getMyCVSuccess.value = Void()
    }
    
    private func logout(id: String) {
        apiServices.requestLogout(id: id) { [weak self] result in
            guard let mSelf = self else { return }
            switch result {
            case.success:
                mSelf.output.requestLogoutSuccess.value = Void()
            case .failure:
                mSelf.output.requestLogoutFailed.value = Void()
            }
        }
    }
    
    private func getAllRecruiters() {
        apiServices.requestAllRecruiters { [weak self] recruiterList, error in
            guard let mSelf = self else { return }
            if error == nil {
                mSelf.output.requestAllRecruitersSuccess.value = recruiterList
            }
        }
    }
    
    private func getAllDepts() {
        apiServices.requestAllDepts { [weak self] departmentList, error in
            guard let mSelf = self else { return }
            if error == nil {
                mSelf.output.requestAllDeptsSuccess.value = departmentList
            }
        }
    }
}
