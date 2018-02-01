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
    
    var tableName: String {
        switch self {
        case .Adjectives:
            return "Adjectives"
        case .Adverbs:
            return "Adverbs"
        case .CoordinatingConjunctions:
            return "CoordinatingConjunctions"
        case .Nouns:
            return "Nouns"
        case .Prepositions:
            return "Prepositions"
        case .Pronouns:
            return "Pronouns"
        case .SubordinatingConjunctions:
            return "SubordinatingConjunctions"
        case .Verbs:
            return "Verbs"
        }
    }
    
    static let values = [WordType.Adjectives, WordType.Adverbs, WordType.CoordinatingConjunctions, WordType.Nouns, WordType.Prepositions, WordType.Pronouns, WordType.Pronouns, WordType.SubordinatingConjunctions, WordType.Verbs]
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

struct DictionaryEntry {
    var words: String
    var definition: String
}

class DatabaseManager {
    
    // MARK: Properties
    
    var ptrToDatabase: OpaquePointer? = nil
    
    init(pathToDatabase: String) {
        if !(sqlite3_open(pathToDatabase, &ptrToDatabase) == SQLITE_OK) {
            fatalError("Unable to establish connection to database.")
        }
    }
    
    deinit {
        sqlite3_close(ptrToDatabase)
    }
    
    // MARK: Parse query results
    
    private func getCommaSeperatedWordString(from words: [String]) -> String {
        var commaSeperatedString = words[0]
        
        let i = words.count + 1
        while i < words.count {
            if !words[i].isEmpty {
                commaSeperatedString = ", " + words[i]
            }
        }
        
        return commaSeperatedString
    }
    
    private func getDefinitionString(definition: String, otherInformation: String) -> String {
        return definition + " (" + otherInformation + ")"
    }
    
    private func getDictionaryEntryFromTableRowData(ptrToRowData: OpaquePointer, category: WordType) -> DictionaryEntry {
        switch category {
            case .Adjectives:
                let firstForm = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let secondForm = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let thirdForm = String(cString: sqlite3_column_text(ptrToRowData, 3))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 4))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 5))
                
                let words = getCommaSeperatedWordString(from: [firstForm, secondForm, thirdForm])
                let fullDefinition = getDefinitionString(definition: definition, otherInformation: otherInformation)
                
                return DictionaryEntry(words: words, definition: fullDefinition)
            case .Adverbs:
                let words = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 3))
                
                let fullDefinition = getDefinitionString(definition: definition, otherInformation: otherInformation)
                
                return DictionaryEntry(words: words, definition: fullDefinition)
                case .CoordinatingConjunctions:
                let firstForm = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let secondForm = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 3))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 4))
                
                let words = getCommaSeperatedWordString(from: [firstForm, secondForm])
                let fullDefinition = getDefinitionString(definition: definition, otherInformation: otherInformation)
                
                return DictionaryEntry(words: words, definition: fullDefinition)
            case .Nouns:
                let nominative = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let genitive = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 3)) + " " + String(cString: sqlite3_column_text(ptrToRowData, 4))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 5))
                
                let words = getCommaSeperatedWordString(from: [nominative, genitive])
                let fullDefinition = getDefinitionString(definition: definition, otherInformation: otherInformation)
                
                return DictionaryEntry(words: words, definition: fullDefinition)
            case .Prepositions:
                let firstForm = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let secondForm = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 3)) + " " + String(cString: sqlite3_column_text(ptrToRowData, 4))
                
                let words = getCommaSeperatedWordString(from: [firstForm, secondForm])
                
                return DictionaryEntry(words: words, definition: definition)
            case .Pronouns:
                let firstForm = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let secondForm = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let thirdForm = String(cString: sqlite3_column_text(ptrToRowData, 3))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 4))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 5))
                
                let words = getCommaSeperatedWordString(from: [firstForm, secondForm, thirdForm])
                let fullDefinition = getDefinitionString(definition: definition, otherInformation: otherInformation)
                
                return DictionaryEntry(words: words, definition: fullDefinition)
            case .SubordinatingConjunctions:
                let firstForm = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let secondForm = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 3))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 4))
                
                let words = getCommaSeperatedWordString(from: [firstForm, secondForm])
                let fullDefinition = getDefinitionString(definition: definition, otherInformation: otherInformation)
                
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
                
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 7)) + " " + String(cString: sqlite3_column_text(ptrToRowData, 8))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 9))
                
                let words = getCommaSeperatedWordString(from: [firstPrincipalPart, secondPrincipalPart, thirdPrincipalPart, fourthPrincipalPart])
                let fullDefinition = getDefinitionString(definition: definition, otherInformation: otherInformation)
                
                return DictionaryEntry(words: words, definition: fullDefinition)
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
            fatalError("SQL query failed")
        }
        sqlite3_finalize(ptrToQueryResults)
        
        return dictionaryEntries
    }
    
    // MARK: View dictionary entries by chapter
    
    func getDictionaryEntires(for chapter: Chapter) -> (dictionaryEntries: [[DictionaryEntry]], categories: [WordType]) {
        var dictionaryEntries = [[DictionaryEntry]]()
        var categories = [WordType]()
        
        for category in WordType.values {
            let query = "SELECT * FROM \(category.tableName) WHERE chapter = \(chapter.rawValue);"
            let resultsForCategory = queryDatabase(query: query, category: category)
            if !resultsForCategory.isEmpty {
                dictionaryEntries.append(resultsForCategory)
                categories.append(category)
            }
        }
        
        return (dictionaryEntries: dictionaryEntries, categories: categories)
    }
    
    // MARK: Viewing dictionary entries up to and including a certain chapter
    
    func getDictionaryEntries(forChaptersUpToAndIncluding chapter: Chapter) -> (dictionaryEntries: [[DictionaryEntry]], categories: [WordType]) {
        var dictionaryEntries = [[DictionaryEntry]]()
        var categories = [WordType]()
        
        for category in WordType.values {
            let resultsForCategory = getDictionaryEntries(forChaptersUpToAndIncluding: chapter, in: category)
            if !resultsForCategory.isEmpty {
                dictionaryEntries.append(resultsForCategory)
                categories.append(category)
            }
        }
        
        return (dictionaryEntries: dictionaryEntries, categories: categories)
    }
    
    func getDictionaryEntries(forChaptersUpToAndIncluding chapter: Chapter, in category: WordType) -> [DictionaryEntry] {
        let query = "SELECT * FROM \(category.tableName) WHERE chapter <= \(chapter.rawValue);"
        return queryDatabase(query: query, category: category)
    }
    
    // MARK: Seaching dictionary entries
    
    func getDictionaryEntries(forChaptersUpToAndIncluding chapter: Chapter, containing string: String) -> [DictionaryEntry] {
        var dictionaryEntries = [DictionaryEntry]()
        
        for category in WordType.values {
            let resultsForCategory = getDictionaryEntries(forChaptersUpToAndIncluding: chapter, containing: string, in: category)
            if !resultsForCategory.isEmpty {
                dictionaryEntries.append(contentsOf: resultsForCategory)
            }
        }
        
        return dictionaryEntries
    }
    
    func getDictionaryEntries(forChaptersUpToAndIncluding chapter: Chapter, containing string: String, in category: WordType) -> [DictionaryEntry] {
        let stringToSearchWordsWith = getStringToSearchWordsWith(string: string)
        switch category {
        case .Adjectives:
            let query = """
                        SELECT *
                        FROM \(category.tableName)
                        WHERE chapter <= \(chapter.rawValue) AND
                            firstForm LIKE \(stringToSearchWordsWith) OR
                            secondForm LIKE \(stringToSearchWordsWith)  OR
                            thirdForm LIKE \(stringToSearchWordsWith) OR
                            definition LIKE \(string);
                        """
            return queryDatabase(query: query, category: category)
        case .Adverbs:
            let query = """
                        SELECT *
                        FROM \(category.tableName)
                        WHERE chapter <= \(chapter.rawValue) AND
                            word LIKE \(stringToSearchWordsWith) OR
                            definition LIKE \(string);
                        """
            return queryDatabase(query: query, category: category)
        case .CoordinatingConjunctions:
            let query = """
                        SELECT *
                        FROM \(category.rawValue)
                        WHERE chapter <= \(chapter.rawValue) AND
                            firstForm LIKE \(stringToSearchWordsWith) OR
                            secondForm LIKE \(stringToSearchWordsWith) OR
                            definition LIKE \(string);
                        """
            return queryDatabase(query: query, category: category)
        case .Nouns:
            let query = """
                        SELECT *
                        FROM \(category.tableName)
                        WHERE chapter <= \(chapter.rawValue) AND
                            nominative LIKE \(stringToSearchWordsWith) OR
                            genitive LIKE \(stringToSearchWordsWith)
                            OR definition LIKE \(string);
                        """
            return queryDatabase(query: query, category: category)
        case .Prepositions:
            let query = """
                        SELECT *
                        FROM \(category.tableName)
                        WHERE chapter <= \(chapter.rawValue) AND
                            firstForm LIKE \(stringToSearchWordsWith) OR
                            secondForm LIKE \(stringToSearchWordsWith) OR
                            definition LIKE \(string);
                        """
            return queryDatabase(query: query, category: category)
        case .Pronouns:
            let query = """
                        SELECT *
                        FROM \(category.tableName)
                        WHERE chapter <= \(chapter.rawValue) AND
                        firstForm LIKE ? OR
                            secondForm LIKE \(stringToSearchWordsWith) OR
                            thirdForm LIKE \(stringToSearchWordsWith) OR
                            definition LIKE \(string);
                        """
            return queryDatabase(query: query, category: category)
        case .SubordinatingConjunctions:
             let query = """
                        SELECT *
                        FROM SubordinatingConjunctions
                        WHERE chapter <= \(chapter.rawValue) AND
                            firstForm LIKE \(stringToSearchWordsWith) OR
                            secondForm LIKE \(stringToSearchWordsWith) OR
                            definition LIKE \(string);
                        """
            return queryDatabase(query: query, category: category)
        case .Verbs:
            let query = """
                        SELECT *
                        FROM Verbs
                        WHERE chapter <= \(chapter.rawValue) AND
                            firstPrincipalPart LIKE \(stringToSearchWordsWith) OR
                            secondPrincipalPart LIKE \(stringToSearchWordsWith) OR
                            thirdPrincipalPart LIKE \(stringToSearchWordsWith) OR
                            thirdPrincipalPartAlt LIKE \(stringToSearchWordsWith) OR
                            fourthPrincipalPart LIKE \(stringToSearchWordsWith) OR
                            fourthPrincipalPartAlt LIKE \(stringToSearchWordsWith) OR
                            definition LIKE \(string);
                        """
            return queryDatabase(query: query, category: category)
        }
    }
    
    private func getStringToSearchWordsWith(string: String) -> String {
        var stringToSearchWordsBy = string + "%"
        stringToSearchWordsBy = stringToSearchWordsBy.replacingOccurrences(of: "e", with: "[eē]")
        stringToSearchWordsBy = stringToSearchWordsBy.replacingOccurrences(of: "i", with: "[iī]")
        stringToSearchWordsBy = stringToSearchWordsBy.replacingOccurrences(of: "o", with: "[oō]")
        stringToSearchWordsBy = stringToSearchWordsBy.replacingOccurrences(of: "a", with: "[aā]")
        stringToSearchWordsBy = stringToSearchWordsBy.replacingOccurrences(of: "u", with: "[uū]")
        return stringToSearchWordsBy
    }
}
