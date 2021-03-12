//
//  StartRun.swift
//
//
//  Created by Maya Schwarz on 2/10/21.
//
import Foundation
import UIKit
import Parse
import MapKit
import Alamofire



class StartRun: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // UI Components
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var inclineSlider: UISlider!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var inclineLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var routeNameLabel: UILabel!
    @IBOutlet weak var routeDistanceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var routeRatingLabel: UILabel!
    @IBOutlet weak var starImg: UIImageView!
    @IBOutlet weak var oldMap: MKMapView!
    @IBOutlet weak var oldNextButton: UIButton!
    @IBOutlet weak var oldPrevButton: UIButton!
    @IBOutlet weak var oldRouteNameLabel: UILabel!
    @IBOutlet weak var oldRouteDistanceLabel: UILabel!
    @IBOutlet weak var upperErrorLabel: UILabel!
    @IBOutlet weak var oldRunStartBtn: UIButton!
    
    @IBOutlet weak var bottomErrorLabel: UILabel!
    
    // Logic Components
    var currIndexOldMap = 0
    var oldRoutes: [PFObject] = []
    
    var suggestedRoutes: [CLLocationCoordinate2D] = []
    var currIndex = 0
    let LocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var routesSegments: [Segments] = [] //array of routes
    var routesSegmentIds: [Int] = []
    var filteredRouteSegments: [Segments] = []
    var userDifficulty = 0
    var userExperience = "Newbie (1-3 miles/week)"
    
    //dictionary for routes and their ratings to keep data in sync
    var routePopularity = [String : Int]()
    

        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize maps
        map.delegate = self
        oldMap.delegate = self
        
        // Initilze user info
        let currentUser = User(user: PFUser.current()!)
        self.userDifficulty = currentUser.difficultyTier
        self.userExperience = currentUser.experienceLevel
        
        // Load New Route UI components
        self.upperErrorLabel.isHidden = true
        getRoutes()
        updateCurrentSegmentUI()
        self.bottomErrorLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reset distance slider for New Route
        distanceSlider.setValue(0.0, animated: false)
        distanceSliderValueChanged(distanceSlider)
        distanceSliderValueChosen(distanceSlider)
        
        // Reset and Load Old Route UI Components
        self.oldRoutes = []
        self.currIndexOldMap = 0
        getOldRoutes()
        updateOldRouteUIComponents()
        self.bottomErrorLabel.isHidden = true

        
    }
    
    
    //Displaying old routes
    //find routes
    func getOldRoutes(){
        self.oldRoutes = []
        self.currIndexOldMap = 0
        
        // fetch current user's old runs from database and rank them by score
        let query = PFQuery(className:"Ranking")
        query.whereKey("user", equalTo: PFUser.current()!)
        query.order(byDescending: "score")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let objects = objects {
                
                // If User has past runs, append to OldRoute list and UPDATE Old Route UI
                if objects.count != 0{
                    
                    for object in objects{
                        let r = object["route"] as! PFObject
                        print("RouteID: \(r.objectId!)")
                        let query2 = PFQuery(className: "Route")
                        query2.getObjectInBackground(withId: r.objectId!, block: { (route, error) in
                            if error != nil {
                                print("Error: Could not find run in database.")
                            }
                            else {
                                print(route!["routeName"]!)
                                self.oldRoutes.append(route!)
                                self.updateOldRouteUIComponents()
                            }
                        })
//                        let route = object["route"] as? PFObject
//                        do {
//                            try route!.fetchIfNeeded()
//                        } catch _ {
//                           print("There was an error ):")
//                        }
//                        self.upperErrorLabel.isHidden = true
//                        self.oldMap.isHidden = false
//                        self.oldNextButton.isHidden = false
//                        self.oldRouteNameLabel.isHidden = false
//                        self.oldRouteDistanceLabel.isHidden = false
//
//                        // append each route to oldRoutes array in correct order
//                        let stravaID = route!["stravaDataId"] as! Int
//                        let sourceLat = route!["startLat"] as! Double
//                        let sourceLng = route!["startLng"] as! Double
//                        let destLat = route!["endLat"] as! Double
//                        let destLong = route!["endLng"] as! Double
//                        let name = route!["routeName"] as! String
//                        let distance = route!["distance"] as! Double
//                        let totalRuns = route!["totalRuns"] as! Int
//                        let difficulty = route!["difficultyTier"] as! Int
//                        let ratings = route!["ratingByTier"] as! [Double]
//
//                        let routeObj = Route(objectId: "", stravaDataId: stravaID, routeName: name, startLat: sourceLat, startLng: sourceLng, endLat: destLat, endLng: destLong, distance: distance, totalRuns: totalRuns, difficultyTier: difficulty, ratingByTier: ratings)
//
//                        self.oldRoutes.append(routeObj)
                        
                    }
//                    self.oldPrevButton.isHidden = true
//                    if(self.oldRoutes.count==1){
//                        self.oldPrevButton.isHidden = true
//                        self.oldNextButton.isHidden = true
//                    }
//                    else{ self.oldNextButton.isHidden = false}
//                    self.displayOldRoutes()
                }
              
                }
            }
    }
    
    func updateOldRouteUIComponents(){
        // If user has no Old Routes, hide UI
        if self.oldRoutes.count == 0 {
            self.upperErrorLabel.text = "No past runs. Try a new run to get started :)"
            self.upperErrorLabel.isHidden = false
            self.oldMap.isHidden = true
            self.oldPrevButton.isHidden = true
            self.oldNextButton.isHidden = true
            self.oldRouteNameLabel.isHidden = true
            self.oldRouteDistanceLabel.isHidden = true
            self.oldRunStartBtn.isHidden = true
            return
        }
        // At Last route
        self.oldNextButton.isHidden = (self.currIndexOldMap == self.oldRoutes.count-1)
        // At First route
        self.oldPrevButton.isHidden = (self.currIndexOldMap == 0)
        
        
        // Update Old Route Map UI
        self.displayOldRoutes()
        
        // Show Old Route UI
        self.upperErrorLabel.isHidden = true
        self.oldMap.isHidden = false
        self.oldRouteNameLabel.isHidden = false
        self.oldRouteDistanceLabel.isHidden = false
        self.oldRunStartBtn.isHidden = false
        
    }
    
    //display past runs on the page
    func displayOldRoutes(){
        if(self.oldRoutes.count == 0) {return}
        // Display user's ranked, old runs on upper map
        let currentRoute = self.oldRoutes[currIndexOldMap]
        print("CURRENT OLD ROUTE: \(currentRoute["routeName"] as! String)")
        
        
        // Set suggestedRoute coordinates for map
        let sourceCoordinates =
            CLLocationCoordinate2D(latitude: currentRoute["startLat"] as! Double,longitude: currentRoute["startLng"] as! Double)
        let destCoordinates =
            CLLocationCoordinate2D(latitude: currentRoute["endLat"] as! Double,longitude: currentRoute["endLng"] as! Double)

        let sourcePlacemark = MKPlacemark(coordinate:sourceCoordinates)
        let destPlacemark = MKPlacemark(coordinate:destCoordinates)

        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destItem =  MKMapItem(placemark: destPlacemark)

        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destItem
        destinationRequest.transportType = .walking
        destinationRequest.requestsAlternateRoutes = true

        let directions = MKDirections(request: destinationRequest)
        directions.calculate{(response, error) in
            guard let response = response else{
                if let error = error{
                    print("something is wrong ): \(error)")
                }
                return
            }
            let route = response.routes[0]
            self.oldMap.addOverlay(route.polyline)
            self.oldMap.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), animated: true)

            // Set labels for current old route name and distance
            self.oldRouteNameLabel.text = currentRoute["routeName"] as! String
            self.oldRouteDistanceLabel.text = String(
                format: "%.2f miles", currentRoute["distance"] as! Double / 1000 * 0.621371)

        }
    }
    
    
    @IBAction func startOldRun(_ sender: Any) {
        let selectedRoute = self.oldRoutes[currIndexOldMap]
        let runStatusPage = self.storyboard?.instantiateViewController(identifier: "RunStatus" ) as! RunStatus
        runStatusPage.route = selectedRoute
        runStatusPage.routeName = selectedRoute["routeName"] as! String
        runStatusPage.routeDist = selectedRoute["distance"] as! Double
        runStatusPage.parentPage = "runpage"

        self.navigationController?.pushViewController(runStatusPage, animated: true)
    }
    
    
    
    @IBAction func nextOldRoute(_ sender: Any) {
        //next button for upper map
//        if((currIndexOldMap+1)<=(self.oldRoutes.count-1)){
//            currIndexOldMap = currIndexOldMap+1
//             oldPrevButton.isHidden = false
//         }
//         if(currIndexOldMap==(self.oldRoutes.count-1)){
//             oldNextButton.isHidden = true
//         }
//         oldMap.removeOverlays(oldMap.overlays)
//         displayOldRoutes()
        
        // Decrement OldRouteIndex
        if(currIndexOldMap<(self.oldRoutes.count-1)){
            currIndexOldMap = currIndexOldMap+1
            updateOldRouteUIComponents()
        }
    }
    
    
    @IBAction func prevOldRoute(_ sender: Any) {
        //prev button for upper map
//        if(currIndexOldMap>0){
//             currIndexOldMap = currIndexOldMap-1
//             oldNextButton.isHidden = false
//         }
//         if(currIndexOldMap==0){
//             oldPrevButton.isHidden = true
//         }
//         oldMap.removeOverlays(oldMap.overlays)
//         displayOldRoutes()
        
        // Increment OldRouteIndex
        if(currIndexOldMap>0){
            currIndexOldMap = currIndexOldMap-1
            updateOldRouteUIComponents()
        }
    }

    
    
    
    
    
    /* Setup for "Generate New Run" */
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        let s = filteredRouteSegments[currIndex]
        var route = PFObject(className: "Route")
        let query = PFQuery(className: "Route")
        query.whereKey("stravaDataId", equalTo: s.stravaDataId)
        query.findObjectsInBackground{ (routes, error) in
            if error != nil {
                print(error!)
                return
            }
            
            if routes?.count != 0 {
                route = routes![0]
            }
            else{
                let r = Route(stravaDataId: s.stravaDataId, routeName: s.routeName, startLat: s.startLoc.coordinate.latitude, startLng: s.startLoc.coordinate.longitude, endLat: s.endLoc.coordinate.latitude, endLng: s.endLoc.coordinate.longitude, distance: s.distance)
                route = r
            }
            let runStatusPage = self.storyboard?.instantiateViewController(identifier: "RunStatus" ) as! RunStatus
            runStatusPage.route = route
            runStatusPage.routeName = s.routeName
            runStatusPage.routeDist = (s.distance)
            runStatusPage.parentPage = "runpage"

            self.navigationController?.pushViewController(runStatusPage, animated: true)
            
        }

    }
    
    @IBAction func distanceSliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        distanceLabel.text = "\(currentValue)"
    }
    
    
    @IBAction func distanceSliderValueChosen(_ sender: UISlider) {
        filterRoutesByDistance(distance: Double(sender.value) )
        for r in filteredRouteSegments{
            let distanceInMiles = r.distance / 1000 * 0.621371
            let distanceAway = r.distanceAway / 1000 * 0.621371
            print(String(format: "%10.d \t %8.2f miles \t %8.2f", r.stravaDataId, distanceInMiles, distanceAway))
        }
        self.sortClimbPriority()
        currIndex = 0
        
        updateCurrentSegmentUI()
    }
    
    
    func sortClimbPriority(){
        // sort routes by difficulty (climb category)
        let sortedSegs = self.filteredRouteSegments.sorted(by: { ($0.climbPriority,$1.popularity) < ($1.climbPriority,$0.popularity) })
        self.filteredRouteSegments = sortedSegs
        
    }
    
    
    func getRoutes() {
        // retrieve routes in all directions based on user current location
        let long = Home.currentLocation!.coordinate.longitude
        let lat = Home.currentLocation!.coordinate.latitude
        
        let northeastBounds = "[\(lat),\(long),\(lat+3),\(long+3)]"
        let northwestBounds = "[\(lat-3),\(long),\(lat),\(long+3)]"
        let southwestBounds = "[\(lat-3),\(long-3),\(lat),\(long)]"
        let southeastBounds = "[\(lat),\(long-3),\(lat+3),\(long)]"
        
        getRoutesFromBounds(bounds: northeastBounds, directionString: "NORTH_EAST")
        getRoutesFromBounds(bounds: northwestBounds, directionString: "NORTH_WEST" )
        getRoutesFromBounds(bounds: southwestBounds, directionString: "SOUTH_WEST")
        getRoutesFromBounds(bounds: southeastBounds, directionString: "SOUTH_EAST")
    }
    
    
    func getRoutesFromBounds(bounds: String, directionString: String){
        // call to strava api to retrieve all routes in a specific area
        let accessToken = LogIn.accessToken
        let parameters: [String: Any] = ["access_token": accessToken, "bounds": bounds, "activity_type": "running"]
        AF.request("https://www.strava.com/api/v3/segments/explore", method: .get, parameters: parameters).response { response in
            guard let data = response.data else { return }
            let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            print("all new segments in \(directionString) area: ")
            var count=0
            let seg = dataDictionary["segments"] as! [AnyObject]
                for key in seg{
                    
                    // Prevent duplicates
                    let id = key["id"] as! Int
                    if self.routesSegmentIds.contains(id){
                        continue
                    }
                    
                    //print(dataDictionary)
                    let dist = key["distance"] as! Double
                    let s = key["start_latlng"] as! NSArray
                    let e = key["end_latlng"] as! NSArray
                    let routeName = key["name"] as! String
                    let climb = key["climb_category"] as! Int
                    let climbPriority = self.convertClimbCategory(climbCat: climb) 
                    
                    
                    //making coords for starting and ending point
                    let start_loc = CLLocation(latitude: s[0] as! CLLocationDegrees, longitude: s[1] as! CLLocationDegrees)
                    let end_loc = CLLocation(latitude: e[0] as! CLLocationDegrees, longitude: e[1] as! CLLocationDegrees)
                    let distanceAway = self.getDistanceAway(location: start_loc)
                    
                    // make segement object
                    let curr_seg = Segments(stravaDataId: id, routeName: routeName, distance: dist, distanceAway: distanceAway, start: start_loc, end: end_loc, climb: climbPriority)
                    //update route popularity
                    self.getPopularity(routeName: routeName, seg: curr_seg)

                
                    //check if user has already run this route
                    //only add if its not in user history
                    let query = PFQuery(className: "Ranking")
                    query.whereKey("routeName",equalTo:routeName)
                    query.whereKey("user",equalTo:PFUser.current()!)
                    query.findObjectsInBackground{ (objects: [PFObject]?, error: Error?) in
                        if let error = error {
                            print("error: \(error)")
                            
                        }
                        else if let objects = objects{
                            if objects.count == 0, !self.routesSegmentIds.contains(id) {
                                self.routesSegments.append(curr_seg)
                                self.routesSegmentIds.append(id)
                                count+=1
                            }
                            
                        }
                    }
                  
                    
                }
            self.sortSegments()
        }
    }
    
    func convertClimbCategory(climbCat: Int) -> Int{
        // map route's climb categoy to current user's fitness level
        if self.userDifficulty==1 {
            return (climbCat+1)
        }
        else if self.userDifficulty==2 {
            if climbCat==0 {
                return 3
            }
            else if climbCat>=3 {
                return climbCat+1
            } else{
                return climbCat
            }
        }
        else if self.userDifficulty==4 {
            if climbCat<=3 {
                return (climbCat-4) * -1
            }
            else{
                return (climbCat+1)
            }
        }
        else {
            //self.userDifficulty==6
            return (climbCat-6) * -1
        }
        
    }
    
    
    func getDistanceAway(location: CLLocation) -> Double{
        let userLoc = CLLocation(
            latitude:Home.currentLocation!.coordinate.latitude,
            longitude:Home.currentLocation!.coordinate.longitude
        )
        return location.distance(from: userLoc)
    }
    
    
    func sortSegments(){

       let sortedSegs = self.routesSegments.sorted(by: {$0.distanceAway < $1.distanceAway})
        self.routesSegments = sortedSegs
    }
    
    
    func filterRoutesByDistance(distance: Double){
        // reset filtered segments
        filteredRouteSegments = []
        
        for r in routesSegments{
            
            //convert meters to miles
            let distanceInMiles = r.distance / 1000 * 0.621371
            if distance >= 3{
                
                if (distanceInMiles > Double(distance - 2))
                {
                    if (distanceInMiles <= distance) {
                    filteredRouteSegments.append(r)
                    }
                }

            }
            else{
                if distanceInMiles <= distance{
                    filteredRouteSegments.append(r)
                }
            }
        }
    }
    
    
    func getPopularity(routeName: String, seg: Segments){
            var numUsers=0
            var totalLikes=0
            
            //create query to find route in ranking table
            let query = PFQuery(className: "Ranking")
            query.whereKey("routeName", equalTo: routeName)
            query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
                if let error = error {
                    // Log details of the failure
                    print(error.localizedDescription)
                } else if let objects = objects
                {
                    // The find succeeded.
                    // Do something with the found objects
                    for object in objects {
                        
                        //get user of this route
                        let routeUser = object["user"] as? PFObject
                        do{
                            try routeUser?.fetchIfNeeded()
                        } catch _ {
                            print("There was an error ):")
                         }
                        let routeUserLevel = routeUser!["experienceLevel"] as! String
                        if routeUserLevel == self.userExperience{
                            //get number of user who have ran this route
                            numUsers+=1
                            //get number of users who have liked running this route
                            if((object["liked"] as! Bool) == true){ totalLikes+=1  }
                        }
                }
                //if route has more than 75% likes then it is considered a popular run
                if(numUsers > 0){
                    let pop_score = (totalLikes/numUsers) * 100
                    self.routePopularity[routeName] = pop_score
                    seg.setPopularity(pop: pop_score)
                }
                    
            }
        }
        
    }
    
    
    func updateCurrentSegmentUI(){
        // No New Routes generated, hide New Route UI
        if(filteredRouteSegments.count == 0){
            self.map.isHidden = true
            self.prevButton.isHidden = true
            self.nextButton.isHidden = true
            self.routeNameLabel.text = "no routes to show, please select a distance!"
            self.routeDistanceLabel.isHidden = true
            self.routeRatingLabel.isHidden = true
            self.startButton.isHidden = true
            self.starImg.isHidden = true
            
            if(distanceLabel.text != "0"){
                bottomErrorLabel.isHidden = true
            }
            
            else{
                bottomErrorLabel.isHidden = false
            }
            return
        }
        // At Last route
        self.nextButton.isHidden = (self.currIndex == self.filteredRouteSegments.count-1)
        // At First route
        self.prevButton.isHidden = (self.currIndex == 0)
        
        // Update New Route Map
        map.removeOverlays(map.overlays)
        displayRoute()
        let currRoute = filteredRouteSegments[currIndex].routeName
        self.routeNameLabel.text = currRoute //filteredRouteSegments[currIndex].routeName
        self.routeDistanceLabel.text = String(
            format: "%.2f miles", filteredRouteSegments[currIndex].distance / 1000 * 0.621371)
        
        // Add popularity label
        if (self.routePopularity[currRoute] ?? 0 >= 75){
            self.routeRatingLabel.text = " Users in your level like this route"
            self.routeRatingLabel.isHidden = false
            self.starImg.isHidden = false
        }
        else{
            self.routeRatingLabel.isHidden = true
            self.starImg.isHidden = true
        }
        
        // Show New Route Map UI
        self.routeDistanceLabel.isHidden = false
        self.startButton.isHidden = false
        self.map.isHidden = false
    }
    
    func displayRoute(){
        let sourceCoordinates = CLLocationCoordinate2D(
            latitude: filteredRouteSegments[currIndex].startLoc.coordinate.latitude,
            longitude: filteredRouteSegments[currIndex].startLoc.coordinate.longitude
        )
        let destCoordinates = CLLocationCoordinate2D(
            latitude: filteredRouteSegments[currIndex].endLoc.coordinate.latitude,
            longitude: filteredRouteSegments[currIndex].endLoc.coordinate.longitude
        )
        
        let sourcePlacemark = MKPlacemark(coordinate:sourceCoordinates)
        let destPlacemark = MKPlacemark(coordinate:destCoordinates)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destItem =  MKMapItem(placemark: destPlacemark)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destItem
        destinationRequest.transportType = .walking
        destinationRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: destinationRequest)
        directions.calculate{(response, error) in
            guard let response = response else{
                if let error = error{
                    print("something is wrong ): \(error)")
                }
                return
            }
            let route = response.routes[0]
            self.map.addOverlay(route.polyline)
            self.map.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), animated:true)

        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.lineWidth = 6
        render.strokeColor = .systemBlue
         return render
    }
    
    
    @IBAction func displayNextRun(_ sender: Any) {
        if(currIndex<(self.filteredRouteSegments.count-1)){
            currIndex = currIndex+1
            updateCurrentSegmentUI()
        }
    }
    
    
    @IBAction func displayPrevRun(_ sender: Any) {
        if(currIndex>0){
            currIndex = currIndex-1
            updateCurrentSegmentUI()
        }
    }

    
}
