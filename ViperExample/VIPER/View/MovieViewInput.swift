//
//  MovieViewInput.swift
//  mansTV
//
//  Created by Matiss Mamedovs on 19/05/2018.
//  Copyright © 2018 DIVI Grupa. All rights reserved.
//

import Foundation

protocol MovieViewInput {
    var loadingStream: Bool { get }
    var holderView: UIViewController { get }
    
    func startLoading()
    func finishLoading()
    func setActionImage(named: String)
    func popViewController()
    func setPosterImageView(image: UIImage)
    func createPosterView(image: UIImage)
    func setPosterView(image: UIImage)
    func showAlertView(message: String)
    func startLoadingRecommendations()
    func finishLoadingRecommendations()
    func deleteRecomendedMoviesUIElements()
    func addRecommendationDelegateSource()
    func addSeasonsDelegateSource()
    func refreshRecommendationsCollectionView()
    func hideNavigationBar()
    func clearViews()
    func startLoadingEpisodes()
    func finishLoadingEpisodes()
    func refreshEpisodesCollectionView()
    func scrollToItem(index: Int)
    func updateExpandabledLabel(label: UILabel, text: String, diff: CGFloat)
    func updateSeasonLabel(text: Int)
    func setButtonLikeCount(likes: String, dislikes: String)
    func setButtonsStatus(like: Bool, dislike: Bool)
    func decorateWatchLaterButton(title: String, imageName: String, state: UIControlState, isSelected: Bool)
    func showSubtitlesAlertView(sender: UITapGestureRecognizer, optionMessage: String, defaultTitle: String, subtitles: [String])
    func addSubtitles(subtitleUrl: String)
    func removeSubtitles()
    func showLanguagesAlertView(sender: UITapGestureRecognizer, optionMessage: String, languages: [String])
    func removePlayer() -> Void
    func startLoadingStream()
    func finishLoadingStream()
    func removePlayeritem()
    func createNewPlayer(url: URL, controllerTag: Int)
    func CWTAlertView(message: String, time: Int64)
    func addPlayer()
    func addYoutubePLayer(url: String)
    func setPosterSize()
    func setOriginalTitleLabel(title_original: String)
    func setTitleLabel(title: String)
    func setSeperatorLine()
    func setTrailerLabel(text: String)
    func setPurchaseLabel(xConstant: CGFloat, text: String)
    func setCurrentSeasonsLabel(season: Int)
    func setLengthLabel(infoText: String, descText: String)
    func setYearLabel(infoText: String, descText: String)
    func setRatingLabel(infoText: String, descText: String)
    func setLanguagesLabel(infoText: String, descText: String)
    func setSubtitlesLabel(infoText: String, descText: String)
    func setGenresLabel(infoText: String, descText: String)
    func setDirectorsLabel(infoText: String, descText: String)
    func setActorsLabel(infoText: String, descText: String)
    func setDescriptionLabel(infoText: String, descText: String)
    func setRecommendationsView(infoText: String)
}
