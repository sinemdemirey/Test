//
//  PhotoListViewModel.swift
//  Test
//
//  Created by Sinem Demirey on 4.02.2020.
//  Copyright © 2020 Sinem Demirey. All rights reserved.
//

import Foundation

class PhotoListViewModel {
    
    private var photos : [Photo] = [Photo]()
    
    let apiService: APIServiceProtocol
    
    private var cellViewModels: [PhotoListCellViewModel] = [PhotoListCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    var isLoading : Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    var numberOfCells: Int {
        return cellViewModels.count
    }
    
    var reloadTableViewClosure: (()->())?
    var updateLoadingStatus: (()->())?
    var showAlertClosure: (()->())?
    
    init(apiService : APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    func initFetch() {
        self.isLoading = true
        apiService.fetchPopularPhoto { [weak self] (success, photos, error) in
            self?.isLoading = false
            if let error = error {
                self?.alertMessage = error.rawValue
            } else {
                self?.processFetchedPhoto(photos: photos)
            }
        }
    }
    
    func getCellViewModel( at indexPath: IndexPath ) -> PhotoListCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    func createCellViewModel( photo: Photo ) -> PhotoListCellViewModel {
        return PhotoListCellViewModel( titleText: photo.title,
                                       imageUrl: photo.image_url)
    }
    
    private func processFetchedPhoto( photos: [Photo] ) {
        self.photos = photos // Cache
        var vms = [PhotoListCellViewModel]()
        for photo in photos {
            vms.append( createCellViewModel(photo: photo) )
        }
        self.cellViewModels = vms
    }
}

struct PhotoListCellViewModel {
    let titleText: String
    let imageUrl: String
}
