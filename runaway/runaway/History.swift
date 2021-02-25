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
    
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var runsCompleted: UILabel!
    @IBOutlet weak var timeCompleted: UILabel!
    @IBOutlet weak var distCompleted: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var currentUser = PFUser.current()
        //set up greeting
        var greeting="Hello "
        greeting+=currentUser?["firstname"] as! String
        username.text=greeting
        //runs
        var runs=String(currentUser?["totalRuns"] as! Int)
        runs+=" runs completed"
        runsCompleted.text=runs
        
        var time=String(currentUser?["totalTime"] as! Int)
        time+=" minutes total"
        timeCompleted.text=time
        
        var dist=String(currentUser?["totalMiles"] as! Int)
        dist+=" miles run"
        distCompleted.text=dist
        
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
