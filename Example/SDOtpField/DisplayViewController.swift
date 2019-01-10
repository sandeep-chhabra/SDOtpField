//
//  DisplayViewController.swift
//  SDOtpField
//
//  Created by Sandeep Chhabra on 06/06/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

import SDOtpField

class DisplayViewController: UIViewController,SDOtpFieldDelegate {

    @IBOutlet weak var displayLabel: UILabel!
   
    @IBOutlet weak var otpField: SDOtpField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        otpField.numberOfDigits = 6
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        otpField.becomeFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getResults(_ sender: Any) {
        displayLabel.text = otpField.currentOtp
        otpField.clearOTPText()
        otpField.resignFirstResponder()
    }

}
