//
//  MovieWireFrame.swift
//  mansTV
//
//  Created by Matiss Mamedovs on 18/05/2018.
//  Copyright © 2018 DIVI Grupa. All rights reserved.
//

import Foundation


class MovieWireFrame {
    
    fileprivate var vc: UIViewController?
    
    init(vc: UIViewController) {
        self.vc = vc
    }
    
    var presenter: MoviePresenter!
    
    func popViewController() {
        self.vc?.navigationController!.popViewController(animated: true)
    }
}
