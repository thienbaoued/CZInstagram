//
//  LoginViewController.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 9/3/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import UIKit
import CZUtils
import ReactiveListViewKit

/**
 Successfully received Instagram authentication token: 5956152420.6d6cef1.e003104aee864ac1bf9a81c53703294b
 */
class LoginViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var loginWebView: UIWebView!
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loginWebView.delegate = self
        unSignedRequest()
    }

    //MARK: - unSignedRequest
    func unSignedRequest () {
        let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True",
                             arguments: [Instagram.authUrl,
                                         Instagram.clientID,
                                         Instagram.redirectURI,
                                         Instagram.scope])

        let urlRequest =  URLRequest.init(url: URL.init(string: authURL)!)
        loginWebView.loadRequest(urlRequest)
    }

    func checkRequestForCallbackURL(request: URLRequest) -> Bool {

        let requestURLString = (request.url?.absoluteString)! as String

        if requestURLString.hasPrefix(Instagram.redirectURI.lowercased()) {
            let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
            handleAuth(authToken: requestURLString.substring(from: range.upperBound))
            return false;
        }
        return true
    }

    func handleAuth(authToken: String)  {
        print("Successfully received Instagram authentication token: ", authToken)
    }

    // MARK: - UIWebViewDelegate

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return checkRequestForCallbackURL(request: request)
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        loginIndicator.isHidden = false
        loginIndicator.startAnimating()
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        loginIndicator.isHidden = true
        loginIndicator.stopAnimating()
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        webViewDidFinishLoad(webView)
    }
}