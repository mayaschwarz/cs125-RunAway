//
//  SignUp.swift
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

class SignUp: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window ?? ASPresentationAnchor()
    }

    @IBOutlet weak var signUpFirstNameField: UITextField!
    // we will use emails for usernames because they are unique
    @IBOutlet weak var signUpUsernameField: UITextField!
    @IBOutlet weak var signUpPasswordField: UITextField!
    @IBOutlet weak var signUpBirthdayField: UIDatePicker!
    @IBOutlet weak var signUpGenderField: UIPickerView!
    @IBOutlet weak var signUpExperienceField: UIPickerView!
    var GenderData: [String] = [String]()
    var ExperienceData: [String] = [String]()
    
    private var authSession: ASWebAuthenticationSession?
    private let clientId: String = "61588"
    private let urlScheme: String = "testerapp"
    private let fallbackUrl: String = "testerapp.com"
    private let clientSecret: String = "4c5efd4b78648d6f3f21a4089c54d1bdfb49f8a6"
    static var accessToken: String = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        signUpFirstNameField.text = ""
        signUpUsernameField.text = ""
        signUpPasswordField.text = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        let date = dateFormatter.date(from: "17:00")
        signUpBirthdayField.date = date!
        signUpGenderField.delegate = self
        signUpGenderField.dataSource = self
        GenderData = ["Male", "Female", "Non-Binary"]
        signUpGenderField.selectRow(0, inComponent: 0, animated: true)
        signUpExperienceField.delegate = self
        signUpExperienceField.dataSource = self
        ExperienceData = ["Newbie (1-3 miles/week)", "Beginner (4-8 miles/week)", "Intermediate (8-12 miles/week)", "Advanced (13+ miles/week)"]
        signUpExperienceField.selectRow(0, inComponent: 0, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return GenderData.count
        } else {
            print("1111asdlkfjlkasdfj")
            return ExperienceData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return GenderData[row]
        } else {
            return ExperienceData[row]
        }
    }
    
    
    
  
    @IBAction func signUp(_ sender: UIButton) {
        let user = PFUser()
        user["firstname"] = signUpFirstNameField.text
        user.username = signUpUsernameField.text
        user.password = signUpPasswordField.text
        user["birthday"] = signUpBirthdayField.date
        user["gender"] = GenderData[signUpGenderField.selectedRow(inComponent: 0)]
        user["totalMiles"]=0
        user["totalRuns"]=0
        user["totalTime"]=0
        user["experienceLevel"] = ExperienceData[signUpExperienceField.selectedRow(inComponent: 0)]
        switch signUpExperienceField.selectedRow(inComponent: 0) {
        case 0:
            user["difficultyLevel"] = 1
        case 1:
            user["difficultyLevel"] = 2
        case 2:
            user["difficultyLevel"] = 4
        case 3:
            user["difficultyLevel"] = 6
        default:
            user["difficultyLevel"] = 0
        }
        
        //if (user["firstname"] as! String == ""){
        //    self.displayErrorMessage(message: ("Please enter your name!"))
        //}
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        user.signUpInBackground { (success, error) in
            UIViewController.removeSpinner(spinner: sv)
            
            PFUser.logInWithUsername(inBackground: user.username!, password: user.password!) { (user, error) in
                UIViewController.removeSpinner(spinner: sv)
                if user != nil {
                    self.presentStrava()
                }else{
                    if let descrip = error?.localizedDescription{
                        self.displayErrorMessage(message: (descrip))
                    }
                }
            }
            
        }
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
    
    
    @IBOutlet weak var signUp: UIButton!

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

}


