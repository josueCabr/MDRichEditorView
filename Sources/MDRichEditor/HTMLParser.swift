import Foundation

public enum HTMLParser {
    public static func asMarkdown(from htmlText: String) -> String {
        var htmlStrng = convert(with: Symbols.toSanitice, in: htmlText)
        var markdown = ""
        
        matchStyleTags(
            expresions: [StyleTag.spanStyle, StyleTag.pStyle],
            from: htmlText,
            sorted: true
        )
            .reduce(Set<String>(),{(list, object) in
                var list = list
                list.insert(object.2)
                return list
            })
            .forEach{
                htmlStrng = htmlStrng.replacingOccurrences(of: $0, with: "")
            }
        
        var tagMatches = matchStyleTags(
            expresions:[
                StyleTag.orderedList,
                StyleTag.unorderedList,
                StyleTag.paragrap,
            ],
            from: htmlStrng,
            sorted: true
        )
        
        let plaintTextMatches = filterAndMatchListItems(tagMatches.map{$0.1}, string: htmlStrng)
        tagMatches.append(contentsOf: plaintTextMatches)
        
        tagMatches.sorted(by: {$0.1.lowerBound < $1.1.lowerBound})
        .forEach { (tag, _, result) in
            switch tag {
            case StyleTag.paragrap:
                markdown += parse(paragraph: result, addExtraLineBreak: true)
            case StyleTag.orderedList:
                markdown += parseOrdered(list: result)
            case StyleTag.unorderedList:
                markdown += parseUnordered(list: result)
            case StyleTag.spanStyle:
                markdown += Symbols.Md.empty
            case StyleTag.plainText:
                return markdown += result
            default:
                break
            }
        }
        
        return markdown
    }
    
    private static func parse(paragraph: String, addExtraLineBreak: Bool = false) -> String {
        let hasOrderedList = paragraph.contains(StyleTag.orderedList)
        let hasUnorderedList = paragraph.contains(StyleTag.unorderedList)
        
        if hasOrderedList {
            return parseOrdered(list: paragraph)
        } else if hasUnorderedList {
            return parseUnordered(list: paragraph)
        }

        let result = convert(with: Symbols.toReplace, in: paragraph)
        
        
        return addExtraLineBreak ? (result + Symbols.Md.doubleLineBreak) : result + Symbols.Md.lineBreak
    }
    
    private static func parseOrdered(list: String) -> String {
        var result = ""
        let matches = matchStyleTags(expresions: [StyleTag.listItem], from: list)
        matches.enumerated().forEach { (idx, arg) in
                let (_, _, text) = arg
                
                result += "\(idx + 1). \(parse(paragraph: text))"
            }
        return result + Symbols.Md.doubleLineBreak
    }
    
    private static func parseUnordered(list: String) -> String {
        var result = ""
        
        matchStyleTags(expresions:[StyleTag.listItem], from: list)
            .forEach { (_, _, text) in
                
                result += Symbols.Md.unorderedItem + "\(parse(paragraph: text))"
            }
        
        return result + Symbols.Md.doubleLineBreak
    }
    
    private static func matchStyleTags(
        expresions: [String],
        from string: String,
        sorted: Bool = true
    ) -> [(String, NSRange, String)] {
        var matches = [(String, NSRange, String)]()
        expresions.forEach{ exp in
            let regex =  NSRegularExpression(exp, options: .caseInsensitive)
            matches.append(contentsOf:regex.matches(in: string, range: .init(location: 0, length: string.utf16.count)).compactMap {
                guard let str = getString(in: string, from: $0.range) else {
                    return nil
                }
                return (exp, $0.range,str)
            })
        }
        
        return sorted ? matches.sorted(by: {$0.1.lowerBound < $1.1.lowerBound}) : matches
    }
    
    private static func filterAndMatchListItems(_ rangeList: [NSRange], string: String) -> [(String, NSRange, String)] {
        let range = NSRange(location: 0, length: string.utf16.count)
        var lastUpperbound = range.location
        var filteredList =  rangeList.compactMap {item -> NSRange? in
            let lowerBound = item.lowerBound
            let upperBound = item.upperBound

            guard lowerBound > 0 else {
                lastUpperbound = upperBound
                return nil
            }
            
            let range = NSRange(
                location: lastUpperbound,
                length: lowerBound - lastUpperbound
            )
            lastUpperbound = upperBound
            return range
        }
        
        if lastUpperbound < range.upperBound {
            filteredList.append(NSRange(location: lastUpperbound, length: range.length - lastUpperbound))
        }
                
        return filteredList.compactMap {
            
            guard let text = getString(in: string, from: $0),
                  !text.isEmpty else {
                return nil
            }
            return (StyleTag.plainText, $0, text)
        }
       
    }
    
    private static func getString(in string: String, from range: NSRange) -> String? {
        
        if let range = Range(range) {
            let length = string.utf16.count
            let start = string.index(string.startIndex, offsetBy: range.lowerBound)
            let end = string.index(string.endIndex, offsetBy: range.upperBound - length)
            let range = start..<end
            return String(string[range])
//                .replacingOccurrences(of:Symbols.Html.lineBreak, with: Symbols.Md.doubleLineBreak)
        }
        
        return nil
    }
    
    private static func convert(with rules: [String: String],in html: String) -> String {
        var saniticedHtml = html
        
        rules.forEach {key, value in
            saniticedHtml = saniticedHtml.replacingOccurrences(of: key, with: value)
        }
        
        return saniticedHtml
    }
    
}

extension HTMLParser {
    
    enum Symbols {
        
        enum Html {
            static var bold = "<b>"
            static var boldClose = "</b>"
            static var italic = "<em>"
            static var italicClose = "</em>"
            static var lineBreak = "<br>"
            static var listItem = "<li>"
            static var listItemClose = "</li>"
            static var orderedList = "<ol>"
            static var orderedListClose = "</ol>"
            static var unorderedList = "<ul>"
            static var unorderedListClose = "</ul>"
            static var paragraph = "<p>"
            static var paragraphClose = "</p>"
            static var strong = "<strong>"
            static var strongClose = "</strong>"
            static var italic2 = "<i>"
            static var italic2Close = "</i>"
            static var div = "<div>"
            static var divClose = "</div>"
            static var space = "&nbsp;"
            static var spanClose = "</span>"

        }

        enum Md {
            static var bold = "**"
            static var italic = "*"
            static var unorderedItem = "* "
            static var lineBreak = "\n"
            static var doubleLineBreak = "\n\n"
            static var tagLineBreak = "<br/>"
            static var space = " "
            static var empty = ""
        }
        
        static var toSanitice:[String:String] {
            [
                Html.strong: Html.bold,
                Html.strongClose: Symbols.Html.boldClose,
                Html.italic2: Html.italic,
                Html.italic2Close: Html.italicClose,
                Html.div: Md.doubleLineBreak,
                Html.divClose: Md.empty,
                Html.space: Md.space,
                Html.paragraph + Html.unorderedList: Html.unorderedList,
                Html.unorderedListClose + Html.paragraphClose : Html.unorderedListClose,
                Html.paragraph + Html.orderedList: Html.orderedList,
                Html.orderedListClose + Html.paragraphClose : Html.orderedListClose,
                Html.spanClose: Md.empty,
                Html.lineBreak: Md.tagLineBreak
            ]
        }
        
        static var toReplace:[String:String] {
            [
                Html.bold: Md.bold,
                Html.boldClose: Md.bold,
                Html.italic: Md.italic,
                Html.italicClose: Md.italic,
                Html.paragraph: Md.empty,
                Html.paragraphClose: Md.empty
            ]
        }
    }

    
    enum StyleTag {
        static var paragrap = "(<p>)(.*?)(</p>)"
        static var orderedList = "(<ol>)(.*?)(</ol>)"
        static var unorderedList = "(<ul>)(.*?)(</ul>)"
        static var listItem = "(?<=<li>)(.*?)(?=</li>)"
        static var spanStyle = "</?span style.+?>"
        static var pStyle = "<p style.+?>"
        static var plainText = "<plainTXT>"
    }
}

extension NSRegularExpression {
    convenience init(_ pattern: String, options: NSRegularExpression.Options = []) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
}

extension NSRegularExpression {
    func matches(_ string: String) -> Bool {
        return firstMatch(
            in: string,
            options: [],
            range: NSRange(location: 0, length: string.utf16.count)
        ) != nil
    }
}
