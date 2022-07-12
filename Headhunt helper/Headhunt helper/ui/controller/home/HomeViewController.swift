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
    private let viewModel = HomeViewModel()
    private let secureDataHelper = SecureDataHelper.shared
    private let sharedPreference = SharedPreference.shared
    var userEmail = kEmptyStr
    var refreshControl: UIRefreshControl!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindModel()
        setupTableView()
        setupSegmentControl()
        cvSearchBar.delegate = self
        initFlickToReloadData()
        isShowingAll = cvSegmentController.selectedSegmentIndex == 1
    }
    
    private func bindModel() {
        viewModel.transform()
        viewModel.output.getUserInfoSuccess.addObserver { [weak self] recruiterInfo in
            guard let mSelf = self else { return }
            if let userId = recruiterInfo?.id, let name = recruiterInfo?.name, let email = recruiterInfo?.email {
                mSelf.secureDataHelper.saveUserInfo(name: name, email: email)
                mSelf.sharedPreference.putInt(key: kUserId, value: userId)
            }
        }
        viewModel.output.getUserInfoFailed.addObserver { [weak self] _ in
            guard let mSelf = self else { return }
            let alert = UIAlertController(title: "Error!", message: "Cannot get recruiter info", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel) { _ in
                alert.dismiss(animated: true)
            }
            alert.addAction(action)
            mSelf.present(alert, animated: true)
        }
        viewModel.output.getAllCVSuccess.addObserver { [weak self] cvList in
            guard let mSelf = self else { return }
            mSelf.refreshControl.endRefreshing()
            mSelf.cvListAll = cvList
            mSelf.viewModel.input.getMyCV.value = Void()
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
            mSelf.cvListMyself = mSelf.cvListAll?.filter { $0.idRecruiter == myId }
            mSelf.cvTableView.reloadData()
        }
        viewModel.input.getUserInfo.value = userEmail
        viewModel.input.getAllCV.value = Void()
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
}
