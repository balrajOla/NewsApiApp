//
//  ArticleTableViewCell.swift
//  NewsApi
//
//  Created by Balraj Singh on 13/01/19.
//  Copyright © 2019 balraj. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

class ArticleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    private var imageUrlString: String?
    
    private var downloadTask : URLSessionDownloadTask?
    public var imageURL: URL? {
        didSet {
            self.downloadItemImageForSearchResult(imageURL: imageURL)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func setUpData(for article: Article) {
        // verify if all data is avialable
        // prepare url from the above data
        guard let title = article.title,
            let urlString = article.urlToImage,
            let imageUrl = URL.init(string: urlString) else {
                self.downloadTask?.cancel()
                imageView?.image = #imageLiteral(resourceName: "Placeholder")
                return
        }
        
        // start downloading image
        self.title.text = title
        self.downloadItemImageForSearchResult(imageURL: imageUrl)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    private func downloadItemImageForSearchResult(imageURL: URL?) {
        
        if let urlOfImage = imageURL {
            if let cachedImage = imageCache.object(forKey: urlOfImage.absoluteString as NSString) {
                self.imgView?.image = cachedImage as? UIImage
            } else {
                let session = URLSession.shared
                self.downloadTask = session.downloadTask(
                    with: urlOfImage as URL, completionHandler: { [weak self] url, response, error in
                        if error == nil, let url = url, let data = NSData(contentsOf: url), let image = UIImage(data: data as Data) {
                            DispatchQueue.main.async() {
                                let imageToCache = image
                                if let strongSelf = self,
                                    let imageView = strongSelf.imgView {
                                    imageView.image = imageToCache
                                    imageCache.setObject(imageToCache, forKey: urlOfImage.absoluteString as NSString , cost: 1)
                                }
                            }
                        }
                })
                self.downloadTask!.resume()
            }
        }
    }
    
    override public func prepareForReuse() {
        self.downloadTask?.cancel()
    }
    
    deinit {
        self.downloadTask?.cancel()
        imgView?.image = nil
    }
}
