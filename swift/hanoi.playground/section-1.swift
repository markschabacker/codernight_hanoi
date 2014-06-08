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
    var firstPeg: Array<HanoiDisk>
    var secondPeg: Array<HanoiDisk>
    var thirdPeg: Array<HanoiDisk>
    
    init(firstPeg: Array<HanoiDisk>, secondPeg: Array<HanoiDisk>, thirdPeg: Array<HanoiDisk>) {
        self.firstPeg = firstPeg
        self.secondPeg = secondPeg
        self.thirdPeg = thirdPeg
    }
    
    init(numberOfDisks: Int){
        self.firstPeg = Array(1...numberOfDisks).map { HanoiDisk(size: $0) }
        self.secondPeg = []
        self.thirdPeg = []
    }
    
    func moveDiskFromPeg(sourcePeg: HanoiPeg, targetPeg: HanoiPeg) -> HanoiPuzzle {
        // This smells funny.  I temporarily store the pegs in a dictionary so I can mutate them.  I need to figure out the rules for mutability of dictionary values.
        var dictPegs = [ HanoiPeg.First : self.firstPeg.copy(),
                         HanoiPeg.Second: self.secondPeg.copy(),
                         HanoiPeg.Third: self.thirdPeg.copy() ]
        
        var tempSourcePeg = dictPegs[sourcePeg]!
        var tempTargetPeg = dictPegs[targetPeg]!
        tempTargetPeg.append(tempSourcePeg.removeLast())
        
        dictPegs[sourcePeg] = tempSourcePeg
        dictPegs[targetPeg] = tempTargetPeg
        
        return HanoiPuzzle(firstPeg: dictPegs[HanoiPeg.First]!, secondPeg: dictPegs[HanoiPeg.Second]!, thirdPeg: dictPegs[HanoiPeg.Third]!)
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

let movedPuzzle = puzzle.moveDiskFromPeg(HanoiPeg.First, targetPeg: HanoiPeg.Second)
HanoiPuzzleQuickLookHelper(puzzle: movedPuzzle)
