// Copyright (c) 2020 ikiApps LLC.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

/// A variation of the Soundex algorithm for coding English words based on their sounds.
/// It has been extended to ignore some digraphs.
///
/// The algorithm is implemented in two parts
///
/// 1. Store the first and nonzero coded characters in a SoundexCodeReady.
/// 2. With a SoundexCodeReady, generate a Soundex code.

public
protocol Soundexable
{
    func soundexEqual(_ first: String, _ second: String) -> Bool
    func soundexCode(source: SoundexCodeReady) -> String
}

extension Soundexable
{
    typealias CharacterPosition = Int
    typealias Subcode = String
    
    func singles() -> [String: String]
    {
        [
            "0": "aehiouwy",
            "1": "bfpv",
            "2": "cgjkqsxz",
            "3": "dt",
            "4": "l",
            "5": "mn",
            "6": "r"
        ]
    }
    
    // The digraph response indicates how to code the group.
    // The possibilities are single coding or skipping.
    func digraphResponses() -> [String: DigraphResponse]
    {
        [
            "gh": .remove            
        ]
    }
    
    func getSubcode(char: Character) -> String?
    {
        for (key, value) in singles() {
            if value.contains(char) {
                return key
            }
        }
        
        return nil
    }
    
    func getDigraphResponse(chars: String) -> DigraphResponse
    {
        for (key, value) in digraphResponses() {
            if key == chars {
                return value
            }
        }
        
        return .none
    }
    
    public
    func soundexEqual(
        _ lhs: String,
        _ rhs: String) -> Bool
    {
        soundexCode(source: keepCoded(input: lhs)) == soundexCode(source: keepCoded(input: rhs))
    }
    
    func emptySoundex() -> String
    {
        zerocode.padding(toLength: soundexCodeLength, withPad: zerocode, startingAt: 0)
    }

    /// Soundex encode a string. Nonzero coded characters get discarded.
    ///
    /// - parameter input: String for encoding.
    /// - returns: A Soundex code with the first letter followed by three coding group numbers.
    public
    func soundexCode(source: SoundexCodeReady) -> String
    {
        guard let first = source.first,
              let nonzeroCoded = source.nonzeroCoded,
              nonzeroCoded.count > 0 else { return emptySoundex() }

        var input = String(first)
        
        if nonzeroCoded[nonzeroCoded.index(nonzeroCoded.startIndex, offsetBy: 0)] == first {
            input += nonzeroCoded[nonzeroCoded.index(nonzeroCoded.startIndex, offsetBy: 1)..<nonzeroCoded.endIndex]
        } else {
            input += nonzeroCoded
        }
        
        guard input.count > 0 else { return emptySoundex() }
        
        let char = input[input.index(input.startIndex, offsetBy: 0)]
        var lastSubcode = getSubcode(char: char)
        // Overall code starts with first character:
        var code = String(first)
        let lastOffset = input.count - 1
        // Numeric subcodes start with the second character:
        var offset = 1
        var chars = ""

        while offset <= lastOffset {
            // Single handling:
            if offset <= lastOffset {
                let char = input[input.index(input.startIndex, offsetBy: offset)]
                if let singleSubcode = getSubcode(char: char) {
                    if lastSubcode != singleSubcode && singleSubcode != zerocode {
                        if code.count < soundexCodeLength {
                            chars += String(char)
                            code += singleSubcode
                            lastSubcode = singleSubcode
                        } else { break }
                    }
                }
            }
            offset += 1
        }
        
        return code
            .padding(toLength: soundexCodeLength, withPad: zerocode, startingAt: 0)
    }    
    
    /// Keep coded characters from an input to get it ready for Soundex coding.
    /// - parameters:
    ///   - input: String for examination.
    ///   - perform: Array of actions to perform.
    /// - returns: String with characters kept according to the code actions.
    func keepCoded(
        input: String,
        perform: [CodeReadyAction] = [.keepSingle, .removeDigraph]) -> SoundexCodeReady
    {
        guard input.count > 0 else { return SoundexCodeReady(first: nil, nonzeroCoded: nil) }
        
        let charAtOffset: (Int) -> Character = { input[input.index(input.startIndex, offsetBy: $0)] }
        
        let first = charAtOffset(0)
        let lastOffset = input.count - 1
        var offset = 0
        var newString = ""
                    
        while offset <= lastOffset {
            if perform.contains(.removeDigraph) {
                offset = digraphRemoveAtPosition(input: input, position: offset)
            }
            if perform.contains(.keepSingle) {
                if let char = keepSingleAtPosition(input: input, position: offset) {
                    newString += String(char)
                }
            } else {
                newString += String(charAtOffset(offset))
            }
            offset += 1
        }
        
        return SoundexCodeReady(first: first, nonzeroCoded: newString)
    }
    
    /// For a given position, if the character is coded then return the character.
    /// - parameters:
    ///   - input: String for examination.
    ///   - position: Position in string to examine.
    /// - returns: The character to keep or nil.
    func keepSingleAtPosition(
        input: String,
        position: CharacterPosition) -> Character?
    {
        let lastOffset = input.count - 1
        
        if position <= lastOffset {
            let char = input[input.index(input.startIndex, offsetBy: position)]
            if let singleSubcode = getSubcode(char: char) {
                if singleSubcode != zerocode {
                    return char
                }
            }
        }
        
        return nil
    }
    
    ///  If digraph removal should occur, then return the position that skips the digraph.
    /// - parameters:
    ///   - input: String for examination.
    ///   - position: Position in string to examine.
    /// - returns: The same character position or a new one if a digraph is removed.
    func digraphRemoveAtPosition(
        input: String,
        position: CharacterPosition) -> CharacterPosition
    {
        let digraphLength = 2
        var newOffset = position
        let charAtOffset: (Int) -> Character = { input[input.index(input.startIndex, offsetBy: $0)] }
        
        // Check if digraph handling fits within input:
        if position + (digraphLength - 1) <= input.count - 1 {
            let first = charAtOffset(position)
            let second = charAtOffset(position + 1)
            let digraph = String(first) + String(second)
            let digraphRemove = digraphRemoves[digraph]
            switch getDigraphResponse(chars: digraph) {
            case .remove:
                if !(position == 0 && (digraphRemove == .keepInitial)) {
                    newOffset = position + digraphLength
                }
            default:
                break
            }
        }
        
        return newOffset
    }
}
