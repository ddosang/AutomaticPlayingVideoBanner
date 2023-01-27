//
//  VideoCollectionViewCell.swift
//  AutomaticPlayingVideoBanner
//
//  Created by qara_macbookpro on 2022/03/18.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    
    private let playerView = PlayerView()
    
    var url: URL?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.contentView.addSubview(playerView)
        
        playerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc
    func volumeAction(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
        playerView.isMuted = sender.isSelected
        PlayerView.videoIsMuted = sender.isSelected
    }
    
    func play() {
        if let url = url {
            playerView.prepareToPlay(withUrl: url, shouldPlayImmediately: true)
        }
    }
    
    func pause() {
        playerView.pause()
    }
    
    // 우리는 로컬 비디오를 재생할 것이므로, 이렇게!
    func configure(video file: String) {
        let file = file.components(separatedBy: ".")
        
        guard let path = Bundle.main.path(forResource: file[0], ofType: file[1]) else {
            debugPrint( "\(file.joined(separator: ".")) not found")
            return
        }
        let url = URL(fileURLWithPath: path)
        self.url = url
        playerView.prepareToPlay(withUrl: url, shouldPlayImmediately: false)
    }
}
