//
// This file (and all other Swift source files in the Sources directory of this playground) will be precompiled into a framework which is automatically made available to SpriteKitPhysicsTest.playground.
//
import Foundation

public func delay(#seconds: Double, completion:()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW,
        Int64( Double(NSEC_PER_SEC) * seconds ))
    
    dispatch_after(popTime,
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            completion()
    }
}

public func random(#min: CGFloat, #max: CGFloat) -> CGFloat {
    return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF)) * (max - min) + min
}
