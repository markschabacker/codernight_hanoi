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
        
        let moveResults = HanoiPuzzle(firstPeg: pegsCopy[HanoiPeg.First]!, secondPeg: pegsCopy[HanoiPeg.Second]!, thirdPeg: pegsCopy[HanoiPeg.Third]!)
        
        HanoiPuzzleQuickLookHelper(puzzle: moveResults) // DEMO: put a quick look here
        
        return moveResults
    }
}

class HanoiSolver : NSObject {
    // TODO: track intermediate steps
    func solve(puzzle: HanoiPuzzle) -> HanoiPuzzle {
        var bottomDisk = puzzle.firstPeg[0]
        return solveRec(puzzle, diskSize: bottomDisk.size, sourcePeg: HanoiPeg.First, destPeg: HanoiPeg.Third, tempPeg: HanoiPeg.Second)
    }
    
    func solveRec(puzzle: HanoiPuzzle, diskSize: Int, sourcePeg: HanoiPeg, destPeg: HanoiPeg, tempPeg: HanoiPeg) -> HanoiPuzzle
    {
        if 1 == diskSize {
            return puzzle.moveDiskFromPeg(sourcePeg, toPeg: destPeg)
        }
        else {
            let smallerDisksMoved = solveRec(puzzle, diskSize: diskSize - 1, sourcePeg: sourcePeg, destPeg: tempPeg, tempPeg: destPeg)
            let smallerDisksRemaining = smallerDisksMoved.moveDiskFromPeg(sourcePeg, toPeg: destPeg)
            return solveRec(smallerDisksRemaining, diskSize: diskSize - 1, sourcePeg: tempPeg, destPeg: destPeg, tempPeg: sourcePeg)
        }
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


let puzzle = HanoiPuzzle(numberOfDisks: 3)
HanoiPuzzleQuickLookHelper(puzzle: puzzle) // DEMO: put a quick look here (Initial State)
let result = HanoiSolver().solve(puzzle)
HanoiPuzzleQuickLookHelper(puzzle: result) // DEMO: put a quick look here (Final State)