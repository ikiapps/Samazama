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

/// Source for testing including definition of
/// - source: A string representing a word or phrase
/// - variantCount: total number of variants possible for the source
/// - uniqueCount: number of unique members possible for the variants.
private
struct VariantSource
{
    var source: String
    var variantCount: Int
    var uniqueCount: Int
}

private
var testSources = [
    VariantSource(source: "Fault", variantCount: 1, uniqueCount: 1),
    VariantSource(source: "astonishment", variantCount: 157, uniqueCount: 26),
    VariantSource(source: "carry pizza over", variantCount: 119, uniqueCount: 10),
    VariantSource(source: "dining hall", variantCount: 25, uniqueCount: 4),
    VariantSource(source: "dnghl", variantCount: 1, uniqueCount: 1),
    VariantSource(source: "paragraph", variantCount: 25, uniqueCount: 9),
    VariantSource(source: "unintentionally", variantCount: 6409, uniqueCount: 42),
]

final
class SamazamaTests: XCTestCase
{
    let timeout: TimeInterval = 5
    var smzm: Samazama!
    var testDeinit = false
    
    // For SwiftPM:
    static var allTests = [
        ("test_variant_sources", test_variant_sources),
        ("test_variant_sources_async", test_variant_sources_async),
        ("test_remove_repeating_characters", test_remove_repeating_characters),
        ("test_exceed_max_recursion", test_exceed_max_recursion),
        ("test_deinit_during_async_generate", test_deinit_during_async_generate),
    ]

    override
    func setUp()
    {
        super.setUp()
        smzm = Samazama()
    }

    /// Used to get variants for a VariantSource.
    ///
    /// - returns: All variants and a set of unique members for them.
    private
    func variants(source: String) throws -> (Permutations, Set<Permutation>)
    {
        let variants = try smzm.repeatCharacterVariants(input: source, onlyUnique: false)
        return (variants, smzm.uniqueStrings(strings: variants))
    }

    /// Used to get variants for a VariantSource.
    ///
    /// - parameters:
    ///   - source: A string.
    ///   - completion: Result of permutations and unique permutations.
    private
    func asyncVariants(
        source: String,
        completion: @escaping (Result<(Permutations, Set<Permutation>), Error>) -> Void)
    {
        smzm.generateVariants(input: source, onlyUnique: false) { result in
            if self.smzm == nil {
                self.smzm = Samazama()
            }
            switch result {
            case .success(let permutations):
                completion(.success((permutations, self.smzm.uniqueStrings(strings: permutations))))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    // MARK: - Tests -
    
    func test_variant_sources() throws
    {
        for src in testSources {
            print("🏁 src \(src)")
            let vars = try variants(source: src.source)
            print("🧮 total_cnt = \(vars.0.count), unique_cnt = \(vars.1.count), sorted = \(vars.1.sorted())")
            XCTAssert(vars.0.count == src.variantCount, "❌ Wrong number of total variants at \(vars.0.count) for \(src).")
            XCTAssert(vars.1.count == src.uniqueCount, "❌ Wrong number of unique variants at \(vars.1.count) for \(src).")
        }
    }
    
    func test_variant_sources_async()
    {
        let expect = expectation(description: #function)
        var cnt = 0
        for src in testSources {
            asyncVariants(source: src.source) { result in
                switch result {
                case .success(let (permutations, unique)):
                    XCTAssert(permutations.count == src.variantCount, "❌ Wrong number of total variants at \(permutations.count) for \(src).")
                    XCTAssert(unique.count == src.uniqueCount, "❌ Wrong number of unique variants at \(unique.count) for \(src).")
                case .failure(let err):
                    XCTFail("❌ \(err.localizedDescription)")
                }
                cnt += 1
                if cnt >= testSources.count {
                    expect.fulfill()
                }
            }
        }
        if testDeinit {
            smzm = nil
        }
        wait(for: [expect], timeout: timeout)
    }
    
    /// Remove repeats prior to generating variants to not overrun computational limits.
    func test_remove_repeating_characters() throws
    {
        let source = "0001111000"
        var transformed = source
        let smzm = Samazama()
        let removeCount = 2
        transformed = smzm.removeRepeats(input: source, removeAtMost: removeCount)
        let variants = try smzm.makeRepeatCharacterVariants(input: transformed)
        let unique = smzm.uniqueStrings(strings: variants)
        XCTAssert(variants.count == 645, "Wrong number of total variants at \(variants.count).")
        XCTAssert(unique.count == 14, "Wrong number of unique variants at \(variants.count).")
    }

    /// Sum of the repeated characters give the number of recursion levels.
    /// For example, "0011", has two zeros and two ones. Therefore, the number of recursion levels is four.
    func test_exceed_max_recursion()
    {
        let source = "0001111000"
        // Count recursion levels in the source:
        let countSource = smzm.repeatCharacterCounts(input: source)
        let totalRepeats = countSource.reduce(0) { acc, source in
            return acc + source.value
        }
        XCTAssert(totalRepeats == source.count, "❌ Wrong number of repeats.")
        let uniqueCharacters = smzm.uniqueCharacters(input: source)
        XCTAssert(uniqueCharacters.count == 2, "❌ Wrong number of unique characters.")
        do {
            _ = try smzm.repeatCharacterVariants(input: source)
        } catch let err { XCTAssert(err as? SamazamaError == SamazamaError.exceededRecursionLevel, "❌ Wrong error of \(err).") }
    }
    
    /// Variant generation should complete even if Samazama is set nil.
    func test_deinit_during_async_generate()
    {
        testDeinit = true
        test_variant_sources_async()
    }
}
