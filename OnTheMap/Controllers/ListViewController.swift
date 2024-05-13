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
    
    var informations = [StudentInformation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getInformations()
    }
    
    func getInformations() {
        activityIndicator.startAnimating()
        LocationServices.shared.getStudentLocations() {[weak self] informations, error in
            self?.informations = informations ?? []
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    @IBAction func didTapPinLocation(_ sender: Any) {
        redirectToFindLocation(sender: sender)
    }
    
    @IBAction func didTapRefresh(_ sender: Any) {
        getInformations()
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return informations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "studentTableViewCell", for: indexPath) as? StudentInformationCell else {
            return UITableViewCell()
        }
        
        let information = informations[indexPath.row]
        cell.lblTitle.text = "\(information.firstName)" + " " + "\(information.lastName)"
        cell.lblDetail?.text = "\(information.mediaURL ?? "")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let information = informations[indexPath.row]
        guard let mediaURL = information.mediaURL else {
            showAlert(message: "Cannot open link.", title: "Invalid Link")
            return
        }
        openUrl(mediaURL)
    }
}
