//
//  ImageCollectionViewCell.swift
//  AutomaticPlayingVideoBanner
//
//  Created by qara_macbookpro on 2022/03/18.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    private let imageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(image: String) {
        if let image = UIImage(named: image) {
            imageView.image = image
        }
    }
}
