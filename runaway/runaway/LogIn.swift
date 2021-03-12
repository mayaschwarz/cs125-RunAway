//
//  LogIn.swift
//  runaway
//
//  Created by Maya Schwarz on 2/5/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Alamofire
import AuthenticationServices

// Parts of the login/sign up functionality is borrowed from https://www.back4app.com/docs/ios/swift-login-tutorial

class LogIn: UIViewController, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }
    
    @IBOutlet weak var signInUsernameField: UITextField!
    @IBOutlet weak var signInPasswordField: UITextField!
    
    private var authSession: ASWebAuthenticationSession?
    private let clientId: String = "61588"
    private let urlScheme: String = "testerapp"
    private let fallbackUrl: String = "testerapp.com"
    private let clientSecret: String = "4c5efd4b78648d6f3f21a4089c54d1bdfb49f8a6"
    static var accessToken: String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInUsernameField.text = ""
        signInPasswordField.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadHomeScreen(){
        let tab_control=storyboard?.instantiateViewController(identifier: "myTabBar") as! myTabBar
        self.present(tab_control, animated: true, completion:nil)

    }

    @IBAction func signIn(_ sender: UIButton) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        PFUser.logInWithUsername(inBackground: signInUsernameField.text!, password: signInPasswordField.text!) { (user, error) in
            UIViewController.removeSpinner(spinner: sv)
            if user != nil {
                self.presentStrava()
                self.loadHomeScreen()
            }else{
                if let descrip = error?.localizedDescription{
                    self.displayErrorMessage(message: (descrip))
                }
            }
        }
    }
    
    // displays an error message if login info is incorrect
    
    func displayErrorMessage(message:String) {
        let alertView = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
        }
        alertView.addAction(OKAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        self.present(alertView, animated: true, completion:nil)
    }
    
    private func presentStrava(){
        
        let url: String = "https://www.strava.com/oauth/mobile/authorize?client_id=\(clientId)&redirect_uri=\(urlScheme)%3A%2F%2F\(fallbackUrl)&response_type=code&approval_prompt=auto&scope=read"
        guard let authenticationUrl = URL(string: url) else { return }
        print(url)
        
        authSession = ASWebAuthenticationSession(url: authenticationUrl, callbackURLScheme: "\(urlScheme)") { url, error in
                   if let error = error {
                       print(error)
                   } else {
                    if let code = self.getCode(from: url) {
                        print("sasuke")
                        print(code)
                        self.requestStravaTokens(with: code)
                        
                       }
                   }
               }
        authSession?.presentationContextProvider = self
        authSession?.start()
    }
    
    
    private func getCode(from url: URL?) -> String? {
        guard let url = url?.absoluteString else { return nil }
        
        let urlComponents: URLComponents? = URLComponents(string: url)
        let code: String? = urlComponents?.queryItems?.filter { $0.name == "code" }.first?.value
        
        return code
    }
    
    private func requestStravaTokens(with code: String) {
        let parameters: [String: Any] = ["client_id": clientId, "client_secret": clientSecret, "code": code, "grant_type": "authorization_code"]

        AF.request("https://www.strava.com/oauth/token", method: .post, parameters: parameters).response { response in
            guard let data = response.data else { return }
            let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            print("cat")
            let accessToken = dataDictionary["access_token"] as! String
            print(accessToken)
            LogIn.accessToken = accessToken
        }
    }
    
    
}


extension WelcomeView: ASWebAuthenticationPresentationContextProviding {

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.windows[0]
    }
}
