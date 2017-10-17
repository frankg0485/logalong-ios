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
    var type: TypePassed = TypePassed(double: 0, int: 0, int64: 0)

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var subtractButton: UIButton!
    @IBOutlet weak var multiplyButton: UIButton!
    @IBOutlet weak var divideButton: UIButton!

    @IBOutlet weak var decimalPointButton: UIButton!

    enum CalculatorState {
        case COLLECT_FIRST_NUMBER
        case COLLECT_SECOND_NUMBER
    }

    var state = CalculatorState.COLLECT_FIRST_NUMBER

    var newText: String = ""
    var firstNumberText: String = ""
    var secondNumberText: String = ""
    var operation: String = ""

    var firstDecimalButtonClicked: Bool = false
    var secondDecimalButtonClicked: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        amountTextField.text = "0"
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

        type.double = Double(amountTextField.text!)!

        delegate?.passDoubleBack(self, type: type)
        dismiss(animated: true, completion: nil)
    }


    @IBAction func handleButtonPress(_ sender: UIButton) {

        newText = (sender.titleLabel?.text)!

        switch state {
        case .COLLECT_FIRST_NUMBER:

            switch newText {
            case "DEL":

                if (amountTextField.text == "") {
                    return
                }
                let lastChar = amountTextField.text?.characters.last

                amountTextField.text = deleteChar(inputStr: amountTextField.text!)

                if (lastChar == ".") {
                    firstDecimalButtonClicked = false
                    decimalPointButton.isEnabled = true

                }

                firstNumberText = deleteChar(inputStr: firstNumberText)

                break

            case "CLEAR":
                amountTextField.text = ""

                firstNumberText = ""
                firstDecimalButtonClicked = false
                decimalPointButton.isEnabled = true

                disableOrEnableOperationButtons(state: false)
                break

            case "+", "-", "*", "/":
                operation = newText
                amountTextField.text = amountTextField.text! + newText

                disableOrEnableOperationButtons(state: false)
                decimalPointButton.isEnabled = true
                state = .COLLECT_SECOND_NUMBER
                break

            case "=":
                return

            default:
                firstNumberText = addDigitToNumber(oldNumberText: firstNumberText)

                if (newText == ".") {
                    firstDecimalButtonClicked = true
                    decimalPointButton.isEnabled = false
                    disableOrEnableOperationButtons(state: false)
                } else {
                    disableOrEnableOperationButtons(state: true)
                }

                amountTextField.text = firstNumberText
                break
            }


            break

        case .COLLECT_SECOND_NUMBER:
            switch newText {
            case "DEL":

                let lastChar = amountTextField.text?.characters.last

                amountTextField.text = deleteChar(inputStr: amountTextField.text!)

                if (lastChar == ".") {
                    secondDecimalButtonClicked = false
                    decimalPointButton.isEnabled = true

                } else if (lastChar == Character(operation)) {
                    operation = ""
                    secondNumberText = ""

                    state = .COLLECT_FIRST_NUMBER
                    return
                }


                secondNumberText = deleteChar(inputStr: secondNumberText)

                break

            case "CLEAR":
                amountTextField.text = ""

                firstNumberText = ""
                secondNumberText = ""
                firstDecimalButtonClicked = false
                secondDecimalButtonClicked = false
                decimalPointButton.isEnabled = true

                disableOrEnableOperationButtons(state: false)

                state = .COLLECT_FIRST_NUMBER
                return

            case "+", "-", "*", "/":
                let result = calculate()
                firstNumberText = String(result)
                secondNumberText = ""
                operation = newText
                amountTextField.text = String(result) + newText

                disableOrEnableOperationButtons(state: false)
                break

            case "=":
                let result = calculate()
                amountTextField.text = String(result)
                operation = ""
                firstNumberText = String(result)
                secondNumberText = ""
                firstDecimalButtonClicked = true
                secondDecimalButtonClicked = false
                decimalPointButton.isEnabled = false

                state = .COLLECT_FIRST_NUMBER
                break
            default:
                secondNumberText = addDigitToNumber(oldNumberText: secondNumberText)

                if (newText == ".") {
                    secondDecimalButtonClicked = true
                    decimalPointButton.isEnabled = false
                    disableOrEnableOperationButtons(state: false)
                } else {
                    disableOrEnableOperationButtons(state: true)
                }

                amountTextField.text = amountTextField.text! + newText

                break
            }


            break



        }

    }

    func addDigitToNumber(oldNumberText: String) -> String {
        let newNumberText: String = oldNumberText + newText

        return newNumberText
    }

    func disableOrEnableOperationButtons(state: Bool) {
        addButton.isEnabled = state
        subtractButton.isEnabled = state
        multiplyButton.isEnabled = state
        divideButton.isEnabled = state
    }

    func deleteChar(inputStr: String) -> String {

        var strCopy = inputStr

        strCopy.remove(at: strCopy.index(before: strCopy.endIndex))
        return strCopy

    }

    func calculate() -> Double {
        let firstNumber = Double(firstNumberText)
        let secondNumber = Double(secondNumberText)

        switch operation {
        case "+":
            return firstNumber! + secondNumber!
            
        case "-":
            return firstNumber! - secondNumber!
            
        case "*":
            return firstNumber! * secondNumber!
            
        case "/":
            return firstNumber! / secondNumber!
            
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
