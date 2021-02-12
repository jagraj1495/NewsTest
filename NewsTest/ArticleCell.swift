//
//  ArticleCell.swift
//  NewsTest
//
//  Created by JAGRAJ SINGH on 11/02/21.
//

import UIKit

class ArticleCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    func setData(_ article: Article) {
        imageView.image = article.image
        titleLabel.text = article.title
        descriptionLabel.text = article.description
        dateLabel.text = article.dateString
    }
}
