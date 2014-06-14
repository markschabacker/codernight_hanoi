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
        var firstPeg = Array(1...numberOfDisks).map { HanoiDisk(size: $0) }
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

let puzzle = HanoiPuzzle(numberOfDisks: 2)
HanoiPuzzleQuickLookHelper(puzzle: puzzle)

let firstStep = puzzle.moveDiskFromPeg(HanoiPeg.First, toPeg: HanoiPeg.Second)
HanoiPuzzleQuickLookHelper(puzzle: firstStep)

let secondStep = firstStep.moveDiskFromPeg(HanoiPeg.First, toPeg: HanoiPeg.Third)
HanoiPuzzleQuickLookHelper(puzzle: secondStep)

let thirdStep = secondStep.moveDiskFromPeg(HanoiPeg.Second, toPeg: HanoiPeg.Third)
HanoiPuzzleQuickLookHelper(puzzle: thirdStep)
