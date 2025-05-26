//
//  ShareViewController.swift
//  Share Extension
//
//  Created by Zawar Mehmood on 2025-05-25.
//

import listen_sharing_intent

class ShareViewController: RSIShareViewController {

    // Use this method to return false if you don't want to redirect to host app automatically.
    // Default is true
    override func shouldAutoRedirect() -> Bool {
        return false
    }
    
    // Use this to change label of Post button
    override func presentationAnimationDidFinish() {
        super.presentationAnimationDidFinish()
        navigationController?.navigationBar.topItem?.rightBarButtonItem?.title = "Save"
    }
}
