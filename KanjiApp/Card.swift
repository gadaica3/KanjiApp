import UIKit
import CoreData

@objc(Card)
class Card: NSManagedObject {
    @NSManaged var kanji: String
    @NSManaged var index: NSNumber
    @NSManaged var hiragana: String
    @NSManaged var jlptLevel: NSNumber
    @NSManaged var interval: NSNumber
    @NSManaged var dueTime: NSNumber
    @NSManaged var enabled: NSNumber
    @NSManaged var suspended: NSNumber
    @NSManaged var known: NSNumber
    @NSManaged var usageAmount: NSNumber
    @NSManaged var isKanji: NSNumber
    @NSManaged var embeddedData: CardData
    
    func answerCard(difficulty: AnswerDifficulty) {
        
//        managedObjectContext.undoManager. = "answer card"
        managedObjectContext?.undoManager?.beginUndoGrouping()
        
        let secondsSince1970 = Globals.secondsSince1970
        let adjustInterval = dueTime.doubleValue < secondsSince1970
        
//        println("dueTime \(dueTime)")
        
        switch difficulty {
        case .Easy:
//            println("Easy")
            if adjustInterval {
                interval = 10
            }
            embeddedData.answersKnown = NSNumber(int: embeddedData.answersKnown.intValue + 1)
        case .Normal:
//            println("Normal")
            if interval.doubleValue < 11 {
                if adjustInterval {
                    interval = interval.doubleValue + 1
                } else {
                    interval = interval.doubleValue + 0.1
                }
            }
            
            embeddedData.answersNormal = NSNumber(int: embeddedData.answersNormal.intValue + 1)
        case .Hard:
            if adjustInterval {
                if interval.doubleValue >= 6 {
                    interval = interval.doubleValue + 0.3
                } else if interval.doubleValue <= 4.5 {
                    interval = interval.doubleValue + 0.4
                }
            }
            
            embeddedData.answersHard = NSNumber(int: embeddedData.answersHard.intValue + 1)
        case .Forgot:
            if adjustInterval {
                interval = interval.doubleValue - 4
            } else {
                interval = interval.doubleValue - 3
            }
            embeddedData.answersForgot = NSNumber(int: embeddedData.answersForgot.intValue + 1)
        }
        
        interval = min(11, interval.doubleValue)
        interval = max(0, interval.doubleValue)
        
        if adjustInterval {
            dueTime = secondsSince1970 + timeForInterval()
        }
//        dueTime = timeForInterval()
        
//        println("newDueTime \(dueTime)")
        
//        println("timeForInterval \(timeForInterval())")
//        println("dueTime \(dueTime)")
        //        println("secondsSince1970 \(secondsSince1970)")
        managedObjectContext?.undoManager?.endUndoGrouping()
    }
    
    /// In seconds
    func timeForInterval() -> Double {
        var small = timeForIntervalSimple(Int(interval.doubleValue))
        var large = timeForIntervalSimple(Int(interval.doubleValue) + 1)
        
        var diff = large - small
        var percent = interval.doubleValue % 1
        diff *= percent
        
        return small + diff
    }
    
    func timeForIntervalSimple(value: Int) -> Double {
        
        let min: Double = 60.0
        let hour: Double = 60.0 * 60.0
        let day: Double = hour * 24.0
        let month: Double = day * (365.0 / 12.0)
        let year: Double = day * 365.0
        
        switch value {
        case 0:
            return 0
        case 1:
            return 5
        case 2:
            return 25
        case 3:
            return 2 * min
        case 4:
            return 10 * min
        case 5:
            return 60 * min
        case 6:
            return 5 * hour
        case 7:
            return day
        case 8:
            return 5 * day
        case 9:
            return 25 * day
        case 10:
            return 4 * month
        case 11:
            return 2 * year
        case 12:
            return 3 * year
        case 13:
            return 4 * year
        default:
            return 0
        }
    }
    
    var verticalKanji: String {
    get {
        var setText = ""
        var spacing = ""
        for char in kanji {
            var add = char
            if add == "ー" {
                add = "丨"
            }
            setText += "\(spacing)\(add)"
            spacing = "\n"
        }
        
        return setText
    }
    }
    
    func animatedLabelText(size: CGFloat) -> NSAttributedString {
    let font = Globals.JapaneseFontLight
        var value = NSMutableAttributedString()
        
        value.beginEditing()
        
//        let size: CGFloat = 30
    
        value.addAttributedText(verticalKanji, [(NSFontAttributeName, UIFont(name: font, size: size)!)])
        value.endEditing()
        
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.paragraphSpacing = -size / 3.0
        
        value.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, value.mutableString.length))
//        addBody(value, font)
        
        return value
    }
    
//    func setFrontTextFont(label: UILabel) -> UIFont {
    //    }
//    var frontText: String {
//        get {
//            return Globals.screenOrientationVertical ? verticalKanji : kanji
//        }
//    }
    
//    var frontFont: UIFont {
//    get {
//        let font = Globals.DefaultFont
//        
////        var numChars: Int,
//        let desiredDistance = Globals.screenOrientationVertical ? Globals.screenSize.height : Globals.screenSize.width
////        let numVerticalChars: Int = Globals.screenOrientationVertical ? countElements(kanji) : 1
//        
//        let baseSize: CGFloat = 250
//        
//        var size = baseSize / CGFloat(countElements(kanji))
//        size *= desiredDistance / (568) * 2
//        
//        if size > baseSize {
//            size = baseSize
//        }
//        
//        return UIFont(name: font, size: size)!
//    }
//    }
    
//    private func generateFrontText(text: String, numChars: Int, desiredDistance: CGFloat, numVerticalChars: Int = 1) -> NSAttributedString {
//        
//        var value = NSMutableAttributedString()
//        
//        value.beginEditing()
//        //        var height = size * CGFloat(numVerticalChars)// * (568.0 / 500.0)
////        println(height)
////        println(Globals.screenSize)
////        let screenHeight = Globals.screenSize.height
////        var offset = (screenHeight / 2 - (height / 2)) / 4
//        println(Globals.retinaScale)
//        value.addAttributedText(" ", [(NSFontAttributeName, UIFont(name: "Helvetica", size: offset))]);
//        let baseSize: CGFloat = 250
        
//        var paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.alignment = .Center
//        
//        let fontPair: (String, AnyObject) = (NSFontAttributeName, )
//        let paragraph: (String, AnyObject) = (NSParagraphStyleAttributeName, paragraphStyle)
//        
//        value.addAttributedText(text, [fontPair, paragraph])
//        value.endEditing()
//
//        return value
//    }
//    
//    var front: NSAttributedString {
//        get {
//            
//        return generateFrontText(
//            verticalKanji,
//            numChars: countElements(kanji),
//            desiredDistance: Globals.screenSize.height * Globals.retinaScale,
//            numVerticalChars: countElements(kanji))
//    }
//    }
//    
//    var frontLandscape: NSAttributedString {
//        get {
//            return generateFrontText(
//                kanji,
//                numChars: countElements(kanji),
//                desiredDistance: Globals.screenSize.width * Globals.retinaScale)
//            
////            let font = Globals.DefaultFont
////            var value = NSMutableAttributedString()
////            
////            value.beginEditing()
////            
////            let baseSize: CGFloat = 250
////            
////            var size = baseSize * 2 / CGFloat(countElements(kanji))
////            
////            if size > baseSize {
////                size = baseSize
////            }
////            
////            var paragraphStyle = NSMutableParagraphStyle()
////            paragraphStyle.alignment = .Center
////            
////            let fontPair: (String, AnyObject) = (NSFontAttributeName, UIFont(name: font, size: size))
////            let paragraph: (String, AnyObject) = (NSParagraphStyleAttributeName, paragraphStyle)
////            
////            value.addAttributedText(kanji, [fontPair, paragraph])
////            value.endEditing()
////            
////            return value
//        }
//    }
    
    
    var front: NSAttributedString {
        get {
            var text = kanji
            
            if !isKanji.boolValue {
                text = hiragana
            }
            
            let baseSize: CGFloat = 102
            
            var size = baseSize * 3 / CGFloat(countElements(text))
            
            if size > baseSize * 2 {
                size = baseSize * 2
            }
            
            let font = Globals.JapaneseFont
            var value = NSMutableAttributedString()
            
            value.beginEditing()
            
            var paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.Center
            
            value.addBreak(Globals.screenSize.height / 2 - size * 0.5 - 190)
            
            value.addAttributedText(text,
                [
                    (NSFontAttributeName, UIFont(name: Globals.DefaultFont, size: size)!),
                    (NSParagraphStyleAttributeName, paragraphStyle)
                ])
            
//            value.addBreak(10)
            
            value.addAttributedText(embeddedData.exampleJapanese, [(NSFontAttributeName, UIFont(name: Globals.DefaultFont, size: 36)!)], processAttributes: true, removeSpaces: true)
            
            value.endEditing()
            
            return value
        }
    }
    
    var back: NSAttributedString {
    get {
        let font = Globals.JapaneseFont
        var value = NSMutableAttributedString()
        
        value.beginEditing()
        
        // scroll up kanji
        value.addAttributedText(kanji, [(NSFontAttributeName, UIFont(name: Globals.DefaultFont, size: backScrollUpKanjiTextHeight)!)])
        
        // main text
        value.addAttributedText(hiragana, [(NSFontAttributeName, UIFont(name: font, size: 50)!)])
        value.endEditing()
        
        addBody(value, font)
        
        return value
    }
    }
    
    var backScrollUpKanjiTextHeight: CGFloat {
        get {
            let baseSize: CGFloat = 80
            
            var size = baseSize * 3 / CGFloat(countElements(kanji))
            
            if size > baseSize {
                size = baseSize
            }
            return size
        }
    }
    
    var definitionAttributedText: NSAttributedString {
    get {
        let font = Globals.JapaneseFont
        var value = NSMutableAttributedString()
        
        value.beginEditing()
        
        value.addAttributedText(kanji, [(NSFontAttributeName, UIFont(name: font, size: 50)!)])
        value.endEditing()
        value.addAttributedText(hiragana, [(NSFontAttributeName, UIFont(name: font, size: 30)!)])
        value.endEditing()
        
        addBody(value, font)
        
        return value
    }
    }
    
    func addBody(addTo: NSMutableAttributedString, _ fontName: String) {
        
        addTo.addBreak(5)
        
//        var entity = managedObjectContext!.fetchCardByIndex(index)
        
        addTo.addAttributedText(embeddedData.definition, [(NSFontAttributeName, UIFont(name: fontName, size: 22)!)], processAttributes: true)
        
        addTo.addBreak(20)
        
        if(embeddedData.exampleJapanese != "")
        {
            addTo.addAttributedText(embeddedData.exampleJapanese, [(NSFontAttributeName, UIFont(name: fontName, size: 24)!)], processAttributes: true, removeSpaces: true)
            
            if settings.romajiEnabled.boolValue {
                var romaji = Globals.romajiConverter.convertToRomajiFromKana(embeddedData.exampleJapanese.asKana())
                
                addTo.addBreak(5)
                
                addTo.addAttributedText(romaji, [(NSFontAttributeName, UIFont(name: fontName, size: 14)!)], processAttributes: true, removeSpaces: false)
            }
            
            addTo.addBreak(5)
            
            addTo.addAttributedText(embeddedData.exampleEnglish, [(NSFontAttributeName, UIFont(name: fontName, size: 16)!)])
            
            addTo.addBreak(30)
        }
        
        if(embeddedData.otherExampleSentences != "")
        {
            addExampleSentences(addTo, fontName)
            
            addTo.addBreak(10)
        }
        
        if(embeddedData.exampleJapanese != "")
        {
            addTo.addAttributedText(embeddedData.exampleJapanese.asKana(), [(NSFontAttributeName, UIFont(name: fontName, size: 24)!)], processAttributes: false, removeSpaces: false)
            
            addTo.addBreak(10)
        }
        
        if(embeddedData.pitchAccent != 0)
        {
            addTo.addAttributedText("\(embeddedData.pitchAccent)", [(NSFontAttributeName, UIFont(name: fontName, size: 16)!)])
            addTo.addBreak(10)
        }
        
        if(jlptLevel != 0)
        {
            addTo.addAttributedText("JLPT \(jlptLevel)", [(NSFontAttributeName, UIFont(name: fontName, size: 16)!)])
            
            addTo.addBreak(10)
        }
        else
        {
            addTo.addBreak(320)
        }
        // Debug
        
        addTo.addAttributedText("Interval \(interval.doubleValue)", [(NSFontAttributeName, UIFont(name: fontName, size: 16)!)])
        
        addTo.addAttributedText("Answers Normal  \(embeddedData.answersNormal.integerValue)", [(NSFontAttributeName, UIFont(name: fontName, size: 16)!)])
        
        addTo.addAttributedText("Answers Hard \(embeddedData.answersHard.integerValue)", [(NSFontAttributeName, UIFont(name: fontName, size: 16)!)])
        
        addTo.addAttributedText("Answers Forgot \(embeddedData.answersForgot.integerValue)", [(NSFontAttributeName, UIFont(name: fontName, size: 16)!)])
        
        addTo.addAttributedText("Due Time \(dueTime.doubleValue)", [(NSFontAttributeName, UIFont(name: fontName, size: 16)!)])
        // End Debug
        
//        var color =
        
        addTo.addAttribute(NSForegroundColorAttributeName, value: pitchAccentColor(), range: NSMakeRange(0, addTo.mutableString.length))
        
        var paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.Center
        
        addTo.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: NSMakeRange(0, addTo.mutableString.length))
        
//        outputText.textAlignment = .Center
    }
    
    func addExampleSentences(addTo: NSMutableAttributedString, _ fontName: String) {
        var validChars = NSCharacterSet(range: NSRange(location: 32, length: 127))
        var isJapanese = true
        var text: String = ""
        
        var examples: String  = embeddedData.otherExampleSentences.removeTagsFromString(embeddedData.otherExampleSentences, removeFurigana: false)
        var passBlock = false
        
        for item in examples {
            var test = String(item).componentsSeparatedByCharactersInSet(validChars)[0]
            var isCurrentJapanese = test != ""
            
            if item == "[" {
                passBlock = true
            }
            
            if isJapanese != isCurrentJapanese &&
                text != "" &&
                item != " " &&
                item != "　" &&
                item != "-" &&
                item != "(" &&
                item != ")" &&
                !passBlock {
            if  item != "0" &&
                item != "1" &&
                item != "2" &&
                item != "3" &&
                item != "4" &&
                item != "5" &&
                item != "6" &&
                item != "7" &&
                item != "8" &&
                item != "9" {
                        if countElements(text) > 1 {
                        var size: CGFloat = isJapanese ? 24 : 16
                        var removeSpaces = isJapanese ? true : false
                        var extraSpace: String = isJapanese ? "" : "\n"
                        
                        addTo.addAttributedText(text + "\n" + extraSpace, [(NSFontAttributeName, UIFont(name: fontName, size: size)!)], processAttributes: true, removeSpaces: removeSpaces, breakLine: false)
                        
                        if settings.romajiEnabled.boolValue && isJapanese {
                            var romaji = Globals.romajiConverter.convertToRomajiFromKana(text.asKana())
                            
                            addTo.addBreak(5)
                            
                            addTo.addAttributedText(romaji, [(NSFontAttributeName, UIFont(name: fontName, size: 14)!)], processAttributes: true, removeSpaces: false)
                        }
                        
                        text = ""
                    }
                    }
                    isJapanese = !isJapanese
            }
            
            if item == "]" {
                passBlock = false
            }
            
            if !(text == "" && item == ".") {
                text.append(item)
            }
        }
    }
    
    
    var cellText: NSAttributedString {
    get {
        let font = "HiraKakuProN-W3"
        var value = NSMutableAttributedString()
        
        value.beginEditing()
        
        value.addAttributedText(kanji + " ", [(NSFontAttributeName, UIFont(name: font, size: CGFloat(25))!)], breakLine: false)
        
        var hiraganaColor = UIColor(red: 0.8125, green: 0, blue: 0.375, alpha: 1)
        
        value.addAttributedText(hiragana + " ", [(NSFontAttributeName, UIFont(name: font, size: CGFloat(16))!), (NSForegroundColorAttributeName, hiraganaColor)], breakLine: false)
        
        var definitionColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        
//        println(kanji)
////        println(embeddedData)
//        println(embeddedData.definition)
        
        var def = embeddedData.definition
        
        def = replaceInString(def, "<br />", " ")
//        
        value.addAttributedText(def, [(NSFontAttributeName, UIFont(name: font, size: CGFloat(12))!), (NSForegroundColorAttributeName, definitionColor)])
        
//        value.addAttributedText("\(usageAmount)", [(NSFontAttributeName, UIFont(name: font, size: CGFloat(12))), (NSForegroundColorAttributeName, definitionColor)])
        
        value.endEditing()
        
        return value
    }
    }
    
    internal func replaceInString(var value: String, _ remove: String, _ newValue: String) -> String
    {
        var items = value.componentsSeparatedByString(remove)
        
        value = ""
        var spacer = ""
        for item in items
        {
            value += spacer + item
            spacer = newValue
        }
        
        return value
    }
    
//    func getAsciiCharacterSet() -> NSCharacterSet
//    {
//        return NSCharacterSet.alphanumericCharacterSet()
////        var asciiCharacters = NSMutableString(string)
////        for NSInteger i = 32; i < 127; i++  {
////            asciiCharacters.appendFormat("%c", i)
////        }
////        
////        var nonAsciiCharacterSet = NSCharacterSet()
////        
////        test = [[test componentsSeparatedByCharactersInSet:nonAsciiCharacterSet] componentsJoinedByString:@""];
////        
////        NSLog(@"%@", test);
//    }
    
    func pitchAccentColor() -> UIColor {
        return caculateColorForPitchAccent(embeddedData.pitchAccent.integerValue)
    }

    func caculateColorForPitchAccent(pitchAccent: Int) -> UIColor {
        var color = UIColor(red: 0, green: 0, blue: 0, alpha: 1)

        switch pitchAccent {
        case 1:
            color = UIColor(red: 0.8125, green: 0, blue: 0.375, alpha: 1)

        case 2:
            color = UIColor(red: 0, green: 0.5625, blue: 0.9375, alpha: 1)

        case 3:
            color = UIColor(red: 1.0 / 16.0, green: 1.0 / 11.0, blue: 0, alpha: 1)

        case 4:
            color = UIColor(red: 1, green: 6.0 / 16.0, blue: 0, alpha: 1)

        case 5:
            color = UIColor(red: 9.0 / 16.0, green: 0, blue: 9.0 / 16.0, alpha: 1)

        case 6:
            color = UIColor(red: 9.0 / 16.0, green: 9.0 / 16.0, blue: 9.0 / 16.0, alpha: 1)

        default:
            color = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }

        return color
    }
    
    func listColor() -> UIColor {
        if suspended.boolValue {
            if known.boolValue {
                return Globals.colorLists
            } else {
                return Globals.colorAddWords
            }
        } else if !enabled.boolValue {
            return Globals.colorKnown
        }
        return Globals.colorMyWords
    }
    
    func listName() -> String {
        if suspended.boolValue {
            if known.boolValue {
                return Globals.textSuspended
            } else {
                return Globals.textAddWord
            }
//            return Globals.textSuspended
        } else if !enabled.boolValue {
            return Globals.textPending
        }
        return Globals.textStudying
    }
    
    private var settings: Settings {
        get {
            return RootContainer.instance.settings
        }
    }
}