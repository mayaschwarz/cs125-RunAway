//
//  History.swift
//  runaway
//
//  Created by Kay Lab on 2/15/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import UIKit
import Parse

class History:UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBOutlet weak var runTable: UITableView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var runsCompleted: UILabel!
    @IBOutlet weak var timeCompleted: UILabel!
    @IBOutlet weak var distCompleted: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let currentUser = User(user: PFUser.current()!)
        let listOfruns = currentUser["listOfRuns"] as! [Run]
//        for run in listOfruns{
//            let r = Run(objectId: run.objectId!)
//
//        }
        
        //set up greeting
        var greeting="Hello "
        greeting+=currentUser.firstName
        username.text=greeting
        
        //runs
        runsCompleted.text = String(format: "%d  completed", currentUser.totalRuns)
        
        //time
        let seconds = currentUser.totalTime
        timeCompleted.text = String(format: "%.1f  seconds", seconds)
        
        //distance
        distCompleted.text = String(format: "%.2f  miles", currentUser.totalMiles)
        
    }

    @IBAction func logout(_ sender: Any) {
        PFUser.logOutInBackground(block: { (error) in
        if error == nil {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                      //let Home = storyBoard.instantiateViewController(withIdentifier: "Home") as! Home
            let login=self.storyboard?.instantiateViewController(identifier:"LogIn" ) as! LogIn
            
        
            self.present(login, animated: true, completion:nil)
               
            }})
    }
    
}
