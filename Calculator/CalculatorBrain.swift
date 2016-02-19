//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by John Truskowski on 2/2/16.
//  Copyright © 2016 John Truskowski. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    private enum Op { //CustomDebug protocol
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        /*
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                }
            }
        }
        */
    }
    
    init(){
        //all the known operations reside here
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["−"] = Op.BinaryOperation("−") { $1 - $0 }
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0 }
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin", sin)
        knownOps["cos"] = Op.UnaryOperation("cos", cos)
        knownOps["tan"] = Op.UnaryOperation("tan", tan)
    }
    
    //evaluates a result recursively using the operators/operands in the stack
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]){ //tuple
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    let operandEvaluation2 = evaluate(operandEvaluation.remainingOps)
                    if let operand2 = operandEvaluation2.result{
                        return (operation(operand, operand2), operandEvaluation2.remainingOps)
                    }
                }
            }
        }
        return (nil, ops) //stack is empty, kick
    }
    
    //removes everything from the opstack
    func clearOpStack(){
        opStack.removeAll()
    }
    
    //evaluates a result
    func evaluate() -> Double? {
        return evaluate(opStack).result
    }
    
    //push an operand onto the opStack
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        print("\(opStack)")
        return evaluate()
    }
    
    //calls evaluate() to perform an operation
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol]{
            opStack.append(operation)
            print("\(opStack)")
            return evaluate()
        }
        return nil
    }
    
}