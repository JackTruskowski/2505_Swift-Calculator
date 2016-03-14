//
//  ViewController.swift
//  Calculator
//
//  Created by John Truskowski on 1/28/16.
//  Copyright © 2016 John Truskowski. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, GraphViewDataSource {

    @IBOutlet weak var display: UILabel!
   
    @IBOutlet weak var history: UILabel!
    
    var userIsTyping = false
    
    var brain = CalculatorBrain()
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController!
        }
        
        if let vc = destination as? GraphViewController{
            vc.gViewDataSource = self
            vc.labelText = brain.mostRecentDescription
            
        }
    }
    
    
    func getYValForXVal(sender: GraphView, x: CGFloat) -> CGFloat? {
        brain.variableValues["M"] = Double(x)
        //print(brain.evaluate())
        if let evaluateResult = brain.evaluate(){
            return CGFloat(evaluateResult)
        }else{
            return nil
        }
    }
    
    func getDescriptionString(sender: GraphView) -> String? {
        return "sin(x)"
    }
    
    //a digit button / . / pi has been pressed
    @IBAction func digitPressed(sender: UIButton) {
        let digit = sender.currentTitle!
        
        //check to make sure that the user hasn't already entered a period
        if digit == "."{
            if userIsTyping && display.text!.rangeOfString(".") != nil{
                return
            }else if !userIsTyping{
                display.text = "0."
                userIsTyping = true
                return
            }
        }
        
        //check if user is typing to allow numbers >1 digit
        if userIsTyping {
            display.text = display.text! + digit
        }else{
            display.text = digit
            userIsTyping = true
        }
        
    }
    
    @IBAction func setVariable(sender: UIButton) {
        if let varValue = displayValue{
            brain.variableValues["M"] = varValue
            userIsTyping = false
            if let result = brain.evaluate() {
                displayValue = result
            }else{
                displayValue = 0
            }
        }
    }
    
    
    @IBAction func varConstPressed(sender: UIButton) {
        
        let varConst = sender.currentTitle!
        
        //if pi is entered, automatically push it onto the stack
        if varConst == "π" {
            displayValue = M_PI
        }else{
            displayValue = 0
        }
        
        if let varValue = brain.variableValues[sender.currentTitle!]{
            displayValue = varValue
        }else{
            displayValue = 0
        }
        
        brain.pushOperand(sender.currentTitle!)
        
    }
    
    
    //clear button pressed
    @IBAction func clearPressed(sender: UIButton) {
        //reset the op stack and display
        brain.clearOpStack()
        brain.variableValues.removeAll()
        displayValue = 0
        history.text = " "
    }
    
    //enter button pressed
    @IBAction func enter() {
        userIsTyping = false
        if let result = brain.pushOperand(displayValue!){
            displayValue = result
        } else {
            displayValue = 0
        }
    }
    
    //tells the brain to perform an operation
    @IBAction func operate(sender: UIButton) {
        if userIsTyping {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation){
                displayValue = result
            } else { //invalid operation, reset display to 0
                displayValue = 0
            }
        }
     
    }
    
    //variable for the calculator display
    var displayValue: Double?{
        get {
            if display.text != nil {
                return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
            }
            return nil
        }
        set {
            if let newDisplayText = newValue{
                display.text = "\(newDisplayText)"
            }else{
                display.text = nil
            }
            userIsTyping = false
            
            history.text = brain.description + " = "
        }
    }

}
