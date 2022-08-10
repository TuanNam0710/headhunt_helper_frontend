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
        let requestAllJDs = ValueTrigger<Void>(Void())
        let requestAllPositions = ValueTrigger<Void>(Void())
        let requestDeleteJD = ValueTrigger<Int?>(nil)
        let requestCreateJD = ValueTrigger<(Int, String, Int, String)>((-1, "", -1, ""))
        let requestUpdateJD = ValueTrigger<(Int, Int, String, Int, String)>((-1, -1, "", -1, ""))
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
        let requestAllJDSuccess = ValueTrigger<[JobDescription]?>(nil)
        let requestAllPositionsSuccess = ValueTrigger<[Position]?>(nil)
        let requestDeleteJDSuccess = ValueTrigger<Void>(Void())
        let requestCreateJDSuccess = ValueTrigger<Void>(Void())
        let requestUpdateJDSuccess = ValueTrigger<Void>(Void())
    }
    
    let input = Input()
    let output = Output()
    
    func transform() {
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
        input.requestAllJDs.addObserver { [weak self] in
            guard let mSelf = self else { return }
            mSelf.getAllJD()
        }
        input.requestAllPositions.addObserver { [weak self] in
            guard let mSelf = self else { return }
            mSelf.getAllPosition()
        }
        input.requestDeleteJD.addObserver { [weak self] id in
            guard let mSelf = self else { return }
            if let id = id {
                mSelf.deleteJD(id: id)
            }
        }
        input.requestCreateJD.addObserver { [weak self] (idPosition, description, noOfJobs, dueDate) in
            guard let mSelf = self else { return }
            mSelf.createJD(idPosition: idPosition,
                           description: description,
                           noOfJobs: noOfJobs,
                           dueDate: dueDate)
        }
        input.requestUpdateJD.addObserver { [weak self] (id, idPosition, description, noOfJobs, dueDate) in
            guard let mSelf = self else { return }
            mSelf.updateJD(id: id,
                           idPosition: idPosition,
                           description: description,
                           noOfJobs: noOfJobs,
                           dueDate: dueDate)
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
                mSelf.output.requestAllRecruitersSuccess.value = recruiterList?.filter { $0.idDepartment == 6 }
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
    
    private func getAllJD() {
        apiServices.requestJD { jdList, error in
            if error == nil {
                self.output.requestAllJDSuccess.value = jdList
            }
        }
    }
    
    private func getAllPosition() {
        apiServices.requestPosition { positionList, error in
            if error == nil {
                self.output.requestAllPositionsSuccess.value = positionList
            }
        }
    }
    
    private func deleteJD(id: Int) {
        apiServices.requestDeleteJD(id: id) { error in
            if error == nil {
                self.output.requestDeleteJDSuccess.value = Void()
            }
        }
    }
    
    private func createJD(idPosition: Int,
                          description: String,
                          noOfJobs: Int,
                          dueDate: String) {
        apiServices.requestCreateJD(idPosition: idPosition,
                                    description: description,
                                    noOfJobs: noOfJobs,
                                    dueDate: dueDate) { error in
            if error == nil {
                self.output.requestCreateJDSuccess.value = Void()
            }
        }
    }
    
    private func updateJD(id: Int,
                          idPosition: Int,
                          description: String,
                          noOfJobs: Int,
                          dueDate: String) {
        apiServices.requestUpdateJD(id: id,
                                    idPosition: idPosition,
                                    description: description,
                                    noOfJobs: noOfJobs,
                                    dueDate: dueDate) { error in
            if error == nil {
                self.output.requestUpdateJDSuccess.value = Void()
            }
        }
    }
}
