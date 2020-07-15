//
//  ViewController.swift
//  Flippy Clock Radio
//
//  Created by Jonathan Kofahl on 15.07.20.
//  Copyright © 2020 JonathanKofahl. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - OUTLETS
       @IBOutlet weak var imageView: UIImageView!
       @IBOutlet weak var buttonView: UIView!
       @IBOutlet weak var offButton: UIButton!
       @IBOutlet weak var button1: UIButton!
       @IBOutlet weak var button2: UIButton!
       @IBOutlet weak var button3: UIButton!
       @IBOutlet weak var radioLabel1: UILabel!
       @IBOutlet weak var radioLabel2: UILabel!
       @IBOutlet weak var radioLabel3: UILabel!
       @IBOutlet weak var slider: UISlider!
       @IBOutlet weak var labelVolume: UILabel!
       @IBOutlet weak var settingsButton: UIButton!
       @IBOutlet weak var clock: UILabel!
    
    //MARK: - VARIABLES
    var clocktimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        showTime()
        
        self.clocktimer =  Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.showTime), userInfo: nil, repeats: true)

    }

    //MARK: - Methods
    @objc func showTime() -> Void {
        // get the current date and time
        let currentDateTime = Date()
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        self.clock!.text = formatter.string(from: currentDateTime)
    }
    
    
    
    
    
}

