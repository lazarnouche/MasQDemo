//
//  Extension+MasQ.swift
//  MasQDemo
//
//  Created by Laurent Azarnouche on 12/30/20.
//  Copyright © 2020 Bucephal. All rights reserved.
//

import Foundation
extension FileManager {

    func directoryExists(atUrl url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = self.fileExists(atPath: url.path, isDirectory:&isDirectory)
        return exists && isDirectory.boolValue
    }

}
