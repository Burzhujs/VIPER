//
//  MoviePresenter.swift
//  mansTV
//
//  Created by Matiss on 17/05/2018.
//  Copyright © 2018 DIVI Grupa. All rights reserved.
//

import Foundation
import shortcutEngine
import AVFoundation
import AVKit
import StoreKit

enum expandableLabel: Int {
    case actors = 1, description = 2
}

enum deleteTitleLabel: Int {
    case recomendations = 3
}

class MoviePresenter: MovieViewOutput {

    private var categoryID: String? = nil
    var movie: Movie!

    private var recomendedMovies: [Movie] = [Movie]()
    private var seasonMovies: [Movie] = [Movie]()
    private var streamList: [VodStream] = []
    
    fileprivate var products: [SKProduct]? = nil
    fileprivate var premiumMovieProduct: SKProduct? {
        get {
            guard let products = self.products else {
                return nil
            }
            
            if let moviePrice = self.movie?.price {
                for product in products {
                    if (moviePrice as Decimal) <= (product.price as Decimal) {
                        return product
                    }
                }
                return products.last
            } else {
                return products.last
            }
        }
    }
    
    var movieView: MovieViewInput!
    var interactor: MovieInteractorInput!
    var wireframe: MovieWireFrame!
    
    var numberOfRecommendations: Int {
        return recomendedMovies.count
    }
    
    init (viewController: UIViewController) {
        wireframe = MovieWireFrame(vc: viewController)
    }
    
    var numberOfSeasonMovies: Int {
        return seasonMovies.count
    }
    
    func getMovie(movieID: String, categoryID: String?=nil) {
        if let categoryID = categoryID {
            self.categoryID = categoryID
        }
        
        self.movieView?.startLoading()
        self.interactor.getMovie(movieID: movieID)
    }
    
    func setMovie(item: Movie) {
        self.movie = item
        setMovieViewAttributes()
    }
    
    func failedToGetMovie() {
        self.movieView.finishLoading()
        self.movieView?.showAlertView(message: MSG_FAILED_BACKEND)
    }
    
    fileprivate func setMovieViewAttributes() {
            self.setActionImage()
            interactor.getPosterImage(movie: self.movie)
            self.loadRecommendations()
            self.loadEpisodes()
            self.setLabelsTitlesAndSizes()
            self.movieView?.finishLoading()
    }
    
    fileprivate func loadEpisodes() {
        if let season_nr = movie?.activeSeason, let series_id = movie?.series_id {
            
            if self.seasonMovies.count > 0 {
                //clear last data
                self.seasonMovies.removeAll()
                movieView?.refreshEpisodesCollectionView()
            }
            
            movieView?.startLoadingEpisodes()
            interactor.getMoviesEpisodes(series_id, season_nr: season_nr)
        }
    }
    
    fileprivate func loadRecommendations() {
        guard let movie = self.movie else {
            return
        }
        
        if self.recomendedMovies.isEmpty {
            // load recomendations from backend
            movieView?.startLoadingRecommendations()
            interactor.loadRecommendations(movieID: movie.id, categoryID: categoryID, excludeID: movie.series_id!)
        } else {
            movieView?.refreshRecommendationsCollectionView()
        }
    }
    
    func recommendedMoviesReturned(_ result: [ContentObject]) {
        if result.count == 0 {
            self.movieView?.deleteRecomendedMoviesUIElements()
            self.movieView?.finishLoadingRecommendations()
        } else {
            
            self.recomendedMovies = result.filter({ $0 is Movie }) as? [Movie] ?? []
            DispatchQueue.main.async {
                self.movieView?.addRecommendationDelegateSource()
                
                self.movieView?.finishLoadingRecommendations()
            }
        }
    }
    
    func recomendedMoviesFailed() {
        DispatchQueue.main.async {
            self.movieView?.deleteRecomendedMoviesUIElements()
        }
    }
    
    func returnLargeImage(image: UIImage) {
        DispatchQueue.main.async {
            self.movieView?.setPosterImageView(image: image)
        }
    }
    func returnPosterView(image: UIImage) {
        DispatchQueue.main.async {
            self.movieView?.setPosterView(image: image)
        }
    }
    
    fileprivate func setLabelsTitlesAndSizes() {
        movieView?.setPosterSize()
        if let title_original = movie.title, title_original != movie?.titleLocalized {
            movieView?.setOriginalTitleLabel(title_original: title_original)
        }
        movieView?.setTitleLabel(title: movie.titleLocalized!)
        if (movie?.trailer != nil && movie.trailer!.characters.count > 0) || (LoginHelper.isLoggedIn && movie.isPremiere && !movie.isPremiere) {
            movieView?.setSeperatorLine()
        }
        if let trailer = movie?.trailer, trailer.characters.count > 0 {
            movieView?.setTrailerLabel(text: "TREILERIS")
        }
        if LoginHelper.isLoggedIn && movie.isPremiere && !movie.isPaid {
            if let product = premiumMovieProduct {
                if let trailer = movie.trailer, trailer.characters.count > 0 {
                    movieView?.setPurchaseLabel(xConstant: 88, text: product.localizedPrice()! + "NOMĀT")
                } else {
                    movieView?.setPurchaseLabel(xConstant: 0, text: product.localizedPrice()! + "NOMĀT")
                }
            }
        }
        
        if let seasons = movie.seasons, !seasons.isEmpty, let season = movie.activeSeason {
            movieView?.setCurrentSeasonsLabel(season: season)
        }
        
        if let length = movie.length, length != "0" {
            movieView?.setLengthLabel(infoText: "Garums", descText: length)
        }
        
        if let year = movie.year, year.characters.count > 0 {
            movieView?.setYearLabel(infoText: "Gads", descText: year)
        }
        
        if let rating = movie.imdb_rating, rating != "0" {
            movieView?.setRatingLabel(infoText: "Reitings", descText: rating)
        }
        
        if movie.languages.count > 0 {
            var labelText: String = ""
            for (index,language) in (movie.languages.enumerated()) {
                labelText += language.title ?? ""
                
                if index != (movie?.languages.count)! - 1 {
                    labelText += ", "
                }
            }
            movieView?.setLanguagesLabel(infoText: "Valodas", descText: labelText)
        }
        
        if movie.subtitles.count > 0 {
            var labelText: String = ""
            for (index,subtitle) in (movie.subtitles.enumerated())! {
                labelText += subtitle.title ?? ""
                
                if index != (movie?.subtitles.count)! - 1 {
                    labelText += ", "
                }
            }
            movieView?.setSubtitlesLabel(infoText: "Valodas", descText: labelText)
            
        }
        
        if self.movie != nil {
            var labelText: String = ""
            if let genres = movie?.genres, genres.count > 0 {
                labelText = genres.joined(separator: ", ")
            } else {
                labelText = (movie?.genre)!
            }
            movieView?.setGenresLabel(infoText: "Žanri", descText: labelText)
        }
        
        if let directors = movie?.directors, directors.count > 0 {
            var infoLabel: String = ""
            if directors.count == 1 {
                infoLabel = "Režisors"
            } else {
                infoLabel = "Režisori"
            }
            movieView?.setDirectorsLabel(infoText: infoLabel, descText: directors.joined(separator: ", "))
        }
        
        if let actors = movie?.actors, actors.count > 0 {
            movieView?.setActorsLabel(infoText: "Aktieri", descText: actors.prefix(5).joined(separator: ", ") + (actors.count > 5 ? " [...]" : ""))
        }
        
        if let annotation = movie?.annotation, annotation.characters.count > 0 {
            movieView?.setDescriptionLabel(infoText: "Apraksts", descText: annotation.trimAnnotation())
        }
        
        movieView?.setRecommendationsView(infoText: "Iesakām noskatīties")
        
    }
    
    fileprivate func setActionImage() {
        var imageUrl: String = ""
        if !movie!.isFree && !LoginHelper.hasVod && !movie!.isPremiere {
            imageUrl = "locked"
        } else {
            imageUrl = "play_button"
        }
        self.movieView?.setActionImage(named: imageUrl)
    }
    
    func episodesReturned(_ movies: [Movie]) {
        self.seasonMovies = movies
        DispatchQueue.main.async {
            
            self.movieView?.refreshEpisodesCollectionView()
            
            for (index, seasonMovie) in self.seasonMovies.enumerated() {
                if seasonMovie.id == self.movie?.id {
                    self.movieView?.scrollToItem(index: index)
                }
            }
            
            self.movieView?.finishLoadingEpisodes()
        }
    }
    
    func episodesFailed()
    {
        DispatchQueue.main.async {
            self.movieView?.showAlertView(message: MSG_FAILED_BACKEND)
            self.movieView?.finishLoadingEpisodes()
        }
    }
    
    func configureSeasonCell(cell: EpisodeCollectionViewCell, forRow row: Int) {
        cell.loadItem(seasonMovies[row], selected: self.movie?.id == seasonMovies[row].id)
    }
    
    func configureRecommendationCell(cell: VideoCollectionViewCell,forRow row: Int) {
        cell.loadItem(recomendedMovies[row])
    }
    
    func didSelectSeasonMovie(forRow: Int) {
        self.movie = seasonMovies[forRow]
        changeMovie()
    }
    
    func didSelectRecommendedMovie(forRow: Int) {
        self.movie = recomendedMovies[forRow]
        changeMovie()
    }
    
    func changeMovie() {
        self.movieView?.removePlayer()
        movieView?.hideNavigationBar()
        movieView?.clearViews()
        self.recomendedMovies.removeAll()
        self.seasonMovies.removeAll()
        if let movie = movie {
            self.getMovie(movieID: movie.id)
        }
    }
    
    @objc public func popViewController() {
        wireframe.popViewController()
    }
    
    @objc public func mainImageAction() {
        if LoginHelper.isLoggedIn && (movie?.isPremiere)! && !(movie?.isPaid)! {
            self.purchaseAction()
        } else {
            self.playMovie()
        }
    }
    
    func playMovie()
    {
        guard let movie = movie else {
            return
        }
        
        self.movieView?.removePlayer()
        
        if !movieView!.loadingStream {
            if !movie.isFree && !LoginHelper.isLoggedIn {
                var message: String
                if !movie.isPremiere {
                    message = MSG_MOIVE_NEED_LOGIN
                } else {
                    message = MSG_MOIVE_NEED_LOGIN_PURCHASE
                }
                //ask if user wants to login in
                movieView?.holderView.login(selected: movie as! ContentObject, message: message)
            } else {
                movieView?.startLoadingStream()
                interactor.getToken(movie: movie, holder: movieView.holderView)
            }
        }
    }
    
    func tokenGranted(_ token: String, _: String)
    {
        guard let movie = movie else {
            return
        }
        
        if !movie.isPremiere && !movie.isFree && !LoginHelper.hasVod {
            // no right to watch movie
            DispatchQueue.main.async {
                self.movieView?.showAlertView(message: MSG_MOIVE_NOT_PURCHASED)
                
                self.movieView?.finishLoadingStream()
            }
        } else {
            //get vod stream url
            interactor.getMovieStream(movie.id, token: token)
        }
    }
    
    func streamGranted(_ streamList: [VodStream], id: String)
    {
        guard let movie = movie else {
            return
        }
        if movie.id == id {
            DispatchQueue.main.async {
                self.streamList = streamList
                var streamUrl: String? = nil
                
                for stream in streamList {
                    for streamSubtitle in stream.subtitles {
                        for subtitle in movie.subtitles {
                            if subtitle.id == streamSubtitle.id {
                                subtitle.url = streamSubtitle.url
                                break
                            }
                        }
                    }
                }
                
                if let selectedLanguage = movie.selectedLanguage {
                    for stream in streamList {
                        if let streamLanguage = stream.language, streamLanguage.code == selectedLanguage.code,
                            let stream_Url = stream.streamUrl {
                            
                            streamUrl = stream_Url
                            break
                        }
                    }
                } else {
                    streamUrl = streamList.first!.streamUrl!
                }
                
                if let streamUrl = streamUrl {
                    self.makePlayer(streamUrl)
                }
                
                self.movieView?.finishLoadingStream()
            }
        }
    }
    
    func makePlayer(_ stream: String, controllerTag: Int = 0)
    {
        if let movie = self.movie {
            
            // show navigation bar
            self.movieView?.hideNavigationBar()
            
            // add player
            
            let url = URL(string: stream)!
            self.movieView?.removePlayeritem()
            
            
            // sends to google analytics
            self.movie?.SendPlayAction()
            
            //
            self.movieView?.createNewPlayer(url: url, controllerTag: controllerTag)
            
            if let selectedSubtitle = self.movie?.selectedSubtitle, let subtitleUrl = selectedSubtitle.url {
                movieView?.addSubtitles(subtitleUrl: subtitleUrl)
            }
            
            if (self.movie.hasContinueWatchingTime) {
                movieView?.CWTAlertView(message: MSG_MOIVE_CONTINUE_WATCHING, time: Int64(self.movie!.continue_watching_time - 12))
            } else {
                movieView?.addPlayer()
            }
        } else {
            return
        }
    }
    
    func resetCWT() {
        interactor.resetCWT(movie: self.movie)
    }
    
    func streamFailed(_ message: String?)
    {
        DispatchQueue.main.async {
            if let message = message {
                if message == MSG_PREMIUM_MOIVE_NOT_PURCHASED {
                    self.movie?.SendPlayFailed()
                }
                self.movieView?.showAlertView(message: message)
            } else {
                self.movieView?.showAlertView(message: MSG_FAILED_VOD_STREAM_RETURN_FROM_BACKEND)
            }
            
            self.movieView?.finishLoadingStream()
        }
    }
    
    func tokenFailed()
    {
        DispatchQueue.main.async {
            self.movieView?.showAlertView(message: MSG_FAILED_VOD_STREAM_RETURN_FROM_BACKEND)
            self.movieView?.finishLoadingStream()
        }
    }
    
    @objc public func backAction() {
        wireframe.popViewController()
        movieView?.popViewController()
    }
    
    @objc public func trailerAction() {
        self.movieView?.removePlayer()
        
        if let youTubeId = self.movie?.trailer {
            self.movieView.addYoutubePLayer(url: youTubeId)
        }
    }
    
    @objc internal func purchaseAction() {
        if let product = self.premiumMovieProduct {
            movieView?.startLoading()
            // start buying product
            interactor.buyProduct(product: product)
            
        }
    }
    
    @objc public func likeButtonAction(isSelected: Bool) {
        guard LoginHelper.isLoggedIn else {
            self.movieView?.showAlertView(message: MSG_MOIVE_RATE_UNAVAILABLE)
            return
        }
        
        movieView?.setButtonsStatus(like: !isSelected, dislike: false)
        
        let newValue: Bool?
        if isSelected {
            newValue = nil
        } else {
            newValue = false
        }
        
        changeUserLikeSatuss(newValue)
        
        
        movieView?.setButtonLikeCount(likes: String(self.movie!.likeCount), dislikes: String(self.movie!.dislikeCount))
    }
    
    @objc public func dislikeButtonAction(isSelected: Bool) {
        guard LoginHelper.isLoggedIn else {
            self.movieView?.showAlertView(message: MSG_MOIVE_RATE_UNAVAILABLE)
            return
        }
        
        movieView?.setButtonsStatus(like: false, dislike: !isSelected)
        
        let newValue: Bool?
        if isSelected {
            newValue = nil
        } else {
            newValue = false
        }
        
        changeUserLikeSatuss(newValue)
        
        
        movieView?.setButtonLikeCount(likes: String(self.movie!.likeCount), dislikes: String(self.movie!.dislikeCount))
    }
    
    @objc public func watchLaterButtonAction(isSelected: Bool) {
        guard LoginHelper.isLoggedIn else {
            self.movieView?.showAlertView(message: MSG_MOIVE_WATCH_LATER)
            return
        }
        
        if isSelected {
            movieView?.decorateWatchLaterButton(title: "Vēlāk", imageName: "add_watch_later", state: .normal, isSelected: false)
            interactor.removeWatchLater(movie: movie)

        } else {
            movieView?.decorateWatchLaterButton(title: "Noņemt", imageName: "remove_watch_later", state: .selected, isSelected: true)
            interactor.setWatchLater(movie: movie)
        }
    }
    
    @objc public func subtitlesAction(_ sender: UITapGestureRecognizer) {
        //turpināt šeit
        guard let movie = movie, movie.languages.count > 0 else {
            return
        }
        var subtitles = [String]()
        for subtitle in movie.subtitles {
            if let title = subtitle.titleShort {
                subtitles.append(title)
            }
        }
        
        self.movieView?.showSubtitlesAlertView(sender: sender, optionMessage: "Subtitru izvēle", defaultTitle: "Bez subtitriem", subtitles: subtitles)
        
        
    }
    
    func removeSubtitles() {
        self.movie?.selectedSubtitle = nil
    }
    
    func selectSubtitle(selectedSubtitle: String) {
        if let subtitles = movie?.subtitles {
            for subs in subtitles {
                if subs.titleShort == selectedSubtitle {
                    self.movie?.selectedSubtitle = subs
                }
            }
        }
    }
    
    func subtitleTrackChanged() {
        if let selectedSubtitle = self.movie?.selectedSubtitle, let subtitleUrl = selectedSubtitle.url {
            movieView?.addSubtitles(subtitleUrl: subtitleUrl)
        } else {
            movieView?.removeSubtitles()
        }
    }
    
    func languageSelectionChanged(currentTime: CMTime) {
        if let selectedLanguage = movie?.selectedLanguage {
            if let streamUrl = VodStream.GetPreferredStream(list: streamList, selectedLanguage: movie?.selectedLanguage, selectedQuality: movie.default_quality)?.streamUrl {
                movieView?.createPlayerItem(url: streamUrl, time: currentTime)
            }
        }
    }
    
    @objc public func languageAction(_ sender: UITapGestureRecognizer) {
        guard let movie = movie, movie.languages.count > 0 else {
            return
        }
        var languages = [String]()
        for language in movie.languages {
            if let title = language.titleShort {
                languages.append(title)
            }
        }
        self.movieView?.showLanguagesAlertView(sender: sender, optionMessage: "Valodas izvēle", languages: languages)
    }
    
    func selectLanguage(selectedLanguage: String) {
        if let languages = movie?.languages {
            for lang in languages {
                if lang.titleShort == selectedLanguage {
                    self.movie?.selectedLanguage = lang
                }
            }
        }
        
    }
    
    func changeUserLikeSatuss(_ newValue: Bool?) {
        guard let movie = self.movie else {
            return
        }
        
        if let newValue = newValue {
            if newValue {
                movie.likeCount += 1
                
                if let userLikes = movie.userLikes, !userLikes {
                    movie.dislikeCount -= 1
                }
            } else {
                movie.dislikeCount += 1
                
                if let userLikes = movie.userLikes, userLikes {
                    movie.likeCount -= 1
                }
            }
        } else {
            // set to neutral
            if let userLikes = movie.userLikes {
                if userLikes {
                    movie.likeCount -= 1
                } else {
                    movie.dislikeCount -= 1
                }
            }
        }
        
        movie.userLikes = newValue
        
        //
        let type: VodRate.Status
        
        if let newValue = newValue {
            if newValue {
                type = .like
            } else {
                type = .dislike
            }
        } else {
            type = .neutral
        }
        
        sendRateToAnalytics(type)
        
        //send to backend
        interactor.sendVodRate(movieID: movie.id!, rate: type)
    }
    
    func sendRateToAnalytics(_ rate: VodRate.Status)
    {
        //add to analytic play action
        interactor.sendAnalyticsRate(title: self.movie!.AnalyticsTitle, rate: VodRate.Status)
    }
    
    @objc public func seasonSwitchTap() {
        if let seasons = movie?.seasons {
            for season in seasons {
                var returnSeasons = [Int]()
                returnSeasons.append(season)
            }
        }
    }
    
    @objc func expandabelLabelTap(_ sender: UITapGestureRecognizer) {
        if let label = sender.view as? UILabel, let type = expandableLabel(rawValue: label.tag) {
            var returnText: String = ""
            let oldSize = label.frame.size
            
            switch type {
            case .actors:
                if let actors = movie?.actors, actors.count > 5 {
                    
                    let longList = actors.joined(separator: ", ")
                    
                    if label.text == longList {
                        returnText = actors.prefix(5).joined(separator: ", ") + " [...]"
                    } else {
                        returnText = longList
                    }
                }
                
                break
            case .description:
                if let annotation = movie?.annotation {
                    let shortAnnotation = annotation.trimAnnotation()
                    if label.text == shortAnnotation {
                        returnText = annotation
                    } else {
                        returnText = shortAnnotation
                    }
                }
                
                break
            }
            
            label.sizeToFit()
            let newSize = label.frame.size
            
            if newSize != oldSize {
                let diff = newSize.height - oldSize.height
                for control in label.superview!.subviews {
                    if control.frame.origin.y > label.frame.origin.y + oldSize.height {
                        control.frame.origin = CGPoint(x: control.frame.origin.x, y: control.frame.origin.y + diff)
                    }
                    
                }
                self.movieView?.updateExpandabledLabel(label: label, text: returnText, diff: diff)
                // update scroll region
            }
            
        }
    }
    
    func switchSeason (_ selectedSeason: Int) {
        // save in model
        movie!.activeSeason = selectedSeason
        movieView?.updateSeasonLabel(text: selectedSeason)
        
        // reload episodes in collection view
        self.loadEpisodes()
    }
    
    func saveContinueWatching(currentItem: AVPlayerItem) {
        if LoginHelper.isLoggedIn {
            if let movie = self.movie {
                if currentItem.duration > currentItem.currentTime() && CMTimeGetSeconds(currentItem.currentTime()) > 20 {
                    // if not the end - set continue watching
                    let currentTime:TimeInterval = CMTimeGetSeconds(currentItem.currentTime())
                    movie.saveContinueWatching(Int(round(currentTime)))
                } else {
                    // has reached the end - reset continue watching
                    movie.resetContinueWatching()
                }
            }
        }
    }
}


extension MoviePresenter: MovieInteractorOutput {
    
}
