// Playground - Tower of Hanoi in Swift

import Cocoa

struct HanoiDisk {
    var size: Int
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

let puzzle = HanoiPuzzle(numberOfDisks: 3)
let puzzleDelegate = HanoiPuzzleSolverStepQuickLookDelegate()
let result = HanoiSolver(delegate: puzzleDelegate).solve(puzzle)

// Ugh. Work around array weirdness?
var puzzleSteps = Array<HanoiPuzzle>()
puzzleSteps.append(puzzle)
for var i=0; i < puzzleDelegate.puzzleSteps.count; i++ {
    puzzleSteps.append(puzzleDelegate.puzzleSteps[i])
}

for var i=0; i < puzzleSteps.count; i++ {
    HanoiPuzzleQuickLookHelper(puzzle: puzzleSteps[i])
}
