//
//  ViewController.swift
//  Facebook
//
//  Created by Rita Zerrizuela on 02/03/2020.
//  Copyright © 2020 Auth0. All rights reserved.
//

import UIKit
import Combine
import Auth0
import FBSDKLoginKit
import FacebookLogin

class ViewController: UIViewController {

    private let fbAPIURL = "https://graph.facebook.com/v6.0"

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLoginButton()
    }

    private func setupLoginButton() {
        let loginButton = FBLoginButton(permissions: [.publicProfile, .email])
        loginButton.center = view.center
        loginButton.delegate = self

        view.addSubview(loginButton)
    }

}

extension ViewController {

    private func fetch(url: URL) -> AnyPublisher<[String: Any], URLError> {
        URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated)) // Execute the request on a background thread
            .receive(on: DispatchQueue.main) // Execute the sink callbacks on the main thread
            .compactMap { try? JSONSerialization.jsonObject(with: $0.data) as? [String: Any] } // Get a JSON dictionary
            .eraseToAnyPublisher()
    }

    private func fetchSessionAccessToken(appId: String, accessToken: String) -> AnyPublisher<String, URLError> {
        var components = URLComponents(string: "\(fbAPIURL)/oauth/access_token")!
        components.queryItems = [URLQueryItem(name: "grant_type", value: "fb_attenuate_token"),
                                 URLQueryItem(name: "fb_exchange_token", value: accessToken),
                                 URLQueryItem(name: "client_id", value: appId)]

        return fetch(url: components.url!)
            .compactMap { $0["access_token"] as? String } // Get the Session Access Token
            .eraseToAnyPublisher()
    }

    private func fetchProfile(userId: String, accessToken: String) -> AnyPublisher<[String: Any], URLError> {
        var components = URLComponents(string: "\(fbAPIURL)/\(userId)")!
        components.queryItems = [URLQueryItem(name: "access_token", value: accessToken),
                                 URLQueryItem(name: "fields", value: "first_name,last_name,email")]

        return fetch(url: components.url!)
    }

    fileprivate func login(with accessToken: FacebookLogin.AccessToken) {
        // Get the request publishers
        let sessionAccessTokenPublisher = fetchSessionAccessToken(appId: accessToken.appID,
                                                                  accessToken: accessToken.tokenString)
        let profilePublisher = fetchProfile(userId: accessToken.userID, accessToken: accessToken.tokenString)

        // Start both requests in parallel and wait until all finish
        _ = Publishers
            .Zip(sessionAccessTokenPublisher, profilePublisher)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            }, receiveValue: { sessionAccessToken, profile in
                // Perform the token exchange
                Auth0
                    .authentication()
                    .login(facebookSessionAccessToken: sessionAccessToken, profile: profile)
                    .start { result in
                        switch result {
                        case .success(let credentials):
                            print(credentials) // Auth0 user credentials
                            DispatchQueue.main.async {
                                UIAlertController.show(message: "Logged in as \(profile["first_name"]!) \(profile["last_name"]!)")
                            }
                        case .failure(let error): print(error)
                    }
                }
            })
    }

}

extension ViewController: LoginButtonDelegate {

    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard error == nil, let accessToken = result?.token else {
            return print(error ?? "Facebook access token is nil")
        }

        login(with: accessToken)
    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Logged out")
    }

}

extension UIAlertController {
    static func show(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
}
