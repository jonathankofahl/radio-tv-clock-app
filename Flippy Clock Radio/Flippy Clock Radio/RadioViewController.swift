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
    @IBOutlet weak var playButton1: UIButton!
    @IBOutlet weak var playButton2: UIButton!
    @IBOutlet weak var playButton3: UIButton!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var clock: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    
    //MARK: - VARIABLES
    var clockTimer: Timer?
    var displayTimer: Timer?
    var shouldSleep: Bool = true
    var dateFormat: Bool = true
    var player : AVPlayer?
    var isPlaying: Bool = false
    var radioURL1: String?
    var radioURL2: String?
    var radioURL3: String?
    var activeRadioTag: Int?
    var volume: Float = 0.5
    var buttons: [UIButton] = []
    var playButtons: [UIButton] = []
    
    override func viewWillAppear(_ animated: Bool) {
        updateView()
        self.showTime()
        
        buttons = [button1, button2, button3]
        playButtons = [playButton1, playButton2, playButton3]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// refreseh clock
        self.clockTimer =  Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.showTime), userInfo: nil, repeats: true)
        
        //register Observer
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: .init("update"), object: nil)
        
        if (UserDefaults.standard.object(forKey: "fontColorRed") == nil) {
            UserDefaults.standard.set(0, forKey: "fontColorRed")
                        UserDefaults.standard.set(0, forKey: "fontColorGreen")
                        UserDefaults.standard.set(0, forKey: "fontColorBlue")
                        UserDefaults.standard.set(1, forKey: "fontColorAlpha")
        }
        
    }
    
    @objc func updateView() -> Void {
        /// Clock Format
        let format = UserDefaults.standard.bool(forKey: "clockDate")
        dateFormat = format
        
        /// Clock Color
        self.clock!.textColor = UIColor(red: CGFloat(UserDefaults.standard.double(forKey: "fontColorRed")), green: CGFloat(UserDefaults.standard.double(forKey: "fontColorGreen")), blue: CGFloat(UserDefaults.standard.double(forKey: "fontColorBlue")), alpha: CGFloat(UserDefaults.standard.double(forKey: "fontColorAlpha")))
        
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
        
        ///set displayMode
        if (UserDefaults.standard.object(forKey: "displayMode") != nil) {
                  self.shouldSleep = UserDefaults.standard.bool(forKey: "displayMode")
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
            self.sliderView.isHidden = false
            self.settingsButton.isHidden = false
            wakeUpDisplay()
            return
        }
        
        self.buttonView.isHidden = true
        self.sliderView.isHidden = true
        self.settingsButton.isHidden = true
        wakeUpDisplay()
        
    }
    
    
    @objc func wakeUpDisplay() -> Void {
        UIScreen.main.brightness = CGFloat(0.5)
        self.displayTimer?.invalidate()
        self.displayTimer =  Timer.scheduledTimer(timeInterval: 3600.0, target: self, selector: #selector(self.dimDisplay), userInfo: nil, repeats: true)
    }
    
    @objc func dimDisplay() -> Void {
        if shouldSleep {
            UIScreen.main.brightness = CGFloat(0.0)
        }
    }
    
    
    //MARK: Radio Methods
    @IBAction func playMedia(_ sender: UIButton) {
        
        hintLabel.isHidden = true
        
        ///stop radio
        if activeRadioTag == sender.tag {
            activeRadioTag = nil
            buttons[sender.tag].setTitleColor(UIColor.white, for: UIControl.State.normal)
            playButtons[sender.tag].setImage(#imageLiteral(resourceName: "playImage"), for: UIControl.State.normal)
            self.player?.pause()
            self.imageView.layer.sublayers = []
            return
        }
        
        var savedURL: String?
        switch sender.tag {
        case 0:
            savedURL = self.radioURL1
        case 1:
            savedURL = self.radioURL2
        case 2:
            savedURL = self.radioURL3
        default:
            break
        }
        
        button1.setTitleColor(UIColor.white, for: UIControl.State.normal)
            button2.setTitleColor(UIColor.white, for: UIControl.State.normal)
            button3.setTitleColor(UIColor.white, for: UIControl.State.normal)
            playButton1.setImage(#imageLiteral(resourceName: "playImage"), for: UIControl.State.normal)
            playButton2.setImage(#imageLiteral(resourceName: "playImage"), for: UIControl.State.normal)
            playButton3.setImage(#imageLiteral(resourceName: "playImage"), for: UIControl.State.normal)
        
        /// handle invalid URL
        guard let url = URL.init(string: savedURL ?? "") else {
            buttons[sender.tag].setTitleColor(UIColor.red, for: UIControl.State.normal)
            playButtons[sender.tag].setImage(#imageLiteral(resourceName: "playImage"), for: UIControl.State.normal)
            self.imageView.layer.sublayers = []
            self.hintLabel.isHidden = false
            self.player?.pause()
            return
        }
        
        switch sender.tag {
        case 0:
            button1.setTitleColor(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), for: UIControl.State.normal)
            playButton1.setImage(#imageLiteral(resourceName: "pauseImage"), for: UIControl.State.normal)
            
        case 1:
            button2.setTitleColor(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), for: UIControl.State.normal)
            playButton2.setImage(#imageLiteral(resourceName: "pauseImage"), for: UIControl.State.normal)
            
        case 2:
            button3.setTitleColor(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), for: UIControl.State.normal)
            playButton3.setImage(#imageLiteral(resourceName: "pauseImage"), for: UIControl.State.normal)
            
        default:
            break
        }
        
        self.activeRadioTag = sender.tag
        let playerItem = AVPlayerItem.init(url: url)
        player = AVPlayer.init(playerItem: playerItem)
        self.imageView.layer.sublayers?.removeAll()
        player?.volume = self.volume
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.imageView.bounds
        self.imageView.layer.addSublayer(playerLayer)
        player?.play()
        self.isPlaying = true
        UIView.animate(withDuration: 0.3, animations: ({
            self.slider.alpha = 1.0
        }))
    }
    
    @IBAction func volumeSliderAction(_ sender: UISlider) {
        if isPlaying {
                  self.volume = sender.value
                  MPVolumeView.setVolume(sender.value)
              }    }
    
}

