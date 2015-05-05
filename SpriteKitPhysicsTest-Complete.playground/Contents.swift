//: Playground - noun: a place where people can play

import Cocoa
import SpriteKit
import XCPlayground

let sceneView = SKView(frame:
    CGRect(x: 0, y: 0, width: 480, height: 320))
let scene = SKScene(size: CGSize(width: 480, height: 320))
sceneView.showsFPS = true
sceneView.showsPhysics = false

scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
sceneView.presentScene(scene)

XCPShowView("My Scene", sceneView)

let square = SKSpriteNode(imageNamed: "square")
square.position = CGPoint(x: scene.size.width * 0.25, y: scene.size.height * 0.50)

let circle = SKSpriteNode(imageNamed: "circle")
circle.position = CGPoint(x: scene.size.width * 0.50, y: scene.size.height * 0.50)

let triangle = SKSpriteNode(imageNamed: "triangle")
triangle.position = CGPoint(x: scene.size.width * 0.75, y: scene.size.height * 0.50)

scene.addChild(square)
scene.addChild(circle)
scene.addChild(triangle)

circle.physicsBody = SKPhysicsBody(circleOfRadius: circle.size.width/2)


delay(seconds: 2.0) {
    scene.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
}

scene.physicsBody = SKPhysicsBody(edgeLoopFromRect: scene.frame)

square.physicsBody = SKPhysicsBody(rectangleOfSize: square.frame.size)


let l = SKSpriteNode(imageNamed:"L")l.position = CGPoint(x: scene.size.width * 0.5,    y: scene.size.height * 0.75)l.physicsBody = SKPhysicsBody(texture: l.texture, size: l.size)
scene.addChild(l)

var trianglePath = CGPathCreateMutable()

CGPathMoveToPoint(trianglePath, nil, -triangle.size.width/2, -triangle.size.height/2)
CGPathAddLineToPoint(trianglePath, nil, triangle.size.width/2, -triangle.size.height/2)
CGPathAddLineToPoint(trianglePath, nil, 0, triangle.size.height/2)
CGPathAddLineToPoint(trianglePath, nil, -triangle.size.width/2, -triangle.size.height/2)

triangle.physicsBody = SKPhysicsBody(polygonFromPath: trianglePath)


func spawnSand() {
    let sand: SKSpriteNode = SKSpriteNode(imageNamed: "sand")
    sand.position = CGPoint(
        x: random(min:0, max:scene.size.width),
        y: scene.size.height - sand.size.height)
    
    sand.physicsBody = SKPhysicsBody(circleOfRadius:
        sand.size.width/2)
    sand.name = "sand"
    scene.addChild(sand)
    
    sand.physicsBody!.restitution = 1.0
    sand.physicsBody!.density = 2.0
}


delay(seconds: 2.0) {
    scene.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
    
    scene.runAction(
        SKAction.repeatAction(
            SKAction.sequence([
                SKAction.runBlock(spawnSand),
                SKAction.waitForDuration(0.01)
                ]),
            count: 100)
    )
    delay(seconds: 8, shake)
}


func shake() {
    
    scene.enumerateChildNodesWithName("sand") { node, _ in
    node.physicsBody!.applyImpulse(
    CGVector(dx: 0, dy: random(min: 20, max: 40))
    )
    }
    
    scene.enumerateChildNodesWithName("shape") { node, _ in        node.physicsBody!.applyImpulse(        CGVector(dx: random(min:20, max:60),        dy: random(min:20, max:60))        )    }        delay(seconds: 3, shake)
}
