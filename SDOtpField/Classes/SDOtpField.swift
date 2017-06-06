//
//  SDOtpField.swift
//
//  Created by Sandeep Chhabra on 20/02/17.
//  Copyright © 2017 Sandeep Chhabra. All rights reserved.
//

import UIKit

class SDTextField: UITextField {
    override func deleteBackward() {
        super.deleteBackward()
        self.sendActions(for: .valueChanged)
    }
}

@objc public protocol SDOtpFieldDelegate : class {
  @objc optional   func otpField(field:UIControl , didEnter otp:String) -> Void
}


@objc public enum FieldShape:Int {
    case square
    case round
}

public class SDOtpField: UIControl,UITextFieldDelegate {

//let lock = NSLock()

    
//TODO: selected back ground color, border color
//TODO: CHECK PROPERTIES DO NOT OVERRIDE - ADD TEXT FIELDS AFTER PARENT VIEW DID LOAD ?
//TODO: Add method to set text and reset last text on reload

 public   var currentOtp:String {
        get{
            var str = ""
            
            for n in 1...numberOfDigits{
                if let txtField = self.viewWithTag(220+n) as! UITextField?{
                    str.append((txtField.text != nil) ? txtField.text! : "")
                }
            }
            return str
        }
    }
    
 public   var numberOfDigits = 6
 public   var fieldMargin:CGFloat = 5
 public   var fieldCornerRadius:CGFloat = 0//8
 public   var fieldHeight:CGFloat = 0
  public  var fieldWidth:CGFloat = 0
    
  public  var fieldBackgroundColor : UIColor = UIColor.white
//    var selectedBackgroundColor : UIColor = UIColor.gray

  public  var fieldBorderColor = UIColor.lightGray
    
  public  var fieldKeyboardType = UIKeyboardType.numberPad
    
 public  weak var delegate:SDOtpFieldDelegate?
    
 public   var allowsSelection : Bool = false
    
 public   var fieldsAdjustHeightToFit = false
    
 public   var fieldShape : FieldShape = .square
    
 public   var secureTextEnabled = false
    
 public   var fieldFont = UIFont.systemFont(ofSize: 15)
    
 public   var fieldTextColor = UIColor.black
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
  public  override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addTarget(self, action: #selector(touch), for: .touchUpInside)
        
        //NEED LOCK MECHANISAM IN ADD TEXTFIELDS AS 2 LAYERS OF TEXT FIELD CAN BE ADDED IF reloadTextfields() WITHOUT ASYNC IN IT is called from view did load of containing view controller
        
//        lock.name = "SDOTPField : Add textfields"
//        DispatchQueue.main.async {
//            self.addTetxFields()
//        }
        
    }
    
//MARK: Setup Views
    private func addTetxFields() -> Void {
        
        //LOCK NOT WORKING
//        lock.lock()
        
        fieldWidth = (self.frame.size.width + fieldMargin)/CGFloat(numberOfDigits) - fieldMargin

        fieldHeight = fieldsAdjustHeightToFit ? self.frame.size.height : fieldWidth
        
        for n in 1...numberOfDigits{
            
            let textField = SDTextField.init()
            textField.delegate = self
            
            textField.frame = CGRect.init(x:(CGFloat(n-1)*fieldWidth)+(fieldMargin*CGFloat(n-1)) , y:0 , width:fieldWidth, height:fieldHeight )
            
            textField.center.y = self.convert(self.center, from: self.superview).y
            textField.tag = 220+n
            textField.backgroundColor = fieldBackgroundColor
            if allowsSelection == false {
                textField.isEnabled = (n == 1 ? true : false)
            }
            
            textField.textAlignment = NSTextAlignment.center
            textField.layer.masksToBounds = true
            textField.layer.cornerRadius = (fieldShape == .round) ? fieldWidth/2 : fieldCornerRadius
            textField.borderStyle = .roundedRect
            textField.layer.borderColor = fieldBorderColor.cgColor
            textField.layer.borderWidth = 1
            textField.keyboardType = fieldKeyboardType
            textField.isSecureTextEntry = secureTextEnabled
            textField.font = fieldFont
            textField.textColor = fieldTextColor
            
            textField.addTarget(self, action: #selector(txtFieldValueChnged(sender:)), for: .valueChanged)
            self.addSubview(textField)
        }
//        lock.unlock()
    }
    
    
//MARK: Method to reload contents
 public   func reloadFields() -> Void {
        
        DispatchQueue.main.async {
            for  vu in self.subviews{
                vu.removeFromSuperview()
            }
            self.addTetxFields()
        }
    }
    
    
//MARK: TOUCH EVENT
    @objc private func touch() -> Void {
        self.edit(shouldEdit: true)
    }
    
    func edit(shouldEdit:Bool) -> Void {
        
        let otp = currentOtp
        var selectTag = 1
        
        if otp.characters.count > 0{
            selectTag = (otp.characters.count + 1 <= numberOfDigits) ? otp.characters.count + 1 : otp.characters.count
        }
        
        if shouldEdit{
            if let vu = self.viewWithTag(220 + selectTag) as! UITextField?{
                vu.isEnabled = true
                if !vu.isFirstResponder {
                    vu.becomeFirstResponder()
                }
            }
        }
        else{
            self.endEditing(true)
        }
        
    }
    
    
//MARK: Clear text
 public func clearOTPText() -> Void {
        for n in 1...numberOfDigits{
            let txtFld = self.viewWithTag(220+n) as! UITextField?
            txtFld?.text = ""
        }
//        self.touch()
    }
    
    
//MARK: UITextFieldDelegate
   public func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        NSLog("textfield end editing")
    }
    
   public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
   public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        NSLog("textfield should clear")
        return true
    }
    
   public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
       // let replacedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""

        if string == " "{
            return false
        }
        
        let str = textField.text ?? ""
        
        let startIn = str.index(str.startIndex, offsetBy: range.location)
        let endIn = str.index(startIn, offsetBy: range.length)
        
        let resultStr = str.replacingCharacters(in:Range(startIn..<endIn) , with: string)
       

        switch (str.characters.count , resultStr.characters.count )
        {
            //User enters text when SELECTED textfield is already full THEN REPLACE TEXT : IN CASE OF ALLOWS SELECTION VAR
            case let(count,resultCount) where count == 1 && resultCount > 1 :
            
                if string.characters.count == 1{
                    textField.text = string
                    let resp = self.viewWithTag(textField.tag + 1 )
                    if resp != nil{
                        resp?.becomeFirstResponder()
                        self.sendActions(for: .valueChanged)
                    }
                    else{
                        textField.endEditing(true)
                        //send call back
                        if let del = self.delegate{
                            del.otpField?(field: self, didEnter: currentOtp)
                        }
                    }
                }
                break
            
          //Deletes a text
            case let(count,resultCount) where count == 1 && resultCount == 0 :
                NSLog("OTPField : Deletes a text current str : \(str) , result str : \(resultStr)")

                    textField.text = resultStr
//                    textField.isEnabled = self.allowsSelection
//                
//                let nxtResponderView = self.viewWithTag(textField.tag - 1 )
//                if let nextTextField = nxtResponderView as! UITextField? {
//                    nextTextField.isEnabled = true
//                    nextTextField.becomeFirstResponder()
//                    self.sendActions(for: .valueChanged)
//                }
                break
            
            case let(count,resultCount) where count == 0 && resultCount == 1 :
                NSLog("OTPField : Added a text current str : \(str) , result str : \(resultStr)")
                
                    textField.text = resultStr
                
                let nxtResponderView = self.viewWithTag(textField.tag + 1 )
                if let nextTextField = nxtResponderView as! UITextField? {
                    nextTextField.isEnabled = true
                    nextTextField.becomeFirstResponder()
                    textField.isEnabled = self.allowsSelection
                    self.sendActions(for: .valueChanged)
                }
                else{
                    textField.endEditing(true)
                    textField.isEnabled = true
                    //send call back : OTP FILLED
                    if let del = self.delegate{
                        del.otpField?(field: self, didEnter: currentOtp)
                    }
                }
                break
                
                default:
                    NSLog("OTPField : Default condition for OTPField current str : \(str) , result str : \(resultStr)")
                
        }
        
        textField.textAlignment = NSTextAlignment.center

        return false
    }
    
//MARK: textField event delete
    @objc  private func txtFieldValueChnged(sender:UITextField){
        NSLog("Callback for text value change")
        
        if let text = sender.text{
            if text == ""{
                let resp = self.viewWithTag(sender.tag - 1 )
                
                if resp != nil{
                    sender.isEnabled = allowsSelection
                    
                    let prevText = resp as! UITextField
                    prevText.text = ""
                    prevText.isEnabled = true
                    prevText.becomeFirstResponder()
                    
                    self.sendActions(for: .valueChanged)
                  }
            }
        }
    }
    
    
    
}
