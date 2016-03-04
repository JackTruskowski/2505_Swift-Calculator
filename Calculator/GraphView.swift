//
//  GraphView.swift
//  Calculator
//
//  Created by John Truskowski on 3/4/16.
//  Copyright © 2016 John Truskowski. All rights reserved.
//

import UIKit

class GraphView: UIView {
    
    var graphAxes = AxesDrawer();

    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        let newOrigin = CGPointMake(rect.width/2, rect.height/2)
        graphAxes.drawAxesInRect(rect, origin: newOrigin, pointsPerUnit: 50.0)
        
    }
    

}
