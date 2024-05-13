//
//  ListViewController.swift
//  OnTheMap
//
//  Created by admin on 8/5/24.
//

import UIKit

class ListViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let studenData = StudentsData.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getInformations()
    }
    
    func getInformations() {
        activityIndicator.startAnimating()
        LocationServices.shared.getStudentLocations() {[weak self] locations, error in
            DispatchQueue.main.async {
                guard let locations = locations else {
                    self?.activityIndicator.stopAnimating()
                    self?.showAlert(message: error?.localizedDescription ?? "Can't get location", title: "Get Location Fail")
                    return
                }
                self?.studenData.students = locations
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    @IBAction func didTapPinLocation(_ sender: Any) {
        redirectToFindLocation(sender: sender)
    }
    
    @IBAction func didTapLogout(_ sender: Any) {
        logout()
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studenData.students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "studentTableViewCell", for: indexPath) as? StudentInformationCell else {
            return UITableViewCell()
        }
        
        let information = studenData.students[indexPath.row]
        cell.lblTitle.text = "\(information.firstName)" + " " + "\(information.lastName)"
        cell.lblDetail?.text = "\(information.mediaURL ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let information = studenData.students[indexPath.row]
        guard let mediaURL = information.mediaURL else {
            showAlert(message: "Cannot open link.", title: "Invalid Link")
            return
        }
        openUrl(mediaURL)
    }
}
