//
//  BaseViewController.swift
//  OnTheMap
//
//  Created by admin on 9/5/24.
//

import UIKit

class BaseViewController: UIViewController {
    
    func showAlert(message: String, title: String?) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true)
    }
    
    func openUrl(_ url: String) {
        guard let url = URL(string: url), UIApplication.shared.canOpenURL(url) else {
            showAlert(message: "Cannot open the URL.", title: "Invalid URL")
            return
        }
        UIApplication.shared.open(url, options: [:])
    }
    
    func redirectToFindLocation(sender: Any?) {
        performSegue(withIdentifier: "findLocation", sender: nil)
    }
}
