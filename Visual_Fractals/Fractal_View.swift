//
//  Fractal_View.swift
//  Visual_Fractals
//
//  Created by Cedric Zwahlen on 19.10.20.
//

import Foundation
import SpriteKit

class Fractal_View: SKView {
    
    var relativePoint = CGPoint()
    
    override func mouseDown(with event: NSEvent) {
        relativePoint = event.location(in: scene!.camera! )
    }
    
    override func mouseDragged(with event: NSEvent) {
        
        let p = event.location(in: scene!.camera! )
        
        let moveBy = CGPoint(x: relativePoint.x - p.x, y: relativePoint.y - p.y)
        
        relativePoint = p
        
        let newP = scene!.camera!.position
        
        scene!.camera!.position = CGPoint(x: newP.x + moveBy.x, y: newP.y + moveBy.y)
        
        
    }
    
    
   
}
