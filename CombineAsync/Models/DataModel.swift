//
//  DataModel.swift
//  CombineAsync
//
//  Created by Chr1s on 2022/4/13.
//

import Foundation

struct PostModel: Codable, Identifiable {
    var userId: Int
    var id: Int
    var title: String
    var body: String
}
