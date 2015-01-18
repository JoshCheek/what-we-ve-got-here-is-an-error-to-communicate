What would it take for error messages to compel you to read them?
=================================================================

Ben Orenstein [observed](https://twitter.com/r00k/status/556608103928856576)
that newbies tend to skim error messages rather than reading them
and understanding the information they are trying to communicate.

I realized that I do this a lot, even still.
I've gotten very good at glancing at the structure
of the text on the screen and knowing what the error is and where to look.
But sometimes it's still hard to find that one piece of info I need from it.
Which means sometimes I just jump to where I expect it to be in my code,
figuring if I look at it for a moment, I'll see it and fix it.
This is usually true, but if I'm not particularly on that day,
I can utterly misunderstand the problem.

For me, this is a conjunction of bad UI and a brain that operates in a certain manner.
I'd love a more patient brain that didn't feel a little overwhelmed every time it
looks at a backtrace, but locating needles in haystacks is a skill unto itself.
As such, stopping to figure out what the error is saying may yank me out of context.
This is probably why my brain has an aversion to it, it's an interruption.

It doesn't need to be this way, it simply is.
We can change it. We aren't _obligated_ to have mediocre error messages.
This code explores what that might look like.


A hypothetical answer to the question
-------------------------------------

![screenshot](https://s3.amazonaws.com/josh.cheek/images/scratch/better-reuby-commandline-errors.png)

This screenshot shows the provided code catching an error raised
from invoking a method with the wrong number of arguments.
It uses colour, location, and size to help you parse the data for the pieces you are interested in.
It tries to direct your attention to what it thinks will be most useful, While still providing context.

Here are specific things to notice in the screenshot:

* It rewords "(3 for 2)" because that is unclear to beginners whether they gave it 3 and it expected 2,
  or whether it expected 3 and they gave it 2.
* It highlights the numbers as they're what you most care about in the message.
* Because this is a "wrong number of arguments" error, there are two relevant places to look for information.
  The method being called, and the location of the invocation. So it renders the code at/around
  those two locations.
* It highlights the method name on both the definition and caller so you can jump to the relevant piece within the code samples.
* It appends the error context to the end of the relevant line "EXPECTED 2" next to the definition,
  showing the two arguments the method expected.
  "SENT 3" next to the invocation, showing the 3 arguments that were sent.
* Filepaths are relative to cut down on noise.
* The filename is brightened compared to the rest of the path,
  because that's usually the piece of information in the path that you care most about,
  and it often takes a little bit of effort to find because it
  shifts around in position based on the length of the path.
* The line number is in the usual place, but is highlighted differently
* All code samples include line numbers, so if you figure it out based on the code,
  you can just look left, and if you figure it out based on the trace, you can look in the usual place.
* The sections of information (error type and message, suggested context, and stacktrace)
  are separated with conspicuous dividers.
* Colouring of paths and line numbers is consistent across the uses so you can use colour to guide your gaze.
* The stacktrace includes code samples of each line.
  Because these are less likely to be useful, they are available but limited to one-line.
  They are also indented and their colours are muted to reduce their imperative.
* Within the stack trace, the call to the next method is highlighted.

This is a proof of concept
--------------------------

This isn't fit for real-world use.
If there is resonance in the community, I'll probably try to make it a real gem.
I'll have some time to do that during my next braeak in late march 2015.

Inspirations:
-------------

* I think initially this was inspired by Sarah Gray's talk at Software Craftsmanship North America:
  [Visualizing Enumerable: Own Abstract Concepts Through Physicalization](https://vimeo.com/54860297)
* Got to thinking about it again with Kerri Miller, conversing at DCamp,
  and then at Ruby Conf, she created [chatty_exceptions](https://github.com/kerrizor/chatty_exceptions)
  which is in this same domain.
* Charlie Sommerville's [better_errors](https://rubygems.org/gems/better_errors)
  gem gives you a nice interface like this for Rails.

License
--------

[<img src="http://www.wtfpl.net/wp-content/uploads/2012/12/wtfpl.svg" width="15" height="15" alt="WTFPL" /> Do what the fuck you want to.](http://www.wtfpl.net/)
