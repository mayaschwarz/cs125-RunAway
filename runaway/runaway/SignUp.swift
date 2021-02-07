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

class SignUp: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var signUpFirstNameField: UITextField!
    // we will use emails for usernames because they are unique
    @IBOutlet weak var signUpUsernameField: UITextField!
    @IBOutlet weak var signUpPasswordField: UITextField!
    @IBOutlet weak var signUpBirthdayField: UIDatePicker!
    @IBOutlet weak var signUpGenderField: UIPickerView!
    var GenderData: [String] = [String]()
    @IBOutlet weak var signUpHeightField: UITextField!
    @IBOutlet weak var signUpWeightField: UITextField!
    

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
        signUpHeightField.text = ""
        signUpWeightField.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return GenderData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return GenderData[row]
    }
  
    @IBAction func signUp(_ sender: UIButton) {
        let user = PFUser()
        user["firstname"] = signUpFirstNameField.text
        user.username = signUpUsernameField.text
        user.password = signUpPasswordField.text
        user["birthday"] = signUpBirthdayField.date
        user["gender"] = GenderData[signUpGenderField.selectedRow(inComponent: 0)]
        user["height"] = signUpHeightField.text
        user["weight"] = signUpWeightField.text
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        user.signUpInBackground { (success, error) in
            UIViewController.removeSpinner(spinner: sv)
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
