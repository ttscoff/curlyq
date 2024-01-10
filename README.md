# CurlyQ

[![Gem](https://img.shields.io/gem/v/na.svg)](https://rubygems.org/gems/curlyq)
[![GitHub license](https://img.shields.io/github/license/ttscoff/curlyq.svg)](./LICENSE.txt)

**A command line helper for curl and web scraping**

_If you find this useful, feel free to [buy me some coffee][donate]._

[donate]: https://brettterpstra.com/donate


The current version of `curlyq` is 0.0.3
.

CurlyQ is a utility that provides a simple interface for curl, with additional features for things like extracting images and links, finding elements by CSS selector or XPath, getting detailed header info, and more. It's designed to be part of a scripting pipeline, outputting everything as structured data (JSON or YAML). It also has rudimentary support for making calls to JSON endpoints easier, but it's expected that you'll use something like `jq` to parse the output.

[github]: https://github.com/ttscoff/curlyq/

### Installation

Assuming you have Ruby and RubyGems installed, you can just run `gem install curlyq`. If you run into errors, try `gem install --user-install curlyq`, or use `sudo gem install curlyq`.

If you're using Homebrew, you have the option to install via [brew-gem](https://github.com/sportngin/brew-gem):

    brew install brew-gem
    brew gem install curlyq

If you don't have Ruby/RubyGems, you can install them pretty easily with [Homebrew], [rvm], or [asdf].

[Homebrew]: https://brew.sh/ "Homebrew???The Missing Package Manager for macOS (or Linux)"
[rvm]: https://rvm.io/ "Ruby Version Manager (RVM)"
[asdf]: https://github.com/asdf-vm/asdf "asdf-vm/asdf:Extendable version manager with support for ..."

### Usage

Run `curlyq help` for a list of subcommands. Run `curlyq help SUBCOMMAND` for details on a particular subcommand and its options.

```
NAME
    curlyq - A scriptable interface to curl

SYNOPSIS
    curlyq [global options] command [command options] [arguments...]

VERSION
    0.0.3

GLOBAL OPTIONS
    --help          - Show this message
    --[no-]pretty   - Output "pretty" JSON (default: enabled)
    --version       - Display the program version
    -y, --[no-]yaml - Output YAML instead of json

COMMANDS
    extract    - Extract contents between two regular expressions
    headlinks  - Return all <head> links on URL's page
    help       - Shows a list of commands or help for one command
    html, curl - Curl URL and output its elements, multiple URLs allowed
    images     - Extract all images from a URL
    json       - Get a JSON response from a URL, multiple URLs allowed
    links      - Return all links on a URL's page
    scrape     - Scrape a page using a web browser, for dynamic (JS) pages. Be sure to have the selected --browser installed.
    screenshot - Save a screenshot of a URL
    tags       - Extract all instances of a tag
```

#### Commands

curlyq makes use of subcommands, e.g. `curlyq html [options] URL` or `curlyq extract [options] URL`. Each subcommand takes its own options, but I've made an effort to standardize the choices between each command as much as possible.

##### extract

```
NAME
    extract - Extract contents between two regular expressions

SYNOPSIS

    curlyq [global options] extract [command options] URL...

COMMAND OPTIONS
    -a, --after=arg       - Text after extraction, parsed as regex (default: none)
    -b, --before=arg      - Text before extraction, parsed as regex (default: none)
    -c, --[no-]compressed - Expect compressed results
    --[no-]clean          - Remove extra whitespace from results
    -h, --header=arg      - Define a header to send as key=value (may be used more than once, default: none)
    --[no-]strip          - Strip HTML tags from results
```


##### headlinks

```
NAME
    headlinks - Return all <head> links on URL's page

SYNOPSIS

    curlyq [global options] headlinks [command options] URL...

COMMAND OPTIONS
    -q, --query, --filter=arg - Filter output using dot-syntax path (default: none)
```

##### html

```
NAME
    html - Curl URL and output its elements, multiple URLs allowed

SYNOPSIS

    curlyq [global options] html [command options] URL...

COMMAND OPTIONS
    -I, --info                - Only retrieve headers/info
    -b, --browser=arg         - Use a browser to retrieve a dynamic web page (firefox, chrome) (default: none)
    -c, --compressed          - Expect compressed results
    --[no-]clean              - Remove extra whitespace from results
    -f, --fallback=arg        - If curl doesn't work, use a fallback browser (firefox, chrome) (default: none)
    -h, --header=arg          - Define a header to send as "key=value" (may be used more than once, default: none)
    --[no-]ignore_fragments   - Ignore fragment hrefs when gathering content links
    --[no-]ignore_relative    - Ignore relative hrefs when gathering content links
    -q, --query, --filter=arg - Filter output using dot-syntax path (default: none)
    -r, --raw=arg             - Output a raw value for a key (default: none)
    --search=arg              - Regurn an array of matches to a CSS or XPath query (default: none)
    -x, --external_links_only - Only gather external links
```

##### images

```
NAME
    images - Extract all images from a URL

SYNOPSIS

    curlyq [global options] images [command options] URL...

COMMAND OPTIONS
    -c, --[no-]compressed - Expect compressed results
    --[no-]clean          - Remove extra whitespace from results
    -h, --header=arg      - Define a header to send as key=value (may be used more than once, default: none)
    -t, --type=arg        - Type of images to return (img, srcset, opengraph, all) (may be used more than once, default: ["all"])
```

##### json

```
NAME
    json - Get a JSON response from a URL, multiple URLs allowed

SYNOPSIS

    curlyq [global options] json [command options] URL...

COMMAND OPTIONS
    -c, --[no-]compressed     - Expect compressed results
    -h, --header=arg          - Define a header to send as key=value (may be used more than once, default: none)
    -q, --query, --filter=arg - Filter output using dot-syntax path (default: none)
```

##### links

```
NAME
    links - Return all links on a URL's page

SYNOPSIS

    curlyq [global options] links [command options] URL...

COMMAND OPTIONS
    -d, --[no-]dedup          - Filter out duplicate links, preserving only first one
    --[no-]ignore_fragments   - Ignore fragment hrefs when gathering content links
    --[no-]ignore_relative    - Ignore relative hrefs when gathering content links
    -q, --query, --filter=arg - Filter output using dot-syntax path (default: none)
    -x, --external_links_only - Only gather external links
```

##### scrape

```
NAME
    scrape - Scrape a page using a web browser, for dynamic (JS) pages. Be sure to have the selected --browser installed.

SYNOPSIS

    curlyq [global options] scrape [command options] URL...

COMMAND OPTIONS
    -b, --browser=arg         - Browser to use (firefox, chrome) (default: none)
    --[no-]clean              - Remove extra whitespace from results
    -h, --header=arg          - Define a header to send as "key=value" (may be used more than once, default: none)
    -q, --query, --filter=arg - Filter output using dot-syntax path (default: none)
    -r, --raw=arg             - Output a raw value for a key (default: none)
    --search=arg              - Regurn an array of matches to a CSS or XPath query (default: none)
```

##### screenshot

Full-page screenshots require Firefox, installed and specified with `--browser firefox`.

```
NAME
    screenshot - Save a screenshot of a URL

SYNOPSIS

    curlyq [global options] screenshot [command options] URL...

COMMAND OPTIONS
    -b, --browser=arg     - Browser to use (firefox, chrome) (default: chrome)
    -h, --header=arg      - Define a header to send as key=value (may be used more than once, default: none)
    -o, --out, --file=arg - File destination (default: none)
    -t, --type=arg        - Type of screenshot to save (full (requires firefox), print, visible) (default: full)
```

##### tags

```
NAME
    tags - Extract all instances of a tag

SYNOPSIS

    curlyq [global options] tags [command options] URL...

COMMAND OPTIONS
    -c, --[no-]compressed     - Expect compressed results
    --[no-]clean              - Remove extra whitespace from results
    -h, --header=arg          - Define a header to send as key=value (may be used more than once, default: none)
    -q, --query, --search=arg - CSS/XPath query (default: none)
    -t, --tag=arg             - Specify a tag to collect (may be used more than once, default: none)
```


PayPal link: [paypal.me/ttscoff](https://paypal.me/ttscoff)

## Changelog

See [CHANGELOG.md](https://github.com/ttscoff/curlyq/blob/main/CHANGELOG.md)
