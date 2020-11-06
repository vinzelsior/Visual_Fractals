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
        relativePoint = event.location(in: scene! )
    }
    
    override func mouseDragged(with event: NSEvent) {
        
        let p = event.location(in: scene! )
        
        let moveBy = CGPoint(x: relativePoint.x - p.x, y: relativePoint.y - p.y)
        
        relativePoint = p
        
        let newP = scene!.childNode(withName: "mother")!.position
        
        scene!.childNode(withName: "mother")!.position = CGPoint(x: newP.x - moveBy.x, y: newP.y - moveBy.y)
        
        
    }
    
    
   
}
