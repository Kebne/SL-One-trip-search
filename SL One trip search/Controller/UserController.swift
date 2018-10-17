//
//  UserController.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit

protocol UserControllerProtocol {
    var user: User? {get}
}

class UserController: UserControllerProtocol {
    
    var user: User? {
        return nil
    }
    
}
