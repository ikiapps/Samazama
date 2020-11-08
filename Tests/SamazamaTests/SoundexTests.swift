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

@testable import Samazama

import XCTest

struct WordSource
{
    var word: String
    var code: String
}

struct CompareSource
{
    var word1: String
    var word2: String
}

private
var testWordCodes = [
    WordSource(word: "autumn", code: "a350"),
    WordSource(word: "blackjack", code: "b420"),
    WordSource(word: "mountain", code: "m350"),
    WordSource(word: "night", code: "n300"),
    WordSource(word: "to be enough", code: "t150"),
]

var digraphCompare = [
    CompareSource(word1: "dining hall", word2: "dnngll"),
    CompareSource(word1: "night", word2: "nt"),
    CompareSource(word1: "neighborhood", word2: "nbrd"),
]

final
class SoundexTests: XCTestCase
{
    let timeout: TimeInterval = 5
    var smzm: Samazama!
    
    static var allTests = [
        ("test_empty", test_empty),
        ("test_soundex_coding", test_soundex_coding),
        ("test_digraph_removes", test_digraph_removes),
    ]
    
    override
    func setUp()
    {
        smzm = Samazama()
    }
    
    func test_empty()
    {
        XCTAssert(smzm.soundexEqual("", "0000"), "❌ Failed on empty string.")
    }
    
    func test_soundex_coding()
    {
        for src in testWordCodes {
            let readyToCode = smzm.keepCoded(input: src.word)
            let code = smzm.soundexCode(source: readyToCode)
            XCTAssert(code == src.code, "❌ Bad code of \(code) for \"\(src.word)\", expected \(src.code).")
        }
    }
    
    func test_digraph_removes()
    {
        for source in digraphCompare {
            let kept = smzm.keepCoded(input: source.word1)
            XCTAssert(kept.nonzeroCoded == source.word2, "❌ Bad digraph handling for \(kept.nonzeroCoded as String?)")
        }
    }
}
