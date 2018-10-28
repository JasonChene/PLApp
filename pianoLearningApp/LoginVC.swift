//
//  LoginVC.swift
//  pianoLearningApp
//
//  Created by 黃恩祐 on 2018/10/1.
//  Copyright © 2018年 ENYUHUANG. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var textFieldBackground: UIView!
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var forgetPwdBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    var loadingView: LoadingView!
    var pwdAlertView: PwdAlertView!
    var alertView: AlertView!
    var AutoLoginTime : Timer?
    
    let btnAttributes : [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 20),
        NSAttributedStringKey.foregroundColor : UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1),
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        accountField.text = "test2"
//        passwordField.text = "test1"
        
        initView()
    }


    @IBAction func tapLogin(_ sender: Any) {
        if let acc = accountField.text, let pwd = passwordField.text {
            if acc == "" || pwd == "" {
                self.textFieldBackground.backgroundColor = UIColor.red
                textFieldBackground.layer.borderColor = UIColor.red.cgColor
            }
            APIManager.shared.login(account: acc, password: pwd) { [weak self] (status, data) in
                if status {
                    // 成功登入
                    UserDefaults.standard.set(acc, forKey: PIANO_ACCOUNT)
                    UserDefaults.standard.set(pwd, forKey: PIANO_PASSWORD)
                    UserDefaults.standard.synchronize()
                    if let mainVC = self?.storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as? TabBarVC {
                        self?.present(mainVC, animated: true, completion: nil)
                    }
                }else {
                    print("acc || pwd is error")
                    self?.textFieldBackground.backgroundColor = UIColor.red
                    self?.textFieldBackground.layer.borderColor = UIColor.red.cgColor
                }
            }
        }else {
            self.textFieldBackground.backgroundColor = UIColor.red
            textFieldBackground.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    @IBAction func tapForgetBtn(_ sender: Any) {
        pwdAlertView = Bundle.main.loadNibNamed("PwdAlertView", owner: self, options: nil)?.first as? PwdAlertView
        pwdAlertView.frame = self.view.frame
        pwdAlertView.delegate = self
        pwdAlertView.initAlert()
        self.view.addSubview(pwdAlertView)
    }
    
    @IBAction func tapRegisterBtn(_ sender: Any) {
        
    }
    
    func showLoadingView() {
        loadingView = Bundle.main.loadNibNamed("loadingView", owner: self, options: nil)?.first as? LoadingView
        loadingView.frame = self.view.frame
        self.view.addSubview(loadingView)
        if AutoLoginTime == nil {
            AutoLoginTime =  Timer.scheduledTimer(timeInterval: TimeInterval(3), target: self, selector: #selector(removeLoadingView), userInfo: nil, repeats: true)
        }
    }
    
    func initView() {
        accountField.setLeftPaddingPoints(15)
        passwordField.setLeftPaddingPoints(15)
        textFieldBackground.layer.borderColor = UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1).cgColor
        textFieldBackground.layer.borderWidth = 1
        textFieldBackground.layer.cornerRadius = 5
        textFieldBackground.layer.masksToBounds = true
        textFieldBackground.clipsToBounds = true
        loginBtn.layer.cornerRadius = 5
        loginBtn.layer.masksToBounds = true
        loginBtn.clipsToBounds = true
        registerBtn.layer.cornerRadius = 5
        registerBtn.layer.masksToBounds = true
        registerBtn.clipsToBounds = true
        let attributeString = NSMutableAttributedString(string: "忘记密码了吗？",
                                                        attributes: btnAttributes)
        forgetPwdBtn.setAttributedTitle(attributeString, for: .normal)
    }
    
    func showAlertView(message: String) {
        alertView = Bundle.main.loadNibNamed("AlertView", owner: self, options: nil)?.first as? AlertView
        alertView.frame = self.view.frame
        alertView.delegate = self
        alertView.initAlert(message: message)
        self.view.addSubview(alertView)
    }
    
    @objc func removeLoadingView() {
        if self.loadingView != nil {
            self.loadingView.removeFromSuperview()
            self.loadingView = nil
        }
        if AutoLoginTime != nil {
            AutoLoginTime?.invalidate()
            AutoLoginTime = nil
        }
    }
}

extension LoginVC: pwdAlertViewDelegate {
    
    func didTapCancelButton() {
        if self.pwdAlertView != nil {
            self.pwdAlertView.removeFromSuperview()
        }
    }
    
    func didTapSendButton() {
        if let account = self.pwdAlertView.textField.text, account != "" {
            APIManager.shared.forgetPwd(account: account) { (isSucceed) in
                if isSucceed {
                    self.showAlertView(message: "已将新密码寄送至您的\n邮箱地址，请前往查看，\n谢谢!!!")
                    self.didTapCancelButton()
                }else {
                    self.showAlertView(message: "资料错误，请填写正确资料")
                }
            }
        }
    }
}

extension LoginVC: alertViewDelegate {
    func didTapButton() {
        if self.alertView != nil {
            self.alertView.removeFromSuperview()
        }
    }
    
    
}


extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
