//
//  Models.swift
//  CryptoTracker
//
//  Created by Margarita Can on 18.03.2024.
//

import Foundation

final class ListViewModel {
    
    var reloadTableView: (() -> Void)?
    
    var list: [Crypto] = [] {
        didSet {
            list = list.filter({$0.asset_id != nil && $0.price_usd != nil})
        }
    }
    var filteredList: [Crypto] = [] {
        didSet {
            filteredList = filteredList.filter({$0.asset_id != nil && $0.price_usd != nil})
        }
    }
    var icons: [IconModel] = []
    
    func fetchData() {
        APICaller.shared.getAllCryptoData { [weak self] result in
            switch result {
            case .success(let result):
                self?.list = result
                self?.filteredList = result
                self?.fetchIcons()
                self?.reloadTableView?()
            case.failure (let error):
                print("Error: \(error)")
            }
        }
    }
    
    func fetchIcons() {
        APICaller.shared.getAllIcons { [weak self] result in
            switch result {
            case .success(let icons):
                self?.icons = icons
                self?.mixIconsWithCryptos()
            case .failure(_):
                break
            }
        }
    }
    
    func mixIconsWithCryptos() {
        self.list.forEach { crypto in
            icons.forEach { icon in
                if crypto.asset_id == icon.asset_id {
                    crypto.imageUrl = icon.url
                }
            }
        }
        self.reloadTableView?()
    }
}
