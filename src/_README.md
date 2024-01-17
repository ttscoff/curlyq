<!--README--><!--GITHUB--># CurlyQ

[![Gem](https://img.shields.io/gem/v/na.svg)](https://rubygems.org/gems/curlyq)
[![GitHub license](https://img.shields.io/github/license/ttscoff/curlyq.svg)](./LICENSE.txt)

**A command line helper for curl and web scraping**

_If you find this useful, feel free to [buy me some coffee][donate]._

[donate]: https://brettterpstra.com/donate
<!--END GITHUB-->

[jq]: https://github.com/jqlang/jq "Command-line JSON processor"
[yq]: https://github.com/mikefarah/yq "yq is a portable command-line YAML, JSON, XML, CSV, TOML and properties processor"

The current version of `curlyq` is <!--VER-->0.0.9<!--END VER-->.

CurlyQ is a utility that provides a simple interface for curl, with additional features for things like extracting images and links, finding elements by CSS selector or XPath, getting detailed header info, and more. It's designed to be part of a scripting pipeline, outputting everything as structured data (JSON or YAML). It also has rudimentary support for making calls to JSON endpoints easier, but it's expected that you'll use something like [jq] to parse the output.

[github]: https://github.com/ttscoff/curlyq/

### Installation

Assuming you have Ruby and RubyGems installed, you can just run `gem install curlyq`. If you run into errors, try `gem install --user-install curlyq`, or use `sudo gem install curlyq`.

If you're using Homebrew, you have the option to install via [brew-gem](https://github.com/sportngin/brew-gem):

    brew install brew-gem
    brew gem install curlyq

If you don't have Ruby/RubyGems, you can install them pretty easily with [Homebrew], [rvm], or [asdf].

[Homebrew]: https://brew.sh/ "Homebrew—The Missing Package Manager for macOS (or Linux)"
[rvm]: https://rvm.io/ "Ruby Version Manager (RVM)"
[asdf]: https://github.com/asdf-vm/asdf "asdf-vm/asdf:Extendable version manager with support for ..."

### Usage

Run `curlyq help` for a list of subcommands. Run `curlyq help SUBCOMMAND` for details on a particular subcommand and its options.

```
@cli(bundle exec bin/curlyq help)
```

### Query and Search syntax

You can shape the results using `--search` (`-s`) and `--query` (`-q`) on some commands.

A search uses either CSS or XPath syntax to locate elements. For example, if you wanted to locate all of the `<article>` elements with a class of `post` inside of the div with an id of `main`, you would run `--search '#main article.post'`. Searches can target tags, ids, and classes, and can accept `>` to target direct descendents. You can also use XPaths, but I hate those so I'm not going to document them.

> I've tried to make the query function useful, but if you want to do any kind of advanced shaping, you're better off piping the JSON output to [jq] or [yq].
<!--JEKYLL{:.warn}-->

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

Comparisons can be numeric or string comparisons. A numeric comparison like `curlyq images -q '[width>500]' URL` would return all of the images on the page with a width attribute greater than 500.

You can also use dot syntax inside of comparisons, e.g. `[links.rel*=me]` to target the links object (`html` command), and return only the links with a `rel=me` attribute. If the comparison is to an array object (like `class` or `rel`), it will match if any of the elements of the array match your comparison.

If you end the query with a specific key, only that key will be output. If there's only one match, it will be output as a raw string. If there are multiple matches, output will be an array:

    curlyq tags --search '#main .post h3' -q '[attrs.id*=what].source' 'https://brettterpstra.com/2024/01/10/introducing-curlyq-a-pipeline-oriented-curl-helper/'
    
    <h3 id="whats-next">What’s Next</h3>

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
@cli(bundle exec bin/curlyq help extract)
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
@cli(bundle exec bin/curlyq help headlinks)
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
@cli(bundle exec bin/curlyq help html)
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
@cli(bundle exec bin/curlyq help images)
```

##### json

The `json` command just returns an object with header/response info, and the contents of the JSON response after it's been read by the Ruby JSON library and output. If there are fetching or parsing errors it will fail gracefully with an error code.

```
@cli(bundle exec bin/curlyq help json)
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
@cli(bundle exec bin/curlyq help links)
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
@cli(bundle exec bin/curlyq help scrape)
```

##### screenshot

Full-page screenshots require Firefox, installed and specified with `--browser firefox`.

Type defaults to `full`, but will only work if `-b` is Firefox. If you want to use Chrome, you must specify a `--type` as 'visible' or 'print'.

The `-o` (`--output`) flag is required. It should be a path to a target PNG file (or PDF for `-t print` output). Extension will be modified automatically, all you need is the base name.

Example:

    curlyq screenshot -b f -o ~/Desktop/test https://brettterpstra.com/2024/01/10/introducing-curlyq-a-pipeline-oriented-curl-helper/

    Screenshot saved to /Users/ttscoff/Desktop/test.png


```
@cli(bundle exec bin/curlyq help screenshot)
```

##### tags

Return a hierarchy of all tags in a page. Use `-t` to limit to a specific tag.

    curlyq tags --search '#main .post h3' -q '[attrs.id*=what]' https://brettterpstra.com/2024/01/10/introducing-curlyq-a-pipeline-oriented-curl-helper/

    [
      {
        "tag": "h3",
        "source": "<h3 id=\"whats-next\">What’s Next</h3>",
        "attrs": [
          {
            "id": "whats-next"
          }
        ],
        "content": "What’s Next",
        "tags": [

        ]
      }
    ]

The above command filters the tags based on a CSS query, then further filters them to just tags with an id containing 'what'.

```
@cli(bundle exec bin/curlyq help tags)
```

<!--GITHUB-->
PayPal link: [paypal.me/ttscoff](https://paypal.me/ttscoff)

## Changelog

See [CHANGELOG.md](https://github.com/ttscoff/curlyq/blob/main/CHANGELOG.md)
<!--END GITHUB--><!--END README-->
