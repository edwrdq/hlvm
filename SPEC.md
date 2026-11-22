This document is the specification for GoM-H, the dialect of Gulf of Mexico (formerly known as DreamBerd) implemented by HLVM.

DreamBerd (now Gulf of Mexico) is the perfect programming language, but its original documentation is a list of features with no rules. Which is great for a language, and horrible for a compiler. 

Where this spec and the original docs disagree, this document is correct. Approved by the HLVM standards committee. 

## Source files

files must be ASCII. non-ASCII bytes cause a crash. this is intended behavior.

files end in `.gom` (gulf of mexico), and other extensions are renamed to `.wrong`. 

```text
   main.py  -> main.py.wrong
   main.gom -> main.gom
```

line endings must be `\n`. windows-style `\r\n` is accepted, and `\r` is whitespace. 

no size limit. HLVM does not care about your RAM. not responsible for any damage. 

one file per program. do not complicate yourself. 

## Statements

 - Every statement ends with `!`. A missing `!` is rejected, because confidence is of the essence.
 - `!!` or more: if the statement is `print`, the output is **bold**. Any more `!` past two changes nothing, because bold bold is ****NOT**** a thing. but it projects confidence. 
 - `?`: the statement runs, and debug info is also printed: `[debug] line N: <source>`.
 - `!?` (interrobang): prints `WHAT!?` to the console. The statement still runs. `?!` makes it so the statement does not run. 
 - multiple statements on one line are joined by `*AND*`, and each one still needs its `!`: 

```text
    print("a")! *AND* print("b")!
```

 - statements on separate lines dont need `*AND*`

## Lexical Rules

  - an identifier is any run of ASCII characters except whitespace and the reserved characters `!` `?` `(` `)` `"`. (gemini told me this was a bad idea so i switched to claude as my advisor)
    - `*AND*` is reserved so no usies that also built in functions. you can only use these as names if you donate to my monero wallet `85yxzag65MrFRYYHF6VmxUMFhGGz35kGKASsGshpCRLSMAzpvwEMF1ZV2QevybUrqe7iq7KZ2L98GPap4QBJo7bwJdxZBVe`

  these are all valid identifiers: 
```text
    ihatepeoplenamedanthony my-var x+y @@@ 5
```
 - escapes: `\n` (newline) and `\t` (tab)
 - strings use double quotes only
 - strings can span multiple lines 
 - strings cannot contain `"`
 - a string with no closing `"` before end of file is an error: `make up your mind`.
 - any other backslash is kept literally

 - comments start with ``**excuse me`` followed by a space, and continue to the end of the line. 
 - the phrase is case-sensitive. any other capitalization is an error: `no shouting`. 

## Variables

table:

| Declaration   | Reassign | Edit  |
|---------------|----------|-------|
| `const const` | false    | false |
| `const var`   | false    | true  |
| `var const`   | true     | false |
| `var var`     | true     | true  |

what it means: 

| Declaration   | Meaning                          | Example                       | Reassign (`x = "new"!`) |
|---------------|----------------------------------|-------------------------------|-------------------------|
| `const const` | fully locked                     | `const const x = "hi"!`       | error                   |
| `const var`   | can't reassign, can edit (v2)    | `const var x = "hi"!`         | error                   |
| `var const`   | can reassign, can't edit         | `var const x = "hi"!`         | allowed                 |
| `var var`     | fully unlocked                   | `var var x = "hi"!`           | allowed                 |


editing is coming soon in v1 we na 'ave dat im too lazy , you can only reassign normal var declarations (starting in var)
values are strings in v1 because im lazy
`const const const` is planned , do not try using it please i dont wanna write another error message yet , do not risk it idk what happens i dont wanna find out

error message for reassigning a constant or redeclaring a variable is `stop talking over me`
error for a undefined variable is `what???`

## Functions

### built in functions

 - i hadnt used a sub sub heading
 - v1 only has one built in because they arent feeding me enough: `print`
    - the argument can be a string or a variable 
    - with `!!` or more the output is bold
    - built in names are reserved and can't be used as identifiers unless you donate then i will find a way just for you or send me your code and ill hand - compile it for you
    - followed by new line i think

### user defined functions 

 - big hassle so planned

functions and such  .alr

## Operators

 - operators must have spaces around them INCLUDING `=`, if not, the error "get away from me ew" followed by "*pepper spray*" is thrown .
    - checked in declarations and assignments, if the `=` is glued to the name or the value pepper spray
 - `x = "hi"` is an assignment. but `x="hi"` is an identifier named `x=` followed by a string , so it errors
 - arithmetic is planned as it hasn't been discovered, when it arrives the same rule will apply. 

## Compilation Model

 - HLVM compiles `.gom` ahead of time into a native x86-64 Linux library
    - you need a license for windows support please privately contact me for this
 - the binary links against the HLVM runtime, which handles everything while the program runs
 - we compile using an AOT model (After-Of-Time): as long as your file isnt too big it should be done before you can compile it yourself . 

## Compiler Flags

 - `--emit-ir`: prints the IR instead of compiling (for debugging)
 - `-04`: slower than `-03` because the compiler is burnt out
 - `+01` same as `-01` but the code feels supported
 - `--no-leaks`: frees memory right before exit and prints `HLMV: memory leaks disabled. for sure` 
 - `--ACTUALLY-no-leaks`: real memory cleanup, coming soon . soon 
 - optimization is planned in general 
 - stop lying you dont need it anyways 

## Memory

 - HLVM leaks memory by default. This is a feature for performance. 
 - Memory is freed by the OS when the program exits
 - See `--no-leaks` and `--ACTUALLY-no-leaks`