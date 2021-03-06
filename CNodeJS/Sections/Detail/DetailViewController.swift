//
//  DetailViewController.swift
//  CNodeJS
//
//  Created by why on 10/21/14.
//  Copyright (c) 2014 why. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIWebViewDelegate,UITableViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var contentWebView: UIWebView!
    @IBOutlet weak var contentWebViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var replyTableView: UITableView!
    @IBOutlet weak var replyTableViewHeight: NSLayoutConstraint!
    
    var topic: TopicModel?
    
    var replyDataSource: ArrayDataSource?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFromTopic()
        replyTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setupFromTopic() {
        // get title
        titleLabel.text = topic?.title
        
        // get tab name
        var tabName = ""
        if let tab = topic?.tab {
            if let name = TAB_DIC[tab] {
                tabName = name
            }
        }
        
        // get author name
        var authorName = ""
        if let name = topic?.author?.loginName {
            authorName = name
        }
        
        // assembly info label
        infoLabel.text = "作者：\(authorName)    来自：\(tabName)"
        
        // set content view
        if let content = topic?.content as String? {
            contentWebView.loadHTMLString(content, baseURL: NSURL(string: "https://cnodejs.org/"))
        }
    }
    
    func setupReplyTableView() {
        
        if topic!.replies.count > 0 {
            replyTableView.hidden = false
        }
        
        var cellConfigureClosure: CellConfigureClosure = { cell,item in
            let myCell = cell as ReplyTableViewCell
            let myItem = item as Reply
            myCell.timeLabel.text = myItem.createAt
            var HTMLData = MMMarkdown.HTMLStringWithMarkdown(myItem.content, error: nil)
            myCell.contentLabel.text = NSAttributedString(HTML: HTMLData).string
            myCell.nameLabel.text = myItem.author?.loginName            
        }
        replyDataSource = ArrayDataSource(anItems:topic!.replies, aCellIdentifier: "replyCell", aConfigureClosure: cellConfigureClosure)
        replyTableView.dataSource = replyDataSource
        replyTableView.reloadData()
    }
    
    func loadHTML(myCell:ReplyTableViewCell,htmlString:String) {
        myCell.contentLabel.attributedText =
            NSAttributedString(
                data: htmlString.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!,
                options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType],
                documentAttributes: nil,
                error: nil)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        
        replyTableViewHeight.constant = replyTableViewHeight.constant + cell.frame.size.height
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - UIWebViewDelegate
    func webViewDidFinishLoad(webView: UIWebView) {
        var frame = webView.frame
        var fittingSize = webView.sizeThatFits(CGSizeZero)
        contentWebViewHeight.constant = fittingSize.height
        
        if let id = topic?.id {
            TopicStore.sharedInstance.loadTopic(topicId: id, finishedClosure: {
                self.topic = TopicStore.sharedInstance.getTopic(topicId: id)
                self.setupReplyTableView()
            })
        }
    }

    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        println(request.URL.description)
        if (request.URL.description == "https://cnodejs.org/") {
            return true
        }
        
        UIApplication.sharedApplication().openURL(request.URL)
        return false
        
    }
    


    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
