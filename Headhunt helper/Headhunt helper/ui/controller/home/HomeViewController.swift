//
//  HomeViewController.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 10/07/2022.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet private weak var cvSegmentController: UISegmentedControl!
    @IBOutlet private weak var cvSearchBar: UISearchBar!
    @IBOutlet private weak var cvTableView: UITableView!
    @IBOutlet private weak var greetingsLabel: UILabel!
    private let viewModel = HomeViewModel()
    private let secureDataHelper = SecureDataHelper.shared
    private let sharedPreference = SharedPreference.shared
    var refreshControl: UIRefreshControl!
    private let currentRole = SharedPreference.shared.getString(key: kRole)
    private var cvListAll: [CVInfo]?
    private var cvListMyself: [CVInfo]?
    private var cvListShow: [CVInfo]? {
        didSet {
            cvTableView.reloadData()
        }
    }
    private var isShowingAll: Bool = true {
        didSet {
            cvListShow = isShowingAll ? cvListAll : cvListMyself
        }
    }
    private var currentSearchText = kEmptyStr {
        didSet {
            if currentSearchText != kEmptyStr {
                cvListShow = isShowingAll ? cvListAll?.filter {
                    $0.position.lowercased().contains(currentSearchText)
                } : cvListMyself?.filter {
                    $0.position.lowercased().contains(currentSearchText)
                }
            } else {
                cvListShow = isShowingAll ? cvListAll : cvListMyself
            }
            cvTableView.reloadData()
        }
    }
    private var recruitersList: [RecruiterInfo] = []
    private var departmentList: [Department] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSegmentControl()
        cvSearchBar.delegate = self
        initFlickToReloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.cvTableView.reloadData()
        }
        greetingsLabel.text = "Hi, \(SharedPreference.shared.getString(key: kKeychainName))"
    }
    
    private func bindModel() {
        viewModel.transform()
        viewModel.output.getAllCVSuccess.addObserver { [weak self] cvList in
            guard let mSelf = self else { return }
            mSelf.refreshControl.endRefreshing()
            mSelf.cvListAll = cvList
            mSelf.viewModel.input.getMyCV.value = Void()
            mSelf.isShowingAll = mSelf.cvSegmentController.selectedSegmentIndex == 1
            mSelf.cvTableView.reloadData()
        }
        viewModel.output.getAllCVFailed.addObserver { [weak self] _ in
            guard let mSelf = self else { return }
            mSelf.refreshControl.endRefreshing()
            let alert = UIAlertController(title: "Error!", message: "Cannot get CV", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel) { _ in
                alert.dismiss(animated: true)
            }
            alert.addAction(action)
            mSelf.present(alert, animated: true)
        }
        viewModel.output.getMyCVSuccess.addObserver { [weak self] in
            guard let mSelf = self else { return }
            let myId = mSelf.sharedPreference.getInt(key: kUserId)
            if mSelf.currentRole == "Recruiter" {
                mSelf.cvListMyself = mSelf.cvListAll?.filter { $0.idRecruiter == myId }
            } else {
                mSelf.cvListMyself = mSelf.cvListAll?.filter { "\($0.idDepartment ?? -1)" == mSelf.sharedPreference.getString(key: kCurrentDept)}
            }
            mSelf.cvTableView.reloadData()
        }
        viewModel.output.requestLogoutSuccess.addObserver { [weak self] in
            guard let mSelf = self else { return }
            UserDefaults.standard.set(nil, forKey: kUserId)
            mSelf.secureDataHelper.saveUserInfo(name: kEmptyStr, email: kEmptyStr)
            let alert = UIAlertController(title: "Success!", message: "Logout success", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel) { _ in
                alert.dismiss(animated: true) {
                    mSelf.performSegue(withIdentifier: "backLogin", sender: mSelf)
                }
            }
            alert.addAction(action)
            mSelf.present(alert, animated: true)
        }
        viewModel.output.requestLogoutFailed.addObserver { [weak self] in
            guard let mSelf = self else { return }
            let alert = UIAlertController(title: "Error!", message: "Cannot logout", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel) { _ in
                alert.dismiss(animated: true)
            }
            alert.addAction(action)
            mSelf.present(alert, animated: true)
        }
        viewModel.output.requestAllRecruitersSuccess.addObserver { [weak self] recruiterList in
            guard let mSelf = self else { return }
            if let recruiterList = recruiterList {
                mSelf.recruitersList = recruiterList
            }
        }
        viewModel.output.requestAllDeptsSuccess.addObserver { [weak self] departmentList in
            guard let mSelf = self else { return }
            if let departmentList = departmentList {
                mSelf.departmentList = departmentList
            }
        }
        viewModel.input.getAllCV.value = Void()
        viewModel.input.requestAllRecruiters.value = Void()
        viewModel.input.requestAllDepts.value = Void()
    }
    
    private func setupTableView() {
        let cvTableViewCellNib = UINib(nibName: "CVTableViewCell", bundle: nil)
        cvTableView.register(cvTableViewCellNib, forCellReuseIdentifier: "cvTableViewCell")
        cvTableView.delegate = self
        cvTableView.dataSource = self
        cvTableView.reloadData()
    }
    
    private func initFlickToReloadData() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        cvTableView.addSubview(refreshControl)
    }
    
    @objc func refresh() {
        viewModel.input.getAllCV.value = Void()
        viewModel.input.getMyCV.value = Void()
    }
    
    private func setupSegmentControl() {
        isShowingAll = cvSegmentController.selectedSegmentIndex == 1
    }
    
    @IBAction func onChangeSheetViewType(_ sender: UISegmentedControl) {
        isShowingAll = cvSegmentController.selectedSegmentIndex == 1
        let currentText = currentSearchText
        currentSearchText = currentText
    }
    
    @IBAction private func onLogout(_ sender: UIButton) {
        let id = sharedPreference.getInt(key: kUserId)
        viewModel.input.requestLogout.value = "\(id)"
    }
    
    @IBAction private func onSelectRecruitmentPlan(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "homeJDViewController") as? HomeJDViewController {
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: false)
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines) != kEmptyStr {
            currentSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        } else {
            if currentSearchText.trimmingCharacters(in: .whitespacesAndNewlines) != kEmptyStr {
                currentSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cvListShow?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cvTableViewCell") as? CVTableViewCell else {
            return UITableViewCell()
        }
        guard let cvInfo = cvListShow?[indexPath.row] else {
            return UITableViewCell()
        }
        cell.setupData(info: cvInfo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailStoryboard = UIStoryboard(name: "Detail", bundle: nil)
        let detailViewController = detailStoryboard.instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController
        if let detailViewController = detailViewController {
            detailViewController.recruiterList = self.recruitersList
            detailViewController.departmentList = self.departmentList
            detailViewController.idCV = cvListShow?[indexPath.row].id ?? -1
            detailViewController.modalPresentationStyle = .fullScreen
            self.present(detailViewController, animated: true)
        }
    }
}
