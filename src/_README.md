<!--README--><!--GITHUB--># CurlyQ

[![Gem](https://img.shields.io/gem/v/na.svg)](https://rubygems.org/gems/curlyq)
[![GitHub license](https://img.shields.io/github/license/ttscoff/curlyq.svg)](./LICENSE.txt)

**A command line helper for curl and web scraping**

_If you find this useful, feel free to [buy me some coffee][donate]._

[donate]: https://brettterpstra.com/donate
<!--END GITHUB-->

The current version of `curlyq` is <!--VER-->0.0.4<!--END VER-->.

CurlyQ is a utility that provides a simple interface for curl, with additional features for things like extracting images and links, finding elements by CSS selector or XPath, getting detailed header info, and more. It's designed to be part of a scripting pipeline, outputting everything as structured data (JSON or YAML). It also has rudimentary support for making calls to JSON endpoints easier, but it's expected that you'll use something like `jq` to parse the output.

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



```
@cli(bundle exec bin/curlyq help html)
```

##### images

```
@cli(bundle exec bin/curlyq help images)
```

##### json

```
@cli(bundle exec bin/curlyq help json)
```

##### links

```
@cli(bundle exec bin/curlyq help links)
```

##### scrape

```
@cli(bundle exec bin/curlyq help scrape)
```

##### screenshot

Full-page screenshots require Firefox, installed and specified with `--browser firefox`.

```
@cli(bundle exec bin/curlyq help screenshot)
```

##### tags

```
@cli(bundle exec bin/curlyq help tags)
```

<!--GITHUB-->
PayPal link: [paypal.me/ttscoff](https://paypal.me/ttscoff)

## Changelog

See [CHANGELOG.md](https://github.com/ttscoff/curlyq/blob/main/CHANGELOG.md)
<!--END GITHUB--><!--END README-->
