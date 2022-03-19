//
//  FileBrower.swift
//  CombineDemo
//
//  Created by apple on 2021/7/2.
//

import Foundation
import UIKit

class FileBrowerViewController:UIViewController  {
    
    let tableView = UITableView(frame: .zero)
    let tableViewPresenter = FileBrowerPreseter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView
            .leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView
            .rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView
            .topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView
            .bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tableView.delegate = tableViewPresenter
        tableView.dataSource = tableViewPresenter
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseid")
        
        tableViewPresenter.tableView = tableView
        tableViewPresenter.load()
        
        
    }
}


