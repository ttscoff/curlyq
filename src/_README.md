<!--README--><!--GITHUB--># CurlyQ

[![Gem](https://img.shields.io/gem/v/na.svg)](https://rubygems.org/gems/curlyq)
[![GitHub license](https://img.shields.io/github/license/ttscoff/curlyq.svg)](./LICENSE.txt)

**A command line helper for curl and web scraping**

_If you find this useful, feel free to [buy me some coffee][donate]._

[donate]: https://brettterpstra.com/donate
<!--END GITHUB-->

The current version of `curlyq` is <!--VER-->0.0.2<!--END VER-->.

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

```
@cli(bundle exec bin/curlyq help extract)
```


##### headlinks

```
@cli(bundle exec bin/curlyq help headlinks)
```

##### html

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

See [CHANGELOG.md](https://github.com/ttscoff/na_gem/blob/master/CHANGELOG.md)
<!--END GITHUB--><!--END README-->
