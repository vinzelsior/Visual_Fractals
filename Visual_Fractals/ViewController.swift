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
    
    
    @IBOutlet weak var skView: Fractal_View!
    
    var scene: SKScene?
    var camera = SKCameraNode()

    let motherNode = SKNode()
    
    var child: SKNode?

    // MARK: Delegates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene = SKScene(size: CGSize(width: skView.frame.width, height: skView.frame.height))
        scene?.backgroundColor = .clear
        
        scene?.camera = camera
        scene?.addChild(camera)
        
        
        
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
        
        camera.position = CGPoint(x: scene!.frame.width / 2, y: scene!.frame.height / 2)
        
        
    }
    
    // MARK: Functions MagicPlus
    
    static let angle: Float = 0
    
    static let factor: Float = 1/3
    let patterns = [
        simd_float3x3(
            simd_float3(cos(angle), sin(angle), 1),
            simd_float3(-sin(angle), cos(angle), 1),
            simd_float3(0, 0, 1)
        ),
        simd_float3x3(
            simd_float3(cos(angle), sin(angle), 1),
            simd_float3(-sin(angle), cos(angle), 0),
            simd_float3(0, 0, 1)
        ),
        simd_float3x3(
            simd_float3(cos(angle), sin(angle), 1),
            simd_float3(-sin(angle), cos(angle), -1),
            simd_float3(0, 0, 1)
        ),
        simd_float3x3(
            simd_float3(cos(angle), sin(angle), 0),
            simd_float3(-sin(angle), cos(angle), -1),
            simd_float3(0, 0, 1)
        ),
        simd_float3x3(
            simd_float3(cos(angle), sin(angle), -1),
            simd_float3(-sin(angle), cos(angle), -1),
            simd_float3(0, 0, 1)
        ),
        simd_float3x3(
            simd_float3(cos(angle), sin(angle), -1),
            simd_float3(-sin(angle), cos(angle), 0),
            simd_float3(0, 0, 1)
        ),
        simd_float3x3(
            simd_float3(cos(angle), sin(angle), -1),
            simd_float3(-sin(angle), cos(angle), 1),
            simd_float3(0, 0, 1)
        ),
        simd_float3x3(
            simd_float3(cos(angle), sin(angle), 0),
            simd_float3(-sin(angle), cos(angle), 1),
            simd_float3(0, 0, 1)
        )
    ]
    
    
    
    
    
    /*
    
     static let factor: Float = 1/2
    let patterns = [
            simd_float3x3(
                simd_float3(cos(angle), sin(angle), sin(Float.pi * 2)),
                simd_float3(-sin(angle), cos(angle), cos(Float.pi * 2)),
                simd_float3(0, 0, 1)
            ),
            simd_float3x3(
                simd_float3(cos(angle), sin(angle), cos(Float.pi / -6)),
                simd_float3(-sin(angle), cos(angle), sin(Float.pi / -6)),
                simd_float3(0, 0, 1)
            ),
            simd_float3x3(
                simd_float3(cos(angle), sin(angle), sin(Float.pi / (-6 / 2))),
                simd_float3(-sin(angle), cos(angle), -cos(Float.pi / (-6 / 2))),
                simd_float3(0, 0, 1)
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
        
        // generate these new matrices based on the one provided
        for i in 0..<patterns.count {
            let newMatrix = matrix * patterns[i] * simd_float3x3(simd_float3(ViewController.factor, 0, 0), simd_float3(0, ViewController.factor, 0), simd_float3(0, 0, 1))
       
            // go as deep as possible
            magicPlus(matrix: newMatrix, iterations: ii, maximum: maximum, element: element * patterns.count + i)
            
        }
        
    }
    
    // MARK: Functions for AdvancedMagic
    
    
    let concurrentQueue = DispatchQueue(label: "", qos: .userInitiated, attributes: .concurrent)
   
    
    // MARK: @objc Functions
    
    @objc func startPressed(_ sender: Any) {
       
        child?.removeFromParent()
        
        child = SKNode()
        
        motherNode.addChild(child!)
        
        // this array only holds the last "layer", not all iterations
        matrices = Array(repeating: simd_float3x3(), count: Int(pow(Double(patterns.count), Double(stepper!.intValue))))
        
        magicPlus(matrix: simd_float3x3(simd_float3(1, 0, 0), simd_float3(0, 1, 0), simd_float3(0, 0, 1)), iterations: 0, maximum: Int(stepper!.intValue), element: 0)
        
        matrices?.forEach({
            
            
            let t = SKTransformNode()
            
            
            // if you want normal display, and not "spherical", remove the following line
//            t.setRotationMatrix($0)
            child!.addChild(t)
            
            
            let s = SKSpriteNode(color: .cyan, size: CGSize(width: 1, height: 1))
            s.position = CGPoint(x: CGFloat($0.columns.0.z), y: CGFloat($0.columns.1.z))
            s.setScale(CGFloat($0.columns.0.x))
            
            t.addChild(s)
            
        })
        
        skView.presentScene(scene)
        
        child?.setScale(200)
        
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
    
    var relativeScale = CGFloat()
    
    @IBAction func magnification(_ sender: Any) {
       
        guard let gestureRecognizer = sender as? NSMagnificationGestureRecognizer else { return }
        
        if gestureRecognizer.state == .began {
            relativeScale = gestureRecognizer.magnification
        }
        
        if gestureRecognizer.state == .changed {
            
            
            
            let s = gestureRecognizer.magnification
            
            let moveBy = relativeScale - s
            
            relativeScale = s
            
            let newS = scene!.camera!.xScale
            
            scene!.camera!.setScale(newS + moveBy)
            
        }
        
    }
    
}

