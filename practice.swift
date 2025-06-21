//
//  ViewController.swift
//  practice2
//
//  Created by OPL on 19/6/25.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKScriptMessageHandler {
       

    
    @IBAction func btn1(_ sender: Any) {
        let js = "fromAndroidToWebSite('Hello from iOS app!')"
            webView.evaluateJavaScript(js) { result, error in
                if let error = error {
                    print("JS error: \(error.localizedDescription)")
                } else {
                    print("JS executed successfully")
                }
            }
    }
    
    @IBAction func btn_iframe(_ sender: Any) {
        let js = "fromAndroidToIFrame('Hello iframe iOS app!')"
            webView.evaluateJavaScript(js) { result, error in
                if let error = error {
                    print("JS error: \(error.localizedDescription)")
                } else {
                    print("JS executed successfully")
                }
            }
    }
    
   
    
    

    @IBOutlet weak var webContainer: UIView!
    var webView: WKWebView!
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Setup message handler
                let contentController = WKUserContentController()
                contentController.add(self, name: "iOSListener")
                contentController.add(self, name: "disableRefresh")
                contentController.add(self, name: "enableRefresh")

                let config = WKWebViewConfiguration()
                config.userContentController = contentController

                // Create WKWebView with configuration
                webView = WKWebView(frame: webContainer.bounds, configuration: config)
                webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                webView.navigationDelegate = self  // Important for refresh to stop
                webView.allowsBackForwardNavigationGestures = true  // 👈 Add this line
                webContainer.addSubview(webView)

        // Setup swipe to refresh
               refreshControl.addTarget(self, action: #selector(refreshWebView), for: .valueChanged)
               webView.scrollView.addSubview(refreshControl)
        
                // Load page
                if let url = URL(string: "http://192.168.2.175:5500/website.html") {
                    let request = URLRequest(url: url)
                    webView.load(request)
                }
    }
    
    @objc func refreshWebView() {
        view.endEditing(true) // Prevent keyboard crash
        if webView.isLoading {
                print("Already loading — skipping refresh")
                refreshControl.endRefreshing()
                return
            }
        

            if let currentURL = webView.url {
                let request = URLRequest(url: currentURL)
                webView.load(request)  // More reliable than reload()
            } else {
                refreshControl.endRefreshing()
                print("No URL to reload")
            }
      }

    // Handle messages from JavaScript
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "iOSListener" {
                if let messageBody = message.body as? String {
                    showToast(messageBody)
                }
            }
            if message.name == "disableRefresh" {
               
                    if webView.scrollView.subviews.contains(refreshControl) {
                        refreshControl.removeFromSuperview()
                        print("Pull-to-refresh removed")
                    } else {
                        print("Pull-to-refresh was already removed")
                    }
                
            }

            if message.name == "enableRefresh" {
              
                    if !webView.scrollView.subviews.contains(refreshControl) {
                        webView.scrollView.addSubview(refreshControl)
                        print("Pull-to-refresh re-added")
                    } else {
                        print("Pull-to-refresh was already added")
                    }
               
            }

        }

        // Show alert (mimicking a toast)
        func showToast(_ message: String) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            self.present(alert, animated: true)

            // Auto-dismiss after 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                alert.dismiss(animated: true)
            }
        }
   

}
// MARK: - WKNavigationDelegate
extension ViewController: WKNavigationDelegate {
    
    // pull - to - Refresh icon show off
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshControl.endRefreshing()
    }
    
    
    // Target _blank link handel by extral brwoser
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        // Detect if it's a target=_blank link
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }
    
}


