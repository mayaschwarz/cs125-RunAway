//
//  Route.swift
//  runaway
//
//  Created by Kay Lab on 2/12/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import Parse

class Route : PFObject, PFSubclassing{
    static func parseClassName() -> String {
        return "Route"
    }
    
    //var objectId: String
    
    // These gathered from Strava
    @NSManaged var stravaDataId: Int
    @NSManaged var routeName: String
    @NSManaged var startLat: Double
    @NSManaged var startLng: Double
    @NSManaged var endLat: Double
    @NSManaged var endLng: Double
    @NSManaged var distance: Double
    
    // These generated here
    @NSManaged var totalRuns: Int
    @NSManaged var difficultyTier: Int
    @NSManaged var ratingByTier: [Double]
    //var listsOfRatingsByTier: [[Rating]]
    
    override init(){
        
        //listsOfRatingsByTier = [[], [], [], [], [], []]
        super.init()
    }
    
    // USE CONSTRUCTOR WHEN FOUND IN PARSEQUERY
    init(objectId: String, stravaDataId: Int, routeName: String, startLat: Double, startLng: Double, endLat: Double, endLng: Double, distance: Double, totalRuns: Int, difficultyTier: Int, ratingByTier: [Double]){
        
        //self.listsOfRatingsByTier = [[], [], [], [], [], []]
        super.init()
        // All variables
        //self.objectId = objectId
        self.stravaDataId = stravaDataId
        self.routeName = routeName
        self.startLat = startLat
        self.startLng = startLng
        self.endLat = endLat
        self.endLng = endLng
        self.distance = distance
        self.totalRuns = totalRuns
        self.difficultyTier = difficultyTier
        self.ratingByTier = ratingByTier
    }
    
    // USE CONSTRUCTOR WHEN GIVEN AN OBJECTID (pull from PARSE database)
    init(objectId: String){
        //listsOfRatingsByTier = [[], [], [], [], [], []]
        super.init()
        
        let query = PFQuery(className: "Route")
        query.whereKey("objectId", equalTo: objectId)
        query.findObjectsInBackground{ (routes, error) in
            if error != nil {
                print("Error: Could not find route in database.")
            }
            else if routes?.count != 0 {
                self.stravaDataId = routes![0]["stravaDataId"] as! Int
                self.routeName = routes![0]["routeName"] as! String
                self.startLat = routes![0]["startLat"] as! Double
                self.startLng = routes![0]["startLng"] as! Double
                self.endLat = routes![0]["endLat"] as! Double
                self.endLng = routes![0]["endLng"] as! Double
                self.distance = routes![0]["distance"] as! Double
                self.totalRuns = routes![0]["totalRuns"] as! Int
                self.difficultyTier = routes![0]["difficultyTier"] as! Int
                self.ratingByTier = routes![0]["ratingByLevel"] as! [Double]
                //self.listsOfRatingsByTier = routes![0]["listOfRating"] as! [[Rating]]
            }
        }
    }
    
    // USE CONSTRUCTOR WHEN MANUALLY CONSTRUCTING
    init(stravaDataId: Int, routeName: String, startLat: Double, startLng: Double, endLat: Double, endLng: Double, distance: Double){
        
        //self.listsOfRatingsByTier = [[], [], [], [], [], []]
        super.init()
        
        // Data from Strava
        self.stravaDataId = stravaDataId
        self.routeName = routeName
        self.startLat = startLat
        self.startLng = startLng
        self.endLat = endLat
        self.endLng = endLng
        self.distance = distance
        
        // Initialize other variables
        self.totalRuns = 0
        self.difficultyTier = 0
        self.ratingByTier = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        
        // Generated Data
        self.difficultyTier = calculateDifficulty(distance: distance)
        self.saveInBackground{
            (success: Bool, error: Error?) in
            if (success) {
              print("Successfully pushed ROUTE to database.")
            } else {
              print("Error: Could not push ROUTE to database.")
            }
        }
    }
    
    
    // Calculates difficulty of route based on distance
    private func calculateDifficulty(distance: Double) -> Int {
        
        let distanceInMiles = distance / 1000 * 0.621371
        // 1.5 miles at 10min/miles = 15 miutes
        if distanceInMiles <= 1.5 { return 1 }
        
        // 3 miles at 10min/miles = 30 miutes
        else if distanceInMiles <= 3 { return 2 }

        // 6 miles at 10min/miles = 60 miutes
        else if distanceInMiles <= 6 { return 3 }
        
        // 9 miles at 10min/miles = 90 miutes
        else if distanceInMiles <= 9 { return 4}
        
        // 12 miles at 10min/miles = 120 miutes
        else if distanceInMiles <= 12{ return 5}
        
        // TODO: Add more cases later?
        return 6
    }
    
    
    private func alreadyExists() -> Bool{
        if self.objectId == "" {
            return false
        }
        return true
    }

    
    func updateInDatabase() -> String{
        if alreadyExists() {
            var id = ""
            let query = PFQuery(className: "Route")
            query.whereKey("objectId", equalTo: self.objectId!)
            query.findObjectsInBackground{ (routes, error) in
                if error != nil {
                    print("Error: Could not update in database.")
                }
                else if routes?.count != 0 {
                    routes![0]["ratingByTier"] = self.ratingByTier
                    //routes![0]["listsOfRatingsByTier"] = self.listsOfRatingsByTier
                    routes![0].saveInBackground()
                    id = routes![0].objectId!
                }
            }
            return id
        }
        else{
            // Create object
            let parseObject = PFObject(className: "Route")
            parseObject["stravaDataId"] = self.stravaDataId
            parseObject["routeName"] = self.routeName
            parseObject["startLat"] = self.startLat
            parseObject["startLng"] = self.startLng
            parseObject["endLat"] = self.endLat
            parseObject["endLng"] = self.endLng
            parseObject["distance"] = self.distance
            parseObject["totalRuns"] = self.totalRuns
            parseObject["difficultyTier"] = self.difficultyTier
            parseObject["ratingByTier"] = self.ratingByTier
            //parseObject["listsOfRatingsByTier"] = self.listsOfRatingsByTier

            var id = ""
            // Saves the new object.
            parseObject.saveInBackground {
              (success: Bool, error: Error?) in
              if (success) {
                id = parseObject.objectId!
                print("Successfully saved route to database.")
              } else {
                print("Error: Could not save route to database.")
              }
            }
            return id
        }
    }
    
    func getStartPoint() -> CLLocation{
        return CLLocation(latitude: self.startLat, longitude: startLng)
    }
    
    func getEndPoint() -> CLLocation{
        return CLLocation(latitude: self.endLat, longitude: endLng)
    }
    
    func getRatingByTier(tier: Int) -> Double{
        return ratingByTier[tier-1]
    }
    
    // Used when User gives a rating
//    func addNewRating(rating: Rating, tier: Int){
//        let tierIndex = tier - 1
//        var oldRating = ratingByTier[tierIndex] // average
//        oldRating *= Double(listsOfRatingsByTier[tierIndex].count) // sum
//
//        listsOfRatingsByTier[tierIndex].append(rating) // new count
//
//        var newRating = oldRating + Double(rating.rating) // new sum
//        newRating /= Double(listsOfRatingsByTier.count) // new average
//
//        ratingByTier[tierIndex] = newRating
//    }
    
}
