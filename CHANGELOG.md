### 0.0.14

2024-10-25 10:26

#### FIXED

- Fix permissions

### 0.0.13

2024-10-25 10:23

#### FIXED

- Fix tests, handle empty results better

### 0.0.12

2024-04-04 13:06

#### NEW

- Add --script option to screenshot command
- Add `execute` command for executing JavaScript on a page

### 0.0.11

2024-01-21 15:29

#### IMPROVED

- Add option for --local_links_only to html and links command, only returning links with the same origin site

### 0.0.10

2024-01-17 13:50

#### IMPROVED

- Update YARD documentation
- Breaking change, ensure all return types are Arrays, even with single objects, to aid in scriptability
- Screenshot test suite

### 0.0.9

2024-01-16 12:38

#### IMPROVED

- You can now use dot syntax inside of a square bracket comparison in --query (`[attrs.id*=what]`)
- *=, ^=, $=, and == work with array values
- [] comparisons with no comparison, e.g. [attrs.id], will return every match that has that element populated

### 0.0.8

2024-01-15 16:45

#### IMPROVED

- Dot syntax query can now operate on a full array using empty set []
- Dot syntax query should output a specific key, e.g. attrs[id*=news].content (work in progress)
- Dot query syntax handling touch-ups. Piping to jq is still more flexible, but the basics are there.

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

