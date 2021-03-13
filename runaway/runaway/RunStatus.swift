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

class RunStatus: UIViewController, CLLocationManagerDelegate {
    var route = PFObject(className: "Route")
    var routeName = ""
    var routeDist = 0.0
    var counter = 0.0
    var timer = Timer()
    var startTime = NSDate()
    var elapsedTime = 0.0
    var breaks = 0
    var (minutes,seconds,frac)=(0,0,0)
    var parentPage:String!
    // present current weather to the user during their run
    let LocationManager = CLLocationManager()
    
    @IBOutlet weak var temperature: UILabel!
    // separate 00:00 (time) from :00 (frac) to avoid jostling numbers
    @IBOutlet weak var fracLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.stopButton.isEnabled = true
        self.resumeButton.isHidden = true
        requestWeatherForLocation()
        // change timer fonts to monospaced digits to avoid jostling numbers
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 90, weight: UIFont.Weight.regular)
        fracLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 90, weight: UIFont.Weight.regular)
        // update time every 0.01 seconds using the update timer function
        // 0.017 because Swift's Timer() function is not meant to be 100% accurate, and we found that updating at this speed is the closest to an actual millisecond, measured by the apple stopwatch app
        timer = Timer.scheduledTimer(timeInterval: 0.017, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
        timeLabel.text = String(counter)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // Get location so we can call the API to get the weather
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, Home.currentLocation==nil{
            Home.currentLocation = locations.first
            LocationManager.stopUpdatingLocation()
        }
    }
    
    // API call to request weather so we can display the current weather during the run
    
    func requestWeatherForLocation(){
        guard let currentLocation = Home.currentLocation else{
            return
        }
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&units=imperial&appid=64611f4ad8a75ee7950a4befef783919")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
           // This will run when the network request returns
           if let error = error {
              print(error.localizedDescription)
           } else if let data = data {
            let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            let main = dataDictionary["main"] as! [String:Any]
            let temp = main["temp"] as! NSNumber

            self.temperature.text = "currently "+temp.stringValue+"°F"
           }
        }
        task.resume()
    
    }
    
    // Stop the timer and switch to post-run survey page
    
    @IBAction func stopTimer(_ sender: AnyObject) {
        timer.invalidate()
        let endTime = NSDate()
        self.elapsedTime = endTime.timeIntervalSince(self.startTime as Date)
        
        performSegue(withIdentifier: "runComplete", sender: self)
       
    }
    
    // Send data from this page to post survey page to calculate score
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! PostRunSurvey
        vc.breaks = self.breaks
        vc.totaltime = self.elapsedTime
        vc.routeName = self.routeName
        vc.route = self.route
        vc.routeDist = self.routeDist
        vc.parentPage = self.parentPage
    }
    
    //update time and format for user display
    
    @objc func UpdateTimer() {
        frac += 1
        if frac > 60 {
            seconds += 1
            frac = 0
        }
        
        if seconds == 60{
            minutes += 1
            seconds = 0
        }
        
        let secstr = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        let minstr = minutes > 9 ? "\(minutes)" : "0\(minutes)"

        timeLabel.text = "\(minstr) : \(secstr) : "
        fracLabel.text = "\(frac)"
        if frac < 10 {
            fracLabel.text = "0\(frac)"
        } else {
            fracLabel.text = "\(frac)"
        }
    }
    
    // Functionality to pause timer for break
    
    @IBAction func PauseTimer(_ sender: Any) {
        // each time user pauses the timer, it counts as a break
        timer.invalidate()
        breaks += 1
        
        // enable resume button so user can continue after the break
        self.resumeButton.isHidden = false
        self.pauseButton.isHidden = true
        
    }
    
    // Functionality to restart/resume timer after runner takes a break
    
    @IBAction func ResumeTimer(_ sender: Any) {
        // Restart timer from where it was stopped
        self.timer = Timer.scheduledTimer(timeInterval: 0.017, target: self, selector: #selector(RunStatus.UpdateTimer), userInfo: nil, repeats: true)
        self.pauseButton.isHidden = false
        self.resumeButton.isHidden = true

    }
    
}

