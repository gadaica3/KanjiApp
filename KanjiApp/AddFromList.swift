import Foundation
import UIKit
import CoreData

class AddFromList: CustomUIViewController {
    @IBOutlet var jlptLevel : UISegmentedControl
    @IBOutlet var isOnlyKanji : UISwitch
    @IBOutlet var addAmount : UITextField
    @IBOutlet var addButton : UIButton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jlptLevel.selectedSegmentIndex = 4 - settings.jlptLevel.integerValue
        isOnlyKanji.on = settings.onlyStudyKanji.boolValue
        addAmount.text = settings.cardAddAmount.stringValue
    }
    
    @IBAction func onAddTouch(sender: AnyObject) {
        var predicate: [(EntityProperties, String)] = []
        
        predicate += (CardProperties.enabled, "false")
        predicate += (CardProperties.jlptLevel, "\(settings.jlptLevel)")
        
        let cards = managedObjectContext.fetchEntities(.Card, predicate, CardProperties.index, sortAscending: true)
        
        var added = 0
        
        for card in cards {
            added++
            
            if let card = card as? Card {
                card.enabled = true
                
                if added >= settings.cardAddAmount.integerValue {
                    break
                }
            }
        }
        
//        self.navigationController.popToRootViewControllerAnimated(false)
        self.performSegueWithIdentifier("GameMode", sender: self)
    }
    
    @IBAction func onJlptLevelChanged(sender : AnyObject) {
        var value = jlptLevel.selectedSegmentIndex
        
        settings.jlptLevel = 4 - value
        
        saveContext()
    }
    
    @IBAction func isOnlyKanjiChanged(sender : AnyObject) {
        settings.onlyStudyKanji = isOnlyKanji.on
        
        saveContext()
    }
    
    @IBAction func addAmountChanged(sender : AnyObject) {
        var amount = addAmount.text.toInt()
        
//        println(addAmount.text)
//        println(amount)
        
        if var amount = amount {
            if amount == 0
            {
                amount = 1
                addAmount.text = "\(1)"
            }
            
            settings.cardAddAmount = amount
        }
        else if addAmount.text != "" {
            addAmount.text = settings.cardAddAmount.stringValue
        }
    }
}
