# CurlyQ

[![Gem](https://img.shields.io/gem/v/na.svg)](https://rubygems.org/gems/curlyq)
[![GitHub license](https://img.shields.io/github/license/ttscoff/curlyq.svg)](./LICENSE.txt)

**A command line helper for curl and web scraping**

_If you find this useful, feel free to [buy me some coffee][donate]._

[donate]: https://brettterpstra.com/donate


The current version of `curlyq` is 0.0.7
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
    0.0.7

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

### Query and Search syntax

You can shape the results using `--search` (`-s`) and `--query` (`-q`) on some commands.

A search uses either CSS or XPath syntax to locate elements. For example, if you wanted to locate all of the `<article>` elements with a class of `post` inside of the div with an id of `main`, you would run `--search '#main article.post'`. Searches can target tags, ids, and classes, and can accept `>` to target direct descendents. You can also use XPaths, but I hate those so I'm not going to document them.

Queries are specifically for shaping CurlyQ output. If you're using the `html` command, it returns a key called `images`, so you can target just the images in the response with `-q 'images'`. The queries accept array syntax, so to get the first image, you would use `-q 'images[0]'`. Ranges are accepted as well, so `-q 'images[1..4]'` will return the 2nd through 5th images found on the page. You can also do comparisons, e.g. `images[rel=me]'` to target only images with a `rel` attribute of `me`.

The comparisons for the query flag are:

- `<` less than
- `>` greater than
- `<=` less than or equal to
- `>=` greater than or equal to
- `=` or `==` is equal to
- `*=` contains text
- `^=` starts with text
- `$=` ends with text

#### Commands

curlyq makes use of subcommands, e.g. `curlyq html [options] URL` or `curlyq extract [options] URL`. Each subcommand takes its own options, but I've made an effort to standardize the choices between each command as much as possible.

##### extract

Example: 

    curlyq extract -i -b 'Adding' -a 'accessing the source.' 'https://stackoverflow.com/questions/52428409/get-fully-rendered-html-using-selenium-webdriver-and-python'

    [
      "Adding <code>time.sleep(10)</code> in various places in case the page had not fully loaded when I was accessing the source."
    ]

This specifies a before and after string and includes them (`-i`) in the result.

```
NAME
    extract - Extract contents between two regular expressions

SYNOPSIS

    curlyq [global options] extract [command options] URL...

COMMAND OPTIONS
    -a, --after=arg       - Text after extraction (default: none)
    -b, --before=arg      - Text before extraction (default: none)
    -c, --[no-]compressed - Expect compressed results
    --[no-]clean          - Remove extra whitespace from results
    -h, --header=arg      - Define a header to send as key=value (may be used more than once, default: none)
    -i, --[no-]include    - Include the before/after matches in the result
    -r, --[no-]regex      - Process before/after strings as regular expressions
    --[no-]strip          - Strip HTML tags from results
```


##### headlinks

Example:

    curlyq headlinks -q '[rel=stylesheet]' https://brettterpstra.com

    {
      "rel": "stylesheet",
      "href": "https://cdn3.brettterpstra.com/stylesheets/screen.7261.css",
      "type": "text/css",
      "title": null
    }

This pulls all `<links>` from the `<head>` of the page, and uses a query `-q` to only show links with `rel="stylesheet"`.

```
NAME
    headlinks - Return all <head> links on URL's page

SYNOPSIS

    curlyq [global options] headlinks [command options] URL...

COMMAND OPTIONS
    -q, --query, --filter=arg - Filter output using dot-syntax path (default: none)
```

##### html

The html command (aliased as `curl`) gets the entire text of the web page and provides a JSON response with a breakdown of:

- URL, after any redirects
- Response code
- Response headers as a keyed hash
- Meta elements for the page as a keyed hash
- All meta links in the head as an array of objects containing (as available): 
    - rel
    - href
    - type
    - title
- source of `<head>`
- source of `<body>`
- the page title (determined first by og:title, then by a title tag)
- description (using og:description first)
- All links on the page as an array of objects with: 
    - href
    - title
    - rel
    - text content
    - classes as array
- All images on the page as an array of objects containing:
    - class
    - all attributes as key/value pairs
    - width and height (if specified)
    - src
    - alt and title

You can add a query (`-q`) to only get the information needed, e.g. `-q images[width>600]`.

Example:

    curlyq html -s '#main article .aligncenter' -q 'images[1]' 'https://brettterpstra.com'

    [
      {
        "class": "aligncenter",
        "original": "https://cdn3.brettterpstra.com/uploads/2023/09/giveaway-keyboardmaestro2024-rb_tw.jpg",
        "at2x": "https://cdn3.brettterpstra.com/uploads/2023/09/giveaway-keyboardmaestro2024-rb@2x.jpg",
        "width": "800",
        "height": "226",
        "src": "https://cdn3.brettterpstra.com/uploads/2023/09/giveaway-keyboardmaestro2024-rb.jpg",
        "alt": "Giveaway Robot with Keyboard Maestro icon",
        "title": "Giveaway Robot with Keyboard Maestro icon"
      }
    ]

The above example queries the full html of the page, but narrows the elements using `--search` and then takes the 2nd image from the results.

    curlyq html -q 'meta.title'  https://brettterpstra.com/2024/01/10/introducing-curlyq-a-pipeline-oriented-curl-helper/

    Introducing CurlyQ, a pipeline-oriented curl helper - BrettTerpstra.com

The above example curls the page and returns the title attribute found in the meta (`-q 'meta.title'`).

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
    -s, --search=arg          - Regurn an array of matches to a CSS or XPath query (default: none)
    -x, --external_links_only - Only gather external links
```

##### images

The images command returns only the images on the page as an array of objects. It can be queried to match certain requirements (see Query and Search syntax above).

The base command will return all images on the page, including OpenGraph images from the head, `<img>` tags from the body, and `<srcset>` tags along with their child images.

OpenGraph images will be returned with the structure:

    {
        "type": "opengraph",
        "attrs": null,
        "src": "https://cdn3.brettterpstra.com/uploads/2024/01/curlyq_header-rb_tw.jpg"
      }

`img` tags will be returned with the structure:

    {
        "type": "img",
        "src": "https://cdn3.brettterpstra.com/uploads/2024/01/curlyq_header-rb.jpg",
        "width": "800",
        "height": "226",
        "alt": "Banner image for CurlyQ",
        "title": "CurlyQ, curl better",
        "attrs": [
          {
            "class": [
              "aligncenter"
             ], // all attributes included
          }
        ]
      }



`srcset` images will be returned with the structure:

    {
        "type": "srcset",
            "attrs": [
              {
                "key": "srcset",
                "value": "https://cdn3.brettterpstra.com/uploads/2024/01/curlyq_header-rb_tw.jpg 1x, https://cdn3.brettterpstra.com/uploads/2024/01/curlyq_header-rb@2x.jpg 2x"
              }
            ],
            "images": [
              {
                "src": "https://cdn3.brettterpstra.com/uploads/2024/01/curlyq_header-rb_tw.jpg",
                "media": "1x"
              },
              {
                "src": "https://cdn3.brettterpstra.com/uploads/2024/01/curlyq_header-rb@2x.jpg",
                "media": "2x"
              }
          ]
        }
    }

Example:

    curlyq images -t img -q '[alt$=screenshot]' https://brettterpstra.com

This will return an array of images that are `<img>` tags, and only show the ones that have an `alt` attribute that ends with `screenshot`.

    curlyq images -q '[width>750]' https://brettterpstra.com

This example will only return images that have a width greater than 750 pixels. This query depends on the images having proper `width` attributes set on them in the source.

```
NAME
    images - Extract all images from a URL

SYNOPSIS

    curlyq [global options] images [command options] URL...

COMMAND OPTIONS
    -c, --[no-]compressed     - Expect compressed results
    --[no-]clean              - Remove extra whitespace from results
    -h, --header=arg          - Define a header to send as key=value (may be used more than once, default: none)
    -q, --query, --filter=arg - Filter output using dot-syntax path (default: none)
    -t, --type=arg            - Type of images to return (img, srcset, opengraph, all) (may be used more than once, default: ["all"])
```

##### json

The `json` command just returns an object with header/response info, and the contents of the JSON response after it's been read by the Ruby JSON library and output. If there are fetching or parsing errors it will fail gracefully with an error code.

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

Returns all the links on the page, which can be queried on any attribute.

Example:

    curlyq links -q '[content*=twitter]' 'https://stackoverflow.com/questions/52428409/get-fully-rendered-html-using-selenium-webdriver-and-python'

    [
      {
        "href": "https://twitter.com/stackoverflow",
        "title": null,
        "rel": null,
        "content": "Twitter",
        "class": [
          "-link",
          "js-gps-track"
        ]
      }
    ]

This example gets all links from the page but only returns ones with link content containing 'twitter' (`-q '[content*=twitter]'`).

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

Loads the page in a web browser, allowing scraping of dynamically loaded pages that return nothing but scripts when `curl`ed. The `-b` (`--browser`) option is required and should be 'chrome' or 'firefox' (or just 'c' or 'f'). The selected browser must be installed on your system.

Example:

    curlyq scrape -b firefox -q 'links[rel=me&content*=mastodon][0]' https://brettterpstra.com/2024/01/10/introducing-curlyq-a-pipeline-oriented-curl-helper/

    {
      "href": "https://nojack.easydns.ca/@ttscoff",
      "title": null,
      "rel": [
        "me"
      ],
      "content": "Mastodon",
      "class": [
        "u-url"
      ]
    }

This example scrapes the page using firefox and finds the first link with a rel of 'me' and text containing 'mastodon'.

```
NAME
    scrape - Scrape a page using a web browser, for dynamic (JS) pages. Be sure to have the selected --browser installed.

SYNOPSIS

    curlyq [global options] scrape [command options] URL...

COMMAND OPTIONS
    -b, --browser=arg         - Browser to use (firefox, chrome) (required, default: none)
    --[no-]clean              - Remove extra whitespace from results
    -h, --header=arg          - Define a header to send as "key=value" (may be used more than once, default: none)
    -q, --query, --filter=arg - Filter output using dot-syntax path (default: none)
    -r, --raw=arg             - Output a raw value for a key (default: none)
    --search=arg              - Regurn an array of matches to a CSS or XPath query (default: none)
```

##### screenshot

Full-page screenshots require Firefox, installed and specified with `--browser firefox`.

Type defaults to `full`, but will only work if `-b` is Firefox. If you want to use Chrome, you must specify a `--type` as 'visible' or 'print'.

The `-o` (`--output`) flag is required. It should be a path to a target PNG file (or PDF for `-t print` output). Extension will be modified automatically, all you need is the base name.

Example:

    curlyq screenshot -b f -o ~/Desktop/test https://brettterpstra.com/2024/01/10/introducing-curlyq-a-pipeline-oriented-curl-helper/

    Screenshot saved to /Users/ttscoff/Desktop/test.png


```
NAME
    screenshot - Save a screenshot of a URL

SYNOPSIS

    curlyq [global options] screenshot [command options] URL...

COMMAND OPTIONS
    -b, --browser=arg     - Browser to use (firefox, chrome) (default: chrome)
    -h, --header=arg      - Define a header to send as key=value (may be used more than once, default: none)
    -o, --out, --file=arg - File destination (required, default: none)
    -t, --type=arg        - Type of screenshot to save (full (requires firefox), print, visible) (default: visible)
```

##### tags

Return a hierarchy of all tags in a page. Use `-t` to limit to a specific tag.

    curlyq tags --search '#main .post h3' -q 'attrs[id*=what]' https://brettterpstra.com/2024/01/10/introducing-curlyq-a-pipeline-oriented-curl-helper/

    [
      {
        "tag": "h3",
        "source": "<h3 id=\"whats-next\">What???s Next</h3>",
        "attrs": [
          {
            "id": "whats-next"
          }
        ],
        "content": "What???s Next",
        "tags": [

        ]
      }
    ]

The above command filters the tags based on a CSS query, then further filters them to just tags with an id containing 'what'.

```
NAME
    tags - Extract all instances of a tag

SYNOPSIS

    curlyq [global options] tags [command options] URL...

COMMAND OPTIONS
    -c, --[no-]compressed            - Expect compressed results
    --[no-]clean                     - Remove extra whitespace from results
    -h, --header=KEY=VAL             - Define a header to send as key=value (may be used more than once, default: none)
    -q, --query, --filter=DOT_SYNTAX - Dot syntax query to filter results (default: none)
    --search=CSS/XPATH               - Regurn an array of matches to a CSS or XPath query (default: none)
    --[no-]source, --[no-]html       - Output the HTML source of the results
    -t, --tag=TAG                    - Specify a tag to collect (may be used more than once, default: none)
```


PayPal link: [paypal.me/ttscoff](https://paypal.me/ttscoff)

## Changelog

See [CHANGELOG.md](https://github.com/ttscoff/curlyq/blob/main/CHANGELOG.md)
