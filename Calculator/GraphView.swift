//
//  GraphView.swift
//  Calculator
//
//  Created by John Truskowski on 3/4/16.
//  Copyright © 2016 John Truskowski. All rights reserved.
//

import UIKit

protocol GraphViewDataSource : class {
    
}

@IBDesignable

class GraphView: UIView {
    
    @IBInspectable var scale: CGFloat = 1.0 { didSet { setNeedsDisplay() }}
    @IBInspectable var origin: CGPoint = CGPointMake(0.0, 0.0) { didSet { setNeedsDisplay() }}
    
    var graphAxes = AxesDrawer();
    
    var didSetOrigin = false
    
    weak var dataSource: GraphViewDataSource?
    
    //Constants
    private struct Scaling {
        static let PointsPerUnit: CGFloat = 100.0
    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        if(!didSetOrigin){
            origin = CGPointMake(rect.width/2, rect.height/2)
        }
        graphAxes.drawAxesInRect(rect, origin: origin, pointsPerUnit: Scaling.PointsPerUnit*scale)
        didSetOrigin = true
        
    }
    
    //scale from a pinch gesture
    func scale(gesture: UIPinchGestureRecognizer){
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1
        }
    }
    
    //for panning
    func origin(gesture: UIPanGestureRecognizer){
        if gesture.state == .Changed {
            print("panning")
            let translation = gesture.translationInView(gesture.view)
            origin = CGPoint(x:origin.x + translation.x, y:origin.y + translation.y)
            gesture.setTranslation(CGPointZero, inView: gesture.view)
        }
    }
    
    //double tap
    func doubleTapped (gesture: UITapGestureRecognizer) {
        
        print("Changing origin1...")
        //if gesture.state == .Changed {
            print("Changing origin...")
            let newOrigin = gesture.locationInView(gesture.view)
            origin = newOrigin
        //}
    }
    

}
