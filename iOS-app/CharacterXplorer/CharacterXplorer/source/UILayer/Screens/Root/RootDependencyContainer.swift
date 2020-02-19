//
//  RootDependencyContainer.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-15-Feb-Sat.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import SimpleLogger

protocol RootDependencyContainer: AnyObject {
    var imageCache: ImageCacheManager { get }
}

class RootDependencyContainerImpl: RootDependencyContainer, RootViewControllerFactory {
    
    // MARK: - Initialization
    init() {
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - RootDependencyContainer protocol
    var imageCache: ImageCacheManager {
        return ImageCacheManagerImpl.shared
    }
    
    // MARK: - RootViewControllerFactory protocol
    func makeRootViewController() -> RootViewController {
        let factory: CharactersListViewControllerFactory = CharactersListDependencyContainerImpl(parent: self)
        let vc: RootViewController = RootViewController(charactersListViewControllerFactory: factory)
        return vc
    }
}
