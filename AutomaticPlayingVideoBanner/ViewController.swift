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
    
    private var cardContents: [String] = ["picka.png", "0.jpg", "picka.mov", "1.jpg", "picka.mov", "2.jpg", "picka.mov", "0.jpg"]
    
    private var nowPage: Int = 1 {
        didSet {
            setAutoCardTimer()
        }
    }
    private var timer: Timer?
    
    
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
        
        // MARK: - Background Observer
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedBackground), name: UIScene.willDeactivateNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        nowPage = 1
        collectionView.scrollToItem(at: [0, nowPage], at: .left, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        initCardView()
    }
    
    @objc func appMovedToForeground(_ notification: Notification) {
        setAutoCardTimer()
        playFirstVisibleVideo()
    }
    
    @objc func appMovedBackground(_ notification: Notification) {
        // code to execute
        initCardView()
    }
}

extension ViewController {
    func initCardView() {
//        collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: false)
//        nowPage = 1
        timer?.invalidate()
        timer = nil
        playFirstVisibleVideo(false)
    }
    
    func setAutoCardTimer() {
        timer?.invalidate()
        timer = nil
        
        if nowPage == 0 || cardContents[nowPage].hasSuffix("mov") {
            timer = Timer.scheduledTimer(withTimeInterval: 13.2, repeats: false) { [weak self] (Timer) in
                self?.cardMove()
            }
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] (Timer) in
                self?.cardMove()
            }
        }
    }

    func cardMove() {
        if nowPage == cardContents.count - 2 {
            collectionView.scrollToItem(at: [0, 1], at: .right, animated: false)
            nowPage = 1
            return
        }
        
        nowPage += 1
        collectionView.scrollToItem(at: [0, nowPage], at: .right, animated: true)
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
        nowPage = Int(round(value))
        
        switch Int(round(value)) {
        case 0:
            let last = cardContents.count - 2
            UIView.animate(withDuration: 0.01, animations: { [weak self] in
                self?.collectionView.scrollToItem(at: [0, last], at: .left, animated: false)
            }, completion: { [weak self] _ in
                self?.playFirstVisibleVideo()
                self?.nowPage = last
            })
        case cardContents.count - 1:
            collectionView.scrollToItem(at: [0, 1], at: .left, animated: false)
            nowPage = 1
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
