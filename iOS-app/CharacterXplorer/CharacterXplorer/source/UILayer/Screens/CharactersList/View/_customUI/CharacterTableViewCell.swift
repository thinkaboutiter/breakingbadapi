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
    private var imageCacheManager: ImageCacheManager {
        return ImageCacheManagerImpl.shared
    }
    
    // MARK: - Initialization
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
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
    func configure(with character: BreakingBadCharacter) {
        self.nameLabel.text = character.name
        self.nicknameLabel.text = character.nickname
        self.configureAvatarImageWithUrlString(character.imageUrlString)
    }
    
    private func configureAvatarImageWithUrlString(_ urlString: String) {
        guard let valid_url: URL = URL(string: urlString) else {
            return
        }
        self.avatarImageView.contentMode = .scaleAspectFill
        if let existingImage: UIImage = self.imageCacheManager.image(withIdentifier: urlString) {
            self.avatarImageView.image = existingImage
        }
        else {
            self.avatarImageView
                .af_setImage(withURL: valid_url)
                { (dataResponse: DataResponse<UIImage>) in
                    if let value: UIImage = dataResponse.result.value {
                        self.imageCacheManager.add(value, withIdentifier: urlString)
                    }
            }
        }
    }
}
