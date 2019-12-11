//
//  UserDefaultsExt.swift
//  Detritus
//
//  Created by Wesley Espinoza on 12/10/19.
//  Copyright © 2019 HazeWritesCode. All rights reserved.
//

import Foundation

extension UserDefaults {
    func checkIfKey(key: String) -> Bool {
        return self.object(forKey: key) != nil
    }
}
