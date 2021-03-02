//
//  RunStatus.swift
//  runaway
//
//  Created by Maya Schwarz on 2/9/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import UIKit
import Parse

class RunStatus: UIViewController {
    var route = PFObject(className: "Route")
    var routeName = ""
    var counter = 0.0
    var timer = Timer()
    var isPlaying = true
    var startTime = NSDate()
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stopButton.isEnabled = true
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
        isPlaying = true
        timeLabel.text = String(counter)
    }
        
    @IBAction func stopTimer(_ sender: AnyObject) {
        createRun()
        stopButton.isEnabled = false
        timer.invalidate()
        isPlaying = false
    }
    
    @objc func UpdateTimer() {
        counter = counter + 0.1
        timeLabel.text = String(format: "%.1f", counter)
    }
    
    func createRun() {
        self.route.incrementKey("totalRuns")
        let endTime = NSDate()
        let elapsedTime = endTime.timeIntervalSince(self.startTime as Date)
        
        let run = PFObject(className: "Run")
        run["route"] = self.route
        run["user"] = PFUser.current()!
        run["startTimeStamp"] = self.startTime
        run["totalDistance"] = self.route["distance"] as! Double
        run["elapsedTime"] = elapsedTime
        run["runName"] = self.routeName
        run.saveInBackground{
            (success: Bool, error: Error?) in
            if (success) {
              print("Successfully pushed RUN to database.")
                let user = PFUser.current() as! User
                user.add(run, forKey: "listOfRuns")
                user.incrementKey("totalRuns")
                user.incrementKey("totalTime", byAmount: elapsedTime as NSNumber)
                user.incrementKey("totalMiles", byAmount: (self.route["distance"] as! Double / 1000 * 0.621371) as NSNumber)
                user.saveInBackground {
                  (success: Bool, error: Error?) in
                  if (success) {
                    print("Successfully added RUN to USER.listOfRuns in database.")
                  } else {
                    print("Error: Could not add RUN to USER.listOfRuns in database.")
                  }
                }
            } else {
              print("Error: Could not push RUN to database.")
            }
          }
    }
}

