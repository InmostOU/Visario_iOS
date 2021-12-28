//
//  WebViewController.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 04.10.2021.
//

import UIKit
import WebKit
import Alamofire

final class WebViewController: UIViewController {
    
    // MARK: - Properties
    
    private let url: URL
    private let fileName: String
    
    // MARK: - UI Elements
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        return webView
    }()
    
    // MARK: - Lifecycle
    
    init(url: URL, fileName: String = "") {
        self.url = url
        self.fileName = fileName
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureConstraints()
        openDocument()
    }
    
    private func setupViews() {
        view.addSubview(webView)
    }
    
    private func configureConstraints() {
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func openDocument() {
        tabBarController?.tabBar.isHidden = true
        
        if url.scheme == "https" {
            downloadFile(with: url)
        } else {
            showFile(with: url)
        }
    }
    
    private func downloadFile(with url: URL) {
        AF.request(url).response { [weak self] response in
            guard let self = self else { return }
            guard response.error == nil else { return }
            guard let data = response.data else { return }
            
            do {
                let fileManager = FileManager.default
                let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let localURL = documentsURL.appendingPathComponent(self.fileName)
                fileManager.createFile(atPath: localURL.path, contents: data)
                DispatchQueue.main.async {
                    self.webView.load(URLRequest(url: localURL))
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func showFile(with url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
