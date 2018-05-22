//
//  MovieViewOutput.swift
//  mansTV
//
//  Created by Matiss Mamedovs on 19/05/2018.
//  Copyright © 2018 DIVI Grupa. All rights reserved.
//

import Foundation
import AVKit

protocol MovieViewOutput {
    var numberOfSeasonMovies: Int { get }
    var numberOfRecommendations: Int { get }
    
    func getMovie(movieID: String, categoryID: String)
    func switchSeason (_ selectedSeason: Int)
    func removeSubtitles()
    func subtitleTrackChanged()
    func selectSubtitle(selectedSubtitle: String)
    func selectLanguage(selectedLanguage: String)
    func languageSelectionChanged(currentTime: CMTime)
    func saveContinueWatching(currentItem: AVPlayerItem)
    func resetCWT()
    func mainImageAction()
    func backAction()
    func likeButtonAction(isSelected: Bool)
    func dislikeButtonAction(isSelected: Bool)
    func watchLaterButtonAction(isSelected: Bool)
    func subtitlesAction(_ sender: UITapGestureRecognizer)
    func languageAction(_ sender: UITapGestureRecognizer)
    func trailerAction()
    func purchaseAction()
    func seasonSwitchTap()
    func expandabelLabelTap(_ sender: UITapGestureRecognizer)
    func configureSeasonCell(cell: EpisodeCollectionViewCell, forRow row: Int)
    func configureRecommendationCell(cell: VideoCollectionViewCell,forRow row: Int)
    func didSelectSeasonMovie(forRow: Int)
    func didSelectRecommendedMovie(forRow: Int)
    func popViewController()
}

extension MovieViewOutput {
    func getMovie(movieID: String, categoryID: String?=nil) {
        getMovie(movieID: movieID, categoryID: categoryID)
    }
}
