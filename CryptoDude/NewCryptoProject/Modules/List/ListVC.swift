//
//  Models.swift
//  CryptoTracker
//
//  Created by Margarita Can on 18.03.2024.
//

import UIKit
import CoreData

final class ListVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: ListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchBar()
        registerCell()
        setupBindings()
        viewModel?.fetchData()
    }
    
    func setupBindings() {
        viewModel?.reloadTableView = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func registerCell() {
        let cellName = String(describing: CryptoCell.self)
        let cellNib = UINib(nibName: cellName, bundle: .main)
        tableView.register(cellNib, forCellReuseIdentifier: cellName)
    }
}

private
extension ListVC {
    func setupUI() {
        self.title = "Markets"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "bookmark.fill"), style: .done, target: self, action: #selector(favButtonTapped))
        tableView.dataSource = self
    }
    
    @objc func favButtonTapped() {
        self.navigationController?.pushViewController(WatchListVC(), animated: true)
    }
    
    func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        if let searchTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            searchTextField.backgroundColor = .white
            searchTextField.attributedPlaceholder = NSAttributedString(string: "Search Cryptos", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.gray])
        }
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
    }
}

extension ListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.filteredList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: "CryptoCell".self), for: indexPath) as? CryptoCell else { return UITableViewCell() }
        cell.delegate = self
        cell.configureCell(viewModel?.filteredList[indexPath.row], indexPath.row)
        return cell
    }
}

extension ListVC: CryptoCellProtocol {
    func addToBookMark(_ index: Int?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let index = index else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let saveData = NSEntityDescription.insertNewObject(forEntityName: "Favorites", into: context)
        
        guard let data = viewModel?.filteredList[index] else { return }
        saveData.setValue(data.name, forKey: "name")
        saveData.setValue(data.price_usd, forKey: "price")
        saveData.setValue(data.imageUrl, forKey: "url")
        saveData.setValue(data.asset_id, forKey: "id")
        
        do {
            try context.save()
            print("Succesfully Saved")
        }catch {
            print("Failure")
        }
    }
}

extension ListVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text?.lowercased() {
            viewModel?.filteredList = viewModel?.list.filter { product in
                return product.name!.lowercased().contains(searchText)
            } ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            viewModel?.filteredList = viewModel?.list ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        if searchController.searchBar.text == "" {
            viewModel?.filteredList = viewModel?.list ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
