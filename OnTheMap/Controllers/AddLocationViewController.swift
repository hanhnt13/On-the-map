//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by admin on 9/5/24.
//

import UIKit
import MapKit

class AddLocationViewController: BaseViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var information: StudentInformation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Location"
        let studentLocation = Location(
            objectId: information.objectId ?? "",
            uniqueKey: information.uniqueKey,
            firstName: information.firstName,
            lastName: information.lastName,
            mapString: information.mapString,
            mediaURL: information.mediaURL,
            latitude: information.latitude,
            longitude: information.longitude,
            createdAt: information.createdAt ?? "",
            updatedAt: information.updatedAt ?? ""
        )
        showLocation(location: studentLocation)
    }
    
    
    @IBAction func didTapFinish(_ sender: Any) {
        guard let objectId = UserServices.shared.currentUser.objectId, !objectId.isEmpty else {
            addLocation()
            return
        }
        
        updateLocation()
    }
    
    func showLocation(location: Location) {
        mapView.removeAnnotations(mapView.annotations)
        guard let latitude = location.latitude, let longitude = location.longitude else {
            return
        }
        
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let annotation = MKPointAnnotation()
        annotation.title = location.locationDescription
        annotation.subtitle = location.mediaURL ?? ""
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func updateLocation() {
        let alertVC = UIAlertController(title: nil, message: "You have already posted a location. Would you like to overwrite your current Location?", preferredStyle: .alert)
        let overwriteAction = UIAlertAction(title: "Overwrite", style: .default, handler: { [weak self] action in
            guard let information = self?.information else {
                return
            }
            self?.activityIndicator.startAnimating()
            LocationServices.shared.updateStudentLocation(information: information) { (success, error) in
                self?.activityIndicator.stopAnimating()
                if success {
                    DispatchQueue.main.async {
                        self?.dismiss(animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showAlert(message: error?.localizedDescription ?? "", title: "Error")
                    }
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction) in
            DispatchQueue.main.async {
                alertVC.dismiss(animated: true, completion: nil)
            }
        })
        alertVC.addAction(overwriteAction)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true)
    }
    
    func addLocation() {
        activityIndicator.startAnimating()
        LocationServices.shared.addStudentLocation(information: information) { [weak self] success, error in
            self?.activityIndicator.stopAnimating()
            if success {
                DispatchQueue.main.async {
                    self?.dismiss(animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self?.showAlert(message: error?.localizedDescription ?? "", title: "Error")
                }
            }
        }
    }
}
