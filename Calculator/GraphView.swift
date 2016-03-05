//
//  GraphView.swift
//  Calculator
//
//  Created by John Truskowski on 3/4/16.
//  Copyright © 2016 John Truskowski. All rights reserved.
//

import UIKit

protocol GraphViewDataSource : class {
    func getYValForXVal(sender: GraphView, x: CGFloat)->CGFloat?
    func getDescriptionString(sender: GraphView)->String?
}

@IBDesignable

class GraphView: UIView {
    
    convenience init(contentScaleFactor: CGFloat) {
        self.init()
        self.scaleFactor = contentScaleFactor
    }
    
    @IBInspectable var scale: CGFloat = 1.0 { didSet { setNeedsDisplay() }}
    @IBInspectable var origin: CGPoint = CGPointMake(0.0, 0.0) { didSet { setNeedsDisplay() }}
    var scaleFactor: CGFloat = 1 // set this from UIView's contentScaleFactor to position axes with maximum accuracy
    var color = UIColor.blackColor()
    
    var graphAxes = AxesDrawer();
    
    var didSetOrigin = false
    
    weak var dataSource: GraphViewDataSource?
    
    //Constants
    private struct Scaling {
        static let PointsPerUnit: CGFloat = 100.0
    }
    
//    func drawAxesInRect(bounds: CGRect, origin: CGPoint, pointsPerUnit: CGFloat)
//    {
//        CGContextSaveGState(UIGraphicsGetCurrentContext())
//        color.set()
//        let path = UIBezierPath()
//        path.moveToPoint(CGPoint(x: bounds.minX, y: align(origin.y)))
//        path.addLineToPoint(CGPoint(x: bounds.maxX, y: align(origin.y)))
//        path.moveToPoint(CGPoint(x: align(origin.x), y: bounds.minY))
//        path.addLineToPoint(CGPoint(x: align(origin.x), y: bounds.maxY))
//        path.stroke()
//        drawHashmarksInRect(bounds, origin: origin, pointsPerUnit: abs(pointsPerUnit))
//        CGContextRestoreGState(UIGraphicsGetCurrentContext())
//    }
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        if(!didSetOrigin){
            origin = CGPointMake(rect.width/2, rect.height/2)
        }
        graphAxes.drawAxesInRect(rect, origin: origin, pointsPerUnit: Scaling.PointsPerUnit*scale)
        didSetOrigin = true
        
        print(convertX(Int(rect.width)/2 - 5))
        print(convertX(Int(rect.width)/2))
        print(convertX(Int(rect.width)/2 + 5))
        
        print(dataSource?.getYValForXVal(self, x: convertX(Int(rect.width)/2 - 5)))
        print(dataSource?.getYValForXVal(self, x: convertX(Int(rect.width)/2)))
        print(dataSource?.getYValForXVal(self, x: convertX(Int(rect.width)/2 + 5)))
        
        print(convertFromY((dataSource?.getYValForXVal(self, x: convertX(Int(rect.width)/2 - 5)))!))
        print(convertFromY((dataSource?.getYValForXVal(self, x: convertX(Int(rect.width)/2)))!))
        print(convertFromY((dataSource?.getYValForXVal(self, x: convertX(Int(rect.width)/2 + 5)))!))
        
        
        //drawing of the function (if it exists)
        if let descripString = dataSource?.getDescriptionString(self){
            color.set()
            
            let path = UIBezierPath()
            for var i=0; i<Int(rect.width)-1; i++ {
                path.moveToPoint(CGPoint(x:CGFloat(i), y:convertFromY((dataSource?.getYValForXVal(self, x: convertX(i)))!)))
                
                let newY = dataSource?.getYValForXVal(self, x: convertX(i+1))
                if((newY != nil && newY?.isFinite != nil && newY?.isNormal != nil && newY?.isZero != nil)){
                    path.addLineToPoint(CGPoint(x:CGFloat(i+1), y:convertFromY((dataSource?.getYValForXVal(self, x: convertX(i+1)))!)))
                }
            }
            path.stroke()
        }
        
    }
    
    //converts from a pixel's X value to an X value on the graph
    private func convertX(x: Int)->CGFloat {
        return ((CGFloat(x) - origin.x)/(scale*Scaling.PointsPerUnit))
    }
    
    //converts from a Y value on the graph to a pixel's Y value
    private func convertFromY(y: CGFloat)->CGFloat {
        return ((-y*Scaling.PointsPerUnit)/(1/scale) + origin.y)
    }
    
    //scale from a pinch gesture
    func scale(gesture: UIPinchGestureRecognizer){
        if gesture.state == .Changed {
            scale *= gesture.scale
            //print(scale)
            gesture.scale = 1
        }
    }
    
    //for panning
    func origin(gesture: UIPanGestureRecognizer){
        if gesture.state == .Changed {
            //print("panning")
            let translation = gesture.translationInView(gesture.view)
            origin = CGPoint(x:origin.x + translation.x, y:origin.y + translation.y)
            gesture.setTranslation(CGPointZero, inView: gesture.view)
        }
    }
    
    //double tap
    func doubleTapped (gesture: UITapGestureRecognizer) {
        let newOrigin = gesture.locationInView(gesture.view)
        origin = newOrigin
    }
    

}
