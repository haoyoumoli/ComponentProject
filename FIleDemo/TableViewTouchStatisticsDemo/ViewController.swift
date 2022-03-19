//
//  ViewController.swift
//  TableViewTouchStatisticsDemo
//
//  Created by apple on 2021/10/29.
//

import UIKit

/**
 demo 目的:
 测试运用 oc runtime api 统计tableview点击次数
 */
class ViewController: UIViewController {

    let tableView1 = UITableView()
    let tableView2 = UITableView()
    
    override func viewDidLoad() {
       super.viewDidLoad()
       _ = UITableView.installTouchesMethodHook()
       setupTableView(tableView: tableView1)
       setupTableView(tableView: tableView2)
        
//        let v = HookTestSubA.installHookMethods()
//        debugPrint("hook result:\(v)")
//        HookTestSubA().methodA()
      
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView1.frame = CGRect(x: 0, y: 0, width: view.bounds.width * 0.5, height: view.bounds.height)
        tableView2.frame = CGRect(x: 0.5 * view.bounds.width, y: 0, width: 0.5 * view.bounds.width, height: view.bounds.height)
    }
    
    func setupTableView(tableView:UITableView) {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "system.cell")
        view.addSubview(tableView)
    }
}

//MARK: - UITableViewDataSource
extension ViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "system.cell")!
        
        if tableView === tableView1  {
            cell.textLabel?.text = "table view 1: \(indexPath.row)"
        } else {
            cell.textLabel?.text = "table view 2: \(indexPath.row)"
        }
        
        return cell
    }
    
}

//MARK: - UITableViewDelegate
extension ViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableView1 {
            debugPrint("table view 1 did selected at \(indexPath.row)")
        } else if tableView == tableView2 {
            debugPrint("table view 2 did selected at \(indexPath.row)")
        }
    }
}

