//
//  StateController.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit

protocol StateControllerProtocol {
    var userController: UserControllerProtocol {get}
    
    init(userController: UserControllerProtocol)
}

class StateController: StateControllerProtocol {
    var userController: UserControllerProtocol
    
    required init(userController: UserControllerProtocol) {
        self.userController = userController
    }
    

}
