// Playground - Tower of Hanoi in Swift

import Cocoa
import QuartzCore
import SceneKit
import XCPlayground

let animationDuration = 1.0

struct HanoiDisk : Hashable, Equatable {
    var size: Int
    
    var hashValue: Int { get { return self.size } }
}

func == (lhs: HanoiDisk, rhs: HanoiDisk) -> Bool {
    return lhs.size == rhs.size
}

enum HanoiPeg {
    case First
    case Second
    case Third
}

struct HanoiPuzzle {
    var firstPeg: Array<HanoiDisk> { get { return self.pegs[HanoiPeg.First]! } }
    var secondPeg: Array<HanoiDisk> { get { return self.pegs[HanoiPeg.Second]! } }
    var thirdPeg: Array<HanoiDisk> { get { return self.pegs[HanoiPeg.Third]! } }
    
    var pegs: Dictionary<HanoiPeg, Array<HanoiDisk>>
    
    init(firstPeg: Array<HanoiDisk>, secondPeg: Array<HanoiDisk>, thirdPeg: Array<HanoiDisk>) {
        self.pegs = [ HanoiPeg.First: firstPeg,
                        HanoiPeg.Second: secondPeg,
                        HanoiPeg.Third: thirdPeg ]
    }
    
    init(numberOfDisks: Int){
        var firstPeg = Array(0..numberOfDisks).map { HanoiDisk(size: numberOfDisks - $0) }
        var secondPeg = Array<HanoiDisk>()
        var thirdPeg = Array<HanoiDisk>()
        
        // TODO: Chaining initializers slows down the playground?
        //self.init(firstPeg: firstPeg, secondPeg: secondPeg, thirdPeg: thirdPeg)
        
        self.pegs = [ HanoiPeg.First: firstPeg,
                        HanoiPeg.Second: secondPeg,
                        HanoiPeg.Third: thirdPeg ]
    }
    
    func moveDiskFromPeg(fromPeg: HanoiPeg, toPeg: HanoiPeg) -> HanoiPuzzle {
        var pegsCopy = self.pegs
        
        var fromPegCopy = pegsCopy[fromPeg]!.copy()
        var toPegCopy = pegsCopy[toPeg]!.copy()
        toPegCopy.append(fromPegCopy.removeLast())
        
        pegsCopy[fromPeg] = fromPegCopy
        pegsCopy[toPeg] = toPegCopy
        
        return HanoiPuzzle(firstPeg: pegsCopy[HanoiPeg.First]!, secondPeg: pegsCopy[HanoiPeg.Second]!, thirdPeg: pegsCopy[HanoiPeg.Third]!)
    }
}

struct HanoiSolverStep {
    var initialState: HanoiPuzzle
    var resultState: HanoiPuzzle
    var sourcePeg: HanoiPeg
    var destinationPeg: HanoiPeg
    
    init(initialState: HanoiPuzzle, resultState: HanoiPuzzle, sourcePeg: HanoiPeg, destinationPeg: HanoiPeg) {
        self.initialState = initialState
        self.resultState = resultState
        self.sourcePeg = sourcePeg
        self.destinationPeg = destinationPeg
    }
}

protocol HanoiSolverStepDelegate {
    func stepMade(initialState: HanoiPuzzle, resultState: HanoiPuzzle, sourcePeg: HanoiPeg, destinationPeg: HanoiPeg) -> Void
}

struct HanoiSolver {
    var stepDelegate: HanoiSolverStepDelegate?
    
    init(delegate: HanoiSolverStepDelegate?) {
        self.stepDelegate = delegate;
    }
    
    func solve(puzzle: HanoiPuzzle) -> HanoiPuzzle {
        var bottomDisk = puzzle.firstPeg[0]
        return solveRec(puzzle, diskSize: bottomDisk.size, sourcePeg: HanoiPeg.First, destPeg: HanoiPeg.Third, tempPeg: HanoiPeg.Second)
    }
    
    func solveRec(puzzle: HanoiPuzzle, diskSize: Int, sourcePeg: HanoiPeg, destPeg: HanoiPeg, tempPeg: HanoiPeg) -> HanoiPuzzle
    {
        if 1 == diskSize {
            return moveDisk(puzzle, fromPeg: sourcePeg, toPeg: destPeg)
        }
        else {
            let smallerDisksMoved = solveRec(puzzle, diskSize: diskSize - 1, sourcePeg: sourcePeg, destPeg: tempPeg, tempPeg: destPeg)
            let smallerDisksRemaining = moveDisk(smallerDisksMoved, fromPeg: sourcePeg, toPeg: destPeg)
            return solveRec(smallerDisksRemaining, diskSize: diskSize - 1, sourcePeg: tempPeg, destPeg: destPeg, tempPeg: sourcePeg)
        }
    }
    
    func moveDisk(puzzle: HanoiPuzzle, fromPeg: HanoiPeg, toPeg: HanoiPeg) -> HanoiPuzzle {
        var result = puzzle.moveDiskFromPeg(fromPeg, toPeg: toPeg)
        
        if let nonNilStepDelegate = self.stepDelegate {
            nonNilStepDelegate.stepMade(puzzle, resultState: result, sourcePeg: fromPeg, destinationPeg: toPeg)
        }
        
        return result
    }
}

// It does not appear to be possible to customize quicklook output for a struct.  Boo.
class HanoiPuzzleQuickLookHelper : NSObject {
    var puzzle: HanoiPuzzle
    
    init(puzzle: HanoiPuzzle) {
        self.puzzle = puzzle;
    }
    
    func debugQuickLookObject() -> AnyObject? {
        let pegs = [self.puzzle.firstPeg, self.puzzle.secondPeg, self.puzzle.thirdPeg];
        let retVal = pegs.map { "\($0.map { $0.size })" }.reduce("") { $0 + $1 }
        return retVal
    }
}

class HanoiPuzzleSolverStepQuickLookDelegate : HanoiSolverStepDelegate {
    var puzzleSteps : Array<HanoiPuzzle>

    init() {
        self.puzzleSteps = Array<HanoiPuzzle>()
    }

    func stepMade(initialState: HanoiPuzzle, resultState: HanoiPuzzle, sourcePeg: HanoiPeg, destinationPeg: HanoiPeg) -> Void {
        self.puzzleSteps.append(resultState)
    }
}

let pipeRadius = 0.25
let maxDiskRadius = 0.5

class HanoiDiskView : SCNTorus {
    var color : NSColor
    
    init(radius: CGFloat, color: NSColor) {
        self.color = color
        
        super.init()
        self.ringRadius = radius
        self.pipeRadius = pipeRadius
        
        self.firstMaterial.diffuse.contents = color
        self.firstMaterial.specular.contents = NSColor.whiteColor()
    }
}

class HanoiView : SCNView {
    var disks: Dictionary<HanoiDisk, SCNNode>
    let diskColors = [
        NSColor.blueColor(),
        NSColor.greenColor(),
        NSColor.redColor(),
        NSColor.yellowColor()
    ]
    
    init(frame: NSRect) {
        self.disks = Dictionary<HanoiDisk, SCNNode>()
        super.init(frame: frame)
        
        var scene = SCNScene()
        
        var camera = SCNCamera()
        var cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 1, z: 3)
        scene.rootNode.addChildNode(cameraNode)
        
        var lightAbove = SCNLight()
        lightAbove.type = SCNLightTypeOmni
        var lightAboveNode = SCNNode()
        lightAboveNode.position = SCNVector3(x: 0, y: 5, z: 0)
        lightAboveNode.light = lightAbove
        scene.rootNode.addChildNode(lightAboveNode)
        
        var lightDirectional = SCNLight()
        lightDirectional.type = SCNLightTypeDirectional
        cameraNode.light = lightDirectional
        
        var floor = SCNFloor()
        floor.reflectivity = 0.25
        var floorNode = SCNNode(geometry: floor)
        scene.rootNode.addChildNode(floorNode)
        
        self.scene = scene
    }
    
    func positionDisk(diskNode: SCNNode, xLocation: Int, yLocation: Int) -> Void {
        
        let verticalSpacing = 2.1 * pipeRadius
        let horizontalSpacing = 4 * maxDiskRadius
        
        SCNTransaction.setAnimationDuration(animationDuration)
        diskNode.position = SCNVector3(
            x: horizontalSpacing * CGFloat(xLocation - 1),
            y: pipeRadius + verticalSpacing * CGFloat(yLocation),
            z: 0
        )
    }
    
    func drawPuzzle(puzzle: HanoiPuzzle) -> Void {
        let pegs = [ puzzle.firstPeg, puzzle.secondPeg, puzzle.thirdPeg]
        
        // TODO: shorthand for count, sum?
        let numDisks = pegs.map({ (peg) -> Int in
            return peg.count
        }).reduce(0, { (acc, count) -> Int in
            return acc + count
        })
        
        for var xIndex = 0; xIndex < pegs.count; xIndex++ {
            let peg = pegs[xIndex]
            for var yIndex = 0; yIndex < peg.count; yIndex++ {
                var disk = peg[yIndex]
                var diskView = self.getDiskView(disk, maxSize: numDisks)
                
                positionDisk(diskView, xLocation: xIndex, yLocation: yIndex)
            }
        }
    }
    
    func getDiskView(disk: HanoiDisk, maxSize: Int) -> SCNNode {
        if let existingDisk = self.disks[disk] {
            return existingDisk
        }
        else {
            var diskRadius = self.diskRadiusForSize(disk.size, maxSize: maxSize)
            var diskColor = self.diskColorForSize(disk.size, maxSize: maxSize)
            
            var newDiskView = HanoiDiskView(
                radius: diskRadius,
                color: diskColor
            )
            
            var diskNode = SCNNode(geometry: newDiskView)
            self.disks[disk] = diskNode
            self.scene.rootNode.addChildNode(diskNode)
            
            return diskNode
        }
    }
    
    func diskColorForSize(diskSize: Int, maxSize: Int) -> NSColor {
        return self.diskColors[diskSize % (maxSize - 1)]
    }
    
    func diskRadiusForSize(diskSize: Int, maxSize: Int) -> CGFloat {
        var halfRadius = self.maxRadius() / 2
        return halfRadius + (CGFloat(diskSize) / CGFloat(maxSize)) * halfRadius
    }
    
    func maxRadius() -> CGFloat {
        return maxDiskRadius
    }
}

class PuzzleAnimator : NSObject {
    var puzzleView: HanoiView
    var puzzleSteps: Array<HanoiPuzzle>
    var timer : NSTimer?
    
    init(puzzleView: HanoiView, puzzleSteps: Array<HanoiPuzzle>)
    {
        self.puzzleView = puzzleView
        self.puzzleSteps = puzzleSteps.reverse()
        
        super.init()
    }
    
    func start() -> Void {
        var timer = NSTimer(timeInterval: animationDuration, target: self, selector: "renderStep", userInfo: nil, repeats: true)
        self.timer = timer
        
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    func renderStep() -> Void {
        if self.puzzleSteps.isEmpty {
            self.timer!.invalidate()
            return
        }
        
        var step = self.puzzleSteps.removeLast()
        self.puzzleView.drawPuzzle(step)
    }
}

let puzzle = HanoiPuzzle(numberOfDisks: 5)
let puzzleDelegate = HanoiPuzzleSolverStepQuickLookDelegate()
let result = HanoiSolver(delegate: puzzleDelegate).solve(puzzle)

// These two lines crash the playground:
// var puzzleSteps = puzzleDelegate.puzzleSteps
// var puzzleSteps = puzzleDelegate.puzzleSteps.copy()
// Instead, manually copy the puzzle steps.  I am probably misunderstanding something but this could be a Playground beta bug.
var puzzleSteps = Array<HanoiPuzzle>()
puzzleSteps.append(puzzle)
for step in puzzleDelegate.puzzleSteps {
    puzzleSteps.append(step)
}
// End Workaround

for step in puzzleSteps {
    HanoiPuzzleQuickLookHelper(puzzle: step)
}

var height = 300.0
var width = 600.0
var hanoiView = HanoiView(frame: NSRect(x: 0, y: 0, width: width, height: height))

XCPShowView("hanoiView", hanoiView)
var puzzleAnimator = PuzzleAnimator(puzzleView: hanoiView, puzzleSteps: puzzleSteps)
puzzleAnimator.start()

