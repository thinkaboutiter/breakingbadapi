//
//  BreakingBadSeason.swift
//  CharacterXplorer
//
//  Created by Boyan Yankov on 2020-W08-22-Feb-Sat.
//  Copyright © 2020 boyankov@yahoo.com. All rights reserved.
//

import Foundation

enum BreakingBadSeason: Int, CaseIterable {
    case allSeasons = 0
    case season_1 = 1
    case season_2 = 2
    case season_3 = 3
    case season_4 = 4
    case season_5 = 5
    
    var stringValue: String {
        let result: String
        switch self {
        case .allSeasons:
            result = NSLocalizedString("BreakingBadSeason.allSeasons.stringValue.all",
                                       comment: AppConstants.LocalizedStringComment.episodeTitle)
        case .season_1:
            result = NSLocalizedString("BreakingBadSeason.allSeasons.stringValue.season-1",
                                       comment: AppConstants.LocalizedStringComment.episodeTitle)
        case .season_2:
            result = NSLocalizedString("BreakingBadSeason.allSeasons.stringValue.season-2",
                                                  comment: AppConstants.LocalizedStringComment.episodeTitle)
        case .season_3:
            result = NSLocalizedString("BreakingBadSeason.allSeasons.stringValue.season-3",
                                                  comment: AppConstants.LocalizedStringComment.episodeTitle)
        case .season_4:
            result = NSLocalizedString("BreakingBadSeason.allSeasons.stringValue.season-4",
                                                  comment: AppConstants.LocalizedStringComment.episodeTitle)
        case .season_5:
            result = NSLocalizedString("BreakingBadSeason.allSeasons.stringValue.season-5",
                                                  comment: AppConstants.LocalizedStringComment.episodeTitle)
        }
        return result
    }
}
