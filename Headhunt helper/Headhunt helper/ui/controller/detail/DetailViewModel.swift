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
        let requestGetDetailCV = ValueTrigger<String>(kEmptyStr)
        let requestUpdateCVDetail = ValueTrigger<(Int, Int, Int, Int)>((-1, -1, -1, -1))
    }
    
    struct Output {
        let requestGetDetailCVSuccess = ValueTrigger<CVDetail?>(nil)
        let requestUpdateCVDetailSuccess = ValueTrigger<Void>(Void())
    }
    
    let input = Input()
    let output = Output()
    
    func transform() {
        input.requestGetDetailCV.addObserver { [weak self] id in
            guard let mSelf = self else { return }
            mSelf.getDetailCV(id: id)
        }
        input.requestUpdateCVDetail.addObserver { [weak self] id, idDept, idRec, status in
            guard let mSelf = self else { return }
            mSelf.updateDetailCV(id: id, idDept: idDept, idRecruiter: idRec, status: status)
        }
    }
    
    private func getDetailCV(id: String) {
        apiServices.requestDetailCV(id: id) { [weak self] cvDetail, error in
            guard let mSelf = self else { return }
            if error == nil {
                mSelf.output.requestGetDetailCVSuccess.value = cvDetail
            }
        }
    }
    
    private func updateDetailCV(id: Int, idDept: Int, idRecruiter: Int, status: Int) {
        apiServices.requestUpdateDetailCV(id: id,
                                          idDepartment: idDept,
                                          idRecruiter: idRecruiter,
                                          status: status) { [weak self] error in
            guard let mSelf = self else { return }
            if error == nil {
                mSelf.output.requestUpdateCVDetailSuccess.value = Void()
            }
        }
    }
}
