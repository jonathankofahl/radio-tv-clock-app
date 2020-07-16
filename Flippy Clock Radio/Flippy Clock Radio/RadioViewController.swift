//
//  ViewController.swift
//  Flippy Clock Radio
//
//  Created by Jonathan Kofahl on 15.07.20.
//  Copyright © 2020 JonathanKofahl. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class RadioViewController: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var clock: UILabel!
    
    //MARK: - VARIABLES
    var clockTimer: Timer?
    var dateFormat: Bool = true
    var player : AVPlayer?
    var isPlaying: Bool = false
    var radioURL1: String?
    var radioURL2: String?
    var radioURL3: String?
    var activeRadioTag: Int?
    var volume: Float = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showTime()
        
        /// refreseh clock
        self.clockTimer =  Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.showTime), userInfo: nil, repeats: true)
        
        updateView()
    }
    
    func updateView() -> Void {
        /// Clock Format
        let format = UserDefaults.standard.bool(forKey: "clockDate")
        dateFormat = format
        
        /// Radio Streams
        if (UserDefaults.standard.object(forKey: "radioLink0") != nil) {
            self.radioURL1 = UserDefaults.standard.string(forKey: "radioLink0")
        }
        if (UserDefaults.standard.object(forKey: "radioLink1") != nil) {
            self.radioURL2 = UserDefaults.standard.string(forKey: "radioLink1")
        }
        if (UserDefaults.standard.object(forKey: "radioLink2") != nil) {
            self.radioURL3 = UserDefaults.standard.string(forKey: "radioLink2")
        }
        /// init Radio Names
        if (UserDefaults.standard.object(forKey: "radioName0") != nil) {
            self.button1.setTitle(UserDefaults.standard.string(forKey: "radioName0"), for: UIControl.State.normal)
        }
        if (UserDefaults.standard.object(forKey: "radioName1") != nil) {
            self.button2.setTitle(UserDefaults.standard.string(forKey: "radioName1"), for: UIControl.State.normal)
        }
        if (UserDefaults.standard.object(forKey: "radioName2") != nil) {
            self.button3.setTitle(UserDefaults.standard.string(forKey: "radioName2"), for: UIControl.State.normal)
        }
        
        ///set BackgroundImage
        self.imageView.image = loadImageFromDiskWith(fileName: "image.png") ?? UIImage(named: "sample_background")
    }
    
    //MARK: - Methods
    @objc func showTime() -> Void {
        /// get the current date and time
        let currentDateTime = Date()
        /// initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        if !dateFormat {
            formatter.dateStyle = .none
        }
        self.clock!.text = formatter.string(from: currentDateTime)
    }
    
    @IBAction func tapPiece(_ gestureRecognizer : UITapGestureRecognizer ) {
        guard gestureRecognizer.view != nil else { return }
        if self.buttonView.isHidden {
            self.buttonView.isHidden = false
            self.slider.isHidden = false
            self.settingsButton.isHidden = false
            return
        }
        
        self.buttonView.isHidden = true
        self.slider.isHidden = true
        self.settingsButton.isHidden = true
    }
    
    
    //MARK: Radio Methods
    @IBAction func playMedia(_ sender: UIButton) {
        
        ///check if button is acitve
        if activeRadioTag == sender.tag {
            activeRadioTag = nil
            self.player?.pause()
        }
        
        guard let url = URL.init(string: self.radioURL1 ?? "") else {
            UIView.animate(withDuration: 0.2, animations: ({
                sender.titleLabel?.textColor = UIColor.red
            }))
            return
        }
        self.activeRadioTag = sender.tag
        let playerItem = AVPlayerItem.init(url: url)
        player = AVPlayer.init(playerItem: playerItem)
        self.imageView.layer.sublayers?.removeAll()
        player?.volume = self.volume
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.imageView.bounds
        if (UserDefaults.standard.object(forKey: "videoSetting1") != nil) {
            if (UserDefaults.standard.bool(forKey: "videoSetting1")) {
                playerLayer.backgroundColor = UIColor.black.cgColor
                self.imageView.layer.addSublayer(playerLayer)
            }
        }
        player?.play()
        self.isPlaying = true
        UIView.animate(withDuration: 0.3, animations: ({
            self.slider.alpha = 1.0
        }))
    }
    
    
    @IBAction func volumeSliderAction(_ sender: UISlider) {
        self.player?.volume = sender.value
    }
    
    
    
}

