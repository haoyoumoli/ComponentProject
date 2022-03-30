//
//  ActionsViewController.swift
//  Live
//
//  Created by apple on 2022/3/28.
//

import UIKit


protocol ActionsViewControllerDelegate:NSObject {
    
    func actionsViewController(_ actionsViewController:ActionsViewController, didSelectedAction action:ActionsViewController.Action)
}

class ActionsViewController: UITableViewController {
    
    private(set) var actions = [Action]()
    
    weak var delegate:ActionsViewControllerDelegate? = nil
    
    var dimissWhenSelectActio = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        actions = [
            .switchCameraPosition,
            .bilateralFilter
        ]
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellid")
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid")!
        cell.textLabel?.text = actions[indexPath.row].displayName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.actionsViewController(self, didSelectedAction: actions[indexPath.row])
        if dimissWhenSelectActio {
            self.dismiss()
        }
    }
    
}

private extension ActionsViewController {
    
    func dismiss() {
        if self.presentationController != nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension ActionsViewController {
    enum Action {
        case switchCameraPosition
        case bilateralFilter
        
        
        var displayName:String {
            switch self {
            case .switchCameraPosition:
                return "切换摄像头"
                
            case .bilateralFilter:
                return "磨皮滤镜"
            }
        }
    }
}
