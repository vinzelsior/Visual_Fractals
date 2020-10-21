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
    var colorWell: NSColorWell?
    
    
    // used for magicPlus
    
    var matrices: ContiguousArray<simd_float3x3>?
    
    
    @IBOutlet weak var skView: Fractal_View!
    
    var scene: SKScene?
    var camera = SKCameraNode()

    let motherNode = SKNode()
    
    var child: SKSpriteNode?
    
    var tileColor: NSColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 1)
    var stepperValue: Int = 0
    
    
    // for testing
    
    var start: DispatchTime = DispatchTime.now()
    var end: DispatchTime = DispatchTime.now()
    var nanoTime: UInt64 = 0
    
    var shader: SKShader?
    var colorUniform = SKUniform(name: "shader_color", vectorFloat4: vector_float4())

    // MARK: Delegates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene = SKScene(size: CGSize(width: skView.frame.width, height: skView.frame.height))
        scene?.backgroundColor = .clear
        
        scene?.camera = camera
        scene?.addChild(camera)
        
        scene?.addChild(motherNode)
        
        skView.showsNodeCount = true
        
        shader = SKShader(fileNamed: "Recolor.fsh")
        shader?.addUniform(colorUniform)

    }
    
    override func viewDidAppear() {
        toolbar = self.view.window?.toolbar
        
        progressIndicator = toolbar?.items.first(where: { $0.itemIdentifier.rawValue == "progressIndicator" })?.view as? NSProgressIndicator
        
        stepper = toolbar?.items.first(where: { $0.itemIdentifier.rawValue == "iterationStepper" })?.view as? NSStepper
        iterationValue = toolbar?.items.first(where: { $0.itemIdentifier.rawValue == "iterationValue" })?.view as? NSTextField
        startButton = toolbar?.items.first(where: { $0.itemIdentifier.rawValue == "startButton" })?.view as? NSButton
        saveButton = toolbar?.items.first(where: { $0.itemIdentifier.rawValue == "saveButton" })?.view as? NSButton
        colorWell = toolbar?.items.first(where: { $0.itemIdentifier.rawValue == "colorWell" })?.view as? NSColorWell
        
        colorWell!.color = tileColor
        
        colorUniform.vectorFloat4Value = simd_float4(Float(tileColor.redComponent),
                                                     Float(tileColor.greenComponent),
                                                     Float(tileColor.blueComponent),
                                                     Float(tileColor.alphaComponent))
        
        iterationValue?.stringValue = String( stepper!.intValue )
        
        progressIndicator?.isDisplayedWhenStopped = false
        progressIndicator?.isIndeterminate = true
        
        stepper!.action = #selector( steppedStepper(_:) )
        startButton!.action = #selector( startPressed(_:) )
        saveButton!.action = #selector( savePressed(_:) )
        colorWell!.action = #selector( colorChanged(_:) )
        
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
    /*
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
    */
    /*
    
    static let factor: Float = 1/2
    let patterns = [
        simd_float3x3(
            simd_float3(cos(angle) * 0.5, sin(angle), 1),
            simd_float3(-sin(angle), cos(angle) * 0.5, 1),
            simd_float3(0, 0, 1)
        ),
        
        simd_float3x3(
            simd_float3(cos(angle) * 0.5, sin(angle), 1),
            simd_float3(-sin(angle), cos(angle) * 0.5, -1),
            simd_float3(0, 0, 1)
        ),
        
        simd_float3x3(
            simd_float3(cos(angle) * 0.5, sin(angle), -1),
            simd_float3(-sin(angle), cos(angle) * 0.5, -1),
            simd_float3(0, 0, 1)
        ),
        
        simd_float3x3(
            simd_float3(cos(angle) * 0.5, sin(angle), -1),
            simd_float3(-sin(angle), cos(angle) * 0.5, 1),
            simd_float3(0, 0, 1)
        ),
        simd_float3x3(
            simd_float3(cos(angle), sin(angle), 0),
            simd_float3(-sin(angle), cos(angle), 0),
            simd_float3(0, 0, 1)
        )
    ]
    
    */
    
    
    static let factor: Float = 1/3
    let patterns = [
        simd_float3x3(
            simd_float3(cos(angle), sin(angle), sin(Float.pi * 2)),
            simd_float3(-sin(angle), cos(angle), cos(Float.pi * 2)),
            simd_float3(0, 0, 1)
        ),
        simd_float3x3(
            simd_float3(cos(angle), sin(angle), cos(Float.pi * 1/6)),
            simd_float3(-sin(angle), cos(angle), sin(Float.pi * 1/6)),
            simd_float3(0, 0, 1)
        ),
        simd_float3x3(
            simd_float3(cos(angle), sin(angle), sin(Float.pi * 2/6)),
            simd_float3(-sin(angle), cos(angle), -cos(Float.pi * 2/6)),
            simd_float3(0, 0, 1)
        ),
        simd_float3x3(
            simd_float3(cos(angle), sin(angle), sin(Float.pi)),
            simd_float3(-sin(angle), cos(angle), cos(Float.pi)),
            simd_float3(0, 0, 1)
        ),
        simd_float3x3(
            simd_float3(cos(angle), sin(angle), cos(Float.pi * 5/6)),
            simd_float3(-sin(angle), cos(angle), -sin(Float.pi * 5/6)),
            simd_float3(0, 0, 1)
        ),
        simd_float3x3(
            simd_float3(cos(angle), sin(angle), -sin(Float.pi * 4/6)),
            simd_float3(-sin(angle), cos(angle), -cos(Float.pi * 4/6)),
            simd_float3(0, 0, 1)
        )
        ]
    
    
    
    /*
    static let factor: Float = 1/2
    let patterns = [
            simd_float3x3(
                simd_float3(1, 0, 0.5),
                simd_float3(0, 1, 0),
                simd_float3(0, 0, 1)
            ),
            simd_float3x3(
                simd_float3(1, 0, -0.5),
                simd_float3(0, 1, 0),
                simd_float3(0, 0, 1)
            )
        ]
    
    */
    
    
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
    
    // in the future, say which pieces, so they can be displayed in tandem
    func displayPieces() {
        
        child?.removeFromParent()
        child = nil
        
        child = SKSpriteNode(color: .black, size: CGSize(width: 1, height: 1))
        child?.setScale(200)
        
        motherNode.addChild(child!)
        
        matrices?.forEach({
            /*
            var pnts = [CGPoint(x: 1, y: 0), CGPoint(x: -1, y: 0) ]
            
            let s = SKShapeNode(points: &pnts, count: 2)
            s.glowWidth = 0
            s.isAntialiased = false
            s.lineWidth = 0.1
            
            */
            let s = SKSpriteNode(color: tileColor, size: CGSize(width: 1, height: 1))
            s.shader = shader
            s.position = CGPoint(x: CGFloat($0.columns.0.z), y: CGFloat($0.columns.1.z))
            s.setScale(CGFloat($0.columns.0.x))
            s.zRotation = atan2(CGFloat($0.columns.1.x), CGFloat($0.columns.0.x))
                print(atan2(CGFloat($0.columns.1.x), CGFloat($0.columns.0.x)))
            
            // apply a shader to the elements, to change their color (not individually so far)
            
            //            t.addChild(s)
            child!.addChild(s)
            
        })
        print("done")
        
        progressIndicator?.stopAnimation(nil)
        
        
    }
    
    
    // eventually, discard this function for tasks or something. This could be solved better.
    
    private var finishedCounter = 0
    private func finished() {
        finishedCounter += 1
        
        if finishedCounter >= patterns.count {
            
            finishedCounter = 0
            
            end = DispatchTime.now()
            nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
            
            
            print("calculation time in nanoseconds: \(nanoTime)")
            
            // more than 3 million (!!!) ui elements could crash my computer / exceed ram needs...
            if matrices!.count < 3_000_000 {
                let concurrentQueue = DispatchQueue(label: "", qos: .userInitiated, attributes: .concurrent)
                
                concurrentQueue.async { [self] in displayPieces() }
            }
            
            skView.presentScene(scene)
        }
    }
    
    // MARK: @objc Functions
    
    
    
    @objc func startPressed(_ sender: Any) {
        
        progressIndicator?.startAnimation(nil)
       
        // this array only holds the last "layer", not all iterations
        matrices = ContiguousArray(repeating: simd_float3x3(), count: Int(pow(Double(patterns.count), Double(stepper!.intValue))))
        
        //print("Calculating Matrices...\n\(stepper!.intValue) iterations generate \(matrices!.count) visible elements.")
        
        // spread this work accross different cores
        
        // this piece of code also occurrs in the recursive function itself, but here we use it to distribute it
        
        let concurrentQueue = DispatchQueue(label: "", qos: .userInitiated, attributes: .concurrent)
        
        start = DispatchTime.now()
        
      
        
        
        for i in 0..<patterns.count {
            // go as deep as possible
            
            
            
            concurrentQueue.async { [self] in
                magicPlus(matrix: patterns[i] * simd_float3x3(simd_float3(ViewController.factor, 0, 0), simd_float3(0, ViewController.factor, 0), simd_float3(0, 0, 1)), iterations: 1, maximum: stepperValue, element: i)
                finished()
            }
            
            
            
        }
        
       
        
        
       
       
        //magicPlus(matrix: simd_float3x3(simd_float3(1, 0, 0), simd_float3(0, 1, 0), simd_float3(0, 0, 1)), iterations: 0, maximum: Int(stepper!.intValue), element: 0)
    }
    
    
    @objc func savePressed(_ sender: Any) {
        
        let previous = child!.xScale
       
        child!.scale(to: CGSize(width: 2048, height: 2048))
        
        let url = NSURL(fileURLWithPath: "/Users/cedriczwahlen/Downloads/fractal.png")
        
        let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypePNG, 1, nil)
        
        CGImageDestinationAddImage(destination!, skView.texture(from: child!)!.cgImage(), nil)
        
        CGImageDestinationFinalize(destination!)
        
        child!.setScale(previous)
        
    }
    
    @objc func steppedStepper(_ sender: Any) {
        
        stepperValue = Int(stepper!.intValue)
        
        iterationValue?.stringValue = String(stepperValue)
        
    }
    
    @objc func colorChanged(_ sender: Any) {
        
        tileColor = colorWell!.color
        
        colorUniform.vectorFloat4Value = simd_float4(Float(tileColor.redComponent),Float(tileColor.greenComponent),Float(tileColor.blueComponent),Float(tileColor.alphaComponent))
        
    }
    
    // MARK: Storyboard Functions
    private var cameraScale = CGFloat()
    
    @IBAction func magnification(_ sender: Any) {
       
        guard let gestureRecognizer = sender as? NSMagnificationGestureRecognizer else { return }
        
        if gestureRecognizer.state == .changed {
            
           // print(gestureRecognizer.magnification)
            
            let s = gestureRecognizer.magnification
            
            cameraScale += s
            
            if cameraScale <= 0 {
                cameraScale = 0
            }
            
            var appliedScale = 1 / cameraScale
            
            if appliedScale >= 0.5 {
                appliedScale = 0.5
            }
            
            
            scene!.camera!.setScale( appliedScale )
            
        }
        
    }
    
}

