//
//  LoginViewController.swift
//  CombineDemo
//
//  Created by apple on 2021/6/11.
//

import Foundation
import UIKit
import Combine

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTxf: UITextField!
    @IBOutlet weak var passwordTxf: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var activityV: UIActivityIndicatorView!
    @IBOutlet weak var tipLbl: UILabel!
    @IBOutlet weak var userNameValidLbl: UILabel!
    
    private(set) var viewModel:LoginViewModel? = nil
    private(set) var cancelables = Set<AnyCancellable>()
    
    private var loginBtnTouched = PassthroughSubject<Void,Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    deinit {
        debugPrint("LoginViewController deinit")
    }
}


//MARK: - UI
extension LoginViewController {
    func setupUI() {
        loginBtn.isEnabled = false
        tipLbl.isHidden = true
        activityV.isHidden = true
        userNameValidLbl.isHidden = true
    }
    
    ///设置正在登陆时状态的UI
    func configIsDoingLogin(isDoing:Bool) {
        tipLbl.isHidden = isDoing
        activityV.isHidden = !isDoing
        loginBtn.isEnabled = !isDoing
        loginBtn.setTitle(isDoing ? "logining ..." : "login", for: .normal)
        if isDoing {
            activityV.startAnimating()
        }
    }
    
    ///设置登陆调用登录接口后状态的UI
    func configIsLogingSuccess(isSuccess:Bool) {
        if isSuccess {
            tipLbl.textColor = .green
            tipLbl.text = "success"
        } else {
            tipLbl.textColor = .red
            tipLbl.text = "fail"
        }
    }
    
    ///设置用户名有效性验证ui
    func configUserName(isValid:Bool) {
        userNameValidLbl.isHidden = isValid
        if !isValid {
            userNameValidLbl.text = "用户名不合法,或已经存在"
            userNameValidLbl.textColor = .red
        }
    }
    
    func configIsValidingUserName(isValiding:Bool) {
        if isValiding {
            userNameValidLbl.isHidden = false
            userNameValidLbl.text = "用户名验证中..."
            userNameValidLbl.textColor = UIColor.blue
        }
    }
}

//MARK: - Action
extension LoginViewController {
    func setupActions() {
        
        let userNameInput = usernameTxf.textDidChange
        
        let pwdInput = passwordTxf.textDidChange
        
        let touchLoginInput = loginBtn
            .publisher(for: .touchUpInside)
            .map({ _ in return ()})
            .share()
            .eraseToAnyPublisher()
        
        touchLoginInput.sink { [weak self] _ in
            self?.usernameTxf.resignFirstResponder()
            self?.passwordTxf.resignFirstResponder()
        }
        .store(in: &cancelables)
        
        self.viewModel = LoginViewModel.init(username: userNameInput,
                                             password: pwdInput,
                                             loginAction: touchLoginInput)
        
        self.viewModel!.loginIsEnabled
            .receive(on: RunLoop.main)
            .sink(receiveValue: {
                [weak self] isEnable in
                self?.loginBtn.isEnabled = isEnable
            })
            .store(in: &cancelables)
        
        self.viewModel!.isLogining
            .receive(on: RunLoop.main)
            .sink(receiveValue: {
                [weak self] isloginging in
                self?.configIsDoingLogin(isDoing: isloginging)
            })
            .store(in: &cancelables)
        
        self.viewModel!.callLogin
            .receive(on: RunLoop.main)
            .sink(receiveValue: {
                [weak self] loginSuccess in
                self?.configIsLogingSuccess(isSuccess: loginSuccess)
            })
            .store(in: &cancelables)
        
        self.viewModel!.userNameIsValid
            .receive(on: RunLoop.main)
            .sink(receiveValue: {
                [weak self] isValid in
                self?.configUserName(isValid: isValid)
            })
            .store(in: &cancelables)
        
        self.viewModel!.validingUserName
            .receive(on: RunLoop.main)
            .sink(receiveValue: {
                [weak self] isValiding in
                self?.configIsValidingUserName(isValiding: isValiding)
            })
            .store(in: &cancelables)
       
    }
    
}
