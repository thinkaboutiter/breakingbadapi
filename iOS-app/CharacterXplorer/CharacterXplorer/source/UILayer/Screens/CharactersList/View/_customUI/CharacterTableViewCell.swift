//
//  CharacterTableViewCell.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-16-Feb-Sun.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import UIKit

class CharacterTableViewCell: BaseTableViewCell {
    
    // MARK: - Properties
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var nicknameLabel: UILabel!
    
    // MARK: - Life cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // TODO: stop any image requests
    }
    
    // MARK: - Configurations
    func configure(with character: BreakingBadCharacter) {
        self.nameLabel.text = character.name
        self.nicknameLabel.text = character.nickname
    }
}
