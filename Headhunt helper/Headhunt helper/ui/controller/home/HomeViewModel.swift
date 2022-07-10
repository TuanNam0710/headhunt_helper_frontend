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
    }
    
    struct Output {
        let getUserInfoSuccess = ValueTrigger<RecruiterInfo?>(nil)
        let getUserInfoFailed = ValueTrigger<Error?>(nil)
        let getAllCVSuccess = ValueTrigger<[CVInfo]?>(nil)
        let getAllCVFailed = ValueTrigger<Error?>(nil)
        let getMyCVSuccess = ValueTrigger<Void>(Void())
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
}
