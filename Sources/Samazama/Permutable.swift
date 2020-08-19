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

public
protocol Permutable: TextProcessable
{
    // Intentionally empty.
}

extension Permutable
{
    /// 1. Generate unique variants of a string where repeated characters get successively removed one
    /// at a time such that at least one occurrence remains in the string. This method preserves the
    /// order of the remaining characters.
    ///
    /// 2. Recursively generate the same results for each lesser string by performing (1) until no
    /// more repeating characters exist.
    ///
    /// For example, "carry pizza over" contains two repeated letters resulting in a set of ten unique,
    /// ordered arrangements after the above process is run:
    ///
    /// ["crpzv", "cpzvr", "crrpzv", "crpzvr", "crpzzv", "cpzzvr", "crrpzvr", "crrpzzv", "crpzzvr", "crrpzzvr"]
    ///
    /// These variants allow matching any of the shorter input sequences to the original term and save
    /// keystrokes.
    ///
    /// - parameter input: String containing input to be processed.
    /// - returns: An array of permutations.
    func makeRepeatCharacterVariants(input: String) throws -> Permutations
    {
        var result = [input]
        let repeated = uniqueCharacters(input: input)

        if repeated.count < 1 {
            return result
        }
        
        var recursionLevel = 0
        
        for rpt in repeated {
            var offset = 0
            for chr in input {
                // Recursively remove repeated characters for each position they appear.
                if chr == rpt {
                    recursionLevel += 1
                    if recursionLevel > maxRecursionLevel { throw SamazamaError.exceededRecursionLevel }
                    let rmv = characterRemove(input: input, atOffset: offset)
                    result.append(rmv)
                    result.append(contentsOf: try makeRepeatCharacterVariants(input: rmv))
                }
                offset += 1
            }
        }
        
        return finalizeResult(permutations: result)
    }
}
