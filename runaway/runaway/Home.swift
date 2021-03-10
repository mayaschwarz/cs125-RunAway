//
//  Home.swift
//  runaway
//
//  Created by Maya Schwarz on 2/6/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import UIKit
import Parse
import CoreLocation
import MapKit


class Home: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var homeMotivationalPhrase: UILabel!
    let homeMotivationalPhrasesBank = ["Practice makes perfect!", "Don't give up!", "Today is the first step!", "Believe in yourself!", "Never quit!", "Life is a journey not a race", "You get what you give", "No pressure, no diamonds", "Prove them wrong", "Doubt kills more dreams than failure ever will", "Dreams don't work unless you do", "The obstacle is the path", "The best revenge is massive success", "Today is your day!"]
    let LocationManager = CLLocationManager()
    static var currentLocation: CLLocation?
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var weatherSummary: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var suggestedRouteNameLabel: UILabel!
    @IBOutlet weak var suggestedRouteDistanceLabel: UILabel!
    var suggestedRoute: [String: CLLocationCoordinate2D] = [:]
    var selectedRoute:Route!
    
    @IBOutlet weak var startRunBtn: UIButton!
    
    @IBOutlet weak var basisLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        setUpLocation()
        let homeRandomNumber = Int.random(in: 0...homeMotivationalPhrasesBank.count-1) 
        homeMotivationalPhrase.text = homeMotivationalPhrasesBank[homeRandomNumber]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // Location
    func setUpLocation() {
        LocationManager.delegate = self
        LocationManager.requestWhenInUseAuthorization()
        LocationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, Home.currentLocation==nil{
            Home.currentLocation = locations.first
            LocationManager.stopUpdatingLocation()
            displayCityForLocation()
            requestWeatherForLocation()
            suggestRoute()
        }
    }
    
    func displayCityForLocation() {
            // Use the last reported location.
        guard let currentLocation = Home.currentLocation else{
                return
            }
            let long = currentLocation.coordinate.longitude
            let lat = currentLocation.coordinate.latitude
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: lat, longitude: long)
            var currentCity = ""
            var currentState = ""
            
            geocoder.reverseGeocodeLocation(location, completionHandler:
                {
                    placemarks, error -> Void in

                    // Place details
                    guard let placeMark = placemarks?.first else { return }

                    // city
                    if (placeMark.locality != nil) {
                        print(currentCity)
                        currentCity = placeMark.locality ?? ""
                    }
                    // state
                    if (placeMark.administrativeArea != nil){
                        currentState = placeMark.administrativeArea ?? ""
                    }
                    
                    self.city.text = currentCity+", "+currentState
                    
            })
            
        
    }
    
    func requestWeatherForLocation(){
        // api request for weather parameters given current location
        guard let currentLocation = Home.currentLocation else{
            return
        }
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        print("\(long) | \(lat)")
        
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&units=imperial&appid=64611f4ad8a75ee7950a4befef783919")!
       
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
           // This will run when the network request returns
           if let error = error {
              print(error.localizedDescription)
           } else if let data = data {
            let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            print(data)
            let main = dataDictionary["main"] as! [String:Any]
            let temp = main["temp"] as! NSNumber
            print(temp)
            let sumObj = dataDictionary["weather"] as! NSArray
            let summary = sumObj[0] as! NSDictionary
            let description = summary["description"] as! String
            print(description)

            self.temperature.text = temp.stringValue+"°F"
            self.weatherSummary.text = description

           }
        }
        task.resume()
        
    }
    
    
    func displayRoutes(){
         //display highest scored run on map
         let sourceCoordinates = self.suggestedRoute["source"]! as CLLocationCoordinate2D
         let destCoordinates = self.suggestedRoute["dest"]! as CLLocationCoordinate2D

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
//             self.map.setRegion(MKCoordinateRegion(route.polyline.boundingMapRect), animated: true)
             self.map.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), animated: true)
            self.startRunBtn.isHidden = false
            self.startRunBtn.isEnabled = true



         }

     }
    
    @IBAction func startRun(_ sender: Any) {
        let runStatusPage = self.storyboard?.instantiateViewController(identifier: "RunStatus" ) as! RunStatus
        runStatusPage.route = self.selectedRoute
        runStatusPage.routeName = selectedRoute.routeName
        runStatusPage.routeDist = selectedRoute.distance

        self.navigationController?.pushViewController(runStatusPage, animated: true)

       /* var route = PFObject(className: "Route")
        let query = PFQuery(className: "Route")
        query.whereKey("routeName", equalTo: self.routeName)
        query.findObjectsInBackground{ (routes:[PFObject]?, error: Error?)
            in
            if error != nil {
                print(error!)
                return
            }
            else if let routes = routes{
                for r in routes{
                    let s = Route(stravaDataId: r["stravaDataId"] as! Int, routeName: self.routeName, startLat: r["startLat"] as! Double, startLng: r["startLng"] as! Double, endLat: r["endLat"] as! Double, endLng: r["endLng"] as! Double, distance: r["distance"] as! Double)
                    self.selectedRoute =
                    let runStatusPage = self.storyboard?.instantiateViewController(identifier: "RunStatus" ) as! RunStatus
                    runStatusPage.route = selectedRoute
                    runStatusPage.routeName = self.routeName
                    runStatusPage.routeDist = ()
                }
                
            }
        }*/
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.lineWidth = 10
        render.strokeColor = .blue
        return render
    }
    
    func suggestRoute(){
        // fetch current user's highest scored run from database
        let query = PFQuery(className:"Ranking")
        query.whereKey("user", equalTo: PFUser.current())
        query.whereKey("liked", equalTo: true)
        query.order(byDescending: "score")
        query.findObjectsInBackground { [self] (objects: [PFObject]?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let objects = objects {
                //if user has no past runs, display error message 
                if objects.count == 0 {
                    self.basisLabel.text = "No past runs. Checkout a new run to get started ! :)"
                    self.suggestedRouteNameLabel.isHidden = true
                    self.suggestedRouteDistanceLabel.isHidden = true
                    self.startRunBtn.isHidden = true
                    self.startRunBtn.isEnabled = false
                }
                else{
                    let object = objects[0]
                    let bestRoute = object["route"] as? PFObject
                    do {
                        try bestRoute!.fetchIfNeeded()
                    } catch _ {
                       print("There was an error ):")
                    }
                    let stravaID = bestRoute!["stravaDataId"] as! Int
                    let sourceLat = bestRoute!["startLat"] as! Double
                    let sourceLng = bestRoute!["startLng"] as! Double
                    let destLat = bestRoute!["endLat"] as! Double
                    let destLong = bestRoute!["endLng"] as! Double
                    let name = bestRoute!["routeName"] as! String
                    let distance = bestRoute!["distance"] as! Double
                    let sourceCoordinates = CLLocationCoordinate2D(latitude: sourceLat,longitude: sourceLng)
                    let destCoordinates = CLLocationCoordinate2D(latitude: destLat,longitude: destLong)
                    self.suggestedRoute["source"] = sourceCoordinates
                    self.suggestedRoute["dest"] = destCoordinates
                    //save routeName

                    //save route
                    self.selectedRoute = Route(stravaDataId: stravaID, routeName: name, startLat: sourceLat, startLng: sourceLng, endLat: destLat, endLng: destLong, distance: distance)
                    
                    //display name and distance labels
                    self.suggestedRouteNameLabel.text = name
                    self.suggestedRouteDistanceLabel.text = String(
                        format: "%.2f miles", distance / 1000 * 0.621371)
                    self.startRunBtn.isHidden = false
                    

                    // display retrived route on map
                    self.displayRoutes()
                }
                
                

                }
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



