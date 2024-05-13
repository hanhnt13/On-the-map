//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by admin on 8/5/24.
//

import UIKit

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    let userService = UserServices.shared
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        txtEmail.text = nil
        txtPassword.text = nil
    }

    @IBAction func didTapLogin(_ sender: Any) {
        guard let email = txtEmail.text, !email.isEmpty else {
            showAlert(message: "Please input email!", title: nil)
            return
        }
        
        guard let passWord = txtPassword.text, !passWord.isEmpty else {
            showAlert(message: "Please input password!", title: nil)
            return
        }
        
        userService.login(email: email, password: passWord) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.performSegue(withIdentifier: "showMap", sender: nil)
                } else {
                    self?.showAlert(message: error?.localizedDescription ?? "Unknown error", title: "Login Error")
                }
            }
        }
    }
    
    @IBAction func didTapSignUp(_ sender: Any) {
        guard let url = URL(string: Endpoints.signUp.stringValue) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

}
