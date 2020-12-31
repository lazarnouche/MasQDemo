//
//  ProfileTableViewController+Mask.swift
//  MasQDemo
//
//  Created by Laurent Azarnouche on 12/31/20.
//  Copyright © 2020 Bucephal. All rights reserved.
//

import Foundation
import UIKit
import ProgressHUD
extension ProfileTableViewController{
    
    @objc func presentPicker() {
        
        let storyboard =  UIStoryboard(name: "Welcome", bundle: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateAvatarImage(_:)), name: Notification.Name(rawValue: "updateAvatarImage"), object: nil)
        
        let MaskVC = storyboard.instantiateViewController(withIdentifier: "MaskVC")
            as! MaskViewController
        self.navigationController?.pushViewController(MaskVC, animated: true)
    }
    @objc func updateAvatarImage(_ notification: Notification) {
        avatar.image = MaskApi.imagewithMask
        image = MaskApi.imagewithMask

       
    }
    
    
}
