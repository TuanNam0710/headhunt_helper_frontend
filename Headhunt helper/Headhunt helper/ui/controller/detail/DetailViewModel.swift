//
//  DetailViewModel.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 11/07/2022.
//

import UIKit

class DetailViewModel {
    let apiServices = APIServices.shared
    
    struct Input {
        let requestGetCVBasicInfo = ValueTrigger<String>(kEmptyStr)
        let requestGetCVSkills = ValueTrigger<String>(kEmptyStr)
        let requestGetCVWorkExperience = ValueTrigger<String>(kEmptyStr)
        let requestGetCVAdditionalInfo = ValueTrigger<String>(kEmptyStr)
        let requestAssignCVDept = ValueTrigger<(String, String)>((kEmptyStr, kEmptyStr))
        let requestAssignCVRecruiter = ValueTrigger<(String, String)>((kEmptyStr, kEmptyStr))
        let requestUpdateCVStatus = ValueTrigger<(String, String)>((kEmptyStr, kEmptyStr))
    }
    
    struct Output {
        let requestGetCVBasicInfoSuccess = ValueTrigger<CVInfo?>(nil)
        let requestGetCVBasicInfoFailed = ValueTrigger<Void>(Void())
        let requestGetCVSkillsSuccess = ValueTrigger<[CVSkills]?>(nil)
        let requestGetCVSkillsFailed = ValueTrigger<Void>(Void())
        let requestGetCVWorkExperienceSuccess = ValueTrigger<[CVWorkExperience]?>(nil)
        let requestGetCVWorkExperienceFailed = ValueTrigger<Void>(Void())
        let requestGetCVAdditionalInfoSuccess = ValueTrigger<[CVAdditionalInfo]?>(nil)
        let requestGetCVAdditionalInfoFailed = ValueTrigger<Void>(Void())
        let requestAssignCVDeptSuccess = ValueTrigger<Void>(Void())
        let requestAssignCVDeptFailed = ValueTrigger<Void>(Void())
        let requestAssignCVRecruiterSuccess = ValueTrigger<Void>(Void())
        let requestAssignCVRecruiterFailed = ValueTrigger<Void>(Void())
        let requestUpdateCVStatusSuccess = ValueTrigger<Void>(Void())
        let requestUpdateCVStatusFailed = ValueTrigger<Void>(Void())
    }
    
    let input = Input()
    let output = Output()
    
    func transform() {
        input.requestGetCVBasicInfo.addObserver { [weak self] id in
            guard let mSelf = self else { return }
            mSelf.getCVBasicInfo(id: id)
        }
        input.requestGetCVSkills.addObserver { [weak self] id in
            guard let mSelf = self else { return }
            mSelf.getCVSkills(id: id)
        }
        input.requestGetCVWorkExperience.addObserver { [weak self] id in
            guard let mSelf = self else { return }
            mSelf.getCVWorkExperience(id: id)
        }
        input.requestGetCVAdditionalInfo.addObserver { [weak self] id in
            guard let mSelf = self else { return }
            mSelf.getCVAdditionalInfo(id: id)
        }
        input.requestAssignCVDept.addObserver { [weak self] id, idDepartment in
            guard let mSelf = self else { return }
            mSelf.assignCVToDept(id: id, idDepartment: idDepartment)
        }
        input.requestAssignCVRecruiter.addObserver { [weak self] id, idRecruiter in
            guard let mSelf = self else { return }
            mSelf.assignCVToRecruiter(id: id, idRecruiter: idRecruiter)
        }
        input.requestUpdateCVStatus.addObserver { [weak self] id, status in
            guard let mSelf = self else { return }
            mSelf.updateCVStatus(id: id, status: status)
        }
    }
    
    private func getCVBasicInfo(id: String) {
        apiServices.requestBasicInfoCV(id: id) { [weak self] basicInfoList, error in
            guard let mSelf = self else { return }
            if error == nil {
                mSelf.output.requestGetCVBasicInfoSuccess.value = basicInfoList?.first
            } else {
                mSelf.output.requestGetCVBasicInfoFailed.value = Void()
            }
        }
    }
    
    private func getCVSkills(id: String) {
        apiServices.requestSkillsCV(id: id) { [weak self] skillList, error in
            guard let mSelf = self else { return }
            if error == nil {
                mSelf.output.requestGetCVSkillsSuccess.value = skillList
            } else {
                mSelf.output.requestGetCVSkillsFailed.value = Void()
            }
        }
    }
    
    private func getCVWorkExperience(id: String) {
        apiServices.requestWorkExperienceCV(id: id) { [weak self] workExperienceList, error in
            guard let mSelf = self else { return }
            if error == nil {
                mSelf.output.requestGetCVWorkExperienceSuccess.value = workExperienceList
            } else {
                mSelf.output.requestGetCVWorkExperienceFailed.value = Void()
            }
        }
    }
    
    private func getCVAdditionalInfo(id: String) {
        apiServices.requestAdditionalInfoCV(id: id) { [weak self] additionalInfoList, error in
            guard let mSelf = self else { return }
            if error == nil {
                mSelf.output.requestGetCVAdditionalInfoSuccess.value = additionalInfoList
            } else {
                mSelf.output.requestGetCVAdditionalInfoFailed.value = Void()
            }
        }
    }
    
    private func assignCVToDept(id: String, idDepartment: String) {
        apiServices.requestAssignCVToDepartment(id: id,
                                                idDepartment: idDepartment) { [weak self] result in
            guard let mSelf = self else { return }
            switch result {
            case.success:
                mSelf.output.requestAssignCVDeptSuccess.value = Void()
            case .failure:
                mSelf.output.requestAssignCVDeptFailed.value = Void()
            }
        }
    }
    
    private func assignCVToRecruiter(id: String, idRecruiter: String) {
        apiServices.requestAssignCVToRecruiter(id: id,
                                               idRecruiter: idRecruiter) { [weak self] result in
            guard let mSelf = self else { return }
            switch result {
            case .success:
                mSelf.output.requestAssignCVRecruiterSuccess.value = Void()
            case .failure:
                mSelf.output.requestAssignCVRecruiterFailed.value = Void()
            }
        }
    }
    
    private func updateCVStatus(id: String, status: String) {
        apiServices.requestUpdateCVStatus(id: id,
                                          status: status) { [weak self] result in
            guard let mSelf = self else { return }
            switch result {
            case .success:
                mSelf.output.requestUpdateCVStatusSuccess.value = Void()
            case .failure:
                mSelf.output.requestUpdateCVStatusFailed.value = Void()
            }
        }
    }
}
