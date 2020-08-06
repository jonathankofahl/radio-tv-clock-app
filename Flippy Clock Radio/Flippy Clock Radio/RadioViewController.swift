//
//  ViewController.swift
//  Flippy Clock Radio
//
//  Created by Jonathan Kofahl on 15.07.20.
//  Copyright © 2020 JonathanKofahl. All rights reserved.
//
// Main ViewController with the Player 

import UIKit
import AVFoundation
import MediaPlayer

class RadioViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: - OUTLETS
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonView: UICollectionView!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var clock: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var collectionViewHeightConstaint: NSLayoutConstraint!
    
    //MARK: - VARIABLES
    var clockTimer: Timer?
    var displayTimer: Timer?
    var shouldSleep: Bool = true
    var dateFormat: Bool = true
    var isPlaying: Bool = false
    var player : AVPlayer?
    var playerLayer : AVPlayerLayer?
    
    /// instantiate a singleton MPVolumeView used everytime the user change the system-volume
    let volumeView = MPVolumeView()
    var radioURL1: String?
    var radioURL2: String?
    var radioURL3: String?
    var activeRadioTag: Int?
    
    override func viewWillAppear(_ animated: Bool) {
        if activeRadioTag != nil {
            resetPlayer(shouldPause: true)
        }
        
        //cells = []
        buttonView.reloadData()
        buttonView.isUserInteractionEnabled = true
        buttonView.delegate = self
        buttonView.dataSource = self
        showTime()
        updateView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        /// show tutorial at first app start
        if (UserDefaults.standard.bool(forKey: "tutorialShown") != true) {
            DispatchQueue.main.async(){
                self.performSegue(withIdentifier: "tutorial", sender: self)
            }
            UserDefaults.standard.set(true, forKey: "tutorialShown")
        }
        
        /// refreseh clock
        clockTimer =  Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.showTime), userInfo: nil, repeats: true)
        
        /// register Observer
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: .init("update"), object: nil)
        
        /// init color values
        if (UserDefaults.standard.object(forKey: "fontColorRed") == nil) {
            UserDefaults.standard.set(0, forKey: "fontColorRed")
            UserDefaults.standard.set(0, forKey: "fontColorGreen")
            UserDefaults.standard.set(0, forKey: "fontColorBlue")
            UserDefaults.standard.set(1, forKey: "fontColorAlpha")
        }
        
        /// register system media controls
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            //Update your button here for the pause command
            self.playMedia(self.activeRadioTag!)
            return .success
        }
        
        commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            //Update your button here for the play command
            self.playMedia(UserDefaults.standard.integer(forKey: "lastPlayedRadio"))
            self.activeRadioTag = UserDefaults.standard.integer(forKey: "lastPlayedRadio")
            return .success
        }
        
        /// playback options with iOS 8,9 fallback
        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay])
            } else {
                // Fallback on earlier versions without AirPlay
                try AVAudioSession.sharedInstance().setCategory(.playback)
            }
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
    }
    
    @objc func updateView() -> Void {
        /// Clock Format
        let format = UserDefaults.standard.bool(forKey: "clockDate")
        dateFormat = format
        
        /// Clock Color
        clock!.textColor = UIColor(red: CGFloat(UserDefaults.standard.double(forKey: "fontColorRed")), green: CGFloat(UserDefaults.standard.double(forKey: "fontColorGreen")), blue: CGFloat(UserDefaults.standard.double(forKey: "fontColorBlue")), alpha: CGFloat(UserDefaults.standard.double(forKey: "fontColorAlpha")))
        
        /// Radio Streams
        if (UserDefaults.standard.object(forKey: "radioLink0") != nil) {
            radioURL1 = UserDefaults.standard.string(forKey: "radioLink0")
        }
        if (UserDefaults.standard.object(forKey: "radioLink1") != nil) {
            radioURL2 = UserDefaults.standard.string(forKey: "radioLink1")
        }
        if (UserDefaults.standard.object(forKey: "radioLink2") != nil) {
            radioURL3 = UserDefaults.standard.string(forKey: "radioLink2")
        }
        
        
        ///set displayMode
        if (UserDefaults.standard.object(forKey: "displayMode") != nil) {
            shouldSleep = UserDefaults.standard.bool(forKey: "displayMode")
        }
        
        ///set BackgroundImage
        imageView.image = loadImageFromDiskWith(fileName: "image.png") ?? UIImage(named: "sample_background")
        
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
        clock!.text = formatter.string(from: currentDateTime)
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
    
    @IBAction func showSettings(_ sender: Any) {
        self.hintLabel.isHidden = true
        self.performSegue(withIdentifier: "showSettings", sender: self)
    }
    
    
    //MARK: Radio Methods
    func resetPlayer(shouldPause: Bool) -> Void {
        if shouldPause {
            player?.pause()
            self.activeRadioTag = nil
        }
        
        /* if cells.count > 5 {
         cells[0].labelButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
         cells[1].labelButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
         cells[2].labelButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
         cells[0].playButton.setImage(#imageLiteral(resourceName: "playImage"), for: UIControl.State.normal)
         cells[1].playButton.setImage(#imageLiteral(resourceName: "playImage"), for: UIControl.State.normal)
         cells[2].playButton.setImage(#imageLiteral(resourceName: "playImage"), for: UIControl.State.normal)
         }*/
        
    }
    
    @IBAction func playMedia(_ sender: Int) {
        
        let cell = buttonView.visibleCells[sender] as! RadioButtonCollectionViewCell
        
        
        hintLabel.isHidden = true
        ///stop radio
        if activeRadioTag == sender {
            activeRadioTag = nil
            
            
            self.player?.pause()
            self.imageView.layer.sublayers = []
            return
        }
        
        var savedURL: String?
        switch sender {
        case 0:
            savedURL = self.radioURL1
        case 1:
            savedURL = self.radioURL2
        case 2:
            savedURL = self.radioURL3
        default:
            break
        }
        
        
        /// handle invalid URL
        guard let url = URL.init(string: savedURL ?? "") else {
            cell.labelButton.setTitleColor(UIColor.red, for: UIControl.State.normal)
            cell.playButton.setImage(#imageLiteral(resourceName: "playImage"), for: UIControl.State.normal)
            self.imageView.layer.sublayers = []
            self.hintLabel.isHidden = false
            self.player?.pause()
            return
        }
        
        resetPlayer(shouldPause: true)
        
        cell.labelButton.setTitleColor(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), for: UIControl.State.normal)
        cell.playButton.setImage(#imageLiteral(resourceName: "pauseImage"), for: UIControl.State.normal)
        
        activeRadioTag = sender
        
        let playerItem = AVPlayerItem.init(url: url)
        player = AVPlayer.init(playerItem: playerItem)
        
        imageView.layer.sublayers?.removeAll()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = self.imageView.bounds
        imageView.layer.addSublayer(playerLayer!)
        player?.play()
        isPlaying = true
        UserDefaults.standard.set(sender, forKey: "lastPlayedRadio")
        
    }
    
    @IBAction func volumeSliderAction(_ sender: UISlider) {
        if isPlaying {
            MPVolumeView.setVolume(sender.value, volumeView: volumeView)
        }    }
    
    
    
    //MARK: - CollectionView Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Button_0", for: indexPath) as! RadioButtonCollectionViewCell
        
        cell.contentView.isUserInteractionEnabled = false
        
        print("create cell: " + indexPath.item.description)
        
        /// refresh values and states of buttons and images
        cell.playButton.setImage(#imageLiteral(resourceName: "playImage"), for: UIControl.State.normal)
        cell.labelButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: UIControl.State.normal)
        
        
        switch indexPath.item {
        case 0:
            cell.labelButton.setTitle("Radio 1", for: UIControl.State.normal)
            if (UserDefaults.standard.object(forKey: "radioName0") != nil) {
                cell.labelButton.setTitle(UserDefaults.standard.string(forKey: "radioName0"), for: UIControl.State.normal)
            }
            cell.labelButton.tag = 0
            cell.playButton.tag = 0
        case 1:
            cell.labelButton.setTitle("Radio 2", for: UIControl.State.normal)
            
            if (UserDefaults.standard.object(forKey: "radioName1") != nil) {
                cell.labelButton.setTitle(UserDefaults.standard.string(forKey: "radioName1"), for: UIControl.State.normal)
            }
            cell.labelButton.tag = 1
            cell.playButton.tag = 1
        case 2:
            cell.labelButton.setTitle("Radio 3", for: UIControl.State.normal)
            
            if (UserDefaults.standard.object(forKey: "radioName2") != nil) {
                cell.labelButton.setTitle(UserDefaults.standard.string(forKey: "radioName2"), for: UIControl.State.normal)
            }
            cell.labelButton.tag = 2
            cell.playButton.tag = 2
        default:
            return cell
        }
        
        if activeRadioTag != nil && activeRadioTag == indexPath.item {
            cell.playButton.setImage(#imageLiteral(resourceName: "pauseImage"), for: UIControl.State.normal)
            cell.labelButton.setTitleColor(#colorLiteral(red: 0.3846494967, green: 0.7928894353, blue: 0.3790125482, alpha: 1), for: UIControl.State.normal)
            print("updated cell " + indexPath.item.description)
            print(buttonView.visibleCells.count)
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.buttonView.bounds.size.width<600 {
            return CGSize(width:300, height:70)
        }
        return CGSize(width:self.buttonView.bounds.size.width/3, height:70)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell =  collectionView.visibleCells[indexPath.item] as! RadioButtonCollectionViewCell
        cell.labelButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        cell.playButton.setImage(#imageLiteral(resourceName: "playImage"), for: UIControl.State.normal)
        self.playMedia(indexPath.item)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    //MARK: - Transition Methods
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        buttonView.reloadData()
        buttonView.layoutIfNeeded()
        resetPlayer(shouldPause: false)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if activeRadioTag != nil {
            playerLayer!.frame = self.imageView.bounds
        }
        buttonView.reloadData()
        
    }
    
}

//MARK: - CollectionViewCell Class
class RadioButtonCollectionViewCell: UICollectionViewCell {
    @IBOutlet var playButton: UIButton!
    @IBOutlet var labelButton: UIButton!
}
