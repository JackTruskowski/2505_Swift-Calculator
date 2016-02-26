//
//  ViewController.swift
//  Calculator
//
//  Created by John Truskowski on 1/28/16.
//  Copyright © 2016 John Truskowski. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
   
    @IBOutlet weak var history: UILabel!
    
    var userIsTyping = false
    
    var brain = CalculatorBrain()
    
    //a digit button / . / pi has been pressed
    @IBAction func digitPressed(sender: UIButton) {
        let digit = sender.currentTitle!
        print("digit = \(digit)")
        
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
        
        //if pi is entered, automatically push it onto the stack
        if digit == "pi" {
            displayValue = M_PI
            enter()
            return
        }
        
        //check if user is typing to allow numbers >1 digit
        if userIsTyping {
            display.text = display.text! + digit
        }else{
            display.text = digit
            userIsTyping = true
        }
        
    }
    
    //clear button pressed
    @IBAction func clearPressed(sender: UIButton) {
        //reset the op stack and display
        history.text = ""
        brain.clearOpStack()
        displayValue = 0
    }
    
    //enter button pressed
    @IBAction func enter() {
        userIsTyping = false
        if let result = brain.pushOperand(displayValue){
            displayValue = result
            history.text! += " \(displayValue)"
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
                history.text! += " " + operation
            } else { //invalid operation, reset display to 0
                displayValue = 0
            }
        }
     
    }
    
    //variable for the calculator display
    var displayValue: Double{
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
        }
    }

}