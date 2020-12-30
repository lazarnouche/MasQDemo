//
//  MaskData.swift
//  ARFaceTest
//
//  Created by Laurent Azarnouche on 12/5/20.
//

import UIKit


class MaskModel {
    
    var index = 0
    var masks = [URL]()
    var localurl: [URL?]
    var remoteurl: [URL]?
    
    init(fromlocal localurl:[URL?], fromremote remoteurl:[URL]?) {
        self.localurl = localurl
        self.remoteurl = remoteurl
        createLocalMask(localurl: localurl)
        createRemoteMask(remoteurl: remoteurl)
    }
    
    func updateRemoteMask(remoteurl: URL?){
        if let maskremoteurl = remoteurl{
            self.masks.append(maskremoteurl)
            
        }
    }
    
    func createRemoteMask(remoteurl: [URL]?){
        if let maskremoteurl = remoteurl{
            for remotemask in maskremoteurl {
                self.masks.append(remotemask)
            }
        }
    }
    func createLocalMask(localurl: [URL?]){
        for _localmask in localurl{
            if let localmask = _localmask{
                self.masks.append(localmask)
            }
        }
    }
    
}



extension MaskModel {
    
    func currentIndex()->URL{
        return masks[index]
    }
    func next(){
        index = (index + 1) % masks.count
        
    }
    
    
}
