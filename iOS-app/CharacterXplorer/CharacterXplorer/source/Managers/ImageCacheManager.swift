//
//  ImageCacheManager.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-16-Feb-Sun.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import UIKit
import AlamofireImage

protocol ImageCacheManager: AnyObject {
    func add(_ image: UIImage,
             withIdentifier identifier: String)
    func image(withIdentifier identifier: String) -> UIImage?
    func removeImage(withIdentifier identifier: String)
}

final class ImageCacheManagerImpl: ImageCacheManager {
    
    // MARK: - Properties
    private let imageCahce: AutoPurgingImageCache
    static let shared: ImageCacheManagerImpl = ImageCacheManagerImpl()
    private let concurentImageQueue: DispatchQueue = DispatchQueue(label: Constants.queueLabel,
                                                                  qos: DispatchQoS.userInteractive,
                                                                  attributes: DispatchQueue.Attributes.concurrent)
    
    // MARK: - Intialization
    private init() {
        self.imageCahce = AutoPurgingImageCache(memoryCapacity: 100_000_000,
                                                preferredMemoryUsageAfterPurge: 60_000_000)
    }
    
    // MARK: - ImageCacheManager
    func add(_ image: UIImage,
             withIdentifier identifier: String)
    {
        self.concurentImageQueue
            .async(qos: DispatchQoS.userInteractive,
                   flags: DispatchWorkItemFlags.barrier)
            { [weak self] in
                guard let valid_self = self else {
                    return
                }
                valid_self.imageCahce.add(image,
                                          withIdentifier: identifier)
        }
        
    }
    
    func image(withIdentifier identifier: String) -> UIImage? {
        var result: UIImage? = nil
        self.concurentImageQueue.sync {
            result = self.imageCahce.image(withIdentifier: identifier)
        }
        return result
    }
    
    func removeImage(withIdentifier identifier: String) {
        self.concurentImageQueue
            .async(qos: DispatchQoS.userInteractive,
                   flags: DispatchWorkItemFlags.barrier)
            { [weak self] in
                guard let valid_self = self else {
                    return
                }
                valid_self.imageCahce.removeImage(withIdentifier: identifier)
        }
    }
    
}

private extension ImageCacheManagerImpl {
    
    enum Constants {
        static let queueLabel: String = "\(AppConstants.projectName).\(String(describing: ImageCacheManagerImpl.self)).queue"
    }
}
