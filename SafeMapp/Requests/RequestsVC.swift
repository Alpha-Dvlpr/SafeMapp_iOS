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
    let refreshControl = UIRefreshControl()
    
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
        
        refreshControl.tintColor = AppColors.greenColor
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("updatingRequests", comment: ""), attributes: [:])
        
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        table.addSubview(refreshControl)
        
        table.register(RequestCell.self, forCellReuseIdentifier: "requestCell")
        
        refreshControl.addTarget(self, action: #selector(swipeRefresh(_:)), for: .valueChanged)
    }
    
    @objc private func swipeRefresh(_ sender: Any) {
        self.viewModel.getLastRequests()
        self.table.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    private func setupConstraints() {
        table.translatesAutoresizingMaskIntoConstraints = false
        
        table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        table.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        table.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
    }
    
    private func acceptRequest(row: Int) {
        print("RVC | accepting request \(row)") //TODO: Setup callbacks
    }
    
    private func ignoreRequest(row: Int) {
        print("RVC | ignoring request. deleting... \(row)") //TODO: Setup callbacks
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
        return RequestCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath) as! RequestCell
        cell.setupData(request: self.viewModel.requests[indexPath.row])
        cell.callback = { (action) in
            if action { self.acceptRequest(row: indexPath.row) }
            else { self.ignoreRequest(row: indexPath.row) }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
