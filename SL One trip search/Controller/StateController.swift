//
//  StateController.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-10-17.
//  Copyright © 2018 Kebne. All rights reserved.
//

import UIKit

protocol StateControllerProtocol {
    var userJourneyController: UserJourneyControllerProtocol {get}
    
    init(userController: UserJourneyControllerProtocol)
}

class StateController: StateControllerProtocol {
    var userJourneyController: UserJourneyControllerProtocol
    
    required init(userController: UserJourneyControllerProtocol) {
        self.userJourneyController = userController
    }
    

}
