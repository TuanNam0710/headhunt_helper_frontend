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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindModel()
        setupTableView()
    }
    
    private func bindModel() {
        
    }
    
    private func setupTableView() {
        
    }
}
