//
//  Congrats.swift
//  runaway
//
//  Created by Maya Schwarz on 2/24/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import UIKit
import SAConfettiView


class Congrats: UIViewController {
    @IBOutlet weak var motivationalPhrase: UILabel!
    let motivationalPhrasesBank = ["\"Don’t be afraid of failure. This is the way to succeed.\"- LeBron James", "\"It’s going to be a journey. It’s not a sprint to get in shape.\" —Kerri Walsh Jennings", "\"Champions keep playing until they get it right\" – Billie Jean King", "\"Nobody who ever gave his best regretted it.\" – George Halas", "\"Nothing, not even pain, lasts forever.\" - Kim Cowart", "\"There will come a day when I can no longer run. Today is not that day.\" - Unknown", "\"Pain is the body's way of ridding itself of weakness.\" - Dean Karnazes", "\"I don’t run to add days to my life, I run to add life to my days.\" – Ronald Rook", "\"If it doesn’t challenge you, it won’t change you.\" – Fred DeVito", "\"The man who moves a mountain begins by carrying away small stones.\" – Confucius",]

    override func viewDidLoad() {
        super.viewDidLoad()
        let confettiView = SAConfettiView(frame: self.view.bounds)
        self.view.addSubview(confettiView)
        confettiView.intensity = 0.8
        confettiView.startConfetti()
        confettiView.isUserInteractionEnabled = false
        
        let randomNumber = Int.random(in: 0...motivationalPhrasesBank.count) - 1
        motivationalPhrase.text = motivationalPhrasesBank[randomNumber]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func leaveButton(_ sender: Any) {
        print("leaving")
        //let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tab_control=storyboard?.instantiateViewController(identifier: "myTabBar") as! myTabBar
        self.present(tab_control, animated: true, completion:nil)
    }
    
    @IBAction func returnHome(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        let resetStartRun = self.navigationController?.topViewController as! StartRun
        resetStartRun.distanceSlider.setValue(0.0, animated: false)
        resetStartRun.distanceSliderValueChanged(resetStartRun.distanceSlider)
        resetStartRun.distanceSliderValueChosen(resetStartRun.distanceSlider)
    }
    
    
}
