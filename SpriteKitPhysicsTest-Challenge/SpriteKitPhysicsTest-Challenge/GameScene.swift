/*
* Copyright (c) 2013-2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import SpriteKit

func delay(#seconds: Double, completion:()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
        completion()
    }
}

func random(#min: CGFloat, #max: CGFloat) -> CGFloat {
    return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF)) * (max - min) + min
}

class GameScene: SKScene {
    
    var dt: NSTimeInterval = 0
    var lastUpdateTime: NSTimeInterval = 0
    var windForce: CGVector = CGVector(dx: 0, dy: 0)
    var blowing: Bool = false
    var timeUntilSwitchingDirection: NSTimeInterval = 0
    
    var circle: SKSpriteNode! = nil
    
    override func didMoveToView(view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        let square = SKSpriteNode(imageNamed: "square")
        square.position = CGPoint(x: size.width * 0.25, y: size.height * 0.50)
        
        circle = SKSpriteNode(imageNamed: "circle")
        circle.position = CGPoint(x: size.width * 0.50, y: size.height * 0.50)
        
        let triangle = SKSpriteNode(imageNamed: "triangle")
        triangle.position = CGPoint(x: size.width * 0.75, y: size.height * 0.50)
        
        addChild(square)
        addChild(circle)
        addChild(triangle)
        
        let l = SKSpriteNode(imageNamed:"L")
        l.position = CGPoint(x: size.width/2, y: size.height * 0.75)
        l.physicsBody = SKPhysicsBody(texture: l.texture, size: l.size)
        addChild(l)
        
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        
        circle.physicsBody = SKPhysicsBody(circleOfRadius: circle.size.width/2)
        circle.physicsBody!.dynamic = false
        
        square.physicsBody = SKPhysicsBody(rectangleOfSize: square.frame.size)
        
        var trianglePath = CGPathCreateMutable()
        CGPathMoveToPoint(trianglePath, nil, -triangle.size.width/2, -triangle.size.height/2)
        CGPathAddLineToPoint(trianglePath, nil, triangle.size.width/2, -triangle.size.height/2)
        CGPathAddLineToPoint(trianglePath, nil, 0, triangle.size.height/2)
        CGPathAddLineToPoint(trianglePath, nil, -triangle.size.width/2, -triangle.size.height/2)
        triangle.physicsBody = SKPhysicsBody(polygonFromPath: trianglePath)
        #if os(OSX)
            CGPathRelease(trianglePath)
        #endif
        square.name = "shape"
        circle.name = "shape"
        triangle.name = "shape"
        
        delay(seconds: 2.0) {
            self.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
            
            //spawn all the sand particles
            self.runAction(
                SKAction.repeatAction(
                    SKAction.sequence([
                        SKAction.runBlock(self.spawnSand),
                        SKAction.waitForDuration(0.01)
                        ])
                    , count: 100)
                
            )
            
            //get seismic
            delay(seconds: 8, self.shake)
        }
    }
    
    func spawnSand() {
        let sand: SKSpriteNode = SKSpriteNode(imageNamed: "sand")
        sand.position = CGPoint(x: random(min:0, max:size.width),
            y: size.height - sand.size.height)
        sand.physicsBody = SKPhysicsBody(circleOfRadius: sand.size.width/2)
        sand.name = "sand"
        sand.physicsBody!.restitution = 0.5
        sand.physicsBody!.density = 20.0
        addChild(sand)
    }
    
    func shake() {
        enumerateChildNodesWithName("sand") { node, _ in
            node.physicsBody!.applyImpulse(CGVector(dx: 0, dy: random(min:20, max:40)))
        }
        
        enumerateChildNodesWithName("shape") { node, _ in
            node.physicsBody!.applyImpulse(CGVector(dx: random(min:20, max:60),
                dy: random(min:20, max:60)))
        }
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        shake()
        
        let touch: UITouch = touches.first as! UITouch
        let location: CGPoint = touch.locationInNode(self)
        
        circle.removeAllActions()
        
        circle.runAction(
            SKAction.moveTo(location, duration: 1.0)
        )
        
    }
    
    
    override func update(currentTime: NSTimeInterval) {
        //1
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        //2
        timeUntilSwitchingDirection -= dt
        
        if timeUntilSwitchingDirection < 0 {
            timeUntilSwitchingDirection = NSTimeInterval(random(min: 1, max: 5))
            windForce = CGVectorMake(random(min: -50, max: 50), 0)
        }
        
        enumerateChildNodesWithName("shape") { node, _ in
            node.physicsBody!.applyForce(self.windForce)
        }
        enumerateChildNodesWithName("sand") { node, _ in
            node.physicsBody!.applyForce(self.windForce)
        }
        
    }
    
}
