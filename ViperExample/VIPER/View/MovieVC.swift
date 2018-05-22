//
//  MovieVC.swift
//  mansTV
//
//  Created by Matiss on 17/05/2018.
//  Copyright © 2018 DIVI Grupa. All rights reserved.
//

import Foundation
import UIKit
import shortcutEngine
import AVFoundation
import AVKit

class MovieVC: UIViewController {
    
    //OUTLETS
    var movieID: String!
    var categoryID: String? = nil
    var loader : loaderView? = nil
    
    var seasonCollectionView: UICollectionView?
    var episodesLoaderView: UIActivityIndicatorView?
    var recomendedCollectionView: UICollectionView!
    var recomendedLoaderView: UIActivityIndicatorView?
    
    var topHolderView: UIView!
    var mainScrollView: UIScrollView!
    var backImageView: UIImageView!
    var mainImageView: UIImageView!
    // used if movie has no main image
    var mainImagePosterView: UIImageView?
    var mainImageBlurView: UIVisualEffectView?
    var mainLoaderView: UIActivityIndicatorView?
    
    var playImageView: UIImageView!
    var posterImageView: UIImageView!
    
    var buttonsView: UIView!
    var subsView: UIView?
    var langView: UIView?
    var watchlaterButton: bottomButtonForm!
    var likeButton: UILikeButton!
    var dislikeButton: UILikeButton!
    
    var titleLabel: UILabel!
    var originalTitleLabel: UILabel!
    var currentSeasonLabel: UILabel?
    var currentSeasonExpander: UIImageView?
    var purchaseLabel: UILabel?
    var contentSeperatorLine: UIView?
    var trailerLabel: UILabel?
    var durationInfoLabel: UILabel?
    var durationDescribingLabel: UILabel?
    var yearInfoLabel: UILabel?
    var yearDescribingLabel: UILabel?
    var ratingInfoLabel: UILabel?
    var ratingDescribingLabel: UILabel?
    var languagesInfoLabel: UILabel?
    var languagesDescribingLabel: UILabel?
    var subtitlesInfoLabel: UILabel?
    var subtitlesDescribingLabel: UILabel?
    var genresInfoLabel: UILabel?
    var genresDescribingLabel: UILabel?
    var directorsInfoLabel: UILabel?
    var directorsDescribingLabel: UILabel?
    var actorsInfoLabel: UILabel?
    var actorsDescribingLabel: UILabel?
    var annotationInfoLabel: UILabel?
    var annotationDescribingLabel: UILabel?
    var recommendationsLabel: UILabel?
    
    // constants
    let bottomHolderHeight: CGFloat = 60.0
    let trailerViewHeight: CGFloat = 50.0
    let padding: CGFloat = 15.0
    let infoBottomPadding : CGFloat = 8.0
    let infoLabelWidth: CGFloat = 100.0
    let titleLabelWidth: CGFloat = 80.0
    let posterWidth: CGFloat = 95.0
    let fontSize: CGFloat = 16.0
    let bottomFontSize: CGFloat = 12.0
    let sideX: CGFloat = 115
    let labelGrayColor: UIColor = UIColor.hexStringToUIColor("949491")
    let bottomGrayColor: UIColor = UIColor.hexStringToUIColor("4A4A4A")
    
    var lastOrientation: orientationType = UIDeviceOrientationIsLandscape(UIDevice.current.orientation) ? .landscape : .portrait
    var lastYposition: CGFloat = 70
    
    // players
    var youTubePlayerView : YouTubePlayerView? = nil
    var playerItem: AVPlayerItem?
    var player:AVPlayer? = nil;
    var playerController:AVPlayerViewController? = nil
    
    var posterSize: CGSize {
        get {
            return CGSize(width: titleLabelWidth, height: titleLabelWidth / 2 * 3)
        }
    }
    
    var sideWidth: CGFloat {
        get {
            return self.view.frame.width - sideX - padding
        }
    }
    
    var episodeCellSize: CGSize {
        get {
            return CGSize(width: 200, height: 150)
        }
    }
    
    var recomendationCellSize: CGSize {
        get {
            return CGSize(width: posterSize.width, height: posterSize.height + 50.0)
        }
    }
    
    //VARIABLES
    var movieViewOutput: MovieViewOutput!
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                if loader == nil {
                    DispatchQueue.main.async {
                        self.loader = loaderView(frame: self.view.frame)
                        self.loader!.translatesAutoresizingMaskIntoConstraints = false
                        self.view.addSubview(self.loader!)
                        
                        var constraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[loader]-0-|", options: [] , metrics: nil, views: ["loader" : self.loader!])
                        NSLayoutConstraint.activate(constraint)
                        
                        constraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[loader]-0-|", options: [] , metrics: nil, views: ["loader" : self.loader!])
                        NSLayoutConstraint.activate(constraint)
                    }
                }
            } else {
                if loader != nil {
                    DispatchQueue.main.async {
                        self.loader!.removeFromSuperview()
                        self.loader = nil
                    }
                }
            }
        }
    }
    
    var isLoadingStream: Bool = false {
        didSet {
            if isLoadingStream {
                if mainLoaderView == nil {
                    mainLoaderView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
                    mainLoaderView?.frame.origin = CGPoint(x: self.topHolderView.frame.width / 2 - mainLoaderView!.frame.width / 2, y: self.topHolderView.frame.height / 2 - mainLoaderView!.frame.height / 2)
                    self.topHolderView.addSubview(mainLoaderView!)
                    mainLoaderView?.startAnimating()
                }
                
                if let playImageView = playImageView {
                    playImageView.isHidden = true
                }
            } else {
                if let playImageView = playImageView {
                    playImageView.isHidden = false
                }
                
                guard let mainLoaderView = mainLoaderView else {
                    return
                }
                
                mainLoaderView.removeFromSuperview()
                self.mainLoaderView = nil
            }
        }
    }
    
    var isLoadingRecomendations: Bool = false {
        didSet {
            if isLoadingRecomendations {
                if recomendedLoaderView == nil {
                    guard let recomendedCollectionView = self.recomendedCollectionView else {
                        return
                    }
                    
                    recomendedLoaderView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                    recomendedLoaderView?.frame.origin = CGPoint(x: padding, y: recomendedCollectionView.frame.origin.y + padding)
                    self.mainScrollView.addSubview(recomendedLoaderView!)
                    recomendedLoaderView?.startAnimating()
                }
            } else {
                guard let recomendedLoaderView = recomendedLoaderView else {
                    return
                }
                
                recomendedLoaderView.removeFromSuperview()
                self.recomendedLoaderView = nil
            }
        }
    }
    
    var isLoadingEpisodes: Bool = false {
        didSet {
            if isLoadingEpisodes {
                if episodesLoaderView == nil {
                    guard let seasonCollectionView = self.seasonCollectionView else {
                        return
                    }
                    
                    episodesLoaderView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                    episodesLoaderView?.frame.origin = CGPoint(x: padding, y: seasonCollectionView.frame.origin.y + padding)
                    self.mainScrollView.addSubview(episodesLoaderView!)
                    episodesLoaderView?.startAnimating()
                }
            } else {
                guard let episodesLoaderView = episodesLoaderView else {
                    return
                }
                
                episodesLoaderView.removeFromSuperview()
                self.episodesLoaderView = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createHolderViews()
        if let categoryID = self.categoryID {
            movieViewOutput.getMovie(movieID: movieID, categoryID: categoryID)
        } else {
            movieViewOutput.getMovie(movieID: movieID)
        }
        
    }
    
    fileprivate func createHolderViews() {
        createTopHolderView()
        createScrollView()
        
        createContentViews()
    }
    
    fileprivate func createContentViews() {
        addTopViews()
        createBackgroundFont()
        addMainScrollViewControls()
    }
    
}

extension MovieVC : MovieViewInput {

    
    func startLoading() {
        self.isLoading = true
    }
    
    func finishLoading() {
        self.isLoading = false
    }
    
    func startLoadingRecommendations() {
        self.isLoadingRecomendations = true
    }
    
    func finishLoadingRecommendations() {
        self.isLoadingRecomendations = false
    }
    
    func startLoadingEpisodes() {
        self.isLoadingEpisodes = true
    }
    
    func finishLoadingEpisodes() {
        self.isLoadingEpisodes = false
    }
    
    func startLoadingStream() {
        isLoadingStream = true
    }
    
    func finishLoadingStream() {
        isLoadingStream = false
    }
    
    var loadingStream: Bool {
        return isLoadingStream
    }
    
    var holderView: UIViewController {
        return self
    }
    
    func showAlertView(message: String) {
        let alertController = UIAlertController(title: "Kļūda", message: message , preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Sapratu", style: UIAlertActionStyle.default, handler: { void in
            self.movieViewOutput.popViewController()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showSwitchSeasonAlertView(seasons: [Int]) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for season in seasons {
            let action = UIAlertAction(title: self.seasonLabel(season), style: .default , handler: {
                (alert: UIAlertAction!) -> Void in
                
                self.movieViewOutput.switchSeason(season)
            })
            optionMenu.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Atcelt", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(cancelAction)
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = currentSeasonExpander
            popoverController.sourceRect = (currentSeasonExpander?.bounds)!
        }
        
        // show action sheet
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func setActionImage(named: String) {
        playImageView.image = UIImage(named: named)
    }
    
    func popViewController() {
        self.removePLayer()
    }
    
    func setPosterImageView(image: UIImage) {
        self.posterImageView.image = image
        mainImageBlurView?.isHidden = true
        mainImagePosterView?.isHidden = true
    }
    
    func setPosterView(image: UIImage) {
        self.mainImageView.image = image
        self.mainImagePosterView?.image = image
        mainImageBlurView?.isHidden = false
        mainImagePosterView?.isHidden = false
    }
    
    func createPosterView(image: UIImage) {
        self.mainImageView.image = image
        self.createBackgroundFont()
    }
    
    func deleteRecomendedMoviesUIElements() {
        let removeLabel = mainScrollView.viewWithTag(3)
        removeLabel?.removeFromSuperview()
        //delete recomendation view constraints
        mainScrollView.contentSize = CGSize(width: mainScrollView.contentSize.width, height: mainScrollView.contentSize.height - recomendedCollectionView.contentSize.height)
    }
    
    func addRecommendationDelegateSource() {
        recomendedCollectionView.delegate = self
        recomendedCollectionView.dataSource = self
    }
    
    func addSeasonsDelegateSource() {
        if let collectionView = seasonCollectionView {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    func refreshRecommendationsCollectionView() {
        self.recomendedCollectionView.reloadData()
    }
    
    func refreshEpisodesCollectionView() {
        self.seasonCollectionView?.reloadData()
    }
    
    func scrollToItem(index: Int) {
        seasonCollectionView?.scrollToItem(at: IndexPath(row: index, section: 0) , at: .left, animated: false)
    }
    
    func hideNavigationBar() {
        if self.navigationController?.navigationBar != nil {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    func clearViews() {
        self.mainScrollView.subviews.forEach({ $0.removeFromSuperview() })
        self.topHolderView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    func updateExpandabledLabel(label: UILabel, text: String, diff: CGFloat) {
        label.text = text
        mainScrollView.contentSize = CGSize(width: mainScrollView.contentSize.width, height: mainScrollView.contentSize.height + diff)
        
    }
    
    func updateSeasonLabel(text: Int) {
        currentSeasonLabel?.text = seasonLabel(text)
        currentSeasonLabel?.sizeToFit()
        currentSeasonExpander?.frame.origin = CGPoint(x: padding * 1.5 + (currentSeasonLabel?.frame.width)!, y: (currentSeasonExpander?.frame.origin.y)!)
    }
    
    func setButtonLikeCount(likes: String, dislikes: String) {
        self.dislikeButton.setTitle(likes, for: UIControlState())
        self.likeButton.setTitle(dislikes, for: UIControlState())
    }
    
    func setButtonsStatus(like: Bool, dislike: Bool) {
        self.likeButton.isSelected = like
        self.dislikeButton.isSelected = dislike
    }
    
    func decorateWatchLaterButton(title: String, imageName: String, state: UIControlState, isSelected: Bool) {
        watchlaterButton.setTitle(title, for: .normal)
        watchlaterButton.setImage(UIImage(named: imageName), for: state)
        watchlaterButton.isSelected = isSelected
    }
    
    func showSubtitlesAlertView(sender: UITapGestureRecognizer, optionMessage: String, defaultTitle: String, subtitles: [String]) {
        
        let optionMenu = UIAlertController(title: nil, message: optionMessage, preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: defaultTitle, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.movieViewOutput.removeSubtitles()
            self.resizeBottomLabel(sender: sender.view!, text: "Subtitri (-)")
            self.movieViewOutput.subtitleTrackChanged()
        })
        optionMenu.addAction(defaultAction)
        
        for subtitle in subtitles {
            let langAction = UIAlertAction(title: subtitle, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                self.movieViewOutput.selectSubtitle(selectedSubtitle: subtitle)
                self.resizeBottomLabel(sender: sender.view!, text: "Subtitri (\(subtitle))")
                self.movieViewOutput.subtitleTrackChanged()
            })
            
            optionMenu.addAction(langAction)
        }
        
        
        let cancelAction = UIAlertAction(title: "Atcelt", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        optionMenu.addAction(cancelAction)
        
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = sender.view!
            popoverController.sourceRect = sender.view!.bounds
        }
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func addSubtitles(subtitleUrl: String) {
        guard let playerController = self.playerController else {
            return
        }
        
        playerController.addSubtitles().open(file: URL(string: subtitleUrl)!, encoding: String.Encoding.utf8)
    }
    
    func removeSubtitles() {
        guard let playerController = self.playerController else {
            return
        }
        
        playerController.removeSubtitles()
    }
    
    func showLanguagesAlertView(sender: UITapGestureRecognizer, optionMessage: String, languages: [String]) {
        let optionMenu = UIAlertController(title: nil, message: optionMessage, preferredStyle: .actionSheet)
        
        for language in languages {
            let langAction = UIAlertAction(title: language, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                self.movieViewOutput.selectLanguage(selectedLanguage: language)
                self.resizeBottomLabel(sender: sender.view!, text: "Valoda (\(language))")
                if self.playerController != nil {
                    self.movieViewOutput.languageSelectionChanged(currentTime: (self.player?.currentItem?.currentTime())!)
                }
            })
            
            optionMenu.addAction(langAction)
        }
    }
    
    func createPlayerItem(url: String, time: CMTime) {
        let next = AVPlayerItem(url: URL(string: url)!)
        self.player!.replaceCurrentItem(with: next)
        self.player!.seek(to: time)
        self.playerItem = next
    }
    
    func removePLayer() -> Void {
        if(playerController != nil)
        {
            // save continue watching
            movieViewOutput.saveContinueWatching(currentItem: (player?.currentItem)!)
            
            if player != nil
            {
                self.player!.pause()
                self.player = nil
            }
            
            playerController?.removeSubtitles()
            playerController!.view.removeFromSuperview()
            playerController = nil
        }
        
        if youTubePlayerView != nil {
            youTubePlayerView!.pause()
            youTubePlayerView!.removeFromSuperview()
            youTubePlayerView = nil
        }
    }
    
    func removePlayeritem() {
        if self.player != nil {
            self.player!.pause()
            self.player = nil
        }
    }
    
    func createNewPlayer(url: URL, controllerTag: Int) {
        self.playerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: self.playerItem!)
        self.playerController = AVPlayerViewController()
        self.playerController!.view.tag = controllerTag
        self.playerController!.view.backgroundColor = UIColor.black
        self.playerController!.player = self.player
    }
    
    func CWTAlertView(message: String, time: Int64) {
        let questionAlert = UIAlertController(title: "Informācija!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        questionAlert.addAction(UIAlertAction(title: "Turpināt", style: .default, handler: { (action: UIAlertAction!) in
            //Returns 12 seconds earlier
            let cmTime : CMTime = CMTimeMake(time, 1)
            self.player!.seek(to: cmTime)
            self.addPlayer()
        }))
        
        questionAlert.addAction(UIAlertAction(title: "No sākuma", style: .default, handler: { (action: UIAlertAction!) in
            self.movieViewOutput.resetCWT()
            self.addPlayer()
        }))
        self.present(questionAlert, animated: true, completion: nil)
    }
    
    func addPlayer() {
        self.addPlayer(self.lastOrientation)
        self.player!.play()
    }
    
    func setPosterSize() {
        self.posterImageView.frame = CGRect(origin: CGPoint(x: padding, y: lastYposition), size: posterSize)
    }
    
    func setOriginalTitleLabel(title_original: String) {
        self.originalTitleLabel.frame = CGRect(origin: CGPoint(x: sideX, y: lastYposition), size: CGSize(width: sideWidth, height: 300))
        self.originalTitleLabel.text = title_original
        lastYposition += 5 + self.originalTitleLabel.frame.height
    }
    
    func setTitleLabel(title: String) {
        self.titleLabel.frame = CGRect(origin: CGPoint(x: sideX, y: lastYposition), size: CGSize(width: sideWidth, height: 300))
        self.titleLabel.text = title
        lastYposition += 5 + self.titleLabel.frame.height
    }
    
    func setSeperatorLine() {
        contentSeperatorLine?.frame = CGRect(x: sideX, y: lastYposition - 5, width: UIScreen.main.bounds.width - sideX - padding , height: 0.5)
        lastYposition += 10
    }
    
    func setTrailerLabel(text: String) {
        trailerLabel?.frame = CGRect(x: sideX, y: lastYposition, width: 75, height: 25)
        trailerLabel?.text = text
    }
    
    func setPurchaseLabel(xConstant: CGFloat, text: String) {
        purchaseLabel?.frame = CGRect(x: sideX + xConstant, y: lastYposition, width: 100, height: 25)
        purchaseLabel?.text = text
    }
    
    func setCurrentSeasonsLabel(season: Int) {
        currentSeasonLabel?.frame = CGRect(x: padding, y: lastYposition, width: 200, height: 30)
        currentSeasonLabel?.text = seasonLabel(season)
        seasonCollectionView?.frame = CGRect(x: padding, y: lastYposition, width: self.view.frame.width - padding * 2, height: episodeCellSize.height)
    }
    
    func setLengthLabel(infoText: String, descText: String) {
        durationInfoLabel?.frame = CGRect(x: padding, y: lastYposition, width: titleLabelWidth, height: 19.5)
        durationDescribingLabel?.frame = CGRect(x: infoLabelWidth + padding, y: lastYposition, width: 200, height: 30)
        
        durationInfoLabel?.text = infoText
        durationDescribingLabel?.text = descText
        
        lastYposition += (durationDescribingLabel?.frame.height)! + infoBottomPadding
    }
    
    func setYearLabel(infoText: String, descText: String) {
        yearInfoLabel?.frame = CGRect(x: padding, y: lastYposition, width: titleLabelWidth, height: 19.5)
        yearDescribingLabel?.frame = CGRect(x: infoLabelWidth + padding, y: lastYposition, width: 200, height: 30)
        
        yearInfoLabel?.text = infoText
        yearDescribingLabel?.text = descText
        
        lastYposition += (yearDescribingLabel?.frame.height)! + infoBottomPadding
    }
    
    func setRatingLabel(infoText: String, descText: String) {
        ratingInfoLabel?.frame = CGRect(x: padding, y: lastYposition, width: titleLabelWidth, height: 19.5)
        ratingDescribingLabel?.frame = CGRect(x: infoLabelWidth + padding, y: lastYposition, width: 200, height: 30)
        
        ratingInfoLabel?.text = infoText
        ratingDescribingLabel?.text = descText
        
        lastYposition += (ratingDescribingLabel?.frame.height)! + infoBottomPadding
    }
    
    func setLanguagesLabel(infoText: String, descText: String) {
        languagesInfoLabel?.frame = CGRect(x: padding, y: lastYposition, width: titleLabelWidth, height: 19.5)
        languagesDescribingLabel?.frame = CGRect(x: infoLabelWidth + padding, y: lastYposition, width: 200, height: 30)
        
        languagesInfoLabel?.text = infoText
        languagesDescribingLabel?.text = descText
        
        lastYposition += (languagesDescribingLabel?.frame.height)! + infoBottomPadding
    }
    
    func setSubtitlesLabel(infoText: String, descText: String) {
        subtitlesInfoLabel?.frame = CGRect(x: padding, y: lastYposition, width: titleLabelWidth, height: 19.5)
        subtitlesDescribingLabel?.frame = CGRect(x: infoLabelWidth + padding, y: lastYposition, width: 200, height: 30)
        
        subtitlesInfoLabel?.text = infoText
        subtitlesDescribingLabel?.text = descText
        
        lastYposition += (subtitlesDescribingLabel?.frame.height)! + infoBottomPadding
    }
    
    func setGenresLabel(infoText: String, descText: String) {
        genresInfoLabel?.frame = CGRect(x: padding, y: lastYposition, width: titleLabelWidth, height: 19.5)
        genresDescribingLabel?.frame = CGRect(x: infoLabelWidth + padding, y: lastYposition, width: self.view.frame.width - (infoLabelWidth + padding * 3), height: 30)
        
        genresInfoLabel?.text = infoText
        genresDescribingLabel?.text = descText
        
        lastYposition += (genresDescribingLabel?.frame.height)! + infoBottomPadding
    }
    
    func setDirectorsLabel(infoText: String, descText: String) {
        directorsInfoLabel?.frame = CGRect(x: padding, y: lastYposition, width: titleLabelWidth, height: 19.5)
        directorsDescribingLabel?.frame = CGRect(x: infoLabelWidth + padding, y: lastYposition, width: self.view.frame.width - (infoLabelWidth + padding * 3), height: 30)
        
        directorsInfoLabel?.text = infoText
        directorsDescribingLabel?.text = descText
        
        lastYposition += (directorsDescribingLabel?.frame.height)! + infoBottomPadding
    }
    
    func setActorsLabel(infoText: String, descText: String) {
        actorsInfoLabel?.frame = CGRect(x: padding, y: lastYposition, width: titleLabelWidth, height: 19.5)
        actorsDescribingLabel?.frame = CGRect(x: infoLabelWidth + padding, y: lastYposition, width: self.view.frame.width - (infoLabelWidth + padding * 3), height: 30)
        
        actorsInfoLabel?.text = infoText
        actorsDescribingLabel?.text = descText
        
        lastYposition += (actorsDescribingLabel?.frame.height)! + infoBottomPadding
    }
    
    func setDescriptionLabel(infoText: String, descText: String) {
        annotationInfoLabel?.frame = CGRect(x: padding, y: lastYposition, width: titleLabelWidth, height: 19.5)
        annotationDescribingLabel?.frame = CGRect(x: infoLabelWidth + padding, y: lastYposition, width: self.view.frame.width - (infoLabelWidth + padding * 3), height: 30)
        
        annotationInfoLabel?.text = infoText
        annotationDescribingLabel?.text = descText
        
        lastYposition += (annotationDescribingLabel?.frame.height)! + infoBottomPadding
    }
    
    func setRecommendationsView(infoText: String) {
        recommendationsLabel?.frame = CGRect(x: padding, y: lastYposition, width: self.view.frame.width - padding, height: 30)
        recomendedCollectionView.frame = CGRect(x: padding, y: lastYposition, width: self.view.frame.width - padding * 2, height: recomendationCellSize.height)
        recommendationsLabel?.text = infoText
    }
    
    func addButtonsConstraints(spacing: CGFloat, isSubsView: Bool = false) {
        var constraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[likeButton]-5-|", options: [] , metrics: nil, views: ["likeButton" : self.likeButton])
        NSLayoutConstraint.activate(constraint)
        constraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[dislikeButton]-5-|", options: [] , metrics: nil, views: ["dislikeButton" : self.dislikeButton])
        NSLayoutConstraint.activate(constraint)
        constraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[watchlaterButton]-5-|", options: [] , metrics: nil, views: ["watchlaterButton" : self.watchlaterButton])
        NSLayoutConstraint.activate(constraint)
        constraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[langView]-5-|", options: [] , metrics: nil, views: ["langView" : langView!])
        if isSubsView {
            constraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[subsView]-5-|", options: [] , metrics: nil, views: ["subsView" : subsView!])
            NSLayoutConstraint.activate(constraint)
            constraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(spacing)-[likeButton(==50)]-\(spacing)-[dislikeButton(==50)]-\(spacing)-[watchlaterButton(==40)]-\(spacing)-[langView(==60)]-\(spacing)-[subsView(==60)]-\(spacing)-|", options: [] , metrics: nil, views: ["likeButton" : likeButton, "dislikeButton" : dislikeButton, "watchlaterButton" : watchlaterButton, "langView" : langView!, "subsView" : subsView!])
            NSLayoutConstraint.activate(constraint)
        } else {
            constraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(spacing)-[likeButton(==50)]-\(spacing)-[dislikeButton(==50)]-\(spacing)-[watchlaterButton(==40)]-\(spacing)-[langView(==60)]-\(spacing)-|", options: [] , metrics: nil, views: ["langView" : langView!, "watchlaterButton" : watchlaterButton, "dislikeButton" : dislikeButton, "likeButton" : likeButton])
            NSLayoutConstraint.activate(constraint)
        }
        
        
    }
}
// content views
extension MovieVC {
    
    fileprivate func createTopHolderView() {
        topHolderView = UIView()
        self.topHolderView.backgroundColor = .red
        topHolderView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.topHolderView)
        
        topHolderView.addConstraint(NSLayoutConstraint(item: topHolderView, attribute: .height, relatedBy: .equal, toItem: topHolderView, attribute: .width, multiplier: 9.0/16.0, constant: 0.0))
    }
    
    fileprivate func createScrollView() {
        // main scroll veiw
        self.mainScrollView = UIScrollView()
        self.mainScrollView.backgroundColor = .blue
        self.mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.mainScrollView.backgroundColor = SHORTCUT_BACKGROUND_COLOR
        self.view.addSubview(self.mainScrollView)
    }
    
    fileprivate func addTopViews() {
        
        // top content
        // main image
        self.mainImageView = UIImageView()
        self.mainImageView.contentMode = .scaleToFill
        self.mainImageView.translatesAutoresizingMaskIntoConstraints = false
        self.mainImageView.isUserInteractionEnabled = true
        self.mainImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(movieViewOutput.mainImageAction)))
        self.topHolderView.addSubview(mainImageView)
        
        var constraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[mainImageView]-0-|", options: [] , metrics: nil, views: ["mainImageView" : mainImageView])
        NSLayoutConstraint.activate(constraint)
        
        constraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[mainImageView]-0-|", options: [] , metrics: nil, views: ["mainImageView" : mainImageView])
        NSLayoutConstraint.activate(constraint)
        
        
        let blured_overlay = UIImageView()
        blured_overlay.image = UIImage(named: "blured_overlay")
        blured_overlay.translatesAutoresizingMaskIntoConstraints = false
        //blured_overlay.frame = CGRect(x: 0, y: 0, width: width, height: width / 16 * 4)
        self.topHolderView.addSubview(blured_overlay)
        
        constraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[blured_overlay]-0-|", options: [] , metrics: nil, views: ["blured_overlay" : blured_overlay])
        NSLayoutConstraint.activate(constraint)
        
        constraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[blured_overlay(==100)]", options: [] , metrics: nil, views: ["blured_overlay" : blured_overlay])
        NSLayoutConstraint.activate(constraint)
        
        
        // play button
        self.playImageView = UIImageView()
        self.playImageView.contentMode = .scaleToFill
        self.playImageView.translatesAutoresizingMaskIntoConstraints = false
        self.topHolderView.addSubview(playImageView)
        
        constraint = NSLayoutConstraint.constraints(withVisualFormat: "H:[playImageView(==50)]", options: .alignAllCenterX , metrics: nil, views: ["playImageView" : playImageView])
        NSLayoutConstraint.activate(constraint)
        
        constraint = NSLayoutConstraint.constraints(withVisualFormat: "V:[playImageView(==50)]", options: .alignAllCenterY , metrics: nil, views: ["playImageView" : playImageView])
        NSLayoutConstraint.activate(constraint)
        
        self.topHolderView.addConstraint(NSLayoutConstraint(item: playImageView, attribute: .centerX, relatedBy: .equal, toItem: topHolderView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.topHolderView.addConstraint(NSLayoutConstraint(item: playImageView, attribute: .centerY, relatedBy: .equal, toItem: topHolderView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        
        // back button
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(movieViewOutput.backAction)))
        backView.isUserInteractionEnabled = true
        self.topHolderView.addSubview(backView)
        
        self.backImageView = UIImageView(image: UIImage(named: "movie_back"))
        self.backImageView.contentMode = .scaleAspectFit
        self.backImageView.frame = CGRect(x: padding, y: 25, width: 15, height: 20)
        self.backImageView.isUserInteractionEnabled = true
        self.backImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(movieViewOutput.backAction)))
        self.topHolderView.addSubview(backImageView)
    }
    
    func createBackgroundFont() {
        self.mainImageBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        self.mainImageBlurView?.translatesAutoresizingMaskIntoConstraints = false
        self.mainImageBlurView?.isUserInteractionEnabled = false
        self.topHolderView.addSubview(self.mainImageBlurView!)
        
        var constraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[mainImageBlurView]-0-|", options: [] , metrics: nil, views: ["mainImageBlurView" : self.mainImageBlurView!])
        NSLayoutConstraint.activate(constraint)
        
        constraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[mainImageBlurView]-0-|", options: [] , metrics: nil, views: ["mainImageBlurView" : self.mainImageBlurView!])
        NSLayoutConstraint.activate(constraint)
        
        
        self.mainImagePosterView = UIImageView()
        self.mainImagePosterView?.translatesAutoresizingMaskIntoConstraints = false
        self.mainImagePosterView?.contentMode = .scaleAspectFit
        //self.mainImagePosterView?.image = image
        self.mainImagePosterView!.isUserInteractionEnabled = false
        self.topHolderView.addSubview(self.mainImagePosterView!)
        
        self.topHolderView.addConstraint(NSLayoutConstraint(item: self.mainImagePosterView!, attribute: .centerX, relatedBy: .equal, toItem: self.topHolderView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.topHolderView.addConstraint(NSLayoutConstraint(item: self.mainImagePosterView!, attribute: .centerY, relatedBy: .equal, toItem: self.topHolderView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.topHolderView.addConstraint(NSLayoutConstraint(item: self.mainImagePosterView!, attribute: .height, relatedBy: .equal, toItem: self.topHolderView, attribute: .height, multiplier: 0.8, constant: 0.0))
        self.topHolderView.addConstraint(NSLayoutConstraint(item: self.mainImagePosterView!, attribute: .width, relatedBy: .equal, toItem: self.mainImagePosterView!, attribute: .height, multiplier: 3.0 / 2.0, constant: 0.0))
        
        self.topHolderView.bringSubview(toFront: self.backImageView)
        self.topHolderView.bringSubview(toFront: self.playImageView)
    }
    
    func addMainScrollViewControls() {
        self.mainScrollView.setContentOffset(CGPoint.zero, animated: false)
        
        addActionButtons()
        addPosterImageView()
        addOriginalTitleLabel()
        addLocalizedTitleLabel()
        
        
    }
    
    func addActionButtons() {
        let width = UIScreen.main.bounds.size.width
        let height : CGFloat = 50.0
        
        buttonsView = UIView()
        buttonsView.backgroundColor = SHORTCUT_BACKGROUND_COLOR
        buttonsView.frame = CGRect(x: 0, y: 0, width: width, height: 50)
        
        // like button
        likeButton = UILikeButton(type: .like)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(movieViewOutput.likeButtonAction)))
        buttonsView.addSubview(likeButton)
        
        var constraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[likeButton]-5-|", options: [] , metrics: nil, views: ["likeButton" : self.likeButton])
        NSLayoutConstraint.activate(constraint)
        //likeButton.backgroundColor = .blue
        
        // dislike button
        dislikeButton = UILikeButton(type: .dislike)
        dislikeButton.translatesAutoresizingMaskIntoConstraints = false
        dislikeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(movieViewOutput.dislikeButtonAction)))
        buttonsView.addSubview(dislikeButton)
        
        constraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[dislikeButton]-5-|", options: [] , metrics: nil, views: ["dislikeButton" : self.dislikeButton])
        NSLayoutConstraint.activate(constraint)
        
        
        // watch later buttons
        watchlaterButton = bottomButtonForm(title: "remove_watch_later")
        watchlaterButton = bottomButtonForm(title: "add_watch_later")
        
        watchlaterButton.translatesAutoresizingMaskIntoConstraints = false
        watchlaterButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(movieViewOutput.watchLaterButtonAction)))
        buttonsView.addSubview(watchlaterButton)
        
        constraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[watchlaterButton]-5-|", options: [] , metrics: nil, views: ["watchlaterButton" : self.watchlaterButton])
        NSLayoutConstraint.activate(constraint)
        
        subsView = UIView()
        subsView!.translatesAutoresizingMaskIntoConstraints = false
        subsView!.isUserInteractionEnabled = true
        subsView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(movieViewOutput.subtitlesAction(_:))))
        buttonsView.addSubview(subsView!)
        
        constraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[subsView]-5-|", options: [] , metrics: nil, views: ["subsView" : subsView!])
        NSLayoutConstraint.activate(constraint)
        
        let subsImage = UIImageView(image: UIImage(named: "subtitles_icon"))
        subsImage.contentMode = .scaleAspectFit
        subsImage.frame = CGRect(origin: CGPoint(x: 22, y: 0), size: CGSize(width: 25, height: 25))
        
        subsView!.addSubview(subsImage)
        let subsTitle = UILabel(frame: CGRect(x: 0, y: 30, width: subsImage.frame.width + 50, height: 12))
        subsTitle.tag = 1
        subsTitle.font = UIFont.systemFont(ofSize: 10)
        subsTitle.textColor = bottomGrayColor
        subsTitle.textAlignment = .center
        subsView!.addSubview(subsTitle)
        // lang
        let langView = UIView()
        //langView.frame = CGRect(x: lastX, y: 10, width: 70, height: height)
        langView.translatesAutoresizingMaskIntoConstraints = false
        langView.isUserInteractionEnabled = true
        langView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(movieViewOutput.languageAction(_:))))
        buttonsView.addSubview(langView)
        
        constraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[langView]-5-|", options: [] , metrics: nil, views: ["langView" : langView])
        NSLayoutConstraint.activate(constraint)
        
        let langImage = UIImageView(image: UIImage(named: "languages_icon"))
        langImage.contentMode = .scaleAspectFit
        langImage.frame = CGRect(origin: CGPoint(x: 17, y: 0), size: CGSize(width: 25, height: 25))
        langView.addSubview(langImage)
        
        let langTitle = UILabel(frame: CGRect(x: 0, y: 30, width: langImage.frame.width + 50, height: 12))
        
        langTitle.textAlignment = .center
        langTitle.tag = 1
        langTitle.font = UIFont.systemFont(ofSize: 10)
        
        langTitle.textColor = bottomGrayColor
        langView.addSubview(langTitle)
        
        mainScrollView.addSubview(buttonsView)
        
        let topBorder : UIView = UIView(frame: CGRect(x: 0, y: 57, width: mainScrollView.frame.width, height: 1.0))
        topBorder.backgroundColor = UIColor.hexStringToUIColor("#979797")
        mainScrollView.addSubview(topBorder)
    }
    
    func addPosterImageView() {
        self.posterImageView = UIImageView()
        self.posterImageView.contentMode = .scaleAspectFit
        self.mainScrollView.addSubview(posterImageView)
    }
    
    func addOriginalTitleLabel() {
        self.originalTitleLabel = UILabel()
        self.originalTitleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        self.originalTitleLabel.numberOfLines = 0
        self.mainScrollView.addSubview(originalTitleLabel)
    }
    
    func addLocalizedTitleLabel() {
        self.titleLabel = UILabel()
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.titleLabel.numberOfLines = 0
        self.mainScrollView.addSubview(titleLabel)
    }
    
    func addContentSeperatorLine() {
        contentSeperatorLine = UIView()
        contentSeperatorLine?.backgroundColor = labelGrayColor
        self.mainScrollView.addSubview(contentSeperatorLine!)
    }
    
    func addTrailerLabel() {
        trailerLabel = UILabel()
        trailerLabel?.isUserInteractionEnabled = true
        trailerLabel?.textAlignment = .center
        trailerLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        trailerLabel?.layer.borderWidth = 1.0
        trailerLabel?.layer.borderColor = UIColor.hexStringToUIColor("#211e2d").cgColor
        trailerLabel?.layer.cornerRadius = 5.0
        trailerLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(movieViewOutput.trailerAction)))
        
        self.mainScrollView.addSubview(trailerLabel!)
    }
    
    func addPurchaseLabel() {
        purchaseLabel = UILabel()
        purchaseLabel?.isUserInteractionEnabled = true
        purchaseLabel?.textAlignment = .center
        purchaseLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        purchaseLabel?.layer.borderWidth = 1.0
        purchaseLabel?.layer.borderColor = UIColor.hexStringToUIColor("#211e2d").cgColor
        purchaseLabel?.layer.cornerRadius = 5.0
        purchaseLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(movieViewOutput.purchaseAction)))
        
        self.mainScrollView.addSubview(purchaseLabel!)
    }
    
    func addSeasonsView() {
        currentSeasonLabel = UILabel()
        currentSeasonLabel!.font = UIFont.boldSystemFont(ofSize: 20)
        currentSeasonLabel!.isUserInteractionEnabled = true
        currentSeasonLabel!.sizeToFit()
        mainScrollView.addSubview(currentSeasonLabel!)
        currentSeasonLabel!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(movieViewOutput.seasonSwitchTap)))
        
        
        currentSeasonExpander = UIImageView(image: UIImage(named: "expand_arrow_dark"))
        currentSeasonExpander!.contentMode = .scaleAspectFit
        currentSeasonExpander!.isUserInteractionEnabled = true
        mainScrollView.addSubview(currentSeasonExpander!)
        currentSeasonExpander!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(movieViewOutput.seasonSwitchTap)))
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        seasonCollectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        seasonCollectionView!.backgroundColor = .clear
        seasonCollectionView!.showsHorizontalScrollIndicator = false
        seasonCollectionView!.clipsToBounds = false
        let cellNib = UINib(nibName: EpisodeCollectionViewCell.ReuseIdentifier, bundle: nil)
        seasonCollectionView!.register(cellNib, forCellWithReuseIdentifier: EpisodeCollectionViewCell.ReuseIdentifier)
        mainScrollView.addSubview(seasonCollectionView!)
    }
    
    func addDurationLabels() {
        durationInfoLabel = UILabel()
        durationInfoLabel?.textAlignment = .right
        durationInfoLabel?.text = "Garums"
        durationInfoLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        mainScrollView.addSubview(durationInfoLabel!)
        
        durationDescribingLabel = UILabel()
        durationDescribingLabel?.font = UIFont.systemFont(ofSize: fontSize)
        durationDescribingLabel?.textColor = labelGrayColor
        durationDescribingLabel?.sizeToFit()
        mainScrollView.addSubview(durationDescribingLabel!)
    }
    
    func addYearLabels() {
        yearInfoLabel = UILabel()
        yearInfoLabel?.textAlignment = .right
        yearInfoLabel?.text = "Gads"
        yearInfoLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        mainScrollView.addSubview(yearInfoLabel!)
        
        yearDescribingLabel = UILabel()
        yearDescribingLabel?.font = UIFont.systemFont(ofSize: fontSize)
        yearDescribingLabel?.textColor = labelGrayColor
        yearDescribingLabel?.sizeToFit()
        mainScrollView.addSubview(yearDescribingLabel!)
    }
    
    func addRatingLabels() {
        ratingInfoLabel = UILabel()
        ratingInfoLabel?.textAlignment = .right
        ratingInfoLabel?.text = "Reitings"
        ratingInfoLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        mainScrollView.addSubview(ratingInfoLabel!)
        
        ratingDescribingLabel = UILabel()
        ratingDescribingLabel?.font = UIFont.systemFont(ofSize: fontSize)
        ratingDescribingLabel?.textColor = labelGrayColor
        ratingDescribingLabel?.sizeToFit()
        mainScrollView.addSubview(ratingDescribingLabel!)
    }
    
    func addLanguagesLabels() {
        languagesInfoLabel = UILabel()
        languagesInfoLabel?.textAlignment = .right
        languagesInfoLabel?.text = "Valodas"
        languagesInfoLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        mainScrollView.addSubview(languagesInfoLabel!)
        
        languagesDescribingLabel = UILabel()
        
        languagesDescribingLabel?.font = UIFont.systemFont(ofSize: fontSize)
        languagesDescribingLabel?.textColor = labelGrayColor
        languagesDescribingLabel?.numberOfLines = 0
        languagesDescribingLabel?.sizeToFit()
        mainScrollView.addSubview(languagesDescribingLabel!)
    }
    
    func addSubtitlesLabels() {
        subtitlesInfoLabel = UILabel()
        subtitlesInfoLabel?.textAlignment = .right
        subtitlesInfoLabel?.text = "Subtitri"
        subtitlesInfoLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        mainScrollView.addSubview(subtitlesInfoLabel!)
        
        subtitlesDescribingLabel = UILabel()
        subtitlesDescribingLabel?.font = UIFont.systemFont(ofSize: fontSize)
        subtitlesDescribingLabel?.textColor = labelGrayColor
        subtitlesDescribingLabel?.numberOfLines = 0
        subtitlesDescribingLabel?.sizeToFit()
        mainScrollView.addSubview(subtitlesDescribingLabel!)
    }
    
    func addGenresLabels() {
        genresInfoLabel = UILabel()
        genresInfoLabel?.textAlignment = .right
        genresInfoLabel?.text = "Žanri"
        genresInfoLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        mainScrollView.addSubview(genresInfoLabel!)
        
        genresDescribingLabel = UILabel()
        genresDescribingLabel?.numberOfLines = 0
        genresDescribingLabel?.font = UIFont.systemFont(ofSize: fontSize)
        genresDescribingLabel?.textColor = labelGrayColor
        genresDescribingLabel?.sizeToFit()
        mainScrollView.addSubview(genresDescribingLabel!)
    }
    
    func addDirectorsLabels() {
        directorsInfoLabel = UILabel()
        directorsInfoLabel?.textAlignment = .right
        directorsInfoLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        mainScrollView.addSubview(directorsInfoLabel!)
        
        directorsDescribingLabel = UILabel()
        directorsDescribingLabel?.font = UIFont.systemFont(ofSize: fontSize)
        directorsDescribingLabel?.textColor = labelGrayColor
        directorsDescribingLabel?.numberOfLines = 0
        directorsDescribingLabel?.sizeToFit()
        mainScrollView.addSubview(directorsDescribingLabel!)
    }
    
    func addActorsLabels() {
        actorsInfoLabel = UILabel()
        actorsInfoLabel?.textAlignment = .right
        actorsInfoLabel?.text = "Aktieri"
        actorsInfoLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        mainScrollView.addSubview(actorsInfoLabel!)
        
        actorsDescribingLabel = UILabel()
        actorsDescribingLabel?.font = UIFont.systemFont(ofSize: fontSize)
        actorsDescribingLabel?.textColor = labelGrayColor
        actorsDescribingLabel?.tag = expandableLabel.actors.rawValue
        actorsDescribingLabel?.isUserInteractionEnabled = true
        actorsDescribingLabel?.numberOfLines = 0
        actorsDescribingLabel?.sizeToFit()
        mainScrollView.addSubview(actorsDescribingLabel!)
        actorsDescribingLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(movieViewOutput.expandabelLabelTap(_:))))
    }
    
    func addAnnotationLabels() {
        annotationInfoLabel = UILabel()
        annotationInfoLabel?.textAlignment = .right
        annotationInfoLabel?.text = "Apraksts"
        annotationInfoLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        mainScrollView.addSubview(annotationInfoLabel!)
        
        annotationDescribingLabel = UILabel()
        annotationDescribingLabel?.font = UIFont.systemFont(ofSize: fontSize)
        annotationDescribingLabel?.textColor = labelGrayColor
        annotationDescribingLabel?.tag = expandableLabel.description.rawValue
        annotationDescribingLabel?.isUserInteractionEnabled = true
        annotationDescribingLabel?.numberOfLines = 0
        annotationDescribingLabel?.sizeToFit()
        mainScrollView.addSubview(annotationDescribingLabel!)
        annotationDescribingLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(movieViewOutput.expandabelLabelTap(_:))))
    }
    
    func addRecommendationsView() {
        recommendationsLabel = UILabel()
        recommendationsLabel?.tag = deleteTitleLabel.recomendations.rawValue
        recommendationsLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        recommendationsLabel?.sizeToFit()
        mainScrollView.addSubview(recommendationsLabel!)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        recomendedCollectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        recomendedCollectionView.backgroundColor = .clear
        recomendedCollectionView.showsHorizontalScrollIndicator = false
        recomendedCollectionView.clipsToBounds = false
        let cellNib = UINib(nibName: VideoCollectionViewCell.ReuseIdentifier, bundle: nil)
        recomendedCollectionView.register(cellNib, forCellWithReuseIdentifier: VideoCollectionViewCell.ReuseIdentifier)
        mainScrollView.addSubview(recomendedCollectionView)
    }
    
    func seasonLabel (_ season_nr: Int) -> String {
        return "\(season_nr). sezona"
    }
    
    func resizeBottomLabel(sender: UIView, text: String) {
        var titleLabel: UILabel?
        for subview: UIView in sender.subviews {
            if subview.tag == 1, let label = subview as? UILabel {
                label.text = text
                //label.sizeToFit()
                label.frame.size = CGSize(width: label.frame.width, height: 12)
                titleLabel = label
            }
            
            if subview.tag == 2, let label = titleLabel {
                subview.frame.origin = CGPoint(x: label.frame.origin.x + label.frame.width + 5, y: 25)
            }
        }
    }
    
    func addPlayer(_ size: orientationType)
    {
        DispatchQueue.main.async {
            if let controller = self.playerController {
                let container: UIView;
                if (size == .landscape && UIDevice.current.userInterfaceIdiom == .phone) {
                    container = self.view
                }
                else {
                    container = self.getPlayerHolderView()
                }
                
                var height = container.bounds.height
                if(height == 0)
                {
                    //vel nav augstums - nav pārzīmēts kontrolis
                    //workaround - aprēķinā kāds būs būs, jo ratio ir 16:9
                    height = container.bounds.width / 16 * 9
                }
                
                controller.view.removeFromSuperview()
                let f = CGRect(x: 0, y: 0, width: container.bounds.width, height: height)
                controller.view.frame = f
                container.addSubview(controller.view)
            }
        }
    }
    
    func getPlayerHolderView() -> UIView {
        return topHolderView
    }
    
    func addYoutubePLayer(url: String) {
        if youTubePlayerView == nil {
            youTubePlayerView = YouTubePlayerView()
            youTubePlayerView!.loadVideoID(url)
        } else {
            youTubePlayerView!.removeFromSuperview()
        }
        
        // set current size
        if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation)) {
            youTubePlayerView?.frame.size = self.view.frame.size
        } else {
            youTubePlayerView?.frame = self.topHolderView.frame
        }
        
        //show the youtube view
        self.view.addSubview(youTubePlayerView!)
    }
    
}

extension MovieVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.seasonCollectionView {
            return movieViewOutput.numberOfSeasonMovies
        } else {
            return movieViewOutput.numberOfRecommendations
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.seasonCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EpisodeCollectionViewCell.ReuseIdentifier, for: indexPath) as! EpisodeCollectionViewCell
            movieViewOutput.configureSeasonCell(cell: cell, forRow: indexPath.row)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.ReuseIdentifier, for: indexPath) as! VideoCollectionViewCell
            movieViewOutput.configureRecommendationCell(cell: cell, forRow: indexPath.row)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if collectionView == self.seasonCollectionView {
            // episodes
            return episodeCellSize
        } else {
            // recomended movies
            return recomendationCellSize
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // load selected movie
        if collectionView == self.seasonCollectionView {
            movieViewOutput.didSelectSeasonMovie(forRow: indexPath.row)
        } else {
            movieViewOutput.didSelectRecommendedMovie(forRow: indexPath.row)
        }
    }
}
