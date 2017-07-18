//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Silver Chu on 2017/7/5.
//  Copyright © 2017年 Silver Chu. All rights reserved.
//

import Foundation

class SearchResult {
    
    private let displayNamesForKind = [
        "album": NSLocalizedString("Album", comment: "Localized kind: Album"),
        "audiobook": NSLocalizedString("Audio Book",comment: "Localized kind: Audio Book"),
        "book": NSLocalizedString("Book", comment: "Localized kind: Book"),
        "ebook": NSLocalizedString("E-Book", comment: "Localized kind: E-Book"),
        "feature-movie": NSLocalizedString("Movie", comment: "Localized kind: Feature Movie"),
        "music-video": NSLocalizedString("Music Video", comment: "Localized kind: Music Video"),
        "podcast": NSLocalizedString("Podcast", comment: "Localized kind: Podcast"),
        "software": NSLocalizedString("App", comment: "Localized kind: Software"),
        "song": NSLocalizedString("Song", comment: "Localized kind: Song"),
        "tv-episode": NSLocalizedString("TV Episode", comment: "Localized kind: TV Episode"), ]
    
    var name = ""
    var artistName = ""
    var artworkSmallURL = ""
    var artworkLargeURL = ""
    var storeURL = ""
    var kind = ""
    var currency = ""
    var price = 0.0
    var genre = ""
    
    func kindForDisplay() -> String {
        return displayNamesForKind[kind] ?? kind
    }
    
    /*
    func kindForDisplay() -> String {
        switch kind {
        case "album":
            return NSLocalizedString("Album", comment: "Localized kind: Album")
        case "audiobook":
            return NSLocalizedString("Audio Book", comment: "Localized kind: Audio Book")
        case "book":
            return NSLocalizedString("Book", comment: "Localized kind: Book")
        case "ebook":
            return NSLocalizedString("E-Book", comment: "Localized kind: E-book")
        case "feature-movie":
            return NSLocalizedString("Movie", comment: "Localized kind: Feature Movie")
        case "music-video":
            return NSLocalizedString("Music Video", comment: "Localized kind: Music Video")
        case "podcast":
            return NSLocalizedString("Podcast", comment: "Localized kind: Podcast")
        case "software":
            return NSLocalizedString("App", comment: "Localized kind: Software")
        case "song":
            return NSLocalizedString("Song", comment: "Localized kind: Song")
        case "tv-episode":
            return NSLocalizedString("TV Episode", comment: "Localized kind: TV Episode")
        default: return kind
        }
    }
    */
    
}

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}
