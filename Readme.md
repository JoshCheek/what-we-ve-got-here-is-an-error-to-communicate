[![Build Status](https://travis-ci.org/JoshCheek/what-we-ve-got-here-is-an-error-to-communicate.svg?branch=master)](https://travis-ci.org/JoshCheek/what-we-ve-got-here-is-an-error-to-communicate)

What if error messages were compelling to read?
-----------------------------------------------

Blog explaining the goal [here](http://blog.turing.io/2015/01/18/what-we-ve-got-here-is-an-error-to-communicate/).

A screenshot of the code rendering an `ArgumentError`.

![screenshot](https://s3.amazonaws.com/josh.cheek/images/scratch/better-reuby-commandline-errors.png)

This is still early and Rough
-----------------------------

But I've been using it on its own test suite, and have to say it's compelling!

Inspirations:
-------------

* I think initially this was inspired by Sarah Gray's talk at Software Craftsmanship North America:
  [Visualizing Enumerable: Own Abstract Concepts Through Physicalization](https://vimeo.com/54860297)
* Got to thinking about it again with Kerri Miller, conversing at DCamp,
  and then at Ruby Conf, she created [chatty_exceptions](https://github.com/kerrizor/chatty_exceptions)
  which is in this same domain.

Related Projects:
-----------------

* Charlie Sommerville's [better_errors](https://rubygems.org/gems/better_errors)
  gem gives you a nice interface like this for Rails.
* Koichi's [pretty_backtrace](https://github.com/ko1/pretty_backtrace)

License
--------

[<img src="http://www.wtfpl.net/wp-content/uploads/2012/12/wtfpl.svg" width="15" height="15" alt="WTFPL" /> Do what the fuck you want to.](http://www.wtfpl.net/)
