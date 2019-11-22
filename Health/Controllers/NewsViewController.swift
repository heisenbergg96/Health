//
//  NewsViewController.swift
//  Health
//
//  Created by Vikhyath on 28/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import UIKit

class NewsViewController: UIViewController {
    
    var newsArticles: [Article] = []
    var imageData: [NSData] = []
    var isError: Bool = false
    @IBOutlet weak var tableView: UITableView!
    var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        fetchArticles()
    }
    
    fileprivate func setUpView() {
        setActivityIndicator()
        setUpTableView()
    }
    
    fileprivate func setUpTableView() {
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = Colors.lightBlue
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setActivityIndicator() {
        
        activityIndicator = {
            let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            activity.center = view.center
            activity.style = UIActivityIndicatorView.Style.gray
            activity.center = view.center
            activity.hidesWhenStopped = true
            return activity
        }()
        activityIndicator?.startAnimating()
        activityIndicator?.backgroundColor = .white
        activityIndicator?.isHidden = false
        guard let unwrappedActivityIndicator = activityIndicator else {
            return
        }
        tableView.addSubview(unwrappedActivityIndicator)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func fetchArticles() {
        
        let session = URLSession(configuration: .default)
        guard let newsUrl = URL(string: Urls.newUrl) else { return }
        
        let task = session.dataTask(with: newsUrl) { data, _, error in
            
            if error != nil {
                self.populateFromCoreData()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.activityIndicator?.stopAnimating()
                }
                return
            }
            guard let dataUnwrapped = data else {
                return
            }
            //json serialisation
            do {
                let json = try JSONSerialization.jsonObject(with: dataUnwrapped, options: .mutableContainers) as? [String: AnyObject]
                if let articles = json?["articles"] as? [[String: AnyObject]] {
                    
                    for article in articles {
                        if let title = article["title"] as? String, let description = article["description"] as? String, let urlToImage = article["urlToImage"] as? String, let webUrl = article["url"] as? String {
                            print(urlToImage)
                            self.newsArticles.append(Article(title: title, description: description, urlToImage: urlToImage, url: webUrl))
                        } else {
                            print("error")
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.activityIndicator?.stopAnimating()
                    self.addToCoreData()
                }
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
    
    private func addToCoreData() {
        
        NewsArticle.deleteObject()
        for article in newsArticles {
            NewsArticle.insertArticle(object: article)
        }
    }
    
    private func populateFromCoreData() {
        newsArticles = NewsArticle.fetchNewsDetails()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArticles.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = newsArticles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as? NewsCell
        cell?.setNeedsUpdateConstraints()
        cell?.updateConstraints()
        cell?.selectionStyle = .none
        cell?.newsImage.image = UIImage(named: "imagePlaceHolder")
        cell?.titleLabel.text = row.title
        cell?.descriptionLabel.text = row.description
        ImageDownloader.downloadImage(urlString: row.urlToImage) { image, _ in
            DispatchQueue.main.async {
                cell?.newsImage?.image = image
            }
        }
        cell?.separatorInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        guard let unwrappedCell = cell else {
            return UITableViewCell()
        }
        return unwrappedCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let webvc = storyboard?.instantiateViewController(withIdentifier: "web") as? WebViewController
        webvc?.urlString = newsArticles[indexPath.row].url
        guard let unwrappedwebvc = webvc else {
            return
        }
        unwrappedwebvc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(unwrappedwebvc, animated: true)
    }
}
