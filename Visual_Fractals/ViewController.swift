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
    
    
    // used for magicPlus
    
    var matrices: [simd_float3x3]?
    
    
    @IBOutlet weak var skView: SKView!
    
    var scene: SKScene?

    let motherNode = SKNode()
    
    var child: SKContainerNode?

    // MARK: Delegates
    
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
    
    override func viewDidLayout() {
        
        scene?.size = skView.frame.size
        motherNode.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 2)
        
        
    }
    
    // MARK: Functions MagicPlus
    
    
    /*
     
     
     let newMatrix = simd_float3x3(
         simd_float3(2, 2, 0),
         simd_float3(1, 2, 3),
         simd_float3(0, 0, 4)
     ) + ( simd_float3x3(
             simd_float3(2, 2, 0),
             simd_float3(1, 2, 3),
             simd_float3(0, 0, 4)
     ) * 0.5 )
     
     */
    
    /*
     
     translate:
     
     0 0 tx
     0 0 ty
     0 0 0
     
     rotate:
     
     cos(angle) sin(angle) 0
     -sin(angle) cos(angle) 0
     0 0 0
     
     scale:
     
     xScale 0 0
     0 yScale 0
     0 0 1
     
     */
    
    static let scl: Float = 1
    
    let patterns = [
        simd_float3x3(
            simd_float3(scl, 0, sin(Float.pi * 2)),
            simd_float3(0, scl, cos(Float.pi * 2)),
            simd_float3(0, 0, scl)
        ),
        simd_float3x3(
            simd_float3(scl, 0, cos(Float.pi / -6)),
            simd_float3(0, scl, sin(Float.pi / -6)),
            simd_float3(0, 0, scl)
        ),
        simd_float3x3(
            simd_float3(scl, 0, sin(Float.pi / (-6 / 2))),
            simd_float3(0, scl, -cos(Float.pi / (-6 / 2))),
            simd_float3(0, 0, scl)
        )
    ]
    
    /*
    let patterns = [
        simd_float3x3(
            simd_float3(scl, 0, 1),
            simd_float3(0, scl, 1),
            simd_float3(0, 0, scl)
        ),
        simd_float3x3(
            simd_float3(scl, 0, 1),
            simd_float3(0, scl, 0),
            simd_float3(0, 0, scl)
        ),
        simd_float3x3(
            simd_float3(scl, 0, 1),
            simd_float3(0, scl, -1),
            simd_float3(0, 0, scl)
        ),
        simd_float3x3(
            simd_float3(scl, 0, 0),
            simd_float3(0, scl, -1),
            simd_float3(0, 0, scl)
        ),
        simd_float3x3(
            simd_float3(scl, 0, -1),
            simd_float3(0, scl, -1),
            simd_float3(0, 0, scl)
        ),
        simd_float3x3(
            simd_float3(scl, 0, -1),
            simd_float3(0, scl, 0),
            simd_float3(0, 0, scl)
        ),
        simd_float3x3(
            simd_float3(scl, 0, -1),
            simd_float3(0, scl, 1),
            simd_float3(0, 0, scl)
        ),
        simd_float3x3(
            simd_float3(scl, 0, 0),
            simd_float3(0, scl, 1),
            simd_float3(0, 0, scl)
        )
    ]
    */
    func magicPlus(matrix: simd_float3x3, iterations: Int, maximum: Int, element: Int) {
        
        // once we have reached the maximum depth, add the matrice to the array
        if (iterations == maximum) {
            
            // add the matrix to the array here
            matrices![element] = matrix
           
            return
        }
        
        let ii = iterations + 1
        
        let multiplier = pow(2,Float(ii))
        
        // generate these new matrices based on the one provided
        for i in 0..<patterns.count {
            var newMatrix = matrix + ( patterns[i] * (1 / multiplier ) )
            
            print(ViewController.scl * (1 / pow(2,Float(ii)) ) )
                                    
                                    // to be honest, it was an accident that i squared scl... but it works so...
            newMatrix.columns.0.x = ViewController.scl * ViewController.scl * (1 / multiplier )
            newMatrix.columns.1.y = ViewController.scl * ViewController.scl * (1 / multiplier )
            
            // go as deep as possible
            magicPlus(matrix: newMatrix, iterations: ii, maximum: maximum, element: element * patterns.count + i)
            
        }
        
        
                                            // 0.5 has to be determined beforehand, or could be calculated as well...
    
        
    }
    
    // MARK: Functions for AdvancedMagic
    
    /*
    
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
    */
    
    let shapeSize = 10
    
    
    
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
    
    
    let concurrentQueue = DispatchQueue(label: "", qos: .userInitiated, attributes: .concurrent)
    
    func advancedMagic(node: SKNode, iterations: Int, maximum: Int) {
        
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
        
        // veeeery dangerous
        
        if iterations == maximum - 1 {
            
            print("new queue")
            
            

            concurrentQueue.async {
                node.children.forEach({ self.advancedMagic(node: $0.children.first!, iterations: ii, maximum: maximum) })
                
            }
            
            
        } else {
            node.children.forEach({ advancedMagic(node: $0.children.first!, iterations: ii, maximum: maximum) })
        }
        
        
        
        
            
        //}
    }
    
    // MARK: @objc Functions
    
    @objc func startPressed(_ sender: Any) {
        /*
        child?.removeFromParent()
        
        child = makeNode()
        
        progressIndicator!.startAnimation(nil)
        
        // nr of shapes pow iterations
        
        motherNode.addChild(child!)
        
        
        DispatchQueue.main.async {
            self.advancedMagic(node: self.child!, iterations: Int(self.stepper!.intValue), maximum: Int(self.stepper!.intValue))
            
            self.progressIndicator!.stopAnimation(nil)
        }
        
        
        
        
        skView.presentScene(scene)
        
        child?.setScale(30)
 
 */
        child?.removeFromParent()
        
        child = SKContainerNode()
        
        motherNode.addChild(child!)
        
        // this array only holds the last "layer", not all iterations
        matrices = Array(repeating: simd_float3x3(), count: Int(pow(Double(patterns.count), Double(stepper!.intValue))))
       
        //Array<Any>(unsafeUninitializedCapacity: , initializingWith: matrices)
        
        print(matrices?.count)
        
        magicPlus(matrix: simd_float3x3(), iterations: 0, maximum: Int(stepper!.intValue), element: 0)
        
        
       
        matrices?.forEach({
            
            let s = SKSpriteNode(color: .cyan, size: CGSize(width: 1, height: 1))
            
            s.position = CGPoint(x: CGFloat($0.columns.0.z), y: CGFloat($0.columns.1.z))
             
            s.xScale = CGFloat($0.columns.0.x)
            s.yScale = CGFloat($0.columns.1.y)
            
            child!.addChild(s)
            
        })
        
        skView.presentScene(scene)
        
        child?.setScale(100)
        
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
    
    
}

