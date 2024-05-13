//
//  LocationServices.swift
//  OnTheMap
//
//  Created by admin on 8/5/24.
//

import UIKit

enum Endpoints {
    static let base = "https://onthemap-api.udacity.com/v1"
    
    case signUp
    case login
    case getStudentLocations
    case addLocation
    case updateLocation
    case getUserProfile
    
    var stringValue: String {
        switch self {
        case .signUp:
            return "https://auth.udacity.com/sign-up"
        case .login:
            return Endpoints.base + "/session"
        case .getStudentLocations:
            return Endpoints.base + "/StudentLocation?limit=100&order=-updatedAt"
        case .addLocation:
            return Endpoints.base + "/StudentLocation"
        case .updateLocation:
            return Endpoints.base + "/StudentLocation/"
        case .getUserProfile:
            return Endpoints.base + "/users/"
            
        }
    }
}

class LocationServices: NSObject {
    static let shared = LocationServices()
    
    func getStudentLocations(completion: @escaping ([StudentInformation]?, Error?) -> Void) {
        guard let url = URL(string: Endpoints.getStudentLocations.stringValue) else {
            return
        }
        Services.shared.taskForGETRequest(url: url, apiType: .none, responseType: StudentsLocations.self) { (response, error) in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func addStudentLocation(information: StudentInformation, completion: @escaping (Bool, Error?) -> Void) {
        guard let url = URL(string: Endpoints.addLocation.stringValue) else {
            return
        }
        let body = "{\"uniqueKey\": \"\(information.uniqueKey ?? "")\", \"firstName\": \"\(information.firstName)\", \"lastName\": \"\(information.lastName)\",\"mapString\": \"\(information.mapString ?? "")\", \"mediaURL\": \"\(information.mediaURL ?? "")\",\"latitude\": \(information.latitude ?? 0.0), \"longitude\": \(information.longitude ?? 0.0)}"
        Services.shared.taskForPOSTRequest(url: url, apiType: .none, responseType: PostLocationResponse.self, body: body, httpMethod: .post) { (response, error) in
            guard let response = response, error == nil else {
                completion(false, error)
                return
            }
            UserServices.shared.currentUser.objectId = response.objectId
            completion(true, nil)
        }
    }
    
    // MARK: Update Location
 
    func updateStudentLocation(information: StudentInformation, completion: @escaping (Bool, Error?) -> Void) {
        guard let objectId = UserServices.shared.currentUser.objectId,
              let url = URL(string: Endpoints.updateLocation.stringValue + objectId) else {
            return
        }
        let body = "{\"uniqueKey\": \"\(information.uniqueKey ?? "")\", \"firstName\": \"\(information.firstName)\", \"lastName\": \"\(information.lastName)\",\"mapString\": \"\(information.mapString ?? "")\", \"mediaURL\": \"\(information.mediaURL ?? "")\",\"latitude\": \(information.latitude ?? 0.0), \"longitude\": \(information.longitude ?? 0.0)}"
        Services.shared.taskForPOSTRequest(url: url, apiType: .none, responseType: UpdateLocationResponse.self, body: body, httpMethod: .put) { (response, error) in
            guard error == nil else {
                completion(false, error)
                return
            }
            
            completion(true, nil)
        }
    }
}

struct PostLocationResponse: Codable {
    let createdAt: String?
    let objectId: String?
}

struct UpdateLocationResponse: Codable {
    let updatedAt: String?
}
