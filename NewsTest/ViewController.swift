//
//  ViewController.swift
//  NewsTest
//
//  Created by JAGRAJ SINGH on 11/02/21.
//

import UIKit

class ViewController: UIViewController, ArticleLayoutDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    private let newsFetcher = NewsFetcher()
    private var articles: [Article] = []
    
    private var loadMoreView: KRPullLoadView?
    internal var layoutStyle = LayoutStyle.list
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        (collectionView.collectionViewLayout as? ArticleLayout)?.delegate = self
        
        fetchInitialData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        newsFetcher.cancelRequests()
    }
    
    @IBAction func changeLayoutStyle(_ sender: UISegmentedControl) {
        layoutStyle = sender.selectedSegmentIndex == 0 ? .list : .collection
        collectionView.reloadData()
    }
    
    private func fetchInitialData() {
        newsFetcher.fetchData { [weak self] articles, error in
            if articles != nil {
                self?.articles = articles!
                self?.canFetchMore = self?.newsFetcher.canFetchMore ?? false
                self?.collectionView.reloadData()
            } else {
                print(error) // I have not handled errors anywhere.
            }
        }
    }
    
    private func fetchImages(of articles: [Article]) {
        for article in articles {
            guard article.image == nil, let url = article.urlToImage else { continue }
            
            // Get cell for that image and animate loader here
            newsFetcher.downloadImage(at: url) { [weak self] image in
                article.image = image // We can store the image or send request each time when cell is displayed, the next time image will be cached so faster response.
                self?.setImageInCell(article)
            }
        }
    }
    
    private func setImageInCell(_ article: Article) {
        guard let index = articles.firstIndex(of: article) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? ArticleCell else {
            return
        }
        
        collectionView.performBatchUpdates {
            // End image loader here
            cell.imageView.image = article.image
        } completion: { _ in
            
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
        let article = articles[indexPath.row]
        
        if article.image == nil { // Get image
            fetchImages(of: [article])
        }
        cell.setData(article)
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
        return  CGSize(width: itemSize, height: itemSize)
    }
}

extension ViewController: KRPullLoadViewDelegate {
    var canFetchMore: Bool {
        get { return loadMoreView != nil }
        set { newValue ? addLoader() : removeLoader() }
    }
    func removeLoader() {
        if let view = loadMoreView {
            collectionView.removePullLoadableView(view)
            loadMoreView = nil
        }
    }
    func addLoader() {
        if self.loadMoreView != nil { return }
        self.loadMoreView = KRPullLoadView()
        self.loadMoreView?.isHidden = true
        self.loadMoreView?.delegate = self
        self.collectionView.addPullLoadableView(self.loadMoreView!, type: .loadMore)
    }
    
    func pullLoadView(_ pullLoadView: KRPullLoadView, didChangeState state: KRPullLoaderState, viewType type: KRPullLoaderType) {
        if type == .loadMore {
            switch state {
            case let .loading(completionHandler):
                pullLoadView.isHidden = false
                fetchMoreData(completionHandler)
                
            default: pullLoadView.isHidden = true
            }
        }
    }
    
    func fetchMoreData(_ completion: @escaping (() -> ())) {
        newsFetcher.fetchData { [weak self] articles, error in
            guard articles != nil else {
                print(error) // Handle error
                return
            }
            
            let count = self?.articles.count ?? 0
            var indexPaths: [IndexPath] = []
            for i in count..<(count + articles!.count) {
                indexPaths.append(IndexPath(row: i, section: 0))
            }
            
            self?.collectionView.performBatchUpdates {
                self?.articles.append(contentsOf: articles!)
                self?.collectionView.insertItems(at: indexPaths)
                
                completion()
                self?.canFetchMore = self?.newsFetcher.canFetchMore ?? false
            } completion: { _ in
                
            }
        }
    }
}


