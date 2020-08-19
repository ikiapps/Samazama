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

import NaturalLanguage

/// Enable tokenization of text.
public
protocol Tokenizable
{
    @available(iOS 11.0, macOS 10.13, *)
    func spacesRemoved(input: String) -> String
    
    @available(iOS 11.0, macOS 10.13, *)
    func punctuationRemoved(input: String) -> String
    
    @available(iOS 11.0, macOS 10.13, *)
    func omitForOptions(input: String,
                        taggerOptions: NSLinguisticTagger.Options) -> String
    
    @available(iOS 12.0, macOS 10.14, *)
    func tokenized(input: String) -> String
}

extension Tokenizable
{
    @available(iOS 11.0, macOS 10.13, *)
    public
    func spacesRemoved(input: String) -> String
    {
        omitForOptions(input: input, taggerOptions: [.omitWhitespace])
    }

    @available(iOS 11.0, macOS 10.13, *)
    public
    func punctuationRemoved(input: String) -> String
    {
        omitForOptions(input: input, taggerOptions: [.omitPunctuation])
    }

    /// - returns: Tokens concatenated.
    @available(iOS 11.0, macOS 10.13, *)
    public
    func omitForOptions(input: String,
                        taggerOptions: NSLinguisticTagger.Options) -> String
    {
        var removed = ""
        let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
        tagger.string = input
        let range = NSRange(location: 0, length: input.utf16.count)
        tagger.enumerateTags(in: range,
                             unit: .word,
                             scheme: .tokenType,
                             options: taggerOptions) { _, tokenRange, _ in
            let word = (input as NSString).substring(with: tokenRange)
            print(word)
            removed += word
        }
        if removed.count > 0 {
            return removed
        }
        
        return spacesRemoved(input: input)
    }

    /// On rare occasions, enumerateTokens was found to emit an empty string due to an inability to
    /// tokenize non-English text. A workaround exists here to return the original string in that case.
    ///
    /// - returns: Tokens concatenated.
    @available(iOS 12.0, macOS 10.14, *)
    public
    func tokenized(input: String) -> String
    {
        var removed = ""
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = input
        tokenizer.enumerateTokens(in: input.startIndex..<input.endIndex) { tokenRange, _ in
            removed += input[tokenRange]
            return true
        }
        if removed.count > 0 {
            return removed
        }
        
        return spacesRemoved(input: input)
    }
}
