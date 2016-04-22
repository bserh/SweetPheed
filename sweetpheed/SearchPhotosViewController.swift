//
//  SerachPhotosViewController.swift
//  sweetpheed
//
//  Created by Sergey Bavykin on 4/22/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit

class SearchPhotosViewController: PhotoCollectionBaseViewController {
    //MARK: - Properties
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var lastSearchedKeyword: String?

    //MARK: - Life Cycle Managing Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    //MARK: - Overrided Methods
    override func fetchData(finishCompletion: (Void -> Void)?) {
        guard let lastSearchedKeyword = lastSearchedKeyword else {
            return
        }
        
        photoSearchService.searchPhotosWithQueryString(lastSearchedKeyword, dataHandler: {
            [weak self] data in
            self?.handleFlickrData(data, finishCompletion: finishCompletion)
        })
    }
    
    //MARK: - Custom Methods
    @objc private func searchData() {
        let newKeyword = searchBar.text!
        
        if let lastSearchedKeyword = lastSearchedKeyword {
            if lastSearchedKeyword != newKeyword {
                self.lastSearchedKeyword = newKeyword
                refreshData()
            }
        } else {
            self.lastSearchedKeyword = newKeyword
            fetchData(nil)
        }
    }
}

//MARK: - Extension - Search Bar Delegate Methods
extension SearchPhotosViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: "searchData", object: nil)
        self.performSelector("searchData", withObject: nil, afterDelay: 0.75)
    }
}