//
//  Chunk+asData.swift
//  video2mvb
//
//  Created by Onee Chan on 08.09.2023.
//

import Foundation

extension Array where Element == Chunk {
    func asData() -> Data {
        reduce(into: Data()) { $0.append($1.asData) }
    }
}
