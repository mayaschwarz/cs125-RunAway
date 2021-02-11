//
//  StartRun.swift
//  
//
//  Created by Maya Schwarz on 2/10/21.
//

import Foundation
import UIKit
import Parse

class StartRun: UIViewController {
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var inclineSlider: UISlider!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var inclineLabel: UILabel!
    
    @IBAction func distanceSliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
            
        distanceLabel.text = "\(currentValue)"
    }
    
    @IBAction func inclineSliderValueChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
            
        inclineLabel.text = "\(currentValue)"
    }
}
