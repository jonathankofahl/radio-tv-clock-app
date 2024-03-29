//
//  SettingsViewControllerTableViewController.swift
//  Flippy Clock Radio
//
//  Created by Jonathan Kofahl on 15.07.20.
//  Copyright © 2020 JonathanKofahl. All rights reserved.
//
// SettingsViewController to store some persistent user settings

import UIKit
import AVFoundation
import UserNotifications

class SettingsViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - OUTLETS
    @IBOutlet weak var dateSwitch: UISwitch!
    @IBOutlet weak var displaySwitch: UISwitch!
    @IBOutlet weak var radioNameLabel1: UITextField!
    @IBOutlet weak var radioNameLabel2: UITextField!
    @IBOutlet weak var radioNameLabel3: UITextField!
    @IBOutlet weak var radioLinkLabel1: UITextField!
    @IBOutlet weak var radioLinkLabel2: UITextField!
    @IBOutlet weak var radioLinkLabel3: UITextField!
    
    //MARK: - STANDARD FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///Load values from UserDefaults
        /// Clock Format
        var bool = UserDefaults.standard.bool(forKey: "clockDate")
        dateSwitch.isOn = bool
        
        /// Display Mode
        bool = UserDefaults.standard.bool(forKey: "displayMode")
        displaySwitch.isOn = bool
        
        
        /// init Radio Streams
        if (UserDefaults.standard.object(forKey: "radioLink0") != nil) {
            self.radioLinkLabel1.text = UserDefaults.standard.string(forKey: "radioLink0")
        }
        if (UserDefaults.standard.object(forKey: "radioLink1") != nil) {
            self.radioLinkLabel2.text = UserDefaults.standard.string(forKey: "radioLink1")
        }
        if (UserDefaults.standard.object(forKey: "radioLink2") != nil) {
            self.radioLinkLabel3.text = UserDefaults.standard.string(forKey: "radioLink2")
        }
        
        /// init Radio Names
        if (UserDefaults.standard.object(forKey: "radioName0") != nil) {
            self.radioNameLabel1.text = UserDefaults.standard.string(forKey: "radioName0")
        }
        if (UserDefaults.standard.object(forKey: "radioName1") != nil) {
            self.radioNameLabel2.text = UserDefaults.standard.string(forKey: "radioName1")
        }
        if (UserDefaults.standard.object(forKey: "radioName2") != nil) {
            self.radioNameLabel3.text = UserDefaults.standard.string(forKey: "radioName2")
        }
        
        
    }
    
    //MARK: - CUSTOM FUNCTIONS
    
    @IBAction func changeRadioName(_ sender: UITextField) {
        UserDefaults.standard.set(sender.text, forKey: "radioName"+sender.tag.description)
        
        if sender.text?.count == 0 {
            UserDefaults.standard.set("Radio " + sender.tag.description, forKey: "radioName"+sender.tag.description)
        }
    }
    
    @IBAction func changeRadioLink(_ sender: UITextField) {
        if sender.text!.count < 6 {
            return
        }
        let index = sender.text!.index(sender.text!.startIndex, offsetBy: 5)
        let mySubstring = sender.text![index...]
        let link = "https" + mySubstring
        let trimmed = link.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaults.standard.set(trimmed, forKey: "radioLink"+sender.tag.description)
    }
    
    @IBAction func openImages(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .popover
        let presentationController = imagePicker.popoverPresentationController
        presentationController?.sourceView = sender
        self.present(imagePicker, animated: true) {}
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let fileName = "image.png"
            saveImage(imageName: fileName, image: pickedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeDateFormat(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "clockDate")
        NotificationCenter.default.post(name: .init("update"), object: nil)
    }
    
    @IBAction func changeFontColor(_ sender: UIButton) {
        UserDefaults.standard.set(sender.backgroundColor?.components.red, forKey: "fontColorRed")
        UserDefaults.standard.set(sender.backgroundColor?.components.green, forKey: "fontColorGreen")
        UserDefaults.standard.set(sender.backgroundColor?.components.blue, forKey: "fontColorBlue")
        UserDefaults.standard.set(sender.backgroundColor?.components.alpha, forKey: "fontColorAlpha")
        NotificationCenter.default.post(name: .init("update"), object: nil)
    }
    
    @IBAction func changeDisplayMode(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "displayMode")
    }
    
    @IBAction func saveSettings(_ sender: Any) {
        NotificationCenter.default.post(name: .init("update"), object: nil)
        self.dismiss(animated: true, completion: {})
    }
    
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .white
        }
    }
    
    //MARK: - helper Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}
