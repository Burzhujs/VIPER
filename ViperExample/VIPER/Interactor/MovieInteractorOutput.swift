//
//  MovieInteractorOutput.swift
//  mansTV
//
//  Created by Matiss Mamedovs on 18/05/2018.
//  Copyright © 2018 DIVI Grupa. All rights reserved.
//

import Foundation
import shortcutEngine

protocol MovieInteractorOutput {
    func setMovie(item: Movie)
    func failedToGetMovie()
    func returnLargeImage(image: UIImage)
    func returnPosterView(image: UIImage)
    func recommendedMoviesReturned(_ result: [ContentObject])
    func recomendedMoviesFailed()
    func episodesReturned(_ movies: [Movie])
    func episodesFailed()
    func tokenGranted(_ token: String, _: String)
    func streamGranted(_ streamList: [VodStream], id: String)
    func streamFailed(_ message: String?)
    func tokenFailed()
}

