//
//  MovieInteractorInput.swift
//  mansTV
//
//  Created by Matiss Mamedovs on 18/05/2018.
//  Copyright © 2018 DIVI Grupa. All rights reserved.
//

import Foundation
import shortcutEngine
import StoreKit

protocol MovieInteractorInput {
    func getMovie(movieID: String)
    func getPosterImage(movie: Movie)
    func loadRecommendations(movieID: String, categoryID: String?, excludeID: String)
    func getMoviesEpisodes(_ seasonID: String, season_nr: Int)
    func getToken(movie: Movie, holder: UIViewController)
    func getMovieStream(_ movieID: String, token: String)
    func resetCWT(movie: Movie)
    func buyProduct(product: SKProduct)
    func sendVodRate(movieID: String, rate: VodRate.Status)
    func sendAnalyticsRate(title: String, rate: VodRate.Status)
    func setWatchLater(movie: Movie)
    func removeWatchLater(movie: Movie)

}


