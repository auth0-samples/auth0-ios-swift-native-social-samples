//
//  ViewController.swift
//  signinwithapple
//
//  Created by Martin Walsh on 10/07/2019.
//  Copyright © 2019 Martin Walsh. All rights reserved.
//

import UIKit
import AuthenticationServices
import Auth0
import SimpleKeychain

class ViewController: UIViewController {
    
    @IBOutlet weak var loginProviderStackView: UIStackView!
    
    @IBOutlet weak var authenticatedStackView: UIStackView!
    
    let keychain = A0SimpleKeychain()
    let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
    var credentials: Credentials?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authenticatedStackView.isHidden = true
        
        setupProviderLoginView()
        
        renewAuth { credentials, error in
            guard error == nil, credentials != nil else {
                return print("Unable to renew auth: \(String(describing: error))")
            }
            
            self.showAuthUI()
        }
    }
    
    @IBAction func logoutButtonTouch(_ sender: Any) {
        logOut { error in
            guard error == nil else {
                return print("Could not log out: \(error.debugDescription)")
            }
            
            self.showAuthUI()
        }
    }
    
    func setupProviderLoginView() {
        // Create Button
        let authorizationButton = ASAuthorizationAppleIDButton()
        
        // Add Callback on Touch
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        
        //Add button to the UIStackView
        self.loginProviderStackView.addArrangedSubview(authorizationButton)
        
        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        authorizationButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        authorizationButton.widthAnchor.constraint(equalToConstant: 140).isActive = true
    }
    
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        // Create the authorization request
        let request = ASAuthorizationAppleIDProvider().createRequest()
        
        // Set Scopes
        request.requestedScopes = [.email, .fullName]
        
        // Setup a controller to display the authorization flow
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        // Set delegate to handle the flow response.
        controller.delegate = self
        controller.presentationContextProvider = self
        
        // Action
        controller.performRequests()
    }
    
    // MARK: private
    
    private func renewAuth(_ callback: @escaping (Credentials?, Error?) -> ()) {
        let provider = ASAuthorizationAppleIDProvider()
            
        guard let userID = keychain.string(forKey: "userId") else {
            callback(nil, nil)
            return
        }
    
        provider.getCredentialState(forUserID: userID) { state, error in
            switch state {
            case .authorized:
                self.credentialsManager.credentials { error, credentials in
                    guard error == nil, let credentials = credentials else {
                        return callback(nil, error)
                    }

                    self.credentials = credentials
                    
                    callback(credentials, error)
                }
                
            default:
                self.keychain.deleteEntry(forKey: "userId")
                
                self.credentialsManager.revoke { _ in
                    callback(nil, error)
                }
            }
        }
    }
    
    private func showAuthUI() {
        DispatchQueue.main.async {
            guard self.credentials != nil else {
                self.authenticatedStackView.isHidden = true
                return
            }
        
            self.authenticatedStackView.isHidden = false
        }
    }
    
    private func logOut(_ callback: @escaping (Error?) -> Void) {
        credentialsManager.revoke { error in
            guard error == nil else {
                return callback(error)
            }
            
            self.credentials = nil
            self.keychain.deleteEntry(forKey: "userId")
            
            callback(nil)
        }
    }
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension ViewController: ASAuthorizationControllerDelegate {
    
    // Handle authorization success
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Convert Data -> String
            guard let authorizationCode = appleIDCredential.authorizationCode,
                let authCode = String(data: authorizationCode, encoding: .utf8) else {
                    return print("Problem with the authorizationCode")
            }
            
            Auth0
                .authentication()
                .login(appleAuthorizationCode: authCode, fullName: appleIDCredential.fullName).start { result in
                    switch(result) {
                    case .success(let credentials):
                        print("Auth0 Success: \(credentials)")
                        
                        _ = self.credentialsManager.store(credentials: credentials)
                        self.credentials = credentials
                        self.keychain.setString(appleIDCredential.user, forKey: "userId")
                        
                        self.showAuthUI()
                    case .failure(let error):
                        print("Exchange Failed: \(error)")
                    }
            }
        }
    }
    
    // Handle authorization failure
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("SIWA Authorization Failed: \(error)")
    }

}
