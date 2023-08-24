//
// WhatARCanDo
// Created by: onee on 2023/8/13
//

import Foundation
import ARKit
import RealityFoundation

class TrackingModel: NSObject, ARSessionDelegate {
    let session = ARSession()
    var rootEntity = AnchorEntity(world: .zero)   
    
    
    func stop() {
        session.pause()
    }
}
