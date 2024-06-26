//
//  MapViewController.swift
//  OnTheMap
//
//  Created by admin on 8/5/24.
//

import UIKit
import MapKit

class MapViewController: BaseViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let service = LocationServices.shared
    let studenData = StudentsData.sharedInstance()
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getStudentsPins()
    }

    func getStudentsPins() {
        activityIndicator.startAnimating()
        LocationServices.shared.getStudentLocations() { [weak self] locations, error in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                guard let locations = locations else {
                    self?.showAlert(message: error?.localizedDescription ?? "Can't get location", title: "Get Location Fail")
                    return
                }
                self?.mapView.removeAnnotations(self?.annotations ?? [])
                self?.annotations.removeAll()
                self?.studenData.students = locations
                for dictionary in locations {
                    let lat = CLLocationDegrees(dictionary.latitude ?? 0.0)
                    let long = CLLocationDegrees(dictionary.longitude ?? 0.0)
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let first = dictionary.firstName
                    let last = dictionary.lastName
                    let mediaURL = dictionary.mediaURL
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                    self?.annotations.append(annotation)
                }
                self?.mapView.addAnnotations(self?.annotations ?? [])
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

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        guard let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView else {
            let pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView.canShowCallout = true
            pinView.tintColor = .red
            pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return pinView
        }
        pinView.annotation = annotation
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard control == view.rightCalloutAccessoryView, let subtitle = view.annotation?.subtitle else {
            return
        }
        
        openUrl(subtitle ?? "")
    }
}
