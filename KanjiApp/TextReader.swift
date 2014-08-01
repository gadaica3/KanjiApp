//
//  TextReader.swift
//  KanjiApp
//
//  Created by Sky on 2014-07-06.
//  Copyright (c) 2014 Sky. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TextReader: CustomUIViewController {
    @IBOutlet var userText : UITextView!
    var tokens: [TextToken] = []
    
//    @IBOutlet var tableView: UITableView!
    
    @IBAction func addAll(sender: AnyObject) {
        for token in tokens {
            if var card = managedObjectContext.fetchCardByIndex(token.index) {
                card.enabled = true
            }
        }
        saveContext()
    }
    
    @IBAction func onTranslate(sender: AnyObject) {
        tokenizeText()
    }
    
    func formatDisplay() {
        
        let font = Globals.JapaneseFontLight
        let size: CGFloat = 24
        
        var value = NSMutableAttributedString()
        value.beginEditing()
        
        for token in tokens {
            
            var color = UIColor.blackColor()
            
            if token.hasDefinition {
                
                color = UIColor(red: 0.8125, green: 0, blue: 0.375, alpha: 1)
                
//                if let card = managedObjectContext.fetchCardByIndex(token.index) {
//                    color = card.pitchAccentColor()
//                }
            }
            
            let fontAttribute: (String, AnyObject) = (NSFontAttributeName, UIFont(name: font, size: size))
            
            let colorAttribute: (String, AnyObject) = (NSForegroundColorAttributeName, color)
            
            value.addAttributedText(token.text, [fontAttribute, colorAttribute], breakLine: false)
        }
        
        value.endEditing()
        
        userText.attributedText = value
    }
    
    func tokenizeText() {
         tokens = []
        
        let textNS:NSString = userText.text as NSString
        let textCF:CFString = textNS as CFString
        let length = textNS.length
        
        let tokenizer = CFStringTokenizerCreate(nil, textCF, CFRangeMake(0, length), 0, CFLocaleCreate(nil, "ja_JP"))
        
        var currentAdd = ""
        while CFStringTokenizerAdvanceToNextToken(tokenizer) != .None {
            let range = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            let subString = CFStringCreateWithSubstring(nil, textCF, range).__conversion() as String
            
            if countElements(subString) > 1 || subString.isPrimarilyKanji()
            {
                if currentAdd != "" {
                    tokens += TextToken(currentAdd, hasDefinition: false)
                    currentAdd = ""
                }
                
                if let card = managedObjectContext.fetchCardByKanji(subString)
                {
                    tokens += TextToken(
                        subString,
                        hasDefinition: true,
                        index: card.index)
                }
            }
            else {
                currentAdd += subString
            }
        }
        
        if currentAdd != "" {
            tokens += TextToken(currentAdd, hasDefinition: false)
            currentAdd = ""
        }
        
        formatDisplay()
//        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tokens = []
        
        tokenizeText()
//        userText.textContainerInset.top = 44
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        userText.scrollRangeToVisible(NSRange(location: 0, length: 1))
        //        userText.scrollEnabled = false
//        userText.scrollEnabled = true
    }
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        println(userText.contentOffset)
//        
//    }
//    override
//
//
////        var text = userText.text
////        
////        userText.text = ""
////        
////        userText.scrollEnabled = false
//////        userText.text = text
////        userText.scrollEnabled = true
////        let animationSpeed = 0.4
////        //        UIView.animateWithDuration(animationSpeed) {}
////        UIView.animateWithDuration(animationSpeed) {
////            self.userText.contentOffset = CGPoint(x: 0, y: 0)
////        }
//
//    }
    
//    override func viewDidAppear(animated: Bool) {
//        
//    }
//    
//    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
//        return self.items.count;
//    }
//    
//    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
//        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
//        
//        var card = managedObjectContext.fetchCardByIndex(self.items[indexPath.row])
//        
//        cell.textLabel.attributedText = card.cellText//"\(card.kanji) \(card.interval)"
//        
//        return cell
//    }
//    
//    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
//        println("You selected cell #\(indexPath.row)!")
//    }
}