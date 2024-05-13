//
//  LoginServices.swift
//  OnTheMap
//
//  Created by admin on 8/5/24.
//

import UIKit

struct LoginResponse: Codable {
    let account: Auth
    let session: Session
}

struct UserProfile: Codable {
    let firstName: String
    let lastName: String
    let nickname: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case nickname
    }
 
}

struct Auth: Codable {
    let registered: Bool
    let key: String
}

struct Session: Codable {
    let id: String
    let expiration: String
}

struct User {
    var sessionId: String?
    var key: String?
    var firstName: String?
    var lastName: String?
    var objectId: String?
}

class UserServices: NSObject {
    static let shared = UserServices()
    var currentUser = User()
    
    func login(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let url = URL(string: Endpoints.login.stringValue) else {
            return
        }
        let body = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
        Services.shared.taskForPOSTRequest(url: url, apiType: .udacity, responseType: LoginResponse.self, body: body, httpMethod: .post) { [weak self] response, error in
            if let response = response {
                self?.currentUser.sessionId = response.session.id
                self?.currentUser.key = response.account.key
                self?.getUserProfile(completion: { success, error in
                    if success {
                        completion(true, nil)
                    } else {
                        completion(false, error)
                    }
                })
            } else {
                completion(false, nil)
            }
        }
    }
    
    func getUserProfile(completion: @escaping (Bool, Error?) -> Void) {
        guard let key = currentUser.key,
              let url = URL(string: Endpoints.getUserProfile.stringValue + key) else {
            return
        }
        Services.shared.taskForGETRequest(url: url, apiType: .udacity, responseType: UserProfile.self) { [weak self] response, error in
            if let response = response {
                self?.currentUser.firstName = response.firstName
                self?.currentUser.lastName = response.lastName
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    func logout(completion: @escaping (Error?) -> Void) {
        guard let url = URL(string: Endpoints.login.stringValue) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = Method.delete.rawValue
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request) {[weak self] _, _, error in
            guard let error = error else {
                self?.currentUser = User()
                StudentsData.sharedInstance().students = []
                completion(nil)
                return
            }
            
            completion(error)
        }
        task.resume()
    }
}
