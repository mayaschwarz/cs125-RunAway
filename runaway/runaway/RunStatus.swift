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
    var counter = 0.0
    var timer = Timer()
    var isPlaying = true
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pauseButton.isEnabled = true
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
        isPlaying = true
        timeLabel.text = String(counter)
    }
        
    @IBAction func pauseTimer(_ sender: AnyObject) {
        pauseButton.isEnabled = false
            
        timer.invalidate()
        isPlaying = false
    }
    
    @objc func UpdateTimer() {
        counter = counter + 0.1
        timeLabel.text = String(format: "%.1f", counter)
    }
}

