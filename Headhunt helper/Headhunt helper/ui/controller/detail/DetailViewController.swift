//
//  DetailViewController.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 11/07/2022.
//

import UIKit
import DropDown

class DetailViewController: UIViewController {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var detailTableView: UITableView!
    @IBOutlet private weak var assignToHRButton: UIButton!
    @IBOutlet private weak var assignToDeptButton: UIButton!
    @IBOutlet private weak var changeStatusButton: UIButton!
    @IBOutlet private weak var detailPageControl: UIPageControl!
    private var swipeLeftGesture = UISwipeGestureRecognizer()
    private var swipeRightGesture = UISwipeGestureRecognizer()
    var idCV = -1
    var recruiterList: [RecruiterInfo] = []
    var departmentList: [Department] = []
    private let assignToHRDD = DropDown()
    private let assignToDeptDD = DropDown()
    private let changeStatusDD = DropDown()
    private var hrDataSource: [String] = [] {
        didSet {
            assignToHRDD.dataSource = hrDataSource
        }
    }
    private var deptDataSource: [String] = [] {
        didSet {
            assignToDeptDD.dataSource = deptDataSource
        }
    }
    private var statusDisplay: [String] = [
        "Waiting", "Processing", "Passed", "Failed"
    ]
    private var statusDataSource: [String] = [
        "Waiting", "Processing", "Passed", "Failed"
    ]
    private var cvPhone = kEmptyStr
    private var cvMail = kEmptyStr
    private let viewModel = DetailViewModel()
    private var cvBasicInfo: CVInfo?
    private var cvSkill: [CVSkills]?
    private var cvWorkExperience: [CVWorkExperience]?
    private var cvAdditionalInfo: [CVAdditionalInfo]?
    private var assignRecruiterFlag = false
    private var assignDeptFlag = false
    private var updateStatusFlag = false
    private var currentSelectRecruiterId: Int?
    private var currentSelectDeptId: Int?
    private var currentSelectStatus: Int?
    private var cvDetail: CVDetail?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hrDataSource.removeAll()
        deptDataSource.removeAll()
        bindModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupDropDown()
    }
    
    private func bindModel() {
        for recruiter in recruiterList {
            hrDataSource.append(recruiter.name)
        }
        for department in departmentList {
            deptDataSource.append(department.name)
        }
        let currentRole = SharedPreference.shared.getString(key: kRole)
        let currentDeptId = Int(SharedPreference.shared.getString(key: kCurrentDept)) ?? -1
        if currentRole == "Manager" {
            deptDataSource.removeAll()
            for department in departmentList {
                if department.id == currentDeptId || department.id == 6 {
                    deptDataSource.append(department.name)
                }
            }
        }
        viewModel.transform()
        viewModel.output.requestGetDetailCVSuccess.addObserver { [weak self] cvDetail in
            guard let mSelf = self else { return }
            mSelf.nameLabel.text = cvDetail?.basicInfo.name
            mSelf.cvDetail = cvDetail
            mSelf.cvBasicInfo = cvDetail?.basicInfo
            mSelf.cvSkill = cvDetail?.skill
            mSelf.cvWorkExperience = cvDetail?.workExperience
            mSelf.cvAdditionalInfo = cvDetail?.additionalInfo
            mSelf.setupViews()
            mSelf.detailTableView.reloadData()
        }
        viewModel.output.requestUpdateCVDetailSuccess.addObserver { [weak self] _ in
            guard let mSelf = self else { return }
            let alert = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel) { _ in
                alert.dismiss(animated: true) {
                    mSelf.dismiss(animated: true)
                }
            }
            alert.addAction(action)
            mSelf.present(alert, animated: true)
        }
        viewModel.input.requestGetDetailCV.value = "\(idCV)"
    }
    
    private func setupTableView() {
        swipeLeftGesture = UISwipeGestureRecognizer(target: self,
                                                    action: #selector(onSwipeLeft))
        swipeLeftGesture.direction = .left
        detailTableView.addGestureRecognizer(swipeLeftGesture)
        swipeRightGesture = UISwipeGestureRecognizer(target: self,
                                                     action: #selector(onSwipeRight))
        detailTableView.addGestureRecognizer(swipeRightGesture)
        detailTableView.register(UINib(nibName: "BasicInfoTableViewCell",
                                       bundle: nil),
                                 forCellReuseIdentifier: "basicInfoTableViewCell")
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.reloadData()
    }
    
    @objc private func onSwipeLeft() {
        if detailPageControl.currentPage < detailPageControl.numberOfPages - 1 {
            detailPageControl.currentPage = detailPageControl.currentPage + 1
            detailTableView.reloadData()
        }
    }
    
    @objc private func onSwipeRight() {
        if detailPageControl.currentPage > 0 {
            detailPageControl.currentPage = detailPageControl.currentPage - 1
            detailTableView.reloadData()
        }
    }
    
    private func setupDropDown() {
        let currentRole = SharedPreference.shared.getString(key: kRole)
        let currentDeptId = Int(SharedPreference.shared.getString(key: kCurrentDept)) ?? -1
        assignToHRDD.anchorView = assignToHRButton
        assignToHRDD.dataSource = hrDataSource
        assignToHRDD.dismissMode = .automatic
        assignToHRDD.selectionAction = { [unowned self] (index: Int, item: String) in
            self.currentSelectRecruiterId = recruiterList[index].id
            self.assignToHRButton.setTitle(item, for: .normal)
            self.detailTableView.reloadData()
        }
        if currentRole == "Manager" {
            deptDataSource.removeAll()
            for department in departmentList {
                if department.id == currentDeptId || department.id == 6 {
                    deptDataSource.append(department.name)
                }
            }
        }
        assignToDeptDD.anchorView = assignToDeptButton
        assignToDeptDD.dataSource = deptDataSource
        assignToDeptDD.dismissMode = .automatic
        assignToDeptDD.selectionAction = { [unowned self] (index: Int, item: String) in
            for department in departmentList {
                if department.name == item {
                    self.currentSelectDeptId = department.id
                }
            }
            self.assignToDeptButton.setTitle(item, for: .normal)
            self.detailTableView.reloadData()
        }
        if currentRole == "Manager" {
            statusDataSource = ["Passed", "Failed"]
        } else {
            statusDataSource = ["Waiting", "Processing"]
        }
        changeStatusDD.anchorView = changeStatusButton
        changeStatusDD.dataSource = statusDataSource
        changeStatusDD.dismissMode = .automatic
        changeStatusDD.selectionAction = { [unowned self] (index: Int, item: String) in
            self.currentSelectStatus = currentRole == "Manager" ? index + 2 : index
            self.changeStatusButton.setTitle(item, for: .normal)
            self.detailTableView.reloadData()
        }
    }
    
    private func setupViews() {
        for index in 0 ..< recruiterList.count {
            if recruiterList[index].id == cvBasicInfo?.idRecruiter {
                assignToHRButton.setTitle(recruiterList[index].name, for: .normal)
                currentSelectRecruiterId = recruiterList[index].id
            }
        }
        for index in 0 ..< departmentList.count {
            if departmentList[index].id == cvBasicInfo?.idDepartment {
                assignToDeptButton.setTitle(departmentList[index].name, for: .normal)
                currentSelectDeptId = departmentList[index].id
            }
        }
        if let cvBasicInfo = cvBasicInfo {
            changeStatusButton.setTitle(statusDisplay[cvBasicInfo.status], for: .normal)
            currentSelectStatus = cvBasicInfo.status
        }
        cvMail = cvBasicInfo?.email ?? kEmptyStr
        cvPhone = cvBasicInfo?.phone ?? kEmptyStr
    }
    
    @IBAction private func onBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction private func onContact(_ sender: UIButton) {
        let alert = UIAlertController(title: "Contact applicant", message: nil, preferredStyle: .actionSheet)
        let phoneAction = UIAlertAction(title: "Call \(cvPhone)", style: .default) { [weak self] _ in
            guard let mSelf = self else { return }
            let phoneURL = URL(string: kTelScheme + mSelf.cvPhone)
            if let phoneURL = phoneURL, UIApplication.shared.canOpenURL(phoneURL) {
                UIApplication.shared.open(phoneURL)
            }
        }
        let mailAction = UIAlertAction(title: "Send email to \(cvMail)", style: .default) { [weak self] _ in
            guard let mSelf = self else { return }
            let mailURL = URL(string: kMailScheme + mSelf.cvMail)
            if let mailURL = mailURL, UIApplication.shared.canOpenURL(mailURL) {
                UIApplication.shared.open(mailURL)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(phoneAction)
        alert.addAction(mailAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    @IBAction private func onChangePage(_ sender: UIPageControl) {
        detailTableView.reloadData()
    }
    
    @IBAction private func onSelectHR(_ sender: UIButton) {
        guard SharedPreference.shared.getString(key: kRole) == "Recruiter" else {
            return
        }
        assignToHRDD.show()
    }
    
    @IBAction private func onSelectDept(_ sender: UIButton) {
        assignToDeptDD.show()
    }
    
    @IBAction private func onChangeStatus(_ sender: UIButton) {
        changeStatusDD.show()
    }
    
    @IBAction private func onSave(_ sender: UIButton) {
        if let currentSelectRecruiterId = currentSelectRecruiterId,
           let currentSelectDeptId = currentSelectDeptId,
           let currentSelectStatus = currentSelectStatus {
            viewModel.input.requestUpdateCVDetail.value = (idCV, currentSelectDeptId, currentSelectRecruiterId, currentSelectStatus)
        } else {
            let alert = UIAlertController(title: "Error", message: "Please fill all fields before sending!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch detailPageControl.currentPage {
        case 0:
            return "Basic Info"
        case 1:
            return "Work Experience"
        case 2:
            return "Skill"
        case 3:
            return "Additional Info"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch detailPageControl.currentPage {
        case 0:
            return 1
        case 1:
            return cvWorkExperience?.count ?? 0
        case 2:
            return cvSkill?.count ?? 0
        case 3:
            return cvAdditionalInfo?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch detailPageControl.currentPage {
        case 0:
            return 5
        case 1:
            return 4
        case 2:
            return 1
        case 3:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "basicInfoTableViewCell") as? BasicInfoTableViewCell else {
            return UITableViewCell()
        }
        switch detailPageControl.currentPage {
        case 0:
            switch indexPath.row {
            case 0:
                cell.setupData(cvBasicInfo?.name)
            case 1:
                cell.setupData(cvBasicInfo?.gender == 0 ? "Male" : "Female")
            case 2:
                cell.setupData(cvBasicInfo?.position)
            case 3:
                cell.setupData(cvBasicInfo?.phone)
            case 4:
                cell.setupData(cvBasicInfo?.email)
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.setupData(cvWorkExperience?[indexPath.section].companyName)
            case 1:
                let time = (cvWorkExperience?[indexPath.section].startTime)! + " - " + (cvWorkExperience?[indexPath.section].endTime)!
                cell.setupData(time)
            case 2:
                cell.setupData(cvWorkExperience?[indexPath.section].position)
            case 3:
                cell.setupData(cvWorkExperience?[indexPath.section].detail)
            default:
                break
            }
        case 2:
            cell.setupData(cvSkill?[indexPath.section].detail)
        case 3:
            switch indexPath.row {
            case 0:
                cell.setupData(cvAdditionalInfo?[indexPath.section].title)
            case 1:
                cell.setupData(cvAdditionalInfo?[indexPath.section].detail)
            default:
                break
            }
        default:
            break
        }
        return cell
    }
}
