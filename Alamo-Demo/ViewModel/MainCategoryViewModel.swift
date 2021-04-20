//
//  MainCategoryViewModel.swift
//  Alamo-Demo
//
//  Created by Akshay on 4/19/21.
//  Copyright © 2021 Pooja Mahajan. All rights reserved.
//

import Foundation

protocol MainCategoryViewModelDelegate: class {
    func loadHomeCategory()
}

class MainCategoryViewModel: NSObject {
    private var apiService = APIService()
    weak var delegate: MainCategoryViewModelDelegate?
    
    private(set) var homeCategory: HomeCategory? = nil {
        didSet {
            delegate?.loadHomeCategory()
        }
    }
    
    func fetchHomeCategory() {
        guard let url = URL(string: Constants.ExternalHyperlinks.homeCategory) else {
            return
        }
        
        APIClient.getHomeCategory(url: url) { result in
            switch result {
            case .success(let homeCategory):
                self.homeCategory = homeCategory
            case .failure(let error):
                print(error)
            }
        }
    }
}
