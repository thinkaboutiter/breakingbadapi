//
//  CharacterDetailsDependencyContainer.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-16-Feb-Sun.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation
import SimpleLogger

protocol CharacterDetailsDependencyContainer: AnyObject {}

class CharacterDetailsDependencyContainerImpl: CharacterDetailsDependencyContainer, CharacterDetailsViewControllerFactory {
    
    // MARK: - Properties
    private let parent: CharactersListDependencyContainer
    private let getCharacter: () -> BreakingBadCharacter
    
    // MARK: - Initialization
    init(parent: CharactersListDependencyContainer,
         characterProvider provider: @escaping () -> BreakingBadCharacter) {
        self.parent = parent
        self.getCharacter = provider
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharacterDetailsViewControllerFactory protocol
    func makeCharacterDetailsViewController() -> CharacterDetailsViewController {
        let vm: CharacterDetailsViewModel = self.makeCharacterDetailsViewModel()
        let vc: CharacterDetailsViewController = CharacterDetailsViewController(viewModel: vm)
        return vc
    }
    
    private func makeCharacterDetailsViewModel() -> CharacterDetailsViewModel {
        let character: BreakingBadCharacter = self.getCharacter()
        let model: CharacterDetailsModel = CharacterDetailsModelImpl(character: character)
        let result: CharacterDetailsViewModel = CharacterDetailsViewModelImpl(model: model)
        return result
    }
}
