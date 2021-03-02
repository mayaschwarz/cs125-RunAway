//
//  User.swift
//  runaway
//
//  Created by Kay Lab on 2/12/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import Parse


// Not sure if this is needed? made it just in case
class User : PFUser  {
    //var gender: String = ""
    //var emailVerified: Bool = false
    //var height: String = ""
    //var weight: String = ""
    //var birthday: NSDate = NSDate()
    //var objectId: String
    @NSManaged var firstName: String
    @NSManaged var experienceLevel: String
    @NSManaged var difficultyTier: Int
    @NSManaged var totalRuns: Int
    @NSManaged var totalTime: TimeInterval
    @NSManaged var totalMiles: Double
    @NSManaged var listOfRuns: [Run]
    //@NSManaged var listOfRatings: [Rating]
    
    override init(){
        super.init()
    }
    
    init(user: PFUser) {
        super.init()
        //self.objectId = user.objectId!
        self.firstName = user["firstname"] as! String
        self.experienceLevel = user["experienceLevel"] as! String
        self.difficultyTier = user["difficultyLevel"] as! Int
        self.listOfRuns = user["listOfRuns"] as! [Run]
        self.totalRuns = user["totalRuns"] as! Int
        self.totalTime = user["totalTime"] as! TimeInterval
        self.totalMiles = user["totalMiles"] as! Double
        //self.listOfRatings = user["listOfRatings"] as! [Rating]
        print(self)
    }
    
    func updateRecords(run: Run, timeInterval: TimeInterval, distanceInMiles: Double){
        self.add(run, forKey: "listOfRuns")
        totalRuns += 1
        totalTime += timeInterval
        totalMiles += distanceInMiles
        self.saveInBackground {
            (success: Bool, error: Error?) in
            if (success) {
              print("Successfully updated USER records in database.")
            } else {
              print("Error: Could not update USER records in database.")
            }
          }
    }
    func giveRating(rating: Rating){
        //listOfRatings.append(rating)
    }
    func getListOfRuns() -> [Run] {
        var l : [Run] = []
        for run in listOfRuns{
            let r = Run(objectId: run.objectId!)
            l.append(r)
        }
        return l
    }
        
}
