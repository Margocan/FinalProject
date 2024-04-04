//
//  Models.swift
//  CryptoTracker
//
//  Created by Margarita Can on 18.03.2024.
//

import UIKit
import CoreData

final class WatchListVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var savedList: [Crypto] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetch()
    }
}

private
extension WatchListVC {
    func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let cellIdentifier = String(describing: FavCell.self)
        let nib = UINib(nibName: cellIdentifier, bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
        
        self.title = "Watchlist"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
}

extension WatchListVC {
    func fetch() {
        savedList.removeAll()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        fetchRequest.returnsObjectsAsFaults = false
        
        
        do {
            let result = try context.fetch(fetchRequest)
            fetchResult(result)
        }catch {
            print("Fetch request has failed.")
        }
    }
    
    func fetchResult(_ results: [NSFetchRequestResult]) {
        for result in results as! [NSManagedObject] {
            if let name = result.value(forKey: "name") as? String,
               let id = result.value(forKey: "id") as? String,
               let price = result.value(forKey: "price") as? Float,
               let url = result.value(forKey: "url") as? String {
                savedList.append(.init(asset_id: id, name: name, price_usd: price, id_icon: nil, imageUrl: url))
            }
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension WatchListVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FavCell.self), for: indexPath) as? FavCell else { return UICollectionViewCell() }
        cell.delegate = self
        cell.configureCell(savedList[indexPath.row], indexPath.row)
        return cell
    }
}

extension WatchListVC: FavCellProtocol {
    func deleteBookmark(_ index: Int?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let index = index else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        
        do {
            guard let fetchedResults = try managedContext.fetch(fetchRequest) as? [NSManagedObject] else { return }
            
            for data in fetchedResults {
                if let id = data.value(forKey: "id") as? String, let assetId = savedList[index].asset_id {
                    if id == assetId {
                        managedContext.delete(data)
                    }
                }
            }
            try managedContext.save()
            
        } catch {
            print(error.localizedDescription)
        }
        
  
        fetch()
    }
}
