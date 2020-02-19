//
//  CharacterTableViewCell.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-16-Feb-Sun.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import SimpleLogger

class CharacterTableViewCell: BaseTableViewCell {
    
    // MARK: - Properties
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var nicknameLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
    // MARK: - Initialization
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configure_ui()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.avatarImageView.af_cancelImageRequest()
        self.avatarImageView.image = nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.avatarImageView.round(cornerRadius: self.avatarImageView.bounds.width * 0.5)
    }
    
    // MARK: - Configurations
    func configure(with character: BreakingBadCharacter,
                   imageCache: ImageCacheManager)
    {
        self.nameLabel.text = character.name
        self.nicknameLabel.text = "(\(character.nickname.uppercased()))"
        self.avatarImageView.configure(with: character.imageUrlString,
                                       using: imageCache)
    }
    
    private func configure_ui() {
        self.separatorView.backgroundColor = UIColor.gray.withAlphaComponent(0.25)
    }
}
