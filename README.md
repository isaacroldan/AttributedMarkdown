# KoaMarkdownRender

KoaMarkdownRender uses [MMMarkdown](https://github.com/mdiep/MMMarkdown) parser as a base to convert [Markdown][] to `NSAttributedString` with customizable styles.

The idea is to add this `NSAttributedString` to a `UITextView` to be able to use Markdown with custom styles avoiding the use of HTML, CSS, `UIWebViews` and that stuff. 
It support a lot of styles, including images, gifs, mentions, links, and more.

All the styles can be easily adapted to any requirement (with the limitations of `NSAttibutedString` of course)

The library includes a category of `UITextView` that supports the use of `NSAttributedStrings` with special elements like GIFs.

## MMMardkdown
KoaMarkdownRender is a fork of [MMMarkdown](https://github.com/mdiep/MMMarkdown)

MMMarkdown is an Objective-C static library for converting [Markdown][] to HTML. Unlike other Markdown libraries, MMMarkdown implements an actual parser. It is not a port of the original Perl implementation and does not use regular expressions to transform the input into HTML. MMMarkdown tries to be efficient and minimize memory usage.

[Markdown]: http://daringfireball.net/projects/markdown/

## WIP!

This library is still a work in progress, it works for almost every case, but need to update some things. The next features will be:
- Videos inside UITextView (youtube only)
- Easy Styles customization (right now you have to edit a file with the Attributed styles)
- Add some configuration options to the library (like, parse GIFs or not, etc...)
- Polish and cleaning (yep!)

## License
KoaMarkdownRender is available under the [MIT License][].

[MIT License]: http://opensource.org/licenses/mit-license.php
