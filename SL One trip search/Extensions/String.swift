//
//  String.swift
//  SL One trip search
//
//  Created by Emil Lundgren on 2018-11-13.
//  Copyright © 2018 Kebne. All rights reserved.
//

import Foundation

extension String {
    func separateParenthesisString() ->(string: String, inParentheses: String) {
        var inPar = ""
        var beforePar = self
        if let areaParentheseStartIndex = self.firstIndex(of: "("),
            let areaParentheseEndIndex = self.firstIndex(of: ")") {
            let textStartIndex = self.index(areaParentheseStartIndex, offsetBy: 1)
            
            inPar = String(self[textStartIndex..<areaParentheseEndIndex])
            let removeStartIndex = self.index(areaParentheseStartIndex, offsetBy: -1)
            beforePar.removeSubrange(removeStartIndex...areaParentheseEndIndex)
        }
        
        return (string: beforePar, inParentheses: inPar)
    }
}
