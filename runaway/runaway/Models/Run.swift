//
//  Run.swift
//  runaway
//
//  Created by Kay Lab on 2/20/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import Parse

/* CURRENTLY NOT BEING USED. FOUND WAY WITHOUT HAVING TO USE */
class Run : PFObject, PFSubclassing{
    static func parseClassName() -> String {
        return "Run"
    }
    
    //var objectId: String
    @NSManaged var route: Route
    @NSManaged var user: User
    @NSManaged var startTimeStamp: NSDate
    @NSManaged var totalDistance: Double
    @NSManaged var elapsedTime: Double
    @NSManaged var runName: String

    //idky but this is required
    override init(){
        super.init()
    }
    
    // Run object should created only AFTER run is complete
    init(route: Route, user: User, startTimeStamp: NSDate, endTimeStamp: NSDate, runName: String){
        super.init()
        
        self.route = route
        self.user = user
        self.startTimeStamp = startTimeStamp
        self.runName = runName
        self.saveInBackground {
          (success: Bool, error: Error?) in
          if (success) {
            print("Successfully pushed RUN to database.")
          } else {
            print("Error: Could not push RUN to database.")
          }
        }
    }
    
    
    init(objectId: String){
        super.init()
//        self.objectId = ""
//        self.routeId = ""
//        self.userId = ""
//        self.startTimeStamp = NSDate()
//        self.endTimeStamp = NSDate()
//        self.runName = ""
        
        let query = PFQuery(className: "Run")
        query.whereKey("objectId", equalTo: objectId)
        query.findObjectsInBackground{ (runs, error) in
            if error != nil {
                print("Error: Could not find route in database.")
            }
            else if runs?.count != 0 {
                //self.objectId = runs![0]["objectId"] as! String
                self.route = runs![0]["route"] as! Route
                self.user = runs![0]["user"] as! User
                self.startTimeStamp = runs![0]["startTimeStamp"] as! NSDate
                self.runName = runs![0]["runName"] as! String
            }
        }
    }
    
    
    private func pushToDatabase() -> String{
//        let parseObject = PFObject(className: "Run")
//
//        parseObject["routeId"] = self.routeId
//        parseObject["userId"] = self.userId
//        parseObject["startTimeStamp"] = self.startTimeStamp
//        parseObject["endTimeStamp"] = self.endTimeStamp
//        parseObject["runName"] = self.runName
        
        // Saves the new object.
        var id = ""
        self.saveInBackground {
          (success: Bool, error: Error?) in
          if (success) {
            print("Successfully pushed RUN to database.")
            id = self.objectId!
          } else {
            print("Error: Could not push RUN to database.")
          }
        }
        return id
    }
    
    
//    func getRoute() -> PFObject? {
//        var route = PFObject()
//        let query = PFQuery(className: "Route")
//        query.whereKey("objectId", equalTo: self.routeId)
//        do{
//            route = try query.findObjects()[0]
//        } catch {
//            print(error)
//        }
//        return route
//    }
    
    
}
