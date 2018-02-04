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
                let firstForm = String(cString: sqlite3_column_text(ptrToRowData, 0))
                let secondForm = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let thirdForm = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 3))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 4))
                
                let words = getCommaSeperatedWordsString(from: [firstForm, secondForm, thirdForm])
                let fullDefinition = otherInformation.isEmpty ? definition : definition + " (" + otherInformation + ")"
                
                return DictionaryEntry(words: words, definition: fullDefinition)
            case .Adverbs:
                let words = String(cString: sqlite3_column_text(ptrToRowData, 0))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 2))
                
                let fullDefinition = otherInformation.isEmpty ? definition : definition + " (" + otherInformation + ")"
                
                return DictionaryEntry(words: words, definition: fullDefinition)
                case .CoordinatingConjunctions:
                let firstForm = String(cString: sqlite3_column_text(ptrToRowData, 0))
                let secondForm = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 3))
                
                let words = getCommaSeperatedWordsString(from: [firstForm, secondForm])
                let fullDefinition = otherInformation.isEmpty ? definition : definition + " (" + otherInformation + ")"
                
                return DictionaryEntry(words: words, definition: fullDefinition)
            case .Nouns:
                let nominative = String(cString: sqlite3_column_text(ptrToRowData, 0))
                let genitive = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 2)) + " " + String(cString: sqlite3_column_text(ptrToRowData, 3))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 4))
                let isIStem = sqlite3_column_int(ptrToRowData, 5)
                
                var words = getCommaSeperatedWordsString(from: [nominative, genitive])
                if isIStem == 1 {
                    words = "*" + words
                }
                    
                let fullDefinition = otherInformation.isEmpty ? definition : definition + " (" + otherInformation + ")"
                
                return DictionaryEntry(words: words, definition: fullDefinition)
            case .Prepositions:
                let firstForm = String(cString: sqlite3_column_text(ptrToRowData, 0))
                let secondForm = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 3))
                
                let words = getCommaSeperatedWordsString(from: [firstForm, secondForm]) + " (+ " + String(cString: sqlite3_column_text(ptrToRowData, 2)) + ")"
                
                return DictionaryEntry(words: words, definition: definition)
            case .Pronouns:
                let firstForm = String(cString: sqlite3_column_text(ptrToRowData, 0))
                let secondForm = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let thirdForm = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 3))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 4))
                
                let words = getCommaSeperatedWordsString(from: [firstForm, secondForm, thirdForm])
                let fullDefinition = otherInformation.isEmpty ? definition : definition + " (" + otherInformation + ")"
                
                return DictionaryEntry(words: words, definition: fullDefinition)
            case .SubordinatingConjunctions:
                let firstForm = String(cString: sqlite3_column_text(ptrToRowData, 0))
                let secondForm = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 3))
                
                let words = getCommaSeperatedWordsString(from: [firstForm, secondForm])
                let fullDefinition = otherInformation.isEmpty ? definition : definition + " (" + otherInformation + ")"
                
                return DictionaryEntry(words: words, definition: fullDefinition)
            case .Verbs:
                let firstPrincipalPart = String(cString: sqlite3_column_text(ptrToRowData, 0))
                let secondPrincipalPart = String(cString: sqlite3_column_text(ptrToRowData, 1))
                
                var thirdPrincipalPart = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let thirdPrincipalPartAlt = String(cString: sqlite3_column_text(ptrToRowData, 3))
                if !thirdPrincipalPartAlt.isEmpty {
                    thirdPrincipalPart = thirdPrincipalPart + " or " + thirdPrincipalPartAlt
                }
                
                var fourthPrincipalPart = String(cString: sqlite3_column_text(ptrToRowData, 4))
                let fourthPrincipalPartAlt = String(cString: sqlite3_column_text(ptrToRowData, 5))
                if !fourthPrincipalPartAlt.isEmpty {
                    fourthPrincipalPart = fourthPrincipalPart + " or " + fourthPrincipalPartAlt
                }
                
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 7))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 8))
                
                let goesWith = String(cString: sqlite3_column_text(ptrToRowData, 6))
                var words = getCommaSeperatedWordsString(from: [firstPrincipalPart, secondPrincipalPart, thirdPrincipalPart, fourthPrincipalPart])
                words = goesWith.isEmpty ? words : words + " (+ " + goesWith + ")"
                let fullDefinition = otherInformation.isEmpty ? definition : definition + " (" + otherInformation + ")"
                
                return DictionaryEntry(words: words, definition: fullDefinition)
        }
    }
    
    // MARK: Generate queries
    
    let adjectiveQueryBegining = "SELECT firstForm, secondForm, thirdForm, definition, otherInformation FROM Adjectives WHERE"
    let adverbQueryBegining = "SELECT word, definition, otherInformation FROM Adverbs WHERE"
    let coordinatingConjunctionsQueryBegining = "SELECT firstForm, secondForm, definition, otherInformation FROM CoordinatingConjunctions WHERE"
    let nounsQueryBegining = "SELECT nominative, genitive, gender, definition, otherInformation, isIStem FROM Nouns WHERE"
    let prepositionsQueryBegining = "SELECT firstForm, secondForm, goesWith, definition FROM Prepositions WHERE"
    let pronounsQueryBegining = "SELECT firstForm, secondForm, thirdForm, definition, otherInformation FROM Pronouns WHERE"
    let subordinatingConjunctionsQueryBegining = "SELECT firstForm, secondForm, definition, otherInformation FROM SubordinatingConjunctions WHERE"
    let verbQueryBegining = "SELECT firstPrincipalPart, secondPrincipalPart, thirdPrincipalPart, thirdPrincipalPartAlt, fourthPrincipalPart, fourthPrincipalPartAlt, goesWith, definition, otherInformation FROM Verbs WHERE"
    
    let adjectiveQueryEnding = "ORDER BY firstFormNM ASC;"
    let adverbQueryEnding = "ORDER BY wordNM ASC;"
    let coordinatingConjunctionsQueryEnding = "ORDER BY firstFormNM ASC;"
    let nounsQueryEnding = "ORDER BY nominativeNM ASC;"
    let prepositionsQueryEnding = "ORDER BY firstFormNM ASC;"
    let pronounsQueryEnding = "ORDER BY firstFormNM ASC;"
    let subordinatingConjunctionsQueryEnding = "ORDER BY firstFormNM ASC;"
    let verbQueryEnding = "ORDER BY firstPrincipalPartNM ASC;"
    
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
            let conditions = " (firstFormNM LIKE '\(stringToSearchWordsFor)' OR secondFormNM LIKE '\(stringToSearchWordsFor)'  OR thirdFormNM LIKE '\(stringToSearchWordsFor)') "
            return adjectiveQueryBegining + chapterCondition + conditions + adjectiveQueryEnding
        case .Adverbs:
            let conditions = " wordNM LIKE '\(stringToSearchWordsFor)' "
            return adverbQueryBegining + chapterCondition + conditions + adverbQueryEnding
        case .CoordinatingConjunctions:
            let conditions = " (firstFormNM LIKE '\(stringToSearchWordsFor)' OR secondFormNM LIKE '\(stringToSearchWordsFor)') "
            return coordinatingConjunctionsQueryBegining + chapterCondition + conditions + coordinatingConjunctionsQueryEnding
        case .Nouns:
            let conditions = " (nominativeNM LIKE '\(stringToSearchWordsFor)' OR genitiveNM LIKE '\(stringToSearchWordsFor)') "
            return nounsQueryBegining + chapterCondition + conditions + nounsQueryEnding
        case .Prepositions:
            let conditions = " (firstFormNM LIKE '\(stringToSearchWordsFor)' OR secondFormNM LIKE '\(stringToSearchWordsFor)') "
            return prepositionsQueryBegining + chapterCondition + conditions + prepositionsQueryEnding
        case .Pronouns:
            let conditions = " (firstFormNM LIKE '\(stringToSearchWordsFor)' OR secondFormNM LIKE '\(stringToSearchWordsFor)' OR thirdFormNM LIKE '\(stringToSearchWordsFor)') "
            return pronounsQueryBegining + chapterCondition + conditions + pronounsQueryEnding
        case .SubordinatingConjunctions:
            let conditions = " (firstFormNM LIKE '\(stringToSearchWordsFor)' OR secondFormNM LIKE '\(stringToSearchWordsFor)') "
            return subordinatingConjunctionsQueryBegining + chapterCondition + conditions + subordinatingConjunctionsQueryEnding
        case .Verbs:
            let conditions = " (firstPrincipalPartNM LIKE '\(stringToSearchWordsFor)' OR secondPrincipalPartNM LIKE '\(stringToSearchWordsFor)' OR thirdPrincipalPartNM LIKE '\(stringToSearchWordsFor)' OR thirdPrincipalPartAltNM LIKE '\(stringToSearchWordsFor)' OR fourthPrincipalPartNM LIKE '\(stringToSearchWordsFor)' OR fourthPrincipalPartAltNM LIKE '\(stringToSearchWordsFor)') "
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
            fatalError("The following SQL query failed: \(query)")
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
