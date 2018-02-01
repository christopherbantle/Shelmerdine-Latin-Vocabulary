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
    
    static let values = [WordType.Adjectives, WordType.Adverbs, WordType.CoordinatingConjunctions, WordType.Nouns, WordType.Prepositions, WordType.Pronouns, WordType.SubordinatingConjunctions, WordType.Verbs]
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
    
    // MARK: Initialization
    
    init(pathToDatabase: String) {
        if !(sqlite3_open(pathToDatabase, &ptrToDatabase) == SQLITE_OK) {
            fatalError("Unable to establish connection to database.")
        }
    }
    
    deinit {
        sqlite3_close(ptrToDatabase)
    }
    
    // MARK: Parse query results
    
    private func getCommaSeperatedWordsString(from words: [String]) -> String {
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
                
                let words = getCommaSeperatedWordsString(from: [firstForm, secondForm, thirdForm])
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
                
                let words = getCommaSeperatedWordsString(from: [firstForm, secondForm])
                let fullDefinition = getDefinitionString(definition: definition, otherInformation: otherInformation)
                
                return DictionaryEntry(words: words, definition: fullDefinition)
            case .Nouns:
                let nominative = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let genitive = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 3)) + " " + String(cString: sqlite3_column_text(ptrToRowData, 4))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 5))
                
                let words = getCommaSeperatedWordsString(from: [nominative, genitive])
                let fullDefinition = getDefinitionString(definition: definition, otherInformation: otherInformation)
                
                return DictionaryEntry(words: words, definition: fullDefinition)
            case .Prepositions:
                let firstForm = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let secondForm = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 3)) + " " + String(cString: sqlite3_column_text(ptrToRowData, 4))
                
                let words = getCommaSeperatedWordsString(from: [firstForm, secondForm])
                
                return DictionaryEntry(words: words, definition: definition)
            case .Pronouns:
                let firstForm = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let secondForm = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let thirdForm = String(cString: sqlite3_column_text(ptrToRowData, 3))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 4))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 5))
                
                let words = getCommaSeperatedWordsString(from: [firstForm, secondForm, thirdForm])
                let fullDefinition = getDefinitionString(definition: definition, otherInformation: otherInformation)
                
                return DictionaryEntry(words: words, definition: fullDefinition)
            case .SubordinatingConjunctions:
                let firstForm = String(cString: sqlite3_column_text(ptrToRowData, 1))
                let secondForm = String(cString: sqlite3_column_text(ptrToRowData, 2))
                let definition = String(cString: sqlite3_column_text(ptrToRowData, 3))
                let otherInformation = String(cString: sqlite3_column_text(ptrToRowData, 4))
                
                let words = getCommaSeperatedWordsString(from: [firstForm, secondForm])
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
                
                let words = getCommaSeperatedWordsString(from: [firstPrincipalPart, secondPrincipalPart, thirdPrincipalPart, fourthPrincipalPart])
                let fullDefinition = getDefinitionString(definition: definition, otherInformation: otherInformation)
                
                return DictionaryEntry(words: words, definition: fullDefinition)
        }
    }
    
    // MARK: Generate queries
    
    private func getSearchQuery(chapter: Chapter, category: WordType, stringToSearchFor: String) -> String {
        var stringToSearchWordsFor = stringToSearchFor + "%"
        stringToSearchWordsFor = stringToSearchWordsFor.replacingOccurrences(of: "e", with: "[eē]")
        stringToSearchWordsFor = stringToSearchWordsFor.replacingOccurrences(of: "i", with: "[iī]")
        stringToSearchWordsFor = stringToSearchWordsFor.replacingOccurrences(of: "o", with: "[oō]")
        stringToSearchWordsFor = stringToSearchWordsFor.replacingOccurrences(of: "a", with: "[aā]")
        stringToSearchWordsFor = stringToSearchWordsFor.replacingOccurrences(of: "u", with: "[uū]")
        
        let stringToSearchDefinitionsFor = "%" + stringToSearchFor + "%"
        
        switch category {
        case .Adjectives:
            let query = """
            SELECT *
            FROM Adjectives
            WHERE chapter <= \(chapter.rawValue) AND
            firstForm LIKE \(stringToSearchWordsFor) OR
            secondForm LIKE \(stringToSearchWordsFor)  OR
            thirdForm LIKE \(stringToSearchWordsFor) OR
            definition LIKE \(stringToSearchDefinitionsFor)
            ORDER BY firstForm ASC;
            """
            return query
        case .Adverbs:
            let query = """
            SELECT *
            FROM Adverbs
            WHERE chapter <= \(chapter.rawValue) AND
            word LIKE \(stringToSearchWordsFor) OR
            definition LIKE \(stringToSearchDefinitionsFor)
            ORDER BY word ASC;
            """
            return query
        case .CoordinatingConjunctions:
            let query = """
            SELECT *
            FROM CoordinatingConjunctions
            WHERE chapter <= \(chapter.rawValue) AND
            firstForm LIKE \(stringToSearchWordsFor) OR
            secondForm LIKE \(stringToSearchWordsFor) OR
            definition LIKE \(stringToSearchDefinitionsFor)
            ORDER BY firstForm ASC;
            """
            return query
        case .Nouns:
            let query = """
            SELECT *
            FROM Nouns
            WHERE chapter <= \(chapter.rawValue) AND
            nominative LIKE \(stringToSearchWordsFor) OR
            genitive LIKE \(stringToSearchWordsFor)
            OR definition LIKE \(stringToSearchDefinitionsFor)
            ORDER BY nominative ASC;
            """
            return query
        case .Prepositions:
            let query = """
            SELECT *
            FROM Prepositions
            WHERE chapter <= \(chapter.rawValue) AND
            firstForm LIKE \(stringToSearchWordsFor) OR
            secondForm LIKE \(stringToSearchWordsFor) OR
            definition LIKE \(stringToSearchDefinitionsFor);
            ORDER BY firstForm ASC;
            """
            return query
        case .Pronouns:
            let query = """
            SELECT *
            FROM Pronouns
            WHERE chapter <= \(chapter.rawValue) AND
            firstForm LIKE \(stringToSearchWordsFor) OR
            secondForm LIKE \(stringToSearchWordsFor) OR
            thirdForm LIKE \(stringToSearchWordsFor) OR
            definition LIKE \(stringToSearchDefinitionsFor)
            ORDER BY firstForm ASC;
            """
            return query
        case .SubordinatingConjunctions:
            let query = """
            SELECT *
            FROM SubordinatingConjunctions
            WHERE chapter <= \(chapter.rawValue) AND
            firstForm LIKE \(stringToSearchWordsFor) OR
            secondForm LIKE \(stringToSearchWordsFor) OR
            definition LIKE \(stringToSearchDefinitionsFor)
            ORDER BY firstForm ASC;
            """
            return query
        case .Verbs:
            let query = """
            SELECT *
            FROM Verbs
            WHERE chapter <= \(chapter.rawValue) AND
            firstPrincipalPart LIKE \(stringToSearchWordsFor) OR
            secondPrincipalPart LIKE \(stringToSearchWordsFor) OR
            thirdPrincipalPart LIKE \(stringToSearchWordsFor) OR
            thirdPrincipalPartAlt LIKE \(stringToSearchWordsFor) OR
            fourthPrincipalPart LIKE \(stringToSearchWordsFor) OR
            fourthPrincipalPartAlt LIKE \(stringToSearchWordsFor) OR
            definition LIKE \(stringToSearchDefinitionsFor);
            """
            return query
        }
    }

    private func getCumulativeQuery(chapter: Chapter, category: WordType) -> String {
        let query = "SELECT * FROM "
        switch category {
        case .Adjectives:
            return query + "Adjectives WHERE chapter <= \(chapter.rawValue) ORDER BY firstForm ASC;"
        case .Adverbs:
            return query + "Adverbs WHERE chapter <= \(chapter.rawValue) ORDER BY word ASC;"
        case .CoordinatingConjunctions:
            return query + "CoordinatingConjunctions WHERE chapter <= \(chapter.rawValue) ORDER BY firstForm ASC;"
        case .Nouns:
            return query + "Nouns WHERE chapter <= \(chapter.rawValue) ORDER BY nominative ASC;"
        case .Prepositions:
            return query + "Prepositions WHERE chapter <= \(chapter.rawValue) ORDER BY firstForm ASC;"
        case .Pronouns:
            return query + "Pronouns WHERE chapter <= \(chapter.rawValue) ORDER BY firstForm ASC;"
        case .SubordinatingConjunctions:
            return query + "SubordinatingConjunctions WHERE chapter <= \(chapter.rawValue) ORDER BY firstForm ASC;"
        case .Verbs:
            return query + "SubordinatingConjunctions WHERE chapter <= \(chapter.rawValue) ORDER BY firstForm ASC;"
        }
    }

    private func getIndividualChapterQuery(chapter: Chapter, category: WordType) -> String {
        let query = "SELECT * FROM "
        switch category {
        case .Adjectives:
            return query + "Adjectives WHERE chapter = \(chapter.rawValue) ORDER BY firstForm ASC;"
        case .Adverbs:
            return query + "Adverbs WHERE chapter = \(chapter.rawValue) ORDER BY word ASC;"
        case .CoordinatingConjunctions:
            return query + "CoordinatingConjunctions WHERE chapter = \(chapter.rawValue) ORDER BY firstForm ASC;"
        case .Nouns:
            return query + "Nouns WHERE chapter = \(chapter.rawValue) ORDER BY nominative ASC;"
        case .Prepositions:
            return query + "Prepositions WHERE chapter = \(chapter.rawValue) ORDER BY firstForm ASC;"
        case .Pronouns:
            return query + "Pronouns WHERE chapter = \(chapter.rawValue) ORDER BY firstForm ASC;"
        case .SubordinatingConjunctions:
            return query + "SubordinatingConjunctions WHERE chapter = \(chapter.rawValue) ORDER BY firstForm ASC;"
        case .Verbs:
            return query + "SubordinatingConjunctions WHERE chapter = \(chapter.rawValue) ORDER BY firstForm ASC;"
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
    
    // MARK: View dictionary entries for a single chapter
    
    func getDictionaryEntires(for chapter: Chapter) -> (dictionaryEntries: [[DictionaryEntry]], categories: [WordType]) {
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
    
    // MARK: View dictionary entries up to and including a given chapter
    
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
        let query = getCumulativeQuery(chapter: chapter, category: category)
        return queryDatabase(query: query, category: category)
    }
    
    // MARK: Seach dictionary entries up to and including a given chapter
    
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
        let query = getSearchQuery(chapter: chapter, category: category, stringToSearchFor: string)
        return queryDatabase(query: query, category: category)
    }
}
