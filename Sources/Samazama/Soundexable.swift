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

public
protocol Soundexable
{
    func soundexEqual(_ first: String, _ second: String) -> Bool
    func encodeString(input: String) -> String
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
    func soundexEqual(_ first: String,
                      _ second: String) -> Bool
    {
        encodeString(input: first) == encodeString(input: second)
    }
    
    /// Soundex encode a string. Noncodable characters get discarded.
    /// 
    /// - parameter input: String for encoding.
    /// - returns: A Soundex code with the first letter followed three coding group numbers.
    public
    func encodeString(input: String) -> String
    {
        guard input.count > 0 else {
            return noncode
                .padding(toLength: soundexCodeLength, withPad: noncode, startingAt: 0)
        }
        let char = input[input.index(input.startIndex, offsetBy: 0)]
        var lastSubcode = getSubcode(char: char)
        // Code starts with first character:
        var code = String(char)
        let lastOffset = input.count - 1
        // Numeric subcodes start with the second character:
        var offset = 1
        var chars = ""

        while offset <= lastOffset {
            // Digraph handling:
            var doubleSubcode = noncode
            if let digraphSubcode = lastSubcode {
                (doubleSubcode, offset) = handleDigraph(input: input,
                                                        lastSubcode: digraphSubcode,
                                                        position: offset)
            }
            if doubleSubcode != lastSubcode && doubleSubcode != noncode && doubleSubcode != removeCode {
                code += doubleSubcode
            }
            
            // Single handling:
            if offset <= lastOffset {
                let char = input[input.index(input.startIndex, offsetBy: offset)]
                if let singleSubcode = getSubcode(char: char) {
                    if lastSubcode != singleSubcode && singleSubcode != noncode {
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
            .padding(toLength: soundexCodeLength, withPad: noncode, startingAt: 0)
    }

    /// Change previous subcode and string pointer based on digraph handling rules.
    /// * Subcode and position do not change if a digraph is not processed.
    /// * Changes happen when a digraph is matched:
    ///   - The subcode changes from the last subcode if a digraph is matched.
    ///   - The position advances so the digraph is not processed again.
    /// - parameters:
    ///   - input: A string, usually user input.
    ///   - lastSubcode: The last subcode is examined to prevent coding repetitive groups.
    ///   - position: The position pointer for examination within the input.
    /// - returns: (A new code, A new character position)
    func handleDigraph(input: String,
                       lastSubcode: Subcode,
                       position: CharacterPosition) -> (Subcode, CharacterPosition)
    {
        let digraphLength = 2
        var newSubcode = lastSubcode
        var newOffset = position
        let charAtOffset: (Int) -> Character = { input[input.index(input.startIndex, offsetBy: $0)] }
        
        // Check if digraph handling fits within input:
        if position + (digraphLength - 1) <= input.count - 1 {
            let first = charAtOffset(position)
            let second = charAtOffset(position + 1)
            let digraph = String(first) + String(second)
            let digraphRemove = digraphRemoves[digraph]
            switch getDigraphResponse(chars: digraph) {
            case .keepFirst:
                if let singleCode = getSubcode(char: first) {
                    if lastSubcode != singleCode {
                        newSubcode = singleCode
                    }
                    newOffset = position + digraphLength
                }
            case .keepSecond:
                if let singleCode = getSubcode(char: second) {
                    if lastSubcode != singleCode {
                        newSubcode = singleCode
                    }
                    newOffset = position + digraphLength
                }
            case .remove:
                if !(position == 0 && (digraphRemove == .keepInitial)) {
                    newSubcode = removeCode
                    newOffset = position + digraphLength
                }
            case .none:
                break
            }
        }
        
        return (newSubcode, newOffset)
    }
}
