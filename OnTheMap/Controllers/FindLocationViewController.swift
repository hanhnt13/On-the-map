//
//  FindLocationViewController.swift
//  OnTheMap
//
//  Created by admin on 9/5/24.
//

import UIKit
import MapKit

class FindLocationViewController: BaseViewController {
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var txtWebsite: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var objectId: String?
    var coordinate: CLLocationCoordinate2D?
    var information: StudentInformation {
        var studentInfo: [String:AnyObject] = [ 
            "uniqueKey": UserServices.shared.currentUser.key as AnyObject,
            "firstName":  UserServices.shared.currentUser.firstName as AnyObject,
            "lastName":  UserServices.shared.currentUser.lastName as AnyObject,
            "mapString": txtLocation.text as AnyObject,
            "mediaURL": txtWebsite.text as AnyObject,
            "latitude": coordinate?.latitude as AnyObject,
            "longitude": coordinate?.longitude as AnyObject
        ]
        
        if let objectId = objectId {
            studentInfo["objectId"] = objectId as AnyObject
        }

        return StudentInformation(studentInfo)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Location"
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func didTapFindLocation(_ sender: Any) {
        guard let url = URL(string: txtWebsite.text ?? ""), UIApplication.shared.canOpenURL(url) else {
            self.showAlert(message: "Please enter a valid url. Must be include 'http://' or 'https://' in your link.", title: "Invalid URL")
            return
        }

        findGeocodePosition(newLocation: txtLocation.text ?? "")
    }
    
    private func findGeocodePosition(newLocation: String) {
        activityIndicator.startAnimating()
        CLGeocoder().geocodeAddressString(newLocation) { [weak self] marker, error in
            self?.activityIndicator.stopAnimating()
            if let error = error {
                self?.showAlert(message: error.localizedDescription, title: "Location Not Found")
            } else if let location = marker?.first?.location {
                self?.coordinate = location.coordinate
                self?.loadLocation()
            } else {
                self?.showAlert(message: "Please try again later.", title: "Error")
            }
        }
    }
    
    private func loadLocation() {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "AddLocationViewController") as? AddLocationViewController else {
            return
        }
        controller.information = information
        navigationController?.pushViewController(controller, animated: true)
    }
}
