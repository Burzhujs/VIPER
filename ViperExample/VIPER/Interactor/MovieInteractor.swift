//
//  MovieInteractor.swift
//  mansTV
//
//  Created by Matiss on 17/05/2018.
//  Copyright © 2018 DIVI Grupa. All rights reserved.
//

import Foundation
import shortcutEngine
import StoreKit

class MovieInteractor: MovieInteractorInput {
    
    var dataHelper: DataHelper?
    var moviePresenterOutput: MovieInteractorOutput!
    
    func getMovie(movieID: String) {
        dataHelper.getMovie(movieID, includeActualEpisode: true, completeCallback: { ( item: ContentObject)  in
            DispatchQueue.main.async {
                if let returnedMovie = item as? Movie {
                    if let actual_episode = returnedMovie.actual_episode {
                         moviePresenterOutput.setMovie(item: actual_episode)
                    } else {
                        moviePresenterOutput.setMovie(item: returnedMovie)
                    }
                }
            }
        }, errorCallback: {
            DispatchQueue.main.async {
                moviePresenterOutput.failedToGetMovie()
            }
        })
    }
    
    func getPosterImage(movie: Movie) {
        self.GetLargeImageAsync({ (image: UIImage?, id: String)   in
            if movie.id == id {
                if let image = image {
                    DispatchQueue.main.async {
                        self.moviePresenterOutput.returnLargeImage(image: image)
                    }
                } else {
                    self.GetPosterImageAsync({ (image: UIImage?, id: String)   in
                        if movie.id == id {
                            if let image = image {
                                DispatchQueue.main.async {
                                    self.moviePresenterOutput.returnPosterView(image: image)
                                }
                            }
                        }
                        
                    })
                }
            }
        })
    }
    
    func loadRecommendations(movieID: String, categoryID: String?, excludeID: String) {
        if let categoryId = categoryID {
            dataHelper.getRecomendedContentByCategory(movieID, categoryId: categoryID, excludeSeriesID: excludeID, completeCallback: {(result: [ContentObject]) in
                moviePresenterOutput.recommendedMoviesReturned(result)
            }, errorCallback: {
                moviePresenterOutput.recomendedMoviesFailed()
            })
        } else {
            dataHelper.getRecomendedContentByVods(movieID, completeCallback: {(result: [ContentObject]) in
                moviePresenterOutput.recommendedMoviesReturned(result)
            }, errorCallback: {
                moviePresenterOutput.recomendedMoviesFailed()
            })
        }
    }
    
    func getMoviesEpisodes(_ seasonID: String, season_nr: Int) {
        dataHelper.getMoviesEpisodes(seasonID, season_nr: season_nr, completeCallback: {(_ movies: [Movie]) in
            moviePresenterOutput.episodesReturned(movies)
        }, errorCallback: {
            moviePresenterOutput.episodesFailed()
        })
    }
    
    func getToken(movie: Movie, holder: UIViewController) {
        dataHelper.GetToken(for: movie, completeCallback: {(_ token: String, _ callerId: String) in
            moviePresenterOutput.tokenGranted(token, callerId)
        }, errorCallback: {
            moviePresenterOutput.tokenFailed()
        }, holder: holder)

    }
    
    func getMovieStream(_ movieID: String, token: String) {
        dataHelper.getMovieStream(movieID, token: token, completeCallback: {(_ links: [VodStream], _ id: String) in
            moviePresenterOutput.streamGranted(links, id: id)
        }, errorCallback: {(message: String) in
            moviePresenterOutput.streamFailed(message)
        })
    }
    
    func resetCWT(movie: Movie) {
        movie.continue_watching_time = 0
        dataHelper.resetContinueWatching(movie.id, type: movie.type)
    }
    
    func buyProduct(product: SKProduct) {
        IAP.buyProduct(product)
    }

    func sendVodRate(movieID: String, rate: VodRate.Status) {
        dataHelper.SendVodRate(movieID: movieID, rate: rate)
    }
    
    func sendAnalyticsRate(title: String, rate: VodRate.Status) {
        GoogleAnalyticsHelper.AddEvnet("SOCIAL (VOD)", action: title, label: "Soc_Type: " + String(describing: rate))
    }
    
    func setWatchLater(movie: Movie) {
        dataHelper.setWatchLater(movie: movie)
    }
    
    func removeWatchLater(movie: Movie) {
        dataHelper.removeWatchLater(movie: movie)

    }
    
    /// MARK: original images (full size and quality)
    open func GetPosterImageAsync(_ completed: @escaping (UIImage?, String) -> Void) {
        movie.GetImageAsync(path: self.posterUrl, placeholder: Movie.placeholderPosterImage, completed: completed)
    }
    
    open func GetLargeImageAsync(_ completed: @escaping (UIImage?, String) -> Void) {
        movie.GetImageAsync(path: self.pictureLargeUrl, placeholder: Movie.placeholderPosterImage, completed: completed)
    }
    
    /// MARK: resized and downgraded images for perfomance
    open func GetResizedPosterImageAsync(size: CGSize, completed: @escaping (UIImage?, String) -> Void) {
        movie.GetImageAsync(path: self.posterUrl, placeholder: Movie.placeholderPosterImage, size: size, completed: completed)
    }
    
    open func GetResizedLargeImageAsync(size: CGSize, completed: @escaping (UIImage?, String) -> Void) {
        movie.GetImageAsync(path: self.pictureLargeUrl, placeholder: Movie.placeholderPosterImage, size: size, completed: completed)
    }
}
