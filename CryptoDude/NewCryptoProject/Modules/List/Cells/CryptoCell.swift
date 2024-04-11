//
//  Models.swift
//  CryptoTracker
//
//  Created by Margarita Can on 18.03.2024.
//

import UIKit
import Kingfisher

protocol CryptoCellProtocol: AnyObject {
    func addToBookMark(_ index: Int?)
}

final class CryptoCell: UITableViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var priceLabel: UILabel!
    
    weak var delegate: CryptoCellProtocol?
    
    private var index: Int?
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    @IBAction func addToBookmarkTapped(_ sender: Any) {
        
        
        
        
        delegate?.addToBookMark(index)
    }
}

extension CryptoCell {
    
    func configureCell(_ model: Crypto?, _ index: Int?) {
        guard let model else { return }
        self.index = index
        self.nameLabel.text = model.name
        if let price = model.price_usd {
            self.priceLabel.text = "\(price) $"
        }else {
            self.priceLabel.text = "N/A"
        }
        iconImageView.kf.setImage(with: URL(string: model.imageUrl ?? ""), placeholder: UIImage(named: "na"))
    }
}
