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

class GameScene: SKScene {
    
  override func didMoveToView(view: SKView) {
    /* Setup your scene here */

    backgroundColor = SKColor(red: 0, green: 0, blue: 0, alpha: 1.0)
    
    let rainTexture = SKTexture(imageNamed: "rainDrop.png")
    let emitterNode = SKEmitterNode()

    emitterNode.particleTexture = rainTexture
    emitterNode.particleBirthRate = 80
    emitterNode.particleColor = SKColor.whiteColor()
    emitterNode.particleSpeed = -450
    emitterNode.particleSpeedRange = 150
    emitterNode.particleLifetime = 2.0
    emitterNode.particleScale = 0.2
    emitterNode.particleAlpha = 0.75
    emitterNode.particleAlphaRange = 0.5
    emitterNode.particleColorBlendFactor = 1
    emitterNode.particleScale = 0.2
    emitterNode.particleScaleRange = 0.5
    emitterNode.position = CGPoint(x: CGRectGetWidth(frame) / 2, y: CGRectGetHeight(frame) + 10)
    emitterNode.particlePositionRange = CGVector(CGRectGetMaxX(frame), 0)
    addChild(emitterNode)
  }
  
  override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    /* Called when a touch begins */
  }
 
  override func update(currentTime: CFTimeInterval) {
    /* Called before each frame is rendered */
  }
}
