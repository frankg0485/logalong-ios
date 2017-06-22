//
//  SelectAmountViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 5/30/17.
//  Copyright © 2017 Frank Gao. All rights reserved.
//

import UIKit

class SelectAmountViewController: UIViewController {

    @IBOutlet weak var amountTextField: UITextField!
    weak var delegate: FViewControllerDelegate?
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var subtractButton: UIButton!
    @IBOutlet weak var multiplyButton: UIButton!
    @IBOutlet weak var divideButton: UIButton!
    
    @IBOutlet weak var decimalPointButton: UIButton!
    
    
    
    var firstNumberText = ""
    var secondNumberText = ""
    var op = ""
    var isFirstNumber = true
    var hasOp = false
    var equalsClicked = false
    var decimalPointClicked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountTextField.text = "0"
        disableOrEnableOperationButtons(state: false)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        if (amountTextField.text?.isEmpty == true) {
            return
        }

        delegate?.passIntBack(self, myInt: Double(amountTextField.text!)!)
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func handleButtonPress(_ sender: UIButton) {
        

        var currentText = amountTextField.text!
        if (currentText == "0") {
            currentText = ""
        }
        
        let textLabel = sender.titleLabel?.text
        if let text = textLabel {
            switch text {
            case "+", "*", "/", "-":
                if hasOp {
                    let result = calculate()
                    firstNumberText = String(result)
                    currentText = String(result)
                    

                } else if (amountTextField.text?.isEmpty)! {
                    return
                }
                
                op = text
                
                changeHasOpAndIsFirstNumberState(hasOpState: true, isFirstNumberState: false)
                
                decimalPointClicked = false
                decimalPointButton.isEnabled = true
                amountTextField.text = "\(currentText)\(op)"
                
                disableOrEnableOperationButtons(state: false)

                
                equalsClicked = false
                break
            case "=":
                changeHasOpAndIsFirstNumberState(hasOpState: false, isFirstNumberState: true)
                
                let result = calculate()
                amountTextField.text = "\(result)"
                firstNumberText = "\(result)"
                
                equalsClicked = true
                decimalPointButton.isEnabled = true
                break
            case "DEL":
                if (amountTextField.text == "") {
                    return
                }
                
                equalsClicked = false
                
                let lastChar = amountTextField.text?.characters.last
                
                amountTextField.text = deleteChar(inputStr: amountTextField.text!)
                
                
                if (lastChar == "+") || (lastChar == "-") || (lastChar == "/") || (lastChar == "*") {
                    changeHasOpAndIsFirstNumberState(hasOpState: false, isFirstNumberState: true)
                    disableOrEnableOperationButtons(state: true)
                    
                } else {
                    if (firstNumberText != "") && (secondNumberText == "") {
                        
                        if (lastChar == ".") {
                            decimalPointClicked = false
                            decimalPointButton.isEnabled = true
                        }
                        
                        firstNumberText = deleteChar(inputStr: firstNumberText)
                        
                    } else if (secondNumberText != "") && (firstNumberText != ""){
                        
                        if (lastChar == ".") {
                            decimalPointClicked = true
                        }
                        secondNumberText = deleteChar(inputStr: secondNumberText)
                    }
                }
                break
            case "CLEAR":
                firstNumberText = "0"
                secondNumberText = ""
                
                changeHasOpAndIsFirstNumberState(hasOpState: false, isFirstNumberState: true)
                
                amountTextField.text = "0"
                break
            default:
                
                
                
                if isFirstNumber {
                    if (equalsClicked) {
                        firstNumberText = "\(text)"
                        equalsClicked = false
                        amountTextField.text = "\(text)"
                        checkAndChangeStateOfDecimalPoint(textInput: text)
                        return
                    }
                    
                    checkAndChangeStateOfDecimalPoint(textInput: text)
                    
                    if (decimalPointClicked) && (text != ".") {
                        disableOrEnableOperationButtons(state: true)
                        
                    }
                    
                    firstNumberText = "\(firstNumberText)\(text)"
                } else {
                    secondNumberText = "\(secondNumberText)\(text)"
                    
                    checkAndChangeStateOfDecimalPoint(textInput: text)
                    
                    if (decimalPointClicked) && (text != ".") {
                        disableOrEnableOperationButtons(state: true)

                    }
                }
                
                amountTextField.text = "\(currentText)\(text)"
                
                
                break
            }
        }
    }
    
    func disableOrEnableOperationButtons(state: Bool) {
        addButton.isEnabled = state
        subtractButton.isEnabled = state
        multiplyButton.isEnabled = state
        divideButton.isEnabled = state
    }
    
    func changeHasOpAndIsFirstNumberState(hasOpState: Bool, isFirstNumberState: Bool) {
        hasOp = hasOpState
        isFirstNumber = isFirstNumberState
    }
    
    func checkAndChangeStateOfDecimalPoint(textInput: String) {
        if (textInput == ".") {
            decimalPointClicked = true
        }
        
        if (decimalPointClicked) {
            decimalPointButton.isEnabled = false
            
        } else {
            decimalPointButton.isEnabled = true
        }
    }
    
    func deleteChar(inputStr: String) -> String {
        return inputStr.substring(to: (inputStr.index(before: (inputStr.endIndex))))
        
    }
    
    func calculate() -> Double {
        if (firstNumberText == "") {
            return 0
        }
        let firstNumber = Double(firstNumberText)!
        if (secondNumberText == "") {
            return firstNumber
        }
        let secondNumber = Double(secondNumberText)!
        
        firstNumberText = ""
        secondNumberText = ""
        switch op {
        case "+":
            return firstNumber + secondNumber
        case "-":
            return firstNumber - secondNumber
        case "*":
            return firstNumber * secondNumber
        case "/":
            return firstNumber / secondNumber
        default:
            return 0
        }
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
