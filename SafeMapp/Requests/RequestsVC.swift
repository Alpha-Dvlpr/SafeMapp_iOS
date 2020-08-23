//
//  RequestsVC.swift
//  SafeMapp
//
//  Created by Aarón on 13/8/20.
//  Copyright © 2020 Aarón. All rights reserved.
//

import UIKit

class RequestsVC: UIViewController {

    var table = UITableView()
    
    var viewModel: MainVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .white
        
        self.addNotificationObservers()
        self.addViews()
        self.setupConstraints()
    }
    
    func setupVM(viewModel: MainVM) {
        self.viewModel = viewModel
    }
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(requestsUpdatedEvent), name: NSNotification.Name(Notifications.requestsUpdated), object: nil)
    }
    
    @objc private func requestsUpdatedEvent() {
        self.table.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addViews() {
        view.addSubview(table)
        
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
    }
    
    private func setupConstraints() {
        table.translatesAutoresizingMaskIntoConstraints = false
        
        table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        table.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        table.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
    }
}

extension RequestsVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.requestsFetched ? self.viewModel.requests.count : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let request = self.viewModel.requests[indexPath.row]
        
        cell.textLabel?.text = request.userName
        cell.detailTextLabel?.text = request.email
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
