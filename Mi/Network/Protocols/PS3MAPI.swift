//
//  PS3MAPI.swift
//  Mi
//
//  Created by Vonley on 9/28/22.
//

import Foundation

protocol PS3MAPI {
   
    
}


class PS3MAPIImpl: PS3MAPI {
    var socket  = {
        return SyncService.shared.getSocket(feat: Feature.ps3mapi())
    }
    
    
    enum cmds {
        
    }
    
    func auth() {
        if socket != nil {
            //let line = socket!.readString()
            //let line = socket!.readString()
        }
    }
}
