# Samazama

A small package in Swift to assist with minimizing words and phrases using the following methods:

- Soundex coding - Group together similar sounds in English
- Permutation generation - Reorder terms while minimizing repeating characters

It can dramatically save user's keystrokes by allowing shorthand input for comparison against full-length words and phrases.

##  Features

- Remove noncoded characters from input, including vowels, 'h', 'w', 'y', spaces, and punctuation.
  - In brief, the first letter is kept and similar sounding letters are grouped together forming a code such as 'A235' for 'astounding'.
  - This method is based on a well-known algorithm for coding English sounds. It reduces repeating characters but does not handle changes in order. The permutation method supplies that ability.
- Generate permutations where repeating characters only appear once to allow matching various orderings.
  - For example, 'stnm' or 'tnsm' or 'nsmt' all match 'astonishment'.
  - Supports main thread or background queue operation.
  - Prevents excessive levels of recursion.
    - Operations can exceed 360,000 at a recursion depth of _N_ = 9 where the operation count is approximately _N!._

## Applications

My jumping into learning Japanese inspired this project. Little did I know how many reviews of kanji and vocabulary it takes to gain an entry point into the language. Thousands later, I am doing everything possible to optimize my study because progress is otherwise dampened.

Using shorthand in quizzes where English is needed substantially reduces individual keystrokes and time to enter them. Immediately, dropping all vowels plus 'h,' 'w,' and 'y' is a 30% savings over the alphabet. Further removal of repeating characters and spaces yields additional efficiency.

Instead of typing "carry pizza over," the shorthand form "crpzv" can match a predefined phrase unambiguously. As long as the relative order is maintained, the rearrangement of letters is also allowed. For example, "cpzvr" skips the 'r's in 'carry' and uses the one from 'over.'

Omitting characters in the same coding group is also possible. For "blackjack," the shorthand of "blkj" is acceptable due to the Soundex algorithm where the code is 'B420.'

### Special cases

During input, silent 'gh' digraphs can feel cumbersome. Therefore, Samazama removes all non-initial occurrences. This handling requires preventing removal in such terms as "dining hall."

### Future directions

- Functionality is primarily oriented around my use of language learning but expanding this project is not out of the question. Pull requests are welcome.
- Reducing the possibility of overlap in coded forms.
  - For example, "Lack" and "Luck" have the same code of "L200." Future versions may differentiate such terms.

## Usage

The following function checks user input against a set of answers.
```swift
    import Samazama

    func answerMatches(input: String) throws -> Bool 
    {
        let smzm = Samazama()                
        let userVariants = try smzm.repeatCharacterVariants(input: input)
        
        // Match user input against one or more answers:
        for answer in answers {                        
            let answerVariants = try smzm.repeatCharacterVariants(input: answer)
            
            // Compare Soundex:                            
            if smzm.soundexEqual(answer, input) { return true }

            // Compare permutations:
            for userVariant in userVariants { 
                for answerVariant in answerVariants {
                    if userVariant == answerVariant { return true }
                }
            }
        }
        return false     
    }   
 ```

## More on Soundex

The Soundex algorithm contains the following additions:

- Remove non-initial 'gh' as they are often silent.

There are probably more exceptions to handle.

## More on permutations

Given the source phrase "carry pizza over," generate all of the minimal forms in the following set:

```
{ 
    "crpzv",    "cpzvr", 
   "crpzvr",   "cpzzvr",
   "crpzzv",   "crrpzv",
  "crrpzvr",  "crpzzvr", 
  "crrpzzv", "crrpzzvr" 
} 
```

A user can enter any of the reduced forms to match the source string successfully. This shorthand allowance significantly reduces input requirements for comparing against fixed sources.

The minimal, or shortest, forms are generated along with all intermediate variants, using only characters in the coding set.

Recursion levels get determined by the number of repeating characters. For example, '00001111' gives eight due to four repeating characters of '0' and four of '1'. Generating all variants for eight levels takes approximately 40 K operations using recursive loops.