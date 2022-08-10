//
//  HomeJDViewController.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 26/07/2022.
//

import UIKit

class HomeJDViewController: UIViewController {
    @IBOutlet private weak var jdTableView: UITableView!
    private let viewModel = HomeViewModel()
    private let currentDept = SharedPreference.shared.getString(key: kCurrentDept)
    private let currentRole = SharedPreference.shared.getString(key: kRole)
    private var jdList = [JobDescription]()
    private var positionList = [Position]()
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.jdTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        jdTableView.reloadData()
        bindModel()
    }
    
    private func bindModel() {
        viewModel.transform()
        viewModel.output.requestAllPositionsSuccess.addObserver { positionList in
            if let positionList = positionList {
                self.positionList = positionList
            }
            self.viewModel.input.requestAllJDs.value = Void()
        }
        viewModel.output.requestAllJDSuccess.addObserver { jdList in
            if let jdList = jdList {
                if self.currentRole == "Manager" {
                    self.jdList = jdList.filter { self.validateJD(idPosition: $0.idPosition!) }
                } else {
                    self.jdList = jdList
                }
                self.jdTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
        viewModel.output.requestDeleteJDSuccess.addObserver { _ in
            self.viewModel.input.requestAllJDs.value = Void()
            self.jdTableView.reloadData()
        }
        viewModel.input.requestAllPositions.value = Void()
    }
    
    private func validateJD(idPosition: Int) -> Bool {
        if currentRole == "Recruiter" {
            return true
        }
        for position in positionList {
            if position.id == idPosition {
                return true
            }
        }
        return false
    }
    
    private func setupTableView() {
        let cell = UINib(nibName: "JDTableViewCell", bundle: nil)
        jdTableView.register(cell, forCellReuseIdentifier: "jdTableViewCell")
        jdTableView.delegate = self
        jdTableView.dataSource = self
        jdTableView.reloadData()
        initFlickToReloadData()
    }
    
    private func initFlickToReloadData() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        jdTableView.addSubview(refreshControl)
    }
    
    @objc func refresh() {
        viewModel.input.requestAllPositions.value = Void()
    }
    
    @IBAction private func onCreateJD(_ sender: UIButton) {
        guard SharedPreference.shared.getString(key: kRole) == "Manager" else {
            return
        }
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "newRequestViewController") as? NewRequestViewController {
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
        }
    }
    
    @IBAction private func onSelectCV(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
}

extension HomeJDViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jdList.count
    }
    
    @available(iOS 15.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "jdTableViewCell") as? JDTableViewCell else {
            return UITableViewCell()
        }
        if let positionName = positionList.first(where: { $0.id == jdList[indexPath.row].idPosition})?.name {
            cell.setupViews(position: positionName,
                            noOfJobs: jdList[indexPath.row].noOfJobs,
                            dueDate: Int(jdList[indexPath.row].dueDate)!)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Alert", message: "Do you really want to delete this JD?", preferredStyle: .alert)
            let action = UIAlertAction(title: "Yes", style: .destructive) { _ in
                if let id = self.jdList[indexPath.row].id {
                    self.viewModel.input.requestDeleteJD.value = id
                    tableView.reloadData()
                }
            }
            let action2 = UIAlertAction(title: "No", style: .cancel)
            alert.addAction(action)
            alert.addAction(action2)
            self.present(alert, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "newRequestViewController") as? NewRequestViewController {
            viewController.currentDate = Date(timeIntervalSince1970: TimeInterval(Int(jdList[indexPath.row].dueDate)!))
            viewController.position = positionList.first(where: { $0.id == jdList[indexPath.row].idPosition})!.name
            viewController.noOfJobs = "\(jdList[indexPath.row].noOfJobs)"
            viewController.jobDescription = jdList[indexPath.row].jobDescription
            viewController.positionList = positionList
            viewController.id = jdList[indexPath.row].id
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
        }
    }
}
