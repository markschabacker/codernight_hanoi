// Playground - Tower of Hanoi in Swift

import Cocoa
import XCPlayground

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

class HanoiDiskView : NSView {
    init(frame: NSRect) {
        super.init(frame: frame)
    }
    
    override func drawRect(dirtyRect: NSRect) {
        var cornerRadius = self.frame.height / 2
        var path = NSBezierPath(roundedRect: dirtyRect, xRadius: cornerRadius, yRadius: cornerRadius)
        path.fill()
    }
    
    func setCenter(point: CGPoint) -> Void {
        let halfWidth = self.frame.width / 2
        let halfHeight = self.frame.height / 2
        self.frame.origin = CGPoint(x: point.x - halfWidth, y: point.y - halfHeight)
    }
}

class HanoiView : NSView {
    var disks: Dictionary<HanoiDisk, HanoiDiskView>
    
    init(frame: NSRect) {
        self.disks = Dictionary<HanoiDisk, HanoiDiskView>()
        
        super.init(frame: frame)
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
                diskView.setCenter(self.getDiskCoords(xIndex, yLocation: yIndex))
            }
        }
    }
    
    func getDiskView(disk: HanoiDisk, maxSize: Int) -> HanoiDiskView {
        if let existingDisk = self.disks[disk] {
            return existingDisk
        }
        else {
            var diskWidth = self.diskWidthForSize(disk.size, maxSize: maxSize)
            var diskHeight = self.diskHeight()
            var newDiskView = HanoiDiskView(frame: NSRect(x: 0, y: 0, width: diskWidth, height: diskHeight))
            
            self.disks[disk] = newDiskView
            self.addSubview(newDiskView)
            
            return newDiskView
        }
    }
    
    func getDiskCoords(xLocation: Int, yLocation: Int) -> CGPoint {
        let diskWidth = self.diskWidth()
        let diskHeight = self.diskHeight()
        
        var centerX = (diskWidth * Double(xLocation)) + (diskWidth / 2)
        var centerY = ((diskHeight + 2) * Double(yLocation)) + (diskHeight / 2)
        
        return CGPoint(x: centerX, y: centerY)
    }
    
    func diskWidthForSize(diskSize: Int, maxSize: Int) -> Double {
        var maxWidth = self.diskWidth()
        var minWidth = maxWidth / Double(maxSize)
        
        return Double(diskSize) * minWidth
    }
    
    func diskWidth() -> Double {
        return self.frame.width / 3
    }
    
    func diskHeight() -> Double {
        return 24
    }
}


let puzzle = HanoiPuzzle(numberOfDisks: 4)
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

var height = 300.0
var width = 600.0
var hanoiView = HanoiView(frame: NSRect(x: 0, y: 0, width: width, height: height))
XCPShowView("hanoiView", hanoiView)

for step in puzzleSteps {
    HanoiPuzzleQuickLookHelper(puzzle: step)
    hanoiView.drawPuzzle(step)
}
