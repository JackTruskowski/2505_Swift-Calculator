//
//  GraphViewController.swift
//  Calculator
//
//  Created by Jack Truskowski on 3/10/16.
//  Copyright © 2016 John Truskowski. All rights reserved.
//

import UIKit


class GraphViewController: UIViewController {
    //property graphviewdatasource, set on segue from calculatorviewcontroller

    var theDataSource: GraphViewDataSource;
    
    @IBOutlet weak var graphView: GraphView!{
        didSet {
            graphView.dataSource = theDataSource
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "origin:"))
            
            //double tap recognizer
            let doubleTap = UITapGestureRecognizer(target: graphView, action: "doubleTapped:")
            doubleTap.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTap)
            
        }
    }
    
}
