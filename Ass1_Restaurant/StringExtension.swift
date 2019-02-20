//
//  StringExtension.swift
//  Ass1_Restaurant
//
//  Created by crow on 1/9/17.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit

extension String {
    
    // use [startIndex..<endIndex] to substring instead String.Index
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            return self[startIndex..<endIndex]
        }
    }
}
