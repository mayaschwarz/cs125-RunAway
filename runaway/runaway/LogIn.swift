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

class LogIn: UIViewController {
    @IBOutlet weak var signInUsernameField: UITextField!
    @IBOutlet weak var signInPasswordField: UITextField!

    
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
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let Home = storyBoard.instantiateViewController(withIdentifier: "Home") as! Home
        self.present(Home, animated: true, completion: nil)
    }

    @IBAction func signIn(_ sender: UIButton) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        PFUser.logInWithUsername(inBackground: signInUsernameField.text!, password: signInPasswordField.text!) { (user, error) in
            UIViewController.removeSpinner(spinner: sv)
            if user != nil {
                self.loadHomeScreen()
            }else{
                if let descrip = error?.localizedDescription{
                    self.displayErrorMessage(message: (descrip))
                }
            }
        }
    }

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
