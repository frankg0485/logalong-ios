//
//  SelectAmountViewController.swift
//  LogAlong
//
//  Created by Frank Gao on 5/30/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class SelectAmountViewController: UIViewController {

    @IBOutlet weak var amountTextField: UITextField!

    weak var delegate: FViewControllerDelegate?
    var type: TypePassed = TypePassed(double: 0, int: 0, int64: 0, array64: nil, allSelected: false)

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button8: UIButton!
    @IBOutlet weak var button9: UIButton!
    @IBOutlet weak var button0: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var subtractButton: UIButton!
    @IBOutlet weak var multiplyButton: UIButton!
    @IBOutlet weak var divideButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var okEqualsButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var decimalPointButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!

    enum CalculatorState {
        case INIT_NO_INPUT
        case INTEGER
        case DECIMAL
        case DECIMAL_1_0
        case MATH_INIT
        case INTEGER_2
        case DECIMAL_2
    }

    enum LastChar {
        case DIGIT
        case DOT
        case MATH
        case EMPTY
    }

    var state = CalculatorState.INIT_NO_INPUT

    var color: UIColor!
    var numberText = ""

    let MAX_INPUT_LENGTH = 16
    let MAX_DECIMAL_DIGITS = 3
    let MAX_VALUE: Double = 999999999999
    var firstValueEnd = 0
    var oldValue: Double = 0
    var value: Double = 0
    var operation = ""
    var allowZero = false

    private var isEqual: Bool = false
    private var isImageReady: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if oldValue == Double(0) {
            state = initNoInputState()
            amountTextField.text = "0.0"
        } else {
            state = initDecimal1State()
            numberText = value2string(oldValue)
            amountTextField.text = numberText
        }

        self.preferredContentSize.width = LTheme.Dimension.amount_picker_width
        self.preferredContentSize.height = LTheme.Dimension.amount_picker_height
    }

    override func viewWillAppear(_ animated: Bool) {
        view.superview?.layer.borderColor = color.cgColor
        view.superview?.layer.borderWidth = 1
        amountTextField.textColor = color

        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        setUpButtonImages()
        super.viewDidAppear(animated)
    }

    func disableEnableOperationButtons(_ enable: Bool) {
        addButton.isEnabled = enable
        subtractButton.isEnabled = enable
        multiplyButton.isEnabled = enable
        divideButton.isEnabled = enable
    }

    func setUpButtonImages() {
        deleteButton.setImage(#imageLiteral(resourceName: "ic_action_backspace").withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.setImage(#imageLiteral(resourceName: "ic_action_undo").withRenderingMode(.alwaysOriginal), for: .normal)
        okEqualsButton.setImage(#imageLiteral(resourceName: "ic_action_accept_disabled").withRenderingMode(.alwaysOriginal), for: .disabled)
        okEqualsButton.setImage( isEqual ? #imageLiteral(resourceName: "ic_action_equal").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "ic_action_accept").withRenderingMode(.alwaysOriginal), for: .normal)

        deleteButton.imageEdgeInsets = UIEdgeInsetsMake(
            (deleteButton.frame.height - 30) / 2,
            (deleteButton.frame.width - 30) / 2,
            (deleteButton.frame.height - 30) / 2,
            (deleteButton.frame.width - 30) / 2)
        backButton.imageEdgeInsets = UIEdgeInsetsMake(
            (backButton.frame.height - 30) / 2,
            (backButton.frame.width - 30) / 2,
            (backButton.frame.height - 30) / 2,
            (backButton.frame.width - 30) / 2)

        okEqualsButton.imageEdgeInsets = UIEdgeInsetsMake(
            (okEqualsButton.frame.height - 30) / 2,
            (okEqualsButton.frame.width - 30) / 2,
            (okEqualsButton.frame.height - 30) / 2,
            (okEqualsButton.frame.width - 30) / 2)

        isImageReady = true
    }


    @IBAction func handleButtonPress(_ sender: UIButton) {
        switch state {
        case .INIT_NO_INPUT:
            state = doNoInputState(sender)
        case .INTEGER:
            state = doInteger1State(sender)
        case .DECIMAL:
            state = doDecimal1State(sender)
        case .MATH_INIT:
            state = doMathInitState(sender)
        case .INTEGER_2:
            state = doInteger2State(sender)
        case .DECIMAL_2:
            state = doDecimal2State(sender)
        case .DECIMAL_1_0:
            state = doDecimal10State(sender)
        }
    }

    private func appendToString(_ ch: String) -> Bool {
        var ret = false
        if (numberText.count < MAX_INPUT_LENGTH) {
            if ((ch >= "0") && (ch <= "9")) {
                let ii = numberText.lastIndexOf(".") ?? 0
                if ((ii > 0) && (ii > firstValueEnd)) {
                    if (numberText.count < (ii + MAX_DECIMAL_DIGITS + 1)) {
                        numberText += ch
                        ret = true
                    }
                } else {
                    numberText += ch
                    ret = true
                }
            } else {
                numberText += ch
                ret = true
            }
        }
        return ret
    }

    private func appendMathToString(_ ch: String) -> Bool{
        var ret = false
        if (numberText.count < (MAX_INPUT_LENGTH - 3)) {
            numberText += " "
            numberText += ch
            numberText += " "
            operation = ch
            ret = true
        }
        return ret
    }

    private func getLastBit() -> LastChar {
        if (numberText.isEmpty) {
            return LastChar.EMPTY
        }

        let lastDigit = numberText[numberText.count - 1]
        if ((lastDigit >= "0") && (lastDigit <= "9")) {
            return LastChar.DIGIT
        } else if (lastDigit == ".") {
            return LastChar.DOT
        } else if (lastDigit == " ") {
            return LastChar.MATH
        }

        LLog.e("\(self)", "unexpected ending character: " + String(lastDigit))
        return LastChar.EMPTY
    }

    private func removeLastBit() -> LastChar {
        if (numberText.isEmpty) {
            return LastChar.EMPTY
        }

        if (numberText[numberText.count - 1] == " ") {
            numberText = numberText[0..<numberText.count - 3]
        } else {
            numberText = numberText[0..<numberText.count - 1]
        }

        if (numberText.isEmpty) {
            return LastChar.EMPTY
        } else {
            if (numberText.count == (firstValueEnd + 1)) &&
                ((numberText[firstValueEnd] == "-") ||
                    (numberText[firstValueEnd] == "0")) {
                numberText = numberText[0..<(numberText.count - 1)]
                if (firstValueEnd > 0) {
                    return LastChar.MATH
                } else {
                    return LastChar.EMPTY
                }
            }
        }

        return getLastBit()
    }

    private func value2string(_ value: Double) -> String {
        return String(format: "%.2f", value)
    }

    private func string2value(_ str: String) -> Double {
        if (str.isEmpty)  { return 0 }

        let lastDigit = str[str.count - 1]
        if (lastDigit == ".") {
            return (Double(str[0..<str.count - 1]))!
        }
        return Double(str)!
    }

    private func applyMath() -> Bool {
        var ret = true
        var str1 = numberText[0..<(firstValueEnd - 3)]
        var str2 = numberText[firstValueEnd..<numberText.count]
        let val1 = string2value(str1)
        let val2 = string2value(str2)

        switch (operation) {
        case "+":
            value = val1 + val2

        case "-":
            value = val1 - val2

        case "*":
            value = val1 * val2

        default:
            if (val2 == 0) {
                ret = false
            } else {
                value = val1 / val2
            }

        }

        if !ret || (value > MAX_VALUE) {
            numberText = ""
            value = 0
            return false
        } else {
            numberText = value2string(value)
        }
        return true
    }

    private func saveLog() {
        type.double = string2value(numberText)
        delegate?.passNumberBack(self, type: type, okPressed: true)

        dismiss(animated: true, completion: nil)
    }

    @IBAction func backPressed(_ sender: UIButton) {
        delegate?.passNumberBack(self, type: type, okPressed: false)

        dismiss(animated: true, completion: nil)
    }

    @IBAction func clearPressed(_ sender: UIButton) {
        numberText = ""
        state = initNoInputState()
    }

    private func getDigit(_ btn: UIButton) -> String {
        var digit = 0
        switch (btn) {
        case button9: digit = 9
        case button8: digit = 8
        case button7: digit = 7
        case button6: digit = 6
        case button5: digit = 5
        case button4: digit = 4
        case button3: digit = 3
        case button2: digit = 2
        case button1: digit = 1
        default: digit = 0
        }
        return String(digit)
    }

    private func getMath(_ btn: UIButton) -> String {
        var ch = ""
        switch (btn) {
        case subtractButton:
            ch = "-"

        case multiplyButton:
            ch = "*"

        case divideButton:
            ch = "/"
        default:
            ch = "+"
        }
        return ch
    }

    private func doNoInputState(_ btn: UIButton) -> CalculatorState {
        switch (btn) {
        case button9, button8, button7, button6, button5, button4, button3, button2, button1:
            appendToString(getDigit(btn))
            return initInteger1State()

        case button0, decimalPointButton:
            appendToString("0")
            appendToString(".")
            return initDecimal10State()
        case okEqualsButton:
            if (allowZero) { saveLog() }
        default:
            break
        }

        return CalculatorState.INIT_NO_INPUT
    }

    private func initNoInputState() -> CalculatorState {
        disableEnableOperationButtons(false)
        okEqualsButton.isEnabled = allowZero ? true : false
        decimalPointButton.isEnabled = true

        amountTextField.text = "0.0"
        amountTextField.alpha = 0.5

        if isImageReady {okEqualsButton.setImage(#imageLiteral(resourceName: "ic_action_accept").withRenderingMode(.alwaysOriginal), for: .normal)}
        isEqual = false

        numberText = ""
        return CalculatorState.INIT_NO_INPUT
    }

    private func doInteger1State(_ btn: UIButton) -> CalculatorState {
        switch (btn) {
        case button9, button8, button7, button6, button5, button4, button3, button2, button1, button0:
            if (appendToString(getDigit(btn))) {
                amountTextField.text = numberText
            }

        case deleteButton:
            switch (removeLastBit()) {
            case .DIGIT:
                amountTextField.text = numberText

            default:
                return initNoInputState()
            }

        case decimalPointButton:
            if (appendToString(".")) {
                return initDecimal1State()
            }

        case addButton, subtractButton, multiplyButton, divideButton:
            if (appendMathToString(getMath(btn))) {
                return initMathInitState()
            }

        case okEqualsButton:
            saveLog()
        default:
            break
        }
        return CalculatorState.INTEGER
    }

    private func initInteger1State() -> CalculatorState {
        decimalPointButton.isEnabled = true
        disableEnableOperationButtons(true)
        okEqualsButton.isEnabled = true

        firstValueEnd = 0

        if isImageReady {okEqualsButton.setImage(#imageLiteral(resourceName: "ic_action_accept").withRenderingMode(.alwaysOriginal), for: .normal)}
        isEqual = false

        amountTextField.text = numberText
        amountTextField.alpha = 1.0

        return CalculatorState.INTEGER
    }

    private func doDecimal10State(_ btn: UIButton) -> CalculatorState {
        switch (btn) {
        case button9, button8, button7, button6, button5, button4, button3, button2, button1:
            if (appendToString(getDigit(btn))) {
                return initDecimal1State()
            }

        case button0:
            if (appendToString("0")) {
                amountTextField.text = numberText
            }

        case deleteButton:
            if (LastChar.DOT == getLastBit()) {
                if (LastChar.EMPTY == removeLastBit()) {
                    return initNoInputState()
                } else {
                    return initInteger1State()
                }
            } else {
                removeLastBit()
                amountTextField.text = numberText
            }
        case okEqualsButton:
            if (allowZero) { saveLog() }
        default:
            break
        }
        return CalculatorState.DECIMAL_1_0
    }

    private func initDecimal10State() -> CalculatorState {
        decimalPointButton.isEnabled = false
        disableEnableOperationButtons(false)
        okEqualsButton.isEnabled = allowZero ? true : false

        if isImageReady {okEqualsButton.setImage(#imageLiteral(resourceName: "ic_action_accept").withRenderingMode(.alwaysOriginal), for: .normal)}
        isEqual = false

        amountTextField.text = numberText
        amountTextField.alpha = 1.0

        return CalculatorState.DECIMAL_1_0
    }

    private func doDecimal1State(_ btn: UIButton) -> CalculatorState {
        switch (btn) {
        case button9, button8, button7, button6, button5, button4, button3, button2, button1, button0:
            if (appendToString(getDigit(btn))) {
                amountTextField.text = numberText
                if allowZero { okEqualsButton.isEnabled = true }
                else {
                    if (string2value(numberText) >= 0.01) {
                        okEqualsButton.isEnabled = true
                    } else {
                        okEqualsButton.isEnabled = false
                    }
                }
            }

        case deleteButton:
            if (LastChar.DOT == getLastBit()) {
                if (LastChar.EMPTY == removeLastBit()) {
                    return initNoInputState()
                } else {
                    return initInteger1State()
                }
            } else {
                removeLastBit()
                if (Double(0) == string2value(numberText)) {
                    return initDecimal10State()
                }
                amountTextField.text = numberText
            }

        case addButton, subtractButton, multiplyButton, divideButton:
            if (appendMathToString(getMath(btn))) {
                return initMathInitState()
            }

        case okEqualsButton:
            saveLog()

        default:
            break
        }
        return CalculatorState.DECIMAL
    }

    private func initDecimal1State() -> CalculatorState {
        decimalPointButton.isEnabled = false
        disableEnableOperationButtons(true)

        if allowZero { okEqualsButton.isEnabled = true }
        else {
            if (string2value(numberText) >= 0.01) {
                okEqualsButton.isEnabled = true
            } else {
                okEqualsButton.isEnabled = false
            }
        }

        firstValueEnd = 0

        if isImageReady {okEqualsButton.setImage(#imageLiteral(resourceName: "ic_action_accept").withRenderingMode(.alwaysOriginal), for: .normal)}
        isEqual = false

        amountTextField.text = numberText
        amountTextField.alpha = 1.0

        return CalculatorState.DECIMAL
    }

    private func doMathInitState(_ btn: UIButton) -> CalculatorState {
        switch (btn) {
        case button9, button8, button7, button6, button5, button4, button3, button2, button1:
            if (appendToString(getDigit(btn))) {
                return initInteger2State()
            }

        case button0, decimalPointButton:
            appendToString("0")
            appendToString(".")
            return initDecimal2State()

        case deleteButton, okEqualsButton:
            removeLastBit()

            if (numberText.lastIndexOf(".") ?? 0 > 0) {
                return initDecimal1State()
            } else {
                return initInteger1State()
            }

        default:
            break
        }
        return CalculatorState.MATH_INIT
    }

    private func initMathInitState() -> CalculatorState {
        disableEnableOperationButtons(false)
        decimalPointButton.isEnabled = true

        if isImageReady {okEqualsButton.setImage(#imageLiteral(resourceName: "ic_action_equal").withRenderingMode(.alwaysOriginal), for: .normal)}
        isEqual = true

        amountTextField.text = numberText
        firstValueEnd = numberText.count

        return CalculatorState.MATH_INIT
    }

    private func doInteger2State(_ btn: UIButton) -> CalculatorState {
        switch (btn) {
        case button9, button8, button7, button6, button5, button4, button3, button2, button1, button0:
            if (appendToString(getDigit(btn))) {
                amountTextField.text = numberText
            }

        case deleteButton:
            switch (removeLastBit()) {
            case .DIGIT:
                amountTextField.text = numberText

            default:
                return initMathInitState()
            }


        case decimalPointButton:
            if (appendToString(".")) {
                return initDecimal2State()
            }


        case addButton, subtractButton, multiplyButton, divideButton:
            if (applyMath()) {
                if (appendMathToString(getMath(btn))) {
                    return initMathInitState()
                } else {
                    return initDecimal1State()
                }
            } else {
                return initNoInputState()
            }

        case okEqualsButton:
            if (applyMath()) {
                return initDecimal1State()
            } else {
                return initNoInputState()
            }

        default:
            break
        }
        return CalculatorState.INTEGER_2
    }

    private func initInteger2State() -> CalculatorState {
        decimalPointButton.isEnabled = true
        disableEnableOperationButtons(true)
        okEqualsButton.isEnabled = true

        amountTextField.text = numberText

        return .INTEGER_2
    }

    private func doDecimal2State(_ btn: UIButton) -> CalculatorState {
        switch (btn) {
        case button9, button8, button7, button6, button5, button4, button3, button2, button1, button0:
            if (appendToString(getDigit(btn))) {
                amountTextField.text = numberText
            }

        case deleteButton:
            if (LastChar.DOT == getLastBit()) {
                if (LastChar.MATH == removeLastBit()) {
                    return initMathInitState()
                } else {
                    return initInteger2State()
                }
            } else {
                removeLastBit()
                amountTextField.text = numberText
            }

        case addButton, subtractButton, multiplyButton, divideButton:
            if (applyMath()) {
                if (appendMathToString(getMath(btn))) {
                    return initMathInitState()
                } else {
                    return initDecimal1State()
                }
            } else {
                return initNoInputState()
            }

        case okEqualsButton:
            if (applyMath()) {
                return initDecimal1State()
            } else {
                return initNoInputState()
            }

        default:
            break
        }
        return .DECIMAL_2
    }

    private func initDecimal2State() -> CalculatorState {
        decimalPointButton.isEnabled = false
        disableEnableOperationButtons(true)
        okEqualsButton.isEnabled = true

        amountTextField.text = numberText

        return .DECIMAL_2
    }

}
