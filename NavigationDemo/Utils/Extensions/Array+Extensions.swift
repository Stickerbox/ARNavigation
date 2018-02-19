//
//  Array+Extensions.swift
//  NavigationDemo
//
//  Created by Jordan.Dixon on 19/02/2018.
//  Copyright © 2018 Mubaloo. All rights reserved.
//

import Foundation

extension Array {

    func elements(from: Int, to elementCount: Int) -> Array {
        guard self.count - 1 >= elementCount else { return self }
        return Array(self[from..<elementCount])
    }
}
