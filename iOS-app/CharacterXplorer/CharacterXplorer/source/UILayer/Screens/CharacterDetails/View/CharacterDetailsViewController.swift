//
//  CharacterDetailsViewController.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W07-16-Feb-Sun.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import UIKit
import SimpleLogger

/// APIs for `DependecyContainer` to expose.
protocol CharacterDetailsViewControllerFactory {
    func makeCharacterDetailsViewController() -> CharacterDetailsViewController
}

class CharacterDetailsViewController: BaseViewController, CharacterDetailsViewModelConsumer {
    
    // MARK: - Properties
    private let viewModel: CharacterDetailsViewModel
    private let imageCache: ImageCacheManager

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var occupationTitleLabel: UILabel!
    @IBOutlet weak var occupationLabel: UILabel!
    @IBOutlet weak var statusTitleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var seasonAppearanceTitleLabel: UILabel!
    @IBOutlet weak var seasonAppearanceLabel: UILabel!
    
    // MARK: - Initialization
    @available(*, unavailable, message: "Creating this view controller with `init(coder:)` is unsupported in favor of initializer dependency injection.")
    required init?(coder aDecoder: NSCoder) {
        fatalError("Creating this view controller with `init(coder:)` is unsupported in favor of dependency injection initializer.")
    }
    
    @available(*, unavailable, message: "Creating this view controller with `init(nibName:bundle:)` is unsupported in favor of initializer dependency injection.")
    override init(nibName nibNameOrNil: String?,
                  bundle nibBundleOrNil: Bundle?)
    {
        fatalError("Creating this view controller with `init(nibName:bundle:)` is unsupported in favor of dependency injection initializer.")
    }
    
    init(viewModel: CharacterDetailsViewModel,
         imageCache: ImageCacheManager)
    {
        self.viewModel = viewModel
        self.imageCache = imageCache
        super.init(nibName: String(describing: CharacterDetailsViewController.self),
                   bundle: nil)
        self.viewModel.setViewModelConsumer(self)
        Logger.success.message()
    }
    
    deinit {
        Logger.fatal.message()
    }
    
    // MARK: - CharacterDetailsViewModelConsumer protocol
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let character: BreakingBadCharacter = self.viewModel.getCharacter()
        self.configure_ui(with: character)
    }
}

// MARK: - Configurations
private extension CharacterDetailsViewController {
    
    func configure_ui(with character: BreakingBadCharacter) {
        self.avatarImageView.configure(with: character.imageUrlString,
                                       using: self.imageCache)
        self.nameLabel.text = character.name
        self.nicknameLabel.text = "(\(character.nickname.uppercased()))"
        let occupationTitle: String =
            NSLocalizedString("CharacterDetailsViewController.occupationTitle.occupation",
                              comment: AppConstants.LocalizedStringComment.labelTitle)
        self.occupationTitleLabel.text = "\(occupationTitle.uppercased()):"
        self.occupationLabel.text = character.occupation
            .joined(separator: ",\n")
        let statusTitle: String =
            NSLocalizedString("CharacterDetailsViewController.statusTitle.status",
                              comment: AppConstants.LocalizedStringComment.labelTitle)
        self.statusTitleLabel.text = "\(statusTitle.uppercased()):"
        self.statusLabel.text = character.status
        let seasonAppearanceTitle: String =
            NSLocalizedString("CharacterDetailsViewController.seasonAppearanceTitle.season-appearance",
                              comment: AppConstants.LocalizedStringComment.labelTitle)
        self.seasonAppearanceTitleLabel.text = "\(seasonAppearanceTitle.uppercased()):"
        self.seasonAppearanceLabel.text = character.seasonAppearance
            .map() { "\($0)" }
            .joined(separator: ", ")
    }
}
