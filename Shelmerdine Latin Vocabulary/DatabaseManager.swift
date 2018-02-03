//
//  DatabaseManager.swift
//  Shelmerdine Latin Vocabulary
//
//  Created by Christopher Bantle on 2018-02-01.
//  Copyright © 2018 Christopher Bantle. All rights reserved.
//

import Foundation
import SQLite3

enum WordType: String {
    case Adjectives = "Adjectives"
    case Adverbs = "Adverbs"
    case CoordinatingConjunctions = "Coordinating Conjunctions"
    case Nouns = "Nouns"
    case Prepositions = "Prepositions"
    case Pronouns = "Pronouns"
    case SubordinatingConjunctions = "Subordinating Conjunctions"
    case Verbs = "Verbs"
    
    static let values = [WordType.Nouns, WordType.Verbs, WordType.Adjectives, WordType.Pronouns, WordType.Adverbs, WordType.Prepositions, WordType.CoordinatingConjunctions, WordType.SubordinatingConjunctions]
}

enum Chapter: Int {
    case ChapterOne = 1
    case ChapterTwo = 2
    case ChapterThree = 3
    case ChapterFour = 4
    case ChapterFive = 5
    case ChapterSix = 6
    case ChapterSeven = 7
    case ChapterEight = 8
    case ChapterNine = 9
    case ChapterTen = 10
    case ChapterEleven = 11
    case ChapterTwelve = 12
    case ChapterThirteen = 13
    case ChapterFourteen = 14
    case ChapterFifteen = 15
    case ChapterSixteen = 16
    case ChapterSeventeen = 17
    case ChapterEighteen = 18
    case ChapterNineteen = 19
    case ChapterTwenty = 20
    case ChapterTwentyOne = 21
    case ChapterTwentyTwo = 22
    case ChapterTwentyThree = 23
    case ChapterTwentyFour = 24
    case ChapterTwentyFive = 25
    case ChapterTwentySix = 26
    case ChapterTwentySeven = 27
    case ChapterTwentyEight = 28
    case ChapterTwentyNine = 29
    case ChapterThirty = 30
    case ChapterThirtyOne = 31
    case ChapterThirtyTwo = 32
}

enum SearchType {
    case ByWord
    case ByDefinition
}

struct DictionaryEntry {
    var words: String
    var definition: String
}

class DatabaseManager {
    
    // MARK: Properties
    
    var ptrToDatabase: OpaquePointer? = nil
    
    // MARK: Initialization
    
    init?(pathToDatabase: String) {
        if !(sqlite3_open(pathToDatabase, &ptrToDatabase) == SQLITE_OK) {
            return nil
        }
    }
    
    deinit {
        sqlite3_close(ptrToDatabase)
    }
    
    // MARK: Parse query results
    
    private func getCommaSeperatedWordsString(from words: [String]) -> String {
        var commaSeperatedString = words[0]
        
        var i = 1
        while i < words.count {
            if !words[i].isEmpty {
                commaSeperatedString = commaSeperatedString + ", " + words[i]
            }
            i = i + 1;
        }
        
        return commaSeperatedString
    }
    
    private func getDictionaryEntryFromTableRowData(ptrToRowData: OpaquePointer, category: WordType) -> DictionaryEntry {
        switch category {
            case .Adjectives:
                let firstForm = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let secondForm = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let thirdForm = String(cString: sqlite3_column_text(ptrToRowData, 3))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 4))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 5))
                
                let words = getCommaSeperatedWordsString(from: [firstForm, secondForm, thirdForm])
                let fullDefinition = otherInformation.isEmpty ? definition : definition + " (" + otherInformation + ")"
                
                return DictionaryEntry(words: words, definition: fullDefinition)
            case .Adverbs:
                let words = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 3))
                
                let fullDefinition = otherInformation.isEmpty ? definition : definition + " (" + otherInformation + ")"
                
                return DictionaryEntry(words: words, definition: fullDefinition)
                case .CoordinatingConjunctions:
                let firstForm = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let secondForm = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 3))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 4))
                
                let words = getCommaSeperatedWordsString(from: [firstForm, secondForm])
                let fullDefinition = otherInformation.isEmpty ? definition : definition + " (" + otherInformation + ")"
                
                return DictionaryEntry(words: words, definition: fullDefinition)
            case .Nouns:
                let nominative = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let genitive = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 3)) + " " + String(cString: sqlite3_column_text(ptrToRowData, 4))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 5))
                
                let words = getCommaSeperatedWordsString(from: [nominative, genitive])
                let fullDefinition = otherInformation.isEmpty ? definition : definition + " (" + otherInformation + ")"
                
                return DictionaryEntry(words: words, definition: fullDefinition)
            case .Prepositions:
                let firstForm = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let secondForm = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 4))
                
                let words = getCommaSeperatedWordsString(from: [firstForm, secondForm]) + " (+ " + String(cString: sqlite3_column_text(ptrToRowData, 3)) + ")"
                
                return DictionaryEntry(words: words, definition: definition)
            case .Pronouns:
                let firstForm = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let secondForm = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let thirdForm = String(cString: sqlite3_column_text(ptrToRowData, 3))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 4))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 5))
                
                let words = getCommaSeperatedWordsString(from: [firstForm, secondForm, thirdForm])
                let fullDefinition = otherInformation.isEmpty ? definition : definition + " (" + otherInformation + ")"
                
                return DictionaryEntry(words: words, definition: fullDefinition)
            case .SubordinatingConjunctions:
                let firstForm = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let secondForm = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 3))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 4))
                
                let words = getCommaSeperatedWordsString(from: [firstForm, secondForm])
                let fullDefinition = otherInformation.isEmpty ? definition : definition + " (" + otherInformation + ")"
                
                return DictionaryEntry(words: words, definition: fullDefinition)
            case .Verbs:
                let firstPrincipalPart = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let secondPrincipalPart = String(cString: sqlite3_column_text(ptrToRowData, 2))
                
                var thirdPrincipalPart = String(cString: sqlite3_column_text(ptrToRowData, 3))
                let thirdPrincipalPartAlt = String(cString: sqlite3_column_text(ptrToRowData, 4))
                if !thirdPrincipalPartAlt.isEmpty {
                    thirdPrincipalPart = thirdPrincipalPart + " or " + thirdPrincipalPartAlt
                }
                
                var fourthPrincipalPart = String(cString: sqlite3_column_text(ptrToRowData, 5))
                let fourthPrincipalPartAlt = String(cString: sqlite3_column_text(ptrToRowData, 6))
                if !fourthPrincipalPartAlt.isEmpty {
                    fourthPrincipalPart = fourthPrincipalPart + " or " + fourthPrincipalPartAlt
                }
                
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 8))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 9))
                
                let goesWith = String(cString: sqlite3_column_text(ptrToRowData, 7))
                var words = getCommaSeperatedWordsString(from: [firstPrincipalPart, secondPrincipalPart, thirdPrincipalPart, fourthPrincipalPart])
                words = goesWith.isEmpty ? words : words + " (+ " + goesWith + ")"
                let fullDefinition = otherInformation.isEmpty ? definition : definition + " (" + otherInformation + ")"
                
                return DictionaryEntry(words: words, definition: fullDefinition)
        }
    }
    
    // MARK: Generate queries
    
    let adjectiveQueryBegining = "SELECT * FROM Adjectives WHERE"
    let adverbQueryBegining = "SELECT * FROM Adverbs WHERE"
    let coordinatingConjunctionsQueryBegining = "SELECT * FROM CoordinatingConjunctions WHERE"
    let nounsQueryBegining = "SELECT * FROM Nouns WHERE"
    let prepositionsQueryBegining = "SELECT * FROM Prepositions WHERE"
    let pronounsQueryBegining = "SELECT * FROM Pronouns WHERE"
    let subordinatingConjunctionsQueryBegining = "SELECT * FROM SubordinatingConjunctions WHERE"
    let verbQueryBegining = "SELECT * FROM Verbs WHERE"
    
    let adjectiveQueryEnding = "ORDER BY firstForm ASC;"
    let adverbQueryEnding = "ORDER BY word ASC;"
    let coordinatingConjunctionsQueryEnding = "ORDER BY firstForm ASC;"
    let nounsQueryEnding = "ORDER BY nominative ASC;"
    let prepositionsQueryEnding = "ORDER BY firstForm ASC;"
    let pronounsQueryEnding = "ORDER BY firstForm ASC;"
    let subordinatingConjunctionsQueryEnding = "ORDER BY firstForm ASC;"
    let verbQueryEnding = "ORDER BY firstPrincipalPart ASC;"
    
    private func getSearchQueryByDefinition(chapter: Chapter, category: WordType, stringToSearchFor: String) -> String {
        let stringToSearchDefinitionsFor = "%" + stringToSearchFor + "%"
        let conditions = " chapter <= \(chapter.rawValue) AND definition LIKE '\(stringToSearchDefinitionsFor)' "
        
        switch category {
        case .Adjectives:
            return adjectiveQueryBegining + conditions + adjectiveQueryEnding
        case .Adverbs:
            return adverbQueryBegining + conditions + adverbQueryEnding
        case .CoordinatingConjunctions:
            return coordinatingConjunctionsQueryBegining + conditions + coordinatingConjunctionsQueryEnding
        case .Nouns:
            return nounsQueryBegining + conditions + nounsQueryEnding
        case .Prepositions:
            return prepositionsQueryBegining + conditions + prepositionsQueryEnding
        case .Pronouns:
            return pronounsQueryBegining + conditions + pronounsQueryEnding
        case .SubordinatingConjunctions:
            return subordinatingConjunctionsQueryBegining + conditions + subordinatingConjunctionsQueryEnding
        case .Verbs:
            return verbQueryBegining + conditions + verbQueryEnding
        }
    }
    
    private func getSearchQueryByWord(chapter: Chapter, category: WordType, stringToSearchFor: String) -> String {
        let stringToSearchWordsFor = stringToSearchFor + "%"
        let chapterCondition = " chapter <= \(chapter.rawValue) AND"
        
        switch category {
        case .Adjectives:
            let conditions = " (firstForm LIKE '\(stringToSearchWordsFor)' OR secondForm LIKE '\(stringToSearchWordsFor)'  OR thirdForm LIKE '\(stringToSearchWordsFor)') "
            return adjectiveQueryBegining + chapterCondition + conditions + adjectiveQueryEnding
        case .Adverbs:
            let conditions = " word LIKE '\(stringToSearchWordsFor)' "
            return adverbQueryBegining + chapterCondition + conditions + adverbQueryEnding
        case .CoordinatingConjunctions:
            let conditions = " (firstForm LIKE '\(stringToSearchWordsFor)' OR secondForm LIKE '\(stringToSearchWordsFor)') "
            return coordinatingConjunctionsQueryBegining + chapterCondition + conditions + coordinatingConjunctionsQueryEnding
        case .Nouns:
            let conditions = " (nominative LIKE '\(stringToSearchWordsFor)' OR genitive LIKE '\(stringToSearchWordsFor)') "
            return nounsQueryBegining + chapterCondition + conditions + nounsQueryEnding
        case .Prepositions:
            let conditions = " (firstForm LIKE '\(stringToSearchWordsFor)' OR secondForm LIKE '\(stringToSearchWordsFor)') "
            return prepositionsQueryBegining + chapterCondition + conditions + prepositionsQueryEnding
        case .Pronouns:
            let conditions = " (firstForm LIKE '\(stringToSearchWordsFor)' OR secondForm LIKE '\(stringToSearchWordsFor)' OR thirdForm LIKE '\(stringToSearchWordsFor)') "
            return pronounsQueryBegining + chapterCondition + conditions + pronounsQueryEnding
        case .SubordinatingConjunctions:
            let conditions = " (firstForm LIKE '\(stringToSearchWordsFor)' OR secondForm LIKE '\(stringToSearchWordsFor)') "
            return subordinatingConjunctionsQueryBegining + chapterCondition + conditions + subordinatingConjunctionsQueryEnding
        case .Verbs:
            let conditions = " (firstPrincipalPart LIKE '\(stringToSearchWordsFor)' OR secondPrincipalPart LIKE '\(stringToSearchWordsFor)' OR thirdPrincipalPart LIKE '\(stringToSearchWordsFor)' OR thirdPrincipalPartAlt LIKE '\(stringToSearchWordsFor)' OR fourthPrincipalPart LIKE '\(stringToSearchWordsFor)' OR fourthPrincipalPartAlt LIKE '\(stringToSearchWordsFor)') "
            return verbQueryBegining + chapterCondition + conditions + verbQueryEnding
        }
    }

    private func getCumulativeQuery(chapter: Chapter, category: WordType) -> String {
        let condition = " chapter <= \(chapter.rawValue) "
        
        switch category {
        case .Adjectives:
            return adjectiveQueryBegining + condition + adjectiveQueryEnding
        case .Adverbs:
            return adverbQueryBegining + condition + adverbQueryEnding
        case .CoordinatingConjunctions:
            return coordinatingConjunctionsQueryBegining + condition + coordinatingConjunctionsQueryEnding
        case .Nouns:
            return nounsQueryBegining + condition + nounsQueryEnding
        case .Prepositions:
            return prepositionsQueryBegining + condition + prepositionsQueryEnding
        case .Pronouns:
            return pronounsQueryBegining + condition + pronounsQueryEnding
        case .SubordinatingConjunctions:
            return subordinatingConjunctionsQueryBegining + condition + subordinatingConjunctionsQueryEnding
        case .Verbs:
            return verbQueryBegining + condition + verbQueryEnding
        }
    }

    private func getIndividualChapterQuery(chapter: Chapter, category: WordType) -> String {
        let condition = " chapter = \(chapter.rawValue) "
        
        switch category {
        case .Adjectives:
            return adjectiveQueryBegining + condition + adjectiveQueryEnding
        case .Adverbs:
            return adverbQueryBegining + condition + adverbQueryEnding
        case .CoordinatingConjunctions:
            return coordinatingConjunctionsQueryBegining + condition + coordinatingConjunctionsQueryEnding
        case .Nouns:
            return nounsQueryBegining + condition + nounsQueryEnding
        case .Prepositions:
            return prepositionsQueryBegining + condition + prepositionsQueryEnding
        case .Pronouns:
            return pronounsQueryBegining + condition + pronounsQueryEnding
        case .SubordinatingConjunctions:
            return subordinatingConjunctionsQueryBegining + condition + subordinatingConjunctionsQueryEnding
        case .Verbs:
            return verbQueryBegining + condition + verbQueryEnding
        }
    }
    
    // MARK: Query database
    
    private func queryDatabase(query: String, category: WordType) -> [DictionaryEntry] {
        var dictionaryEntries = [DictionaryEntry]()
        
        var ptrToQueryResults: OpaquePointer? = nil
        if sqlite3_prepare_v2(ptrToDatabase, query, -1, &ptrToQueryResults, nil) == SQLITE_OK {
            while (sqlite3_step(ptrToQueryResults) == SQLITE_ROW) {
                dictionaryEntries.append(getDictionaryEntryFromTableRowData(ptrToRowData: ptrToQueryResults!, category: category))
            }
        } else {
            fatalError("SQL query \(query) failed.")
        }
        sqlite3_finalize(ptrToQueryResults)
        
        return dictionaryEntries
    }
    
    // MARK: Public interface
    
    func getDictionaryEntries(for chapter: Chapter) -> (dictionaryEntries: [[DictionaryEntry]], categories: [WordType]) {
        var dictionaryEntries = [[DictionaryEntry]]()
        var categories = [WordType]()
        
        for category in WordType.values {
            let query = getIndividualChapterQuery(chapter: chapter, category: category)
            let resultsForCategory = queryDatabase(query: query, category: category)
            if !resultsForCategory.isEmpty {
                dictionaryEntries.append(resultsForCategory)
                categories.append(category)
            }
        }
        
        return (dictionaryEntries: dictionaryEntries, categories: categories)
    }
    
    func getDictionaryEntries(forChaptersUpToAndIncluding chapter: Chapter) -> (dictionaryEntries: [[DictionaryEntry]], categories: [WordType]) {
        var dictionaryEntries = [[DictionaryEntry]]()
        var categories = [WordType]()
        
        for category in WordType.values {
            let query = getCumulativeQuery(chapter: chapter, category: category)
            let resultsForCategory = queryDatabase(query: query, category: category)
            if !resultsForCategory.isEmpty {
                dictionaryEntries.append(resultsForCategory)
                categories.append(category)
            }
        }
        
        return (dictionaryEntries: dictionaryEntries, categories: categories)
    }
    
    func getDictionaryEntries(forChaptersUpToAndIncluding chapter: Chapter, containing string: String, searchType: SearchType) -> (dictionaryEntries: [[DictionaryEntry]], categories: [WordType]) {
        var dictionaryEntries = [[DictionaryEntry]]()
        var categories = [WordType]()
        
        for category in WordType.values {
            var query = ""
            switch searchType {
            case .ByWord:
                query = getSearchQueryByWord(chapter: chapter, category: category, stringToSearchFor: string)
            case .ByDefinition:
                query = getSearchQueryByDefinition(chapter: chapter, category: category, stringToSearchFor: string)
            }
            
            let resultsForCategory = queryDatabase(query: query, category: category)
            if !resultsForCategory.isEmpty {
                dictionaryEntries.append(resultsForCategory)
                categories.append(category)
            }
        }
        
        return (dictionaryEntries: dictionaryEntries, categories: categories)
    }
}
