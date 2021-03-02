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



class StartRun: UIViewController {
    
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
    
    
    // Logic Components
    var suggestedRoutes: [CLLocationCoordinate2D] = []
    var currIndex = 0
    let LocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var routesSegments: [Segments] = [] //array of routes
    var routesSegmentIds: [Int] = []
    var filteredRouteSegments: [Segments] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getRoutes()
        updateCurrentSegmentUI()
    }

    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        let s = filteredRouteSegments[currIndex]
        var route = PFObject(className: "Route")
        let query = PFQuery(className: "Route")
        query.whereKey("stravaDataId", equalTo: s.stravaDataId)
        query.findObjectsInBackground{ (routes, error) in
            //var routeId = ""
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
            self.present(runStatusPage, animated: true, completion: nil)
        }

    }
    
    @IBAction func distanceSliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        distanceLabel.text = "\(currentValue)"
    }
    
    
    @IBAction func distanceSliderValueChosen(_ sender: UISlider) {
        filterRoutesByDistance(distance: Double(sender.value) )
        print("\nFiltered Routes (Id, TotalDistance, DistanceAway):")
        for r in filteredRouteSegments{
            let distanceInMiles = r.distance / 1000 * 0.621371
            let distanceAway = r.distanceAway / 1000 * 0.621371
            print(String(format: "%10.d \t %8.2f miles \t %8.2f", r.stravaDataId, distanceInMiles, distanceAway))
        }
        currIndex = 0
        
        updateCurrentSegmentUI()
    }
    
    
    @IBAction func inclineSliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
            
        inclineLabel.text = "\(currentValue)"
    }
    
    
    func getRoutes() {
        let long = Home.currentLocation!.coordinate.longitude
        let lat = Home.currentLocation!.coordinate.latitude
        
        // Not sure how the bounds are supposed to be (fix this if needed)
        let northeastBounds = "[\(lat),\(long),\(lat+3),\(long+3)]"
        let northwestBounds = "[\(lat),\(long-3),\(lat+3),\(long)]"
        let southwestBounds = "[\(lat-3),\(long-3),\(lat),\(long)]"
        let southeastBounds = "[\(lat-3),\(long),\(lat),\(long+3)]"
        
        print("\n")
        getRoutesFromBounds(bounds: northeastBounds, directionString: "NORTH_EAST")
        getRoutesFromBounds(bounds: northwestBounds, directionString: "NORTH_WEST" )
        getRoutesFromBounds(bounds: southwestBounds, directionString: "SOUTH_WEST")
        getRoutesFromBounds(bounds: southeastBounds, directionString: "SOUTH_EAST")
    }
    
    
    func getRoutesFromBounds(bounds: String, directionString: String){
        let accessToken = LogIn.accessToken
        let parameters: [String: Any] = ["access_token": accessToken, "bounds": bounds, "activity_type": "running"]
        AF.request("https://www.strava.com/api/v3/segments/explore", method: .get, parameters: parameters).response { response in
            guard let data = response.data else { return }
            let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            print("ALL NEW SEGMENTS IN \(directionString) AREA: ")
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
                    
                    //making coords for starting and ending point
                    let start_loc = CLLocation(latitude: s[0] as! CLLocationDegrees, longitude: s[1] as! CLLocationDegrees)
                    let end_loc = CLLocation(latitude: e[0] as! CLLocationDegrees, longitude: e[1] as! CLLocationDegrees)
                    let distanceAway = self.getDistanceAway(location: start_loc)
                    
                    // make segement object
                    let curr_seg = Segments(stravaDataId: id, routeName: routeName, distance: dist, distanceAway: distanceAway, start: start_loc, end: end_loc)
                
                    //let curr_seg = Segments(d:dist, slat: s[0] as! Double, slong: s[1] as! Double, elat: e[0] as! Double, elong: e[1] as! Double)
                    self.routesSegments.append(curr_seg)
                    self.routesSegmentIds.append(id)
                    count+=1
                    
                }
            self.sortSegments()
            //print(self.routesSegments)
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
        print("\tsorted count = \(sortedSegs.count) normal count = \(self.routesSegments.count)")
    }
    
    func filterRoutesByDistance(distance: Double){
        // reset filtered segments
        filteredRouteSegments = []
        
        for r in routesSegments{
            
            //convert meters to miles
            let distanceInMiles = r.distance / 1000 * 0.621371
            if distanceInMiles <= distance{
                filteredRouteSegments.append(r)
            }
        }
    }
    
    func updateCurrentSegmentUI(){
        // No routes
        if(filteredRouteSegments.count == 0){
            self.map.isHidden = true
            self.prevButton.isHidden = true
            self.nextButton.isHidden = true
            self.routeNameLabel.text = "no routes"
            self.routeDistanceLabel.isHidden = true
            self.startButton.isHidden = true
            return
        }
        // At Last route
        self.nextButton.isHidden = (self.currIndex == self.filteredRouteSegments.count-1)
        // At First route
        self.prevButton.isHidden = (self.currIndex == 0)
        map.removeOverlays(map.overlays)
        displayRoute()
        self.routeNameLabel.text = filteredRouteSegments[currIndex].routeName
        self.routeDistanceLabel.text = String(
            format: "%.2f miles", filteredRouteSegments[currIndex].distance / 1000 * 0.621371)
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
            self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated:true)

        }
    }
    
    
    func findRoutes(){
        //get routes from Strava API:
        
        //create CLLocationCoordinate2D object for each route and append to self.suggestedRoutes

        //sample routes:
        var destCoordinates = CLLocationCoordinate2D(latitude: 37.331193,longitude: -122.031401)
        self.suggestedRoutes.append(destCoordinates)
        destCoordinates = CLLocationCoordinate2D(latitude: 37.330247,longitude: -122.027774)
        self.suggestedRoutes.append(destCoordinates)
        destCoordinates = CLLocationCoordinate2D(latitude: 37.326644,longitude: -122.030186)
        self.suggestedRoutes.append(destCoordinates)

        //init navig buttons
        prevButton.isHidden = true
        if(self.suggestedRoutes.count==1){
            prevButton.isHidden = true
        }
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
