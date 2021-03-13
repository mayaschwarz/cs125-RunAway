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

class History : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var runTable: UITableView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var runsCompleted: UILabel!
    @IBOutlet weak var timeCompleted: UILabel!
    @IBOutlet weak var distCompleted: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var sample = ["this", "is", "a", "sample", "list"]
    var userRunHistory : [PFObject] = []
    var currentUser = PFUser.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "RunTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "RunTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.currentUser = PFUser.current()
        getRunHistory()
        
        let name = self.currentUser?["firstname"] as! String
        var greeting="Hello, "
        greeting+=name.lowercased().capitalized
        username.text=greeting
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRunHistory.count
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RunTableViewCell", for: indexPath) as! RunTableViewCell
        
        // Set Run Name
        cell.nameLabel.text = userRunHistory[indexPath.row]["runName"] as! String
        
        // Set Distance
        let miles = (userRunHistory[indexPath.row]["totalDistance"] as! Double) / 1000 * 0.621371
        cell.distanceLabel.text = String(format: "%.2f miles", miles)
        
        // Set Time
        cell.timeLabel.text = String(format: "%.2f sec", userRunHistory[indexPath.row]["elapsedTime"] as! TimeInterval)
        
        // Set Date
        let d = userRunHistory[indexPath.row]["startTimeStamp"] as! Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "en_US")
        cell.dateLabel.text = dateFormatter.string(from: d) // Jan 2, 2001
        
        return cell
    }
    
    
    
    func getRunHistory(){
        userRunHistory = []
        let list = self.currentUser?["listOfRuns"] as! [PFObject]
        for run in list {
            //print(run.objectId!)
            let q = PFQuery(className: "Run")
            q.getObjectInBackground(withId: run.objectId!, block: { (run, error) in
                if error != nil {
                    print("Error: Could not find run in database.")
                }
                else {
                    self.userRunHistory.append(run!)
                    self.userRunHistory.sort { (run1, run2) -> Bool in
                        let d1 = run1["startTimeStamp"] as! Date
                        let d2 = run2["startTimeStamp"] as! Date
                        return d1.compare(d2) == .orderedDescending
                    }
                    self.updateUIComponents()
                }
            })
            
        }
    }
    func updateUIComponents(){
        self.tableView.reloadData()
        print(userRunHistory)
        
        //runs
        runsCompleted.text = String(format: "%d runs completed", self.currentUser?["totalRuns"] as! Int)
        
        //time
        let seconds = self.currentUser?["totalTime"] as! TimeInterval
        timeCompleted.text = String(format: "%.1f  seconds total", seconds)
        
        //distance
        distCompleted.text = String(format: "%.2f  miles run", self.currentUser?["totalMiles"] as! Double)
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
