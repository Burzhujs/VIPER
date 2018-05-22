//
//  AppDependencies.swift
//  mansTV
//
//  Created by Matiss on 17/05/2018.
//  Copyright © 2018 DIVI Grupa. All rights reserved.
//

import Foundation
import UIKit
import shortcutEngine

class appDependencies {
    
    fileprivate var controller: MovieVC?
    
    init(controller: MovieVC) {
        self.controller = controller
        configure()
    }
    
    fileprivate func configure() {
        let presenter = MoviePresenter(viewController: controller!)
        let interactor = MovieInteractor()
        let dataHelper = DataHelper()
        
        controller?.movieViewOutput = presenter
        
        presenter.interactor = interactor
        presenter.movieView = controller
        interactor.dataHelper = dataHelper
        interactor.moviePresenterOutput = presenter
    }
    
}
