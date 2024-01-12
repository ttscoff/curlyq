### 0.0.7

2024-01-12 17:03

#### FIXED

- Revert back to offering single response (no array) in cases where there are single results (for some commands)

### 0.0.6

2024-01-12 14:44

#### CHANGED

- Attributes array is now a hash directly keyed to the attribute key

#### NEW

- Tags command has option to output only raw html of matched tags

#### FIXED

- --query works with --search on scrape and tags command
- Json command dot query works now

### 0.0.5

2024-01-11 18:06

#### IMPROVED

- Add --query capabilities to images command
- Add --query to links command
- Allow hyphens in query syntax
- Allow any character other than comma, ampersand, or right square bracket in query value

#### FIXED

- Html --search returns a full Curl::Html object
- --query works better with --search and is consistent with other query functions
- Scrape command outputting malformed data
- Hash output when --query is used with scrape
- Nil match on tags command

### 0.0.4

2024-01-10 13:54

#### FIXED

- Queries combined with + or & not requiring all matches to be true

### 0.0.3

2024-01-10 13:38

#### IMPROVED

- Refactor Curl and Json libs to allow setting of options after creation of object
- Allow setting of headers on most subcommands
- --clean now affects source, head, and body keys of output
- Also remove tabs when cleaning whitespace

### 0.0.2

2024-01-10 09:18

### 0.0.1

2024-01-10 08:20

