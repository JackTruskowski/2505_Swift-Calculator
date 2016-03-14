//
//  GraphViewController.swift
//  Calculator
//
//  Created by Jack Truskowski on 3/10/16.
//  Copyright © 2016 John Truskowski. All rights reserved.
//

import UIKit


class GraphViewController: CalculatorViewController {
    //property graphviewdatasource, set on segue from calculatorviewcontroller
    
    weak var gViewDataSource : GraphViewDataSource?
    var labelText = " " //this is set by the CalculatorViewController to update the description
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    @IBOutlet weak var graphView: GraphView!{
        didSet {
            graphView.dataSource = gViewDataSource
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "origin:"))
            
            //double tap recognizer
            let doubleTap = UITapGestureRecognizer(target: graphView, action: "doubleTapped:")
            doubleTap.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTap)
            
            //update description
            descriptionLabel.text = labelText
            
        }
    }
    
}
