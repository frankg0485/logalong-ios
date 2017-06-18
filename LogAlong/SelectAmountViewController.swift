//
//  SelectAmountViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 5/30/17.
//  Copyright © 2017 Frank Gao. All rights reserved.
//

import UIKit

class SelectAmountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var amountTextField: UITextField!
    weak var delegate: FViewControllerDelegate?
    
    var firstNumberText = ""
    var secondNumberText = ""
    var op = ""
    var isFirstNumber = true
    var hasOp = false
    var canClear = true
    var noNumber = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountTextField.delegate = self
        amountTextField.keyboardType = .numbersAndPunctuation
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

        delegate?.passIntBack(self, myInt: Float(amountTextField.text!)!)
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func handleButtonPress(_ sender: UIButton) {
        
        if canClear {
            amountTextField.text = ""
            canClear = false
            noNumber = true
        }
        var currentText = amountTextField.text!
        let textLabel = sender.titleLabel?.text
        if let text = textLabel {
            switch text {
            case "+", "*", "/", "-":
                if hasOp {
                    if (secondNumberText == "") {
                        return
                    }
                    
                    let result = calculate()
                    firstNumberText = String(result)
                    currentText = String(result)
                } else if noNumber {
                    return
                }
                
                op = text
                isFirstNumber = false
                hasOp = true
                amountTextField.text = "\(currentText) \(op) "
                break
            case "=":
                isFirstNumber = true
                hasOp = false
                canClear = true
                let result = calculate()
                amountTextField.text = "\(result)"
                break
            case "DEL":
                if (amountTextField.text == "") {
                    return
                }
                
                let truncated = amountTextField.text?.substring(to: (amountTextField.text?.index(before: (amountTextField.text?.endIndex)!))!)
                
                amountTextField.text = truncated
                
                if (firstNumberText != "") {
                    
                } else if (secondNumberText != "") {
                    secondNumberText = String(Int(secondNumberText)! % 10)
                }

                case "CLEAR":
                amountTextField.text = ""
                firstNumberText = ""
                secondNumberText = ""
                hasOp = false
                noNumber = true
                isFirstNumber = true
                break
            default:
                if isFirstNumber {
                    firstNumberText = "\(firstNumberText)\(text)"
                } else {
                    secondNumberText = "\(secondNumberText)\(text)"
                }
                
                amountTextField.text = "\(currentText)\(text)"
                noNumber = false
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
