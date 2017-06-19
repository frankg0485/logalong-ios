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
    var canClear = true
    var equalsClicked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountTextField.text = "0"
        addButton.isEnabled = false
        subtractButton.isEnabled = false
        multiplyButton.isEnabled = false
        divideButton.isEnabled = false
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
                isFirstNumber = false
                hasOp = true
                amountTextField.text = "\(currentText)\(op)"
                
                addButton.isEnabled = false
                subtractButton.isEnabled = false
                multiplyButton.isEnabled = false
                divideButton.isEnabled = false
                break
            case "=":
                isFirstNumber = true
                hasOp = false
                let result = calculate()
                amountTextField.text = "\(result)"
                firstNumberText = "\(result)"
                equalsClicked = true
                break
            case "DEL":
                if (amountTextField.text == "") {
                    return
                }
                
                let lastChar = amountTextField.text?.characters.last
                let truncated = amountTextField.text?.substring(to: (amountTextField.text?.index(before: (amountTextField.text?.endIndex)!))!)
                
                amountTextField.text = truncated
                
                
                if (lastChar == "+") || (lastChar == "-") || (lastChar == "/") || (lastChar == "*") {
                    hasOp = false
                    addButton.isEnabled = true
                    subtractButton.isEnabled = true
                    multiplyButton.isEnabled = true
                    divideButton.isEnabled = true
                } else {
                    if (firstNumberText != "") {
                        firstNumberText = firstNumberText.substring(to: (firstNumberText.index(before: (firstNumberText.endIndex))))
                    } else if (secondNumberText != "") {
                        secondNumberText = secondNumberText.substring(to: (secondNumberText.index(before: (secondNumberText.endIndex))))
                    }
                }
                break
            case "CLEAR":
                firstNumberText = ""
                secondNumberText = ""
                hasOp = false
                isFirstNumber = true
                amountTextField.text = "0"
                break
            default:
                
                
                
                if isFirstNumber {
                    if (equalsClicked) {
                        firstNumberText = "\(text)"
                        equalsClicked = false
                        amountTextField.text = "\(text)"
                        return
                    }
                    
                    firstNumberText = "\(firstNumberText)\(text)"
                } else {
                secondNumberText = "\(secondNumberText)\(text)"
            }
            
            amountTextField.text = "\(currentText)\(text)"
                
                if (text == ".") {
                    decimalPointButton.isEnabled = false
                    addButton.isEnabled = false
                    subtractButton.isEnabled = false
                    multiplyButton.isEnabled = false
                    divideButton.isEnabled = false
                } else {
                    decimalPointButton.isEnabled = true
                    addButton.isEnabled = true
                    subtractButton.isEnabled = true
                    multiplyButton.isEnabled = true
                    divideButton.isEnabled = true
                }
                
                break
            }
        }
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
