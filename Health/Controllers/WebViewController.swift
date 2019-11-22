//
//  WebViewController.swift
//  Health
//
//  Created by Vikhyath on 28/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    var urlString: String?
    var urlrequest: URLRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let urlunwrapped = urlString else {
            return
        }
        
        guard let url = URL(string: urlunwrapped) else {
            return
        }
        
        urlrequest = URLRequest(url: url)
        guard let urlReq = urlrequest else {
            return
        }
        webView.loadRequest(urlReq)
    }
    
    @IBAction private func backButton(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
}
