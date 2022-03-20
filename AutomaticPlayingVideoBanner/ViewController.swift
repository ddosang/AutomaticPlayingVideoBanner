//
//  ViewController.swift
//  AutomaticPlayingVideoBanner
//
//  Created by qara_macbookpro on 2022/03/18.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    typealias VideoCell = VideoCollectionViewCell
    typealias ImageCell = ImageCollectionViewCell
    
    private var cardContents: [String] = ["picka.mov", "0.jpg", "picka.mov", "1.jpg", "picka.mov", "2.jpg", "picka.mov", "0.jpg"]
    
    
    lazy var collectionView: UICollectionView = {
        
        // collection view layout setting
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.footerReferenceSize = .zero
        layout.headerReferenceSize = .zero
        
        // collection view setting
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.isScrollEnabled = true
        v.isPagingEnabled = true
        v.showsHorizontalScrollIndicator = false
        v.register(VideoCell.self, forCellWithReuseIdentifier: "VideoCell")
        v.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        v.delegate = self
        v.dataSource = self
        
        // UI setting
        v.backgroundColor = UIColor.black
        v.layer.cornerRadius = 16
        
        return v
    }()
    
    lazy var pageControl = UIPageControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor(red: 227/255, green: 219/255, blue: 235/255, alpha: 1)
        
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        
        let edge = view.frame.width - 40
        
        collectionView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(edge)
        }
        
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.scrollToItem(at: [0, 1], at: .left, animated: false)
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.frame.size.width != 0 {
            let value = (scrollView.contentOffset.x / scrollView.frame.width)
            pageControl.currentPage = Int(round(value))
        }
        playFirstVisibleVideo()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let value = (scrollView.contentOffset.x / scrollView.frame.width)
        
        switch Int(round(value)) {
        case 0:
            let last = cardContents.count - 2
            UIView.animate(withDuration: 0.01, animations: { [weak self] in
              self?.collectionView.scrollToItem(at: [0, last], at: .left, animated: false)
            }, completion: { [weak self] _ in
              self?.playFirstVisibleVideo()
            })
        case cardContents.count - 1:
            self.collectionView.scrollToItem(at: [0, 1], at: .left, animated: false)
        default:
            break
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = cardContents.count
        return self.cardContents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if cardContents[indexPath.item].hasSuffix(".mov") {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
            cell.configure(video: cardContents[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
            cell.configure(image: cardContents[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

extension ViewController {
    func playFirstVisibleVideo(_ shouldPlay:Bool = true) {
        let cells = collectionView.visibleCells.sorted {
            collectionView.indexPath(for: $0)?.item ?? 0 < collectionView.indexPath(for: $1)?.item ?? 0
        }
        let videoCells = cells.compactMap({ $0 as? VideoCollectionViewCell })
        if videoCells.count > 0 {
            let firstVisibileCell = videoCells.first(where: { checkVideoFrameVisibility(ofCell: $0) })
            for videoCell in videoCells {
                if shouldPlay && firstVisibileCell == videoCell {
                    videoCell.play()
                }
                else {
                    videoCell.pause()
                }
            }
        }
    }
    
    func checkVideoFrameVisibility(ofCell cell: VideoCollectionViewCell) -> Bool {
        var cellRect = cell.bounds
        cellRect = cell.convert(cell.bounds, to: collectionView.superview)
        return collectionView.frame.contains(cellRect)
    }
}
