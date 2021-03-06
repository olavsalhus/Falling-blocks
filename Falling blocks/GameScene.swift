//
//  GameScene.swift
//
//  Created by Olav Salhus on 2010-01-05.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let boardWidth = 10
    let boardHeight = 20
    var x = Int(0)
    var y = Int(0)
    var board : [[SKShapeNode]] = [[]]
    var boardIsBrickSolid : [[Bool]] = [[]]
    var nextBrickPreviewBoard : [[SKShapeNode]] = [[]]
    var swapBrickPreviewBoard : [[SKShapeNode]] = [[]]
    
    var score = 0
    
    var oldHighScore = UserDefaults.standard.integer(forKey: "highscore")
    var highscore = UserDefaults.standard.integer(forKey: "highscore")
    var linesCleared = 0
    func addScore(_ addedScore : Int) {
        score += addedScore
        scoreLabel.text = "\(score)"
        if score > highscore {
            UserDefaults.standard.set(score, forKey: "highscore")
            highscore = score
        }
        printLabel("\(score)")
        updateLevel()
    }
    
    func updateLevel() {
        let level = score / 1000
        let interval = timeIntervals[level > timeIntervals.count ? (timeIntervals.count - 1) : level]
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.timedEvent), userInfo: nil, repeats: true)
    }
    
    
    
    
    var rotation = 0
    var currentShape = 0
    var backupBrick = -1
    let boardBackgroundColor = UIColor(white: 0.1, alpha: 1.0)
    
    var gridsize = CGFloat(0.0)
    var justSwapped = false
    func swapBrick() {
        if (justSwapped) { return }
        previewShapeLanding(false)
        drawShape(color: boardBackgroundColor, solidify: false)
        previewShape(swapBrickPreviewBoard)
        (currentShape, backupBrick) = (backupBrick, currentShape)
        
        if (currentShape == -1) {
            currentShape = getNextShape()
        }
        (x, y) = (Int(boardWidth / 2) - 2, boardHeight - 2)
        if (isShapeColliding()) {
            gameOver()
            return
        }
        justSwapped = true
        previewShapeLanding(true)
        
    }
    
    func gameOver() {
        if (score > oldHighScore) {
            printLabel("Game over\nNew high score:\n\(score)", 3)
            oldHighScore = highscore
        } else {
            printLabel("Game over\nHigh score:\n\(highscore)\nScore:\n\(score)", 3)
        }
        clearBoard()
        score = 0
        updateLevel()
        scoreLabel.text = "0"
    }
    var nodesToRemove :  [SKNode] = []
    @objc func removeLabels() {
        for node in nodesToRemove {
            node.removeFromParent()
        }
        nodesToRemove = []
    }
    
    func printLabel(_ text: String, _ secondsToShow: Double = 1.0) {
        removeLabels()
        var labels : [SKLabelNode] = []
        var shapes : [SKShapeNode] = []
        for (i, line) in text.split(separator:   "\n").reversed().enumerated() {
            let currentScoreLabel = SKLabelNode()
            currentScoreLabel.text = String(line)
            currentScoreLabel.fontSize = 120
            currentScoreLabel.position.y = +currentScoreLabel.fontSize * CGFloat(i + 1) - size.height / 2
            
            currentScoreLabel.color = .white
            let shade = SKShapeNode(rect: CGRect(
                    x: -size.width / 2,
                    y: currentScoreLabel.position.y,
                    width: size.width,
                    height: currentScoreLabel.fontSize
                )
            )
            shade.fillColor = UIColor.init(white: 0, alpha: 0.3)
            shade.strokeColor = shade.fillColor
            labels += [currentScoreLabel]
            shapes += [shade]
            nodesToRemove +=  [shade, currentScoreLabel]
        }
        
        for shape in shapes { addChild(shape) }
        for label in labels { addChild(label) }
        
        nodesToRemove += shapes + labels
        
        Timer.scheduledTimer(timeInterval: secondsToShow, target: self, selector: #selector(self.removeLabels), userInfo: nil, repeats: false)
    }
    
    var scoreLabel = SKLabelNode(text: "0")
    
    override func sceneDidLoad() {
        x = Int(boardWidth / 2) - 2
        y = boardHeight - 2
        board             = Array(repeating: Array(repeating: SKShapeNode(), count: boardHeight), count: boardWidth)
        boardIsBrickSolid = Array(repeating: Array(repeating:          false, count: boardHeight), count: boardWidth)
        nextBrickPreviewBoard = Array(repeating: Array(repeating: SKShapeNode(), count: 5), count: 5)
        swapBrickPreviewBoard = Array(repeating: Array(repeating: SKShapeNode(), count: 5), count: 5)
        
        startx = Int(boardWidth / 2) - 2
        starty = boardHeight - 2
        
        // Create board
        backgroundColor = .black
        let w = size.width
        let h = size.height
        gridsize = min(w / CGFloat(boardWidth), h / CGFloat(boardHeight))
        let brickMargin : CGFloat = 0.1
        let brickInnerSizeRatio : CGFloat = (1.0 - brickMargin * 2.0)
        for (x, line) in board.enumerated() {
            for (y, _) in line.enumerated() {
                
                board[x][y] = SKShapeNode(rect: CGRect(
                        x: gridsize * (CGFloat(x) + brickMargin - CGFloat(boardWidth) / 2.0),
                        y: gridsize * (CGFloat(y) + brickMargin - CGFloat(boardHeight) / 2.0),
                        width : gridsize * brickInnerSizeRatio,
                        height: gridsize * brickInnerSizeRatio
                    )
                )
                board[x][y].lineWidth = gridsize * 0.1
                board[x][y].strokeColor = boardBackgroundColor
                
                addChild(board[x][y])
            }
        }
        
        // Create preview board
        
        let offset = brickMargin - CGFloat(nextBrickPreviewBoard.count)
        let previewGridSize = gridsize / 2
        for (x, line) in nextBrickPreviewBoard.enumerated() {
            for (y, _) in line.enumerated() {
                
                nextBrickPreviewBoard[x][y] = SKShapeNode(rect: CGRect(
                        x: previewGridSize * (CGFloat(x) + CGFloat(boardWidth) + offset),
                        y: previewGridSize * (CGFloat(y) + CGFloat(boardHeight) + offset),
                        width : previewGridSize * brickInnerSizeRatio,
                        height: previewGridSize * brickInnerSizeRatio
                    )
                )
                nextBrickPreviewBoard[x][y].lineWidth = previewGridSize * 0.1
                nextBrickPreviewBoard[x][y].isHidden = true
                
                
                addChild(nextBrickPreviewBoard[x][y])
            }
        }
        for (x, line) in swapBrickPreviewBoard.enumerated() {
            for (y, _) in line.enumerated() {
                
                swapBrickPreviewBoard[x][y] = SKShapeNode(rect: CGRect(
                        x: previewGridSize * (CGFloat(x) - CGFloat(boardWidth)),
                        y: previewGridSize * (CGFloat(y) + CGFloat(boardHeight) + offset),
                        width : previewGridSize * brickInnerSizeRatio,
                        height: previewGridSize * brickInnerSizeRatio
                    )
                )
                swapBrickPreviewBoard[x][y].lineWidth = previewGridSize * 0.1
                swapBrickPreviewBoard[x][y].isHidden = true
                
                addChild(swapBrickPreviewBoard[x][y])
            }
        }
        
        self.currentShape = getNextShape()
        
        previewShapeLanding(true)
        
        // Start the first level
        updateLevel()
        
        // Show score
        scoreLabel.position = CGPoint(x: CGFloat(boardWidth) - size.width / 2, y: size.height / 2.0 - CGFloat(boardWidth))
        scoreLabel.fontSize = 52
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
    }
    
    var timer = Timer()
    
    @objc func timedEvent() {
        semaphore.wait()
        _ = down(gracefulLanding: true)
        semaphore.signal()
    }
    
    func isOutOfBounds(x: Int, y: Int, ignoreTop: Bool = false) -> Bool {
        if ignoreTop && (y >= boardHeight) {
            return !(0 <= x && x < boardWidth)
        }
        return !(0 <= x && x < boardWidth && 0 <= y && y < boardHeight) || boardIsBrickSolid[x][y]
    }
    
    func isShapeColliding() -> Bool {
        
        for (dx, line) in getCurrentShape().enumerated() {
            for (dy, block) in line.enumerated() {
                if (block == 1 && isOutOfBounds(x: x + dx, y: y + dy, ignoreTop: true)) {
                    return true
                }
            }
        }
        return false
    }
    
    
    
    // lower is higher
    var xSensitivity = CGFloat(60); var ySensitivity = CGFloat(30)
    
    func removeLineIfNeeded(i: Int) {
        if (0 > i || i >= boardHeight) { return }
        for (_x, line) in board.enumerated() {
            for (_y, _) in line.enumerated() {
                if (_y == i) {
                    if (!boardIsBrickSolid[_x][_y]) {
                        return
                    }
                }
            }
        }
        addScore(100)
        for (_x, line) in board.enumerated() {
            for (_y, _) in line.enumerated() {
                if (i <= _y) {
                    if  (_y == (boardHeight - 1)) {
                        board[_x][_y].strokeColor = boardBackgroundColor
                        boardIsBrickSolid[_x][_y] = false
                    } else {
                        board[_x][_y].strokeColor = board[_x][_y + 1].strokeColor
                        boardIsBrickSolid[_x][_y] = boardIsBrickSolid[_x][_y + 1]
                    }
                }
            }
        }
    }
    func getCurrentColor() -> UIColor {
        return shapeColors[currentShape]
    }
    
    func getCurrentShape() -> Array<[Int]> {
        var newshape:Array<[Int]>
        let shape = shapes[currentShape]
        if (rotation == 1 || rotation == 3) { // 90 or 270 deg
            newshape = Array(repeating: Array(repeating: 0, count: shape.count), count: shape[0].count)
            for (dx, line) in shape.enumerated() {
                for (dy, block) in line.enumerated() {
                    if (rotation == 1) {
                        newshape[line.count - 1 - dy][dx] = block
                    }
                    if (rotation == 3) {
                        newshape[dy][shape.count - 1 - dx] = block
                    }
                }
            }
        }
        else if (rotation == 2) { // 180 deg
            newshape = shape
            for (dx, line) in shape.enumerated() {
                for (dy, block) in line.enumerated() {
                    newshape[shape.count - 1 - dx][line.count - 1 - dy] = block
                }
            }
        } else {
            newshape = shape
        }
        return newshape
    }
    
    func drawShape(color:UIColor, solidify: Bool = false) {
        for (dx, line) in getCurrentShape().enumerated() {
            for (dy, block) in line.enumerated() {
                if (block == 1 && !isOutOfBounds(x: x + dx, y: y + dy)) {
                    boardIsBrickSolid[x + dx][y + dy] = solidify
                    board[x + dx][y + dy].strokeColor = color
                }
            }
        }
    }
    var semaphore = DispatchSemaphore(value: 1)
    
    fileprivate func clearBoard() {
        for (x, line) in board.enumerated() {
            for (y, block) in line.enumerated() {
                block.strokeColor = boardBackgroundColor
                boardIsBrickSolid[x][y] = false
            }
        }
        
    }
    
    var currentShapes : [Int] = []
    
    func previewShape(_ board:  [[SKShapeNode]]) {
        for line in board {
            for brickPreview in line {
                brickPreview.isHidden = true
                brickPreview.strokeColor = UIColor(white: 0, alpha: 0)
            }
        }
                
        for (dx, line) in getCurrentShape().enumerated() {
            for (dy, block) in line.enumerated() {
                if (block == 1) {
                    board[dx][dy].strokeColor = getCurrentColor()
                    board[dx][dy].isHidden = false
                } else {
                    board[dx][dy].isHidden = true
                }
            }
        }
    }
    
    func getNextShape() -> Int {
        if currentShapes.count < 2 {
            var newShapes = [0, 1, 2, 3, 4, 5, 6]
            newShapes.shuffle()
            currentShapes = newShapes + currentShapes
        }
        let nextShape = currentShapes.popLast()!
        currentShape = currentShapes.last!
        
        previewShape(nextBrickPreviewBoard)
        
        currentShape = nextShape
        return nextShape
    }
    var timeOfLastDown = DispatchTime.now()
    @objc func down(gracefulLanding: Bool = false) -> Bool {
        _ = drawShape(color: boardBackgroundColor)
        
        y -= 1
        
        if (isShapeColliding()) {
            y += 1
            
            if gracefulLanding {
                let secondsSinceLastDown = Double(DispatchTime.now().uptimeNanoseconds - timeOfLastDown.uptimeNanoseconds) / 1_000_000_000
                if secondsSinceLastDown < 1 {
                    _ = drawShape(color: getCurrentColor())
                    return false
                }
            }
            _ = drawShape(color: getCurrentColor(), solidify: true)
            let height = getCurrentShape()[0].count
            for i in stride(from: y + height - 1, through: y, by: -1) {
                removeLineIfNeeded(i: i)
            }
            rotation = 0
            currentShape = getNextShape()
            justSwapped = false
            //previewShapeLanding(false)
            x = Int(boardWidth / 2) - 2; y = boardHeight - 2
            if (isShapeColliding()) {
                gameOver()
            }
            ignoreSwipes = true
            
            previewShapeLanding(true)
            
            return true
        }
        
        _ = drawShape(color: getCurrentColor())
        timeOfLastDown = DispatchTime.now()
        return false
    }
    
    
    fileprivate func previewShapeLanding(_ colored: Bool = true) {
        let oldY = y;
        while (!isShapeColliding()) { y -= 1 }
        y += 1
        var h = CGFloat(); var s = CGFloat(); var v = CGFloat(); var a = CGFloat()
        getCurrentColor().getHue(&h, saturation: &s, brightness: &v, alpha: &a)
        
        let darkerColor = colored ? UIColor(hue: h, saturation: s, brightness: v * 0.5, alpha: a) : boardBackgroundColor
        drawShape(color: darkerColor, solidify: false)
        y = oldY
    }
    
    func move(dx: Int, draw: Bool = true) -> Bool {
        if draw {
            drawShape(color: boardBackgroundColor)
            previewShapeLanding(false)
            
        }
        defer {
            if draw {
                previewShapeLanding(true)
                drawShape(color: getCurrentColor())
            }
        }
        
        x += dx
        if (isShapeColliding()) {
            x -= dx
            return true
        }
        
        return false
    }
    
    var startx = Int(0)
    var starty = Int(0)
    
    func modu(_ a: Int, _ b: Int) -> Int {
        var result = a % b
        if result < 0 { result += b }
        return result
    }
    
    func rotate(_ steps: Int = 1) {
        previewShapeLanding(false)
        defer { previewShapeLanding(true) }
        
        rotation = modu(rotation + steps, 4)
        
        if isShapeColliding() {
            
            for i in 0...4 {
                var collided = move(dx: i, draw: false)
                if !collided { return }
                collided = move(dx: -i, draw: false)
                if !collided { return }
            }
            
            rotation = modu(rotation - steps, 4)
        }
        
    }
    var ignoreSwipes = false
    
    var startp = CGPoint()
    var touchMovement = false
    var timeSinceTouchBegan = DispatchTime.now().uptimeNanoseconds
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        timeSinceTouchBegan = DispatchTime.now().uptimeNanoseconds
        semaphore.wait()
        startx = x; starty = y
        startp = touches.first?.location(in: self) ?? CGPoint()
        
        ignoreSwipes = false
        touchMovement = false
        semaphore.signal()
    }
    
    var timeSinceLastTouchMove = DispatchTime.now().uptimeNanoseconds
    
    
    
    var timeOfLastThreeFingerTap = UInt64(0)
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        timeSinceLastTouchMove = DispatchTime.now().uptimeNanoseconds
        semaphore.wait()
        defer { semaphore.signal() }
        
        if (ignoreSwipes) { return }
        var p = (touches.first?.location(in: self))!
        p.x -= startp.x; p.y -= startp.y
        let delay = CGFloat(DispatchTime.now().uptimeNanoseconds - timeSinceTouchBegan) / 10e9
        
        let dx = Int(p.x / xSensitivity)
        let dy = Int(-p.y / ySensitivity)
        
        let avgPixelsPerSecond = p.y / delay
        
        if avgPixelsPerSecond < -(gridsize * 350.0) && abs(dy) > 2 && abs(dx) == 0 {
            timeSinceTouchBegan = DispatchTime.now().uptimeNanoseconds
            while (down() == false) {}
            return
        }
        
        if (abs(p.x) + abs(-p.y) > 25) { touchMovement = true }
        let nx = startx + dx
        let ny = starty - dy
        
        while (x < nx) {
            if (move(dx:  1)) { break }
        }
        while (nx < x) {
            if (move(dx: -1)) { break }
        }
        while (ny < y) {
            if (down()) {
                ignoreSwipes = true
                break
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (ignoreSwipes) { return }
        semaphore.wait()
        defer { semaphore.signal() }
        
        let p = (touches.first?.location(in: self))!
        let dySinceLast = p.y - startp.y
        
        let dx = Int((p.x - startp.x) / xSensitivity); let dy = Int(-(p.y - startp.y) / ySensitivity)
        let delay = CGFloat(DispatchTime.now().uptimeNanoseconds - timeSinceTouchBegan) / 10e9
        let avgPixelsPerSecond = dySinceLast / delay
        
        if avgPixelsPerSecond < -(gridsize * 350.0) && abs(dy) > 2 && abs(dx) == 0 {
            timeSinceTouchBegan = DispatchTime.now().uptimeNanoseconds
            while (down() == false) {}
            return
        }
        
        drawShape(color: boardBackgroundColor)
        if (!touchMovement && dy == 0) { rotate(-1) }
        else if (dy < -3 && abs(dx) < 2)    { swapBrick() }
        drawShape(color: getCurrentColor())
    }
}
