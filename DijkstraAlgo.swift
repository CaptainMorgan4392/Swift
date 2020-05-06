func swap(_ permutation : inout [Int], _ firstIndex : Int, _ secondIndex : Int) -> Void {
    let tmp = permutation[firstIndex]
    permutation[firstIndex] = permutation[secondIndex]
    permutation[secondIndex] = tmp
}

func swapTail(_ permutation: inout [Int], _ startIndex : Int) {
    var leftBound : Int = startIndex + 1
    var rightBound : Int = permutation.count - 1
    
    while (leftBound < rightBound) {
        swap(&permutation, leftBound, rightBound)
        
        leftBound += 1
        rightBound -= 1
    }
}

func getNextIndex(_ permutation : [Int], _ index : Int) -> Int {
    var currentMin : Int = permutation[index + 1]
    var finalSecondIndex : Int = index + 1
    for secondIndex in stride(from: index + 1, through: permutation.count - 1, by: 1) {
        if permutation[secondIndex] > permutation[index] && permutation[secondIndex] < currentMin {
            currentMin = permutation[secondIndex]
            finalSecondIndex = secondIndex
        }
    }
    
    return finalSecondIndex
}

func getIndexes(_ permutation : [Int]) -> (Int, Int, Bool) {
    for index in stride(from: permutation.count - 2, through: 0, by: -1) {
        if permutation[index] < permutation[index + 1] {
            return (index, getNextIndex(permutation, index), false)
        }
    }
    
    return (-1, -1, true)
}

func getNextPermutation(_ permutation : inout [Int]) -> [Int] {
    let indexes : (indexFirst: Int, indexLast : Int, isLast: Bool) = getIndexes(permutation)
    if (indexes.isLast) {
        return permutation
    }
    
    swap(&permutation, indexes.indexFirst, indexes.indexLast)
    
    swapTail(&permutation, indexes.indexFirst)
    
    return permutation
}

let numberOfDigits : Int = 6
let numberOfPermutations : Int = 12

var currentPerm = [Int]()
for index in stride(from: 0, to: numberOfDigits, by: 1) {
    currentPerm.insert(index + 1, at: index)
}

print(currentPerm)
for _ in stride(from: 0, to: numberOfPermutations - 1, by: 1) {
    print(getNextPermutation(&currentPerm))
}
