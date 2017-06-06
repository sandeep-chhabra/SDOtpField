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
        otpField.reloadFields()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func getResults(_ sender: Any) {
        displayLabel.text = otpField.currentOtp
    }
    
    
    //MARK : - SDOtpFieldDelegate
    func otpField(field: UIControl, didEnter otp: String) {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
