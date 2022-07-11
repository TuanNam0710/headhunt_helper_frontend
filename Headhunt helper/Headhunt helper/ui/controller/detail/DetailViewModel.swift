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
}
