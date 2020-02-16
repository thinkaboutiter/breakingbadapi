//
//  BreakingBadCharacter.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-15-Feb-Sat.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation

protocol BreakingBadCharacter {
    var charID: Int { get }
    var name: String { get }
    var imageUrlString: String { get }
    var nickname: String { get }
    var seasonAppearance: [Int] { get }
    var status: String { get }
}

struct BreakingBadCharacterAppEntity: BreakingBadCharacter {
    
    // MARK: - Properties
    let charID: Int
    let name: String
    let imageUrlString: String
    let nickname: String
    let seasonAppearance: [Int]
    let status: String
    
    // MARK: - Initialization
    init(webEntity: BreakingBadCharacterWebEntity) {
        self.charID = webEntity.charID
        self.name = webEntity.name
        self.imageUrlString = webEntity.imageUrlString
        self.nickname = webEntity.nickname
        self.seasonAppearance = webEntity.appearance
        self.status = webEntity.status
    }
}

struct BreakingBadCharacterWebEntity: Codable {
    
    // MARK: - Properties
    let charID: Int
    let name: String
    let birthday: String
    let occupation: [String]
    let imageUrlString: String
    let status: String
    let nickname: String
    let appearance: [Int]
    let portrayed: String
    let category: String
    let betterCallSaulAppearance: [Int]
    
    // MARK: - Codable protocol
    enum CodingKeys: String, CodingKey {
        case charID = "char_id"
        case name, birthday, occupation, status, nickname, appearance, portrayed, category
        case imageUrlString = "img"
        case betterCallSaulAppearance = "better_call_saul_appearance"
    }
}
