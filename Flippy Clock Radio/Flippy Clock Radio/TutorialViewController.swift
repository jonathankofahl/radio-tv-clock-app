//
//  TutorialViewController.swift
//  Flippy Clock Radio
//
//  Created by Jonathan Kofahl on 22.07.20.
//  Copyright © 2020 JonathanKofahl. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation

    @IBAction func endTutorial(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }

}
