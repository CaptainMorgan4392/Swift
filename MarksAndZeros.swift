protocol GameFieldProtocol {
    mutating func setSign (move: Pair<Int>, sign: Character) -> Bool
    mutating func isFree(coord: Pair<Int>) -> Bool
}

protocol AIProtocol {
    mutating func analyse(model: inout Model) -> Pair<Int>
}

protocol Observer {
    mutating func handleEvent() -> Void
}

protocol Game {
    mutating func startEvent() -> Void
}





class PlayerProtocol {
    var sign: Character = " "

    func setSign(sign: Character) -> Void {
        self.sign = sign
    }

    func getSign() -> Character {
        sign
    }

    func doMove() -> Pair<Int> {
        Pair<Int> (a: -1, b: -1)
    }
}





enum GameExceptions : Error {
    case WrongInputException
    case InvalidMoveException
}

class Pair<T> {
    var first : T
    var second : T

    init(a: T, b: T) {
        first = a
        second = b
    }
}

class HumanPlayer : PlayerProtocol {
    override func doMove() -> Pair<Int> {
        print("Enter the line and column numbers: ")
        let values : [String.SubSequence] = (readLine()?.split(separator: " "))!

        let line = Int(values[0])!
        let col = Int(values[1])!

        return Pair(a: line, b: col)
    }
}

class AI : PlayerProtocol, AIProtocol {
    var tiedModel: Model

    init(model: inout Model) {
        tiedModel = model
    }

    func analyse(model: inout Model) -> Pair<Int> {
        var availablePair: Pair<Int> = Pair<Int>(a: -1, b: -1)
        for i in 1...3 {
            for j in 1...3 {
                if model.isFree(coord: Pair<Int>(a: i, b: j)) {
                    availablePair = Pair<Int>(a: i, b: j)

                    return availablePair
                }
            }
        }

        return availablePair
    }

    override func doMove() -> Pair<Int> {
        analyse(model: &tiedModel)
    }
}

class Controller {
    func modelRequestToUpdate(model: inout Model, move: Pair<Int>, sign: Character) throws -> Void {
        if (!model.setSign(move: move, sign: sign)) {
            throw GameExceptions.InvalidMoveException
        }
    }
}

class Model : GameFieldProtocol {
    var matrix: Array<Array<Character>> = Array(repeating: Array(repeating: " ", count: 3), count: 3)
    var isGameEnded: Bool

    var observers: Array<Observer>

    init() {
        isGameEnded = false
        observers = Array<Observer>()
    }

    func addViewer(viewer: Observer) -> Void {
        observers.append(viewer)
    }

    func validCoord (row: Int, col: Int) -> Bool {
        (1 <= row && row <= 3) && (1 <= col && col <= 3)
    }

    func setSign(move: Pair<Int>, sign: Character) -> Bool {
        if (!validCoord(row: move.first, col: move.second) || !isFree(coord: move)) {
            return false
        }

        matrix[move.first - 1][move.second - 1] = sign

        for var obs in observers {
            obs.handleEvent()
        }

        return true
    }

    func isFree(coord: Pair<Int>) -> Bool {
        if (!validCoord(row: coord.first, col: coord.second)) {
            return false
        }

        return matrix[coord.first - 1][coord.second - 1] == " "
    }

    func checkEnd() -> Void {
        func checkLines() -> Bool {
            for arr in matrix {
                if arr[0] == arr[1] && arr[1] == arr[2] && arr[0] != " " {
                    return true
                }
            }

            return false
        }

        func checkColumns() -> Bool {
            for i in 0...2 {
                if matrix[0][i] == matrix[1][i] && matrix[1][i] == matrix[2][i] && matrix[0][i] != " " {
                    return true
                }
            }

            return false
        }

        func checkDiagonals() -> Bool {
            if matrix[0][0] == matrix[1][1] && matrix[1][1] == matrix[2][2] && matrix[0][0] != " " {
                return true
            }

            if matrix[2][0] == matrix[1][1] && matrix[1][1] == matrix[0][2] && matrix[0][2] != " " {
                return true
            }

            return false
        }

        isGameEnded = checkLines() || checkColumns() || checkDiagonals()
    }
}

class Viewer : Observer {
    var model: Model

    init(tiedModel: Model) {
        model = tiedModel
    }

    func handleEvent() {
        print("-------")
        for arr in model.matrix {
            print("|", terminator: "")
            for el in arr {
                print(el, terminator: "|")
            }
            print("\n", terminator: "")
            print("-------")
        }


        print("\n\n")
    }
}

class Session : Game {
    func startEvent() -> Void {
        var model: Model = Model()
        let control: Controller = Controller()
        let view: Viewer = Viewer(tiedModel: model)

        model.addViewer(viewer: view)

        var firstPlayer: PlayerProtocol = PlayerProtocol()
        var secondPlayer: PlayerProtocol = PlayerProtocol()

        func selectPlayers() -> Void {
            print("""
                  Please, select signature of players: Human(h) or Bot(b)\n
                  How to: "<signature of first><whitespace><signature of second>"
                  """)
            let selects: Array<Substring> = (readLine()!.split(separator: " "))
            switch selects[0] {
                case "h":
                    firstPlayer = HumanPlayer()
                case "b":
                    firstPlayer = AI(model: &model)
                default:
                    firstPlayer = AI(model: &model)
            }
            firstPlayer.setSign(sign: "x")
            switch selects[1] {
                case "h":
                    secondPlayer = HumanPlayer()
                case "b":
                    secondPlayer = AI(model: &model)
                default:
                    secondPlayer = AI(model: &model)
            }
            secondPlayer.setSign(sign: "o")
        }
        selectPlayers()


        var isFirstPlayer: Bool = true
        while !model.isGameEnded {
            let curPlayer: PlayerProtocol = isFirstPlayer ? firstPlayer : secondPlayer

            do {
                let curMove = curPlayer.doMove()
                try control.modelRequestToUpdate(model: &model, move: curMove, sign: curPlayer.getSign())
                model.checkEnd()
                isFirstPlayer = !isFirstPlayer
            } catch {
                print(error)
            }
        }
    }
}

var game: Session = Session()
game.startEvent()


