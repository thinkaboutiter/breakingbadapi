//
//  UIImageView+Extensions.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W08-17-Feb-Mon.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import UIKit
import Alamofire

extension UIImageView {
    
    func configure(with urlString: String,
                   using imageCacheManager: ImageCacheManager)
    {
        guard let valid_url: URL = URL(string: urlString) else {
            return
        }
        self.contentMode = .scaleAspectFill
        if let existingImage: UIImage = imageCacheManager.image(withIdentifier: urlString) {
            self.image = existingImage
        }
        else {
            self
                .af_setImage(withURL: valid_url)
                { (dataResponse: DataResponse<UIImage>) in
                    if let value: UIImage = dataResponse.result.value {
                        imageCacheManager.add(value, withIdentifier: urlString)
                    }
            }
        }
    }
}
