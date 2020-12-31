//
//  SignUpViewController+Mask.swift
//  MasQDemo
//
//  Created by Laurent Azarnouche on 12/30/20.
//  Copyright © 2020 Bucephal. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import ZIPFoundation

extension SignUpViewController{
    
    
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
    
    func _downloadMasks(from item: StorageReference, folderUrl: URL, fileUrl: URL){
        let fileManager = FileManager()
        item.write(toFile: fileUrl) { (url, error) in
            if error != nil {
                print("ERROR FOUND: \(error!)")
            }else{
                print("before \(Thread.isMainThread)")
                let queue = DispatchQueue(label: "work_queue")
                queue.async{
                    do {
                        try fileManager.unzipItem(at: url!, to: folderUrl)
                        
                        let name = (url!.lastPathComponent as NSString).deletingPathExtension
                        let pathToFolder = URL(string: "\(folderUrl.absoluteString)/\(name)/\(name).scn")
                        
                        
                        print("is main thread \(Thread.isMainThread)")
                        print("current thread is \(Thread.current)")
                        
                        MaskApi.maskRemoteURL!.append(pathToFolder!)
                        
                        
                        
                    } catch {
                        print("Extraction of ZIP archive failed with error:\(error)")
                    }
                }
                
                }
            }
        }


    func downloadMasks(){
        
        let ref = Ref().storageRoot.child("Mask")
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let sourceDirectory = URL.init(fileURLWithPath: paths, isDirectory: true)
        
        
        
        ref.listAll { (result, error) in
            if let error = error{
                print(error)
            }
            print("result result \(result)")
            for item in result.items{
                print("item itm \(item)")
                item.downloadURL { (dataURL, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    if let url = dataURL {
                        let fileUrl = sourceDirectory.appendingPathComponent("Data/\(url.lastPathComponent)")
                        let masknameurl = (url.lastPathComponent as NSString).deletingPathExtension
                        let targetUrl = sourceDirectory.appendingPathComponent("Data/\(masknameurl)")
                        if url.pathExtension == "zip"{
                                
                            self._downloadMasks(from: item, folderUrl: targetUrl, fileUrl: fileUrl)
                                        
                        }
       
                    }
                    
                }
            }
            
        }


       
    }
}
