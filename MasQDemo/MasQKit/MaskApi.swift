//
//  UserImages.swift
//  DatingApp
//
//  Created by Laurent Azarnouche on 12/20/20.
//

import Foundation
import UIKit
struct MaskApi{

    static var imagewithMask: UIImage?
    static var imagewitouthMask: UIImage?
    static var maskRemoteURL: [URL]? = []
    {
        didSet{
            
            maskOptions.updateRemoteMask(remoteurl: MaskApi.maskRemoteURL?.last)
            print("+++++++++++++++++ \(maskOptions.masks)+++++++++++++++++++++++++")

        }

    }
    static var masktextureRemoteURL: [URL]? = []
    static var meshRemoteURL: [URL]? = []

}
