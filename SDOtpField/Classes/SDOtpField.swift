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

public protocol SDOtpFieldDelegate : class {
    func otpField(field:UIControl , didEnter otp:String) -> Void
}
public extension SDOtpFieldDelegate{
    func otpField(field:UIControl , didEnter otp:String){ }
}

@objc public enum FieldShape:Int {
    case square
    case round
}

public class SDOtpField: UIControl,UITextFieldDelegate {
    //TODO: selected back ground color, border color
    //TODO: CHECK PROPERTIES DO NOT OVERRIDE - ADD TEXT FIELDS AFTER PARENT VIEW DID LOAD ?
    //TODO: Add method to set text and reset last text on reload
    
    public var currentOtp:String {
        get{
            var str = ""
            for n in 1...numberOfDigits{
                if let txtField = self.viewWithTag(220+n) as? UITextField{
                    str.append((txtField.text != nil) ? txtField.text! : "")
                }
            }
            return str
        }
    }
    
    public  var numberOfDigits = 6
    public  var fieldMargin:CGFloat = 5
    public  var fieldCornerRadius:CGFloat = 0
    public  var fieldHeight:CGFloat = 0
    public  var fieldWidth:CGFloat = 0
    
    public  var fieldBackgroundColor : UIColor = UIColor.white
    public  var fieldBorderColor = UIColor.lightGray
    public  var fieldKeyboardType = UIKeyboardType.numberPad
    public  var allowsSelection = false
    public  var fieldsAdjustHeightToFit = false
    public  var fieldShape : FieldShape = .square
    public  var secureTextEnabled = false
    public  var fieldFont = UIFont.systemFont(ofSize: 15)
    public  var fieldTextColor = UIColor.black
    //var selectedBackgroundColor : UIColor = UIColor.gray
    
    public  weak var delegate:SDOtpFieldDelegate?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.addTarget(self, action: #selector(touch), for: .touchUpInside)
        reloadFields()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        fieldWidth = (self.frame.size.width + fieldMargin)/CGFloat(numberOfDigits) - fieldMargin
        fieldHeight = fieldsAdjustHeightToFit ? self.frame.size.height : fieldWidth
        for position in 1...numberOfDigits{
            if let textField = viewWithTag(220+position) as? SDTextField{
                textField.frame = CGRect.init(x:(CGFloat(position-1)*fieldWidth)+(fieldMargin*CGFloat(position-1)) , y:0 , width:fieldWidth, height:fieldHeight )
                textField.center.y = self.convert(self.center, from: self.superview).y
            }
        }
    }
    
    
    //MARK: Setup Views
    private func addTetxFields() -> Void {
        for n in 1...numberOfDigits{
            if let textField = viewWithTag(220+n) as? SDTextField{
                setupTextField(textField:textField)
            }else{
                let textField = SDTextField.init()
                textField.delegate = self
                textField.addTarget(self, action: #selector(txtFieldValueChnged(sender:)), for: .valueChanged)
                textField.tag = 220+n
                setupTextField(textField:textField)
                self.addSubview(textField)
            }
        }
    }
    
    private func setupTextField(textField:SDTextField){
        textField.backgroundColor = fieldBackgroundColor
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
    }
    private func enableTextField(){
        let otpCount = currentOtp.count
        let selectTag = 220 + ((otpCount + 1 <= numberOfDigits) ? otpCount + 1 : otpCount)
        for  vu in self.subviews{
            if let textField = vu as? UITextField{
                if textField.tag == selectTag {
                    textField.isEnabled = true
                }else {
                    textField.isEnabled = allowsSelection
                }
            }
        }
    }
    
    //MARK: Method to reload contents
    public func reloadFields() -> Void {
        addTetxFields()
        enableTextField()
    }
    
    //MARK: TOUCH EVENT
    @objc private func touch() -> Void {
        if allowsSelection{ return }
        self.edit(shouldEdit: true)
    }
    
    private func edit(shouldEdit:Bool) -> Void {
        if shouldEdit{
            selectTextField()
        }
        else{
            endEditing(true)
        }
    }
    
    private func selectTextField(){
        let otpCount = currentOtp.count
        let selectTag = 220 + ((otpCount + 1 <= numberOfDigits) ? otpCount + 1 : otpCount)

        if let vu = self.viewWithTag(selectTag) as? UITextField{
            if !vu.isFirstResponder {
                vu.becomeFirstResponder()
            }
        }
    }
    
   @discardableResult override public func becomeFirstResponder() -> Bool{
        defer{
            selectTextField()
        }
       return super.becomeFirstResponder()
    }
    @discardableResult override public func resignFirstResponder() -> Bool{
        defer{
            endEditing(true)
        }
        return super.resignFirstResponder()
    }
    //MARK: Clear text
    public func clearOTPText() -> Void {
        for n in 1...numberOfDigits{
            let txtFld = self.viewWithTag(220+n) as! UITextField?
            txtFld?.text = ""
            txtFld?.isEnabled =  n == 1 ? true : allowsSelection
        }
    }
    
    //MARK: UITextFieldDelegate
    public func textFieldDidBeginEditing(_ textField: UITextField) { }
    public func textFieldDidEndEditing(_ textField: UITextField) { }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        if string == " "{
            return false
        }
        
        let str = textField.text ?? ""
        
        let startIn = str.index(str.startIndex, offsetBy: range.location)
        let endIn = str.index(startIn, offsetBy: range.length)
        
        let resultStr = str.replacingCharacters(in:(startIn..<endIn) , with: string)
        
        switch (str.count , resultStr.count ){
            //User enters text when SELECTED textfield is already full THEN REPLACE TEXT : IN CASE OF ALLOWS SELECTION VAR
            case let(count,resultCount) where count == 1 && resultCount > 1 :
                
                if string.count == 1{
                    textField.text = string
                    let resp = self.viewWithTag(textField.tag + 1 )
                    if resp != nil{
                        resp?.becomeFirstResponder()
                        self.sendActions(for: .valueChanged)
                    }
                    else{
                        //send call back
                        if let del = self.delegate{
                            del.otpField(field: self, didEnter: currentOtp)
                        }
                    }
                }
                break
            
            //Deletes a text
            case let(count,resultCount) where count == 1 && resultCount == 0 :
                    textField.text = resultStr
                break
            
            case let(count,resultCount) where count == 0 && resultCount == 1 :
                
                textField.text = resultStr
                
                let nxtResponderView = self.viewWithTag(textField.tag + 1 )
                if let nextTextField = nxtResponderView as? UITextField {
                    nextTextField.isEnabled = true
                    nextTextField.becomeFirstResponder()
                    textField.isEnabled = self.allowsSelection
                    self.sendActions(for: .valueChanged)
                }
                else{
                    textField.isEnabled = true
                    //send call back : OTP FILLED
                    if let del = self.delegate{
                        del.otpField(field: self, didEnter: currentOtp)
                    }
                }
                break
            
            default: break
            
        }
        
        textField.textAlignment = NSTextAlignment.center
        
        return false
    }
    
    //MARK: textField event delete
    @objc  private func txtFieldValueChnged(sender:UITextField){
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
