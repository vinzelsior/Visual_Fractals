//
//  ViewController.swift
//  Visual_Fractals
//
//  Created by Cedric Zwahlen on 08.10.20.
//

import Cocoa
import SpriteKit

class ViewController: NSViewController, NSToolbarDelegate {
    
    // toolbar and items
    var toolbar: NSToolbar?
    
    var progressIndicator: NSProgressIndicator?
    var stepper: NSStepper?
    var iterationValue: NSTextField?
    var startButton: NSButton?
    var saveButton: NSButton?
    
    
    
    
    @IBOutlet weak var skView: SKView!
    
    var scene: SKScene?

    let motherNode = SKNode()
    
    var child: SKContainerNode?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene = SKScene(size: CGSize(width: skView.frame.width, height: skView.frame.height))
        scene?.backgroundColor = .clear
        
        scene?.addChild(motherNode)
        
        skView.showsNodeCount = true

    }
    
    override func viewDidAppear() {
        toolbar = self.view.window?.toolbar
        
        progressIndicator = toolbar?.items.first(where: { $0.itemIdentifier.rawValue == "progressIndicator" })?.view as? NSProgressIndicator
        
        stepper = toolbar?.items.first(where: { $0.itemIdentifier.rawValue == "iterationStepper" })?.view as? NSStepper
        iterationValue = toolbar?.items.first(where: { $0.itemIdentifier.rawValue == "iterationValue" })?.view as? NSTextField
        startButton = toolbar?.items.first(where: { $0.itemIdentifier.rawValue == "startButton" })?.view as? NSButton
        saveButton = toolbar?.items.first(where: { $0.itemIdentifier.rawValue == "saveButton" })?.view as? NSButton
        
        iterationValue?.stringValue = String( stepper!.intValue )
        
        progressIndicator?.isDisplayedWhenStopped = false
        progressIndicator?.isIndeterminate = true
        
        stepper!.action = #selector( steppedStepper(_:) )
        startButton!.action = #selector( startPressed(_:))
        saveButton!.action = #selector( savePressed(_:) )
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func makeNode() -> SKContainerNode {
        
        let testNode = SKContainerNode()
        
        let n = SKNode()
        n.position = CGPoint(x: 10, y: 10)
//        n.setScale(0.3)
        testNode.addChild(n)
        
        let nn = SKNode()
        nn.position = CGPoint(x: -10, y: -10)
//        nn.setScale(0.3)
        testNode.addChild(nn)
        
        
        let nnn = SKNode()
        nnn.position = CGPoint(x: -10, y: 10)
//        nnn.setScale(0.3)
        testNode.addChild(nnn)
        
        let nnnn = SKNode()
        nnnn.position = CGPoint(x: 10, y: -10)
//        nnnn.setScale(0.3)
        testNode.addChild(nnnn)
        
        let m = SKNode()
        m.position = CGPoint(x: 0, y: 10)
//        m.setScale(0.3)
        testNode.addChild(m)
        
        let mm = SKNode()
        mm.position = CGPoint(x: 0, y: -10)
//        mm.setScale(0.3)
        testNode.addChild(mm)
        
        
        let mmm = SKNode()
        mmm.position = CGPoint(x: -10, y: 0)
//        mmm.setScale(0.3)
        testNode.addChild(mmm)
       
        let mmmm = SKNode()
        mmmm.position = CGPoint(x: 10, y: 0)
//        mmmm.setScale(0.3)
        testNode.addChild(mmmm)
        
        testNode.setScale(1/3)
        
        return testNode
    }
    
    
    let shapeSize = 10
    
    /*
    
    func makeNode() -> SKContainerNode {
        
        let testNode = SKContainerNode()
        
        let n = SKNode()
        n.position = CGPoint(x: sin(Double.pi * 2) * 10, y: cos(Double.pi * 2) * 10)
        
        testNode.addChild(n)
        
        let nn = SKNode()
        nn.position = CGPoint(x: cos(Double.pi / -6) * 10, y: sin(Double.pi / -6) * 10)

        testNode.addChild(nn)
        
        let nnn = SKNode()
        nnn.position = CGPoint(x: sin(Double.pi / (-6 / 2)) * 10, y: cos(Double.pi / (-6 / 2)) * -10)
        
        testNode.addChild(nnn)
        
        testNode.setScale(0.5)
        
        return testNode
    }
    */
    func advancedMagic(node: SKNode, iterations: Int) {
        
        if (iterations == 0) { return }
        
        let ii = iterations - 1
        
       // if node as? SKContainerNode != nil {
           
        node.children.forEach({
            
            let n = makeNode()
//            print($0.zPosition)
//            $0.zPosition = CGFloat(ii)
//            print($0.zPosition)
            n.zPosition = CGFloat($0.zPosition - 1)
            
            if ii - 1 == -1 {
                let s = SKSpriteNode(color: .cyan, size: CGSize(width: shapeSize, height: shapeSize))
                $0.addChild(s)
                
                // in a loop, use continue instead...
                return
            } else {
                $0.addChild(n)
            }
        })
        
        /*
        for nd in node.children {
            
            let n = makeNode()
            
            n.zPosition = CGFloat(nd.zPosition - 1)
            
            if ii - 1 == -1 {
                
                DispatchQueue.main.async {
                    let s = SKSpriteNode(color: .cyan, size: CGSize(width: self.shapeSize, height: self.shapeSize))
                    nd.addChild(s)
                    
                }
                
               
                
                // in a loop, use continue instead...
                return
            } else {
                nd.addChild(n)
            }
        
        }
        
        */
        node.children.forEach({ advancedMagic(node: $0.children.first!, iterations: ii) })
            
        //}
    }
    
    @objc func startPressed(_ sender: Any) {
        
        child?.removeFromParent()
        
        child = makeNode()
        
        progressIndicator!.startAnimation(nil)
        
        // nr of shapes pow iterations
        
        motherNode.addChild(child!)
        
        DispatchQueue.main.async {
            self.advancedMagic(node: self.child!, iterations: Int(self.stepper!.intValue))
            
            self.progressIndicator!.stopAnimation(nil)
        }
        
        
       
//            self.advancedMagic(node: self.child!, iterations: Int(self.stepper!.intValue))
            
//            self.progressIndicator!.stopAnimation(nil)
        
        
        
        
        child?.setScale(30)
    }
    
    @objc func savePressed(_ sender: Any) {
        
        let url = NSURL(fileURLWithPath: "/Users/cedriczwahlen/Downloads/fractal.png")
        
        let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypePNG, 1, nil)
        
        CGImageDestinationAddImage(destination!, skView.texture(from: child!)!.cgImage(), nil)
        
        CGImageDestinationFinalize(destination!)
    }
    
    @objc func steppedStepper(_ sender: Any) {
        
        iterationValue?.stringValue = String(stepper!.intValue)
        
    }
    
    override func viewDidLayout() {
        
        scene?.size = skView.frame.size
        motherNode.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 2)
        skView.presentScene(scene)
        
    }
}

