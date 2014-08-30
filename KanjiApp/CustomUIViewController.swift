import Foundation
import UIKit
import CoreData

class CustomUIViewController : UIViewController {
    var managedObjectContext : NSManagedObjectContext = NSManagedObjectContext()
    
    var settings: Settings {
    get {
        return (managedObjectContext.fetchEntity(CoreDataEntities.Settings, SettingsProperties.userName, "default") as Settings?)!
    }
    }
    
    func loadContext () {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        self.managedObjectContext = context
    }
    
    var isGameView: Bool {
        get {
            return true
        }
    }
    
    var sidebarEnabled: Bool {
        get {
            return true
        }
    }
    
    var alwaysReceiveNotifications: Bool {
    get {
        return false
    }
    }
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        loadContext()
        
        var settings = (managedObjectContext.fetchEntity(.Settings, SettingsProperties.userName, "default", createIfNil: true) as Settings?)!
        
        settings.userName = "default"
        
        if !settings.generatedCards.boolValue {
            settings.generatedCards = true
            settings.cardAddAmount = 5
            settings.onlyStudyKanji = true
            settings.volume = 0.5
            settings.readerText = ""
            
            createDatabase("AllCards copy")
        }
        
        saveContext()
    }
    
    var notificationsActive = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        println("viewWillAppear \(self)")
        if !alwaysReceiveNotifications && !notificationsActive {
            addNotifications()
        }
        
//        if isGameView {
//            println(self)
//            if RootContainer.instance != nil {
//                println(RootContainer.instance)
//                println(RootContainer.instance.sidebarEdgeReveal)
//                RootContainer.instance.sidebarEdgeReveal.visible = sidebarEnabled
//            }
//        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !alwaysReceiveNotifications && !notificationsActive {
            addNotifications()
        }
        
//        println(self)
        
//        println(self)
//        
//        println(isGameView)
        
//        if isGameView {
        Globals.notificationGameViewDidAppear.postNotification(self)
//        }
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        println("viewWillDisappear")
        if !alwaysReceiveNotifications && notificationsActive {
            removeNotifications()
        }
    }
    
    
    override func viewDidDisappear(animated: Bool) {
//        println("viewDidDisappear")
        super.viewWillAppear(animated)
        if !alwaysReceiveNotifications && notificationsActive {
            removeNotifications()
        }
    }
    
    func addNotifications() {
        notificationsActive = true
//        println("addNotifications \(self)")
        
        Globals.notificationTransitionToView.addObserver(self, selector: "onTransitionToView")
    }
    
    func removeNotifications() {
        notificationsActive = false
//        println("removeNotifications \(self)")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func createDatabase(filename: String) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "txt")
        var possibleContent = String.stringWithContentsOfFile(path, encoding: NSUTF8StringEncoding, error: nil)
        
        var values: [Card] = []
        
        if let content = possibleContent {
            var deck = content.componentsSeparatedByString("\n")
            for deckItem in deck {
                var items = deckItem.componentsSeparatedByString("\t")
                
                var index: Int = items[1].toInt()!
                var pitchAccent = 0
                if var p = items[12].toInt() {
                    pitchAccent = p
                }
                
                var usageAmount = 0
                if var u = items[9].toInt() {
                    usageAmount = u
                }
                
                var jlptLevel = 0
                if var j = items[10].toInt() {
                    jlptLevel = j
                }
                
                let kanji = items[0]
                
                var card = managedObjectContext.fetchEntity(CoreDataEntities.Card, CardProperties.kanji, kanji, createIfNil: true)! as Card
                
                card.kanji = kanji
                
                var dataDesc = NSEntityDescription.entityForName("CardData", inManagedObjectContext: managedObjectContext)
                
                card.embeddedData = CardData(entity: dataDesc, insertIntoManagedObjectContext: managedObjectContext)
                
                card.index = index
                card.hiragana = items[2]
                card.definition = items[3]
                card.embeddedData.exampleEnglish = items[4]
                card.embeddedData.exampleJapanese = items[5]
                card.embeddedData.soundWord = items[6]
                card.embeddedData.soundDefinition = items[7]
                card.embeddedData.definitionOther = items[8]
                card.usageAmount = usageAmount
                card.jlptLevel = jlptLevel
                card.embeddedData.pitchAccentText = items[11]
                card.embeddedData.pitchAccent = pitchAccent
                card.embeddedData.otherExampleSentences = items[13]
                card.answersKnown = 0
                card.answersNormal = 0
                card.answersHard = 0
                card.answersForgot = 0
                card.interval = 0
                card.dueTime = 0
                card.enabled = false
                card.suspended = true
                card.known = false
                
                values.append(card)
            }
        }
        
        
        saveContext()
    }
    
    func onTransitionToView() {
        if isGameView {
//            println("transition to root \(Globals.notificationTransitionToView.value.description())")
            self.navigationController?.popToRootViewControllerAnimated(false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if alwaysReceiveNotifications {
            addNotifications()
        }
    }
    
    func saveContext (_ context: NSManagedObjectContext? = nil) {
        if var c = context {
            var error: NSError? = nil
            c.save(&error)
        }
        else {
            var error: NSError? = nil
            self.managedObjectContext.save(&error)
        }
    }
}