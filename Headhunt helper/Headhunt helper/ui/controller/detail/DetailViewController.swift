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
    var idCV = 0
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
        viewModel.transform()
        viewModel.output.requestGetCVBasicInfoSuccess.addObserver { [weak self] cvBasicInfo in
            guard let mSelf = self else { return }
            mSelf.cvBasicInfo = cvBasicInfo
            mSelf.detailTableView.reloadData()
        }
        viewModel.output.requestGetCVSkillsSuccess.addObserver { [weak self] cvSkill in
            guard let mSelf = self else { return }
            mSelf.cvSkill = cvSkill
            mSelf.detailTableView.reloadData()
        }
        viewModel.output.requestGetCVWorkExperienceSuccess.addObserver { [weak self] cvWorkExperience in
            guard let mSelf = self else { return }
            mSelf.cvWorkExperience = cvWorkExperience
            mSelf.detailTableView.reloadData()
        }
        viewModel.output.requestGetCVAdditionalInfoSuccess.addObserver { [weak self] cvAdditionalInfo in
            guard let mSelf = self else { return }
            mSelf.cvAdditionalInfo = cvAdditionalInfo
            mSelf.detailTableView.reloadData()
        }
        viewModel.input.requestGetCVBasicInfo.value = "\(idCV)"
        viewModel.input.requestGetCVSkills.value = "\(idCV)"
        viewModel.input.requestGetCVWorkExperience.value = "\(idCV)"
        viewModel.input.requestGetCVAdditionalInfo.value = "\(idCV)"
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
        assignToHRDD.anchorView = assignToHRButton
        assignToHRDD.dataSource = hrDataSource
        assignToHRDD.dismissMode = .automatic
        assignToHRDD.selectionAction = { [unowned self] (_, item: String) in
            self.assignToHRButton.setTitle(item, for: .normal)
            self.detailTableView.reloadData()
        }
        
        assignToDeptDD.anchorView = assignToDeptButton
        assignToDeptDD.dataSource = deptDataSource
        assignToDeptDD.dismissMode = .automatic
        assignToDeptDD.selectionAction = { [unowned self] (_, item: String) in
            self.assignToDeptButton.setTitle(item, for: .normal)
            self.detailTableView.reloadData()
        }
        
        changeStatusDD.anchorView = changeStatusButton
        changeStatusDD.dataSource = statusDataSource
        changeStatusDD.dismissMode = .automatic
        changeStatusDD.selectionAction = { [unowned self] (_, item: String) in
            self.changeStatusButton.setTitle(item, for: .normal)
            self.detailTableView.reloadData()
        }
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
        assignToHRDD.show()
    }
    
    @IBAction private func onSelectDept(_ sender: UIButton) {
        assignToDeptDD.show()
    }
    
    @IBAction private func onChangeStatus(_ sender: UIButton) {
        changeStatusDD.show()
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
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
