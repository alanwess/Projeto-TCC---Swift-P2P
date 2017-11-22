//
//  TGDateMessageCellLayout.swift
//  NoChat-Swift-Example
//
//  Copyright (c) 2016-present, little2s.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import NoChat

class TGDateMessageCellLayout: NSObject, NOCChatItemCellLayout {
    
    var reuseIdentifier: String = "TGDateMessageCell"
    var chatItem: NOCChatItem
    var width: CGFloat
    var height: CGFloat = 0
    
    var message: Message {
        return chatItem as! Message
    }
    
    var backgroundImageViewFrame = CGRect.zero
    var backgroundImage: UIImage?
    var dateLabelFrame = CGRect.zero
    var attributedDate: NSAttributedString?
    
    required init(chatItem: NOCChatItem, cellWidth width: CGFloat) {
        self.chatItem = chatItem
        self.width = width
        super.init()
        setupBackgroundImage()
        setupAttributedDate()
        calculate()
    }
    
    func calculate() {
        height = 0
        backgroundImageViewFrame = CGRect.zero
        dateLabelFrame = CGRect.zero
        
        guard let ad = attributedDate, ad.length > 0 else {
            return
        }
        
        let limitSize = CGSize(width: ceil(width * 0.75), height: CGFloat.greatestFiniteMagnitude)
        let textLabelSize = ad.noc_sizeThatFits(size: limitSize)
        
        let vPadding = CGFloat(4)
        
        let dateLabelInsets = Style.dateInsets
        
        dateLabelFrame = CGRect(x: width/2 - textLabelSize.width/2, y: vPadding, width: textLabelSize.width, height: textLabelSize.height)
        
        backgroundImageViewFrame = CGRect(x: dateLabelFrame.origin.x - dateLabelInsets.left, y: dateLabelFrame.origin.y - dateLabelInsets.top, width: dateLabelFrame.width + dateLabelInsets.left + dateLabelInsets.right, height: dateLabelFrame.height + dateLabelInsets.top + dateLabelInsets.bottom)
        
        height = vPadding * 2 + backgroundImageViewFrame.height
    }
    
    private func setupBackgroundImage() {
        backgroundImage = TGSystemMessageCellLayout.Style.systemMessageBackground
    }
    
    private func setupAttributedDate() {
        let dateString = Style.dateFormatter.string(from: message.date)
        let one = NSAttributedString(string: dateString, attributes: [NSFontAttributeName: Style.dateFont, NSForegroundColorAttributeName: Style.dateColor])
        attributedDate = one
    }
    
    struct Style {
        static let dateInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
        static let dateFont = UIFont.noc_mediumSystemFont(ofSize: 13)
        static let dateColor = UIColor.white
        static let dateFormatter: DateFormatter = {
            let df = DateFormatter()
            df.locale = Locale(identifier: "pt_BR")
            df.dateFormat = "dd MMMM"
            return df
        }()
    }
    
}
