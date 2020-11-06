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
    
    var visibleMaxX = CGFloat()
    var visibleMaxY = CGFloat()
    var visibleMinX = CGFloat()
    var visibleMinY = CGFloat()
    
    override func mouseDown(with event: NSEvent) {
        relativePoint = event.location(in: scene! )
    }
    
    override func mouseDragged(with event: NSEvent) {
        
        let p = event.location(in: scene! )
        
        let moveBy = CGPoint(x: relativePoint.x - p.x, y: relativePoint.y - p.y)
        
        relativePoint = p
        
        let newP = scene!.childNode(withName: "mother")!.position
        
        let motherPos = CGPoint(x: newP.x - moveBy.x, y: newP.y - moveBy.y)
        
        scene!.childNode(withName: "mother")!.position = motherPos
        
        // the position of the mothernode needs to be applied to the check in magicplus as well.
        if let camera = scene?.camera {
            visibleMaxX = (scene!.frame.width / 2 - motherPos.x) + (scene!.frame.width * camera.xScale) / 2
            visibleMinX = (scene!.frame.width / 2 - motherPos.x) + -(scene!.frame.width * camera.xScale) / 2
            
            visibleMaxY = (scene!.frame.height / 2 - motherPos.y) + (scene!.frame.height * camera.yScale) / 2
            visibleMinY = (scene!.frame.height / 2 - motherPos.y) + -(scene!.frame.height * camera.yScale) / 2
            
            print("maxX: \(visibleMaxX), minX: \(visibleMinX)")
            print("maxY: \(visibleMaxY), minY: \(visibleMinY)")
        }
        
        
        
    }
    
    
   
}
