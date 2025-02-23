import Noora

class MockTerminal: Terminaling {
    var isInteractive: Bool = true
    var isColored: Bool = true
    var size: (rows: Int, columns: Int)? = nil

    init(
        isInteractive: Bool = true,
        isColored: Bool = true,
        size: (rows: Int, columns: Int)? = nil
    ) {
        self.isInteractive = isInteractive
        self.isColored = isColored
        self.size = size
    }

    func inRawMode(_ body: @escaping () throws -> Void) rethrows {
        try body()
    }

    func withoutCursor(_ body: () throws -> Void) rethrows {
        try body()
    }

    var characters: [Character] = []
    func readCharacter() -> Character? {
        characters.removeFirst()
    }

    func readCharacterNonBlocking() -> Character? {
        nil
    }
}
