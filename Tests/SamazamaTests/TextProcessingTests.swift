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

struct DigraphTestSource
{
    var word: String
    var expected: String
}

private
var digraphSource = [
    DigraphTestSource(word: "night", expected: "nit"),
    DigraphTestSource(word: "ghost", expected: "ghost"),
    DigraphTestSource(word: "dining hall", expected: "dining hall"),
    DigraphTestSource(word: "dininghall", expected: "dininall"),
]

final
class TextProcessingTests: XCTestCase
{
    let timeout: TimeInterval = 5
    var smzm: Samazama!
    
    static var allTests = [
        ("test_remove_digraph", test_remove_digraph)
    ]
    
    override
    func setUp()
    {
        smzm = Samazama()
    }
    
    /// Vowels not removed.
    func test_remove_digraph()
    {
        for source in digraphSource {
            let newSource = smzm.removeDigraphs(input: source.word)
            XCTAssert(newSource == source.expected, "❌ Result \(newSource ) is not \(source.expected)")
        }
    }
}
