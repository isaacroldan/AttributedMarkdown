# AttributedMarkdown

AttributedMarkdown uses [MMMarkdown](https://github.com/mdiep/MMMarkdown) parser as a base to convert [Markdown][] to `NSAttributedString` with customizable styles.

The idea is to add this `NSAttributedString` to a `UITextView` (or custom TextView) to be able to use Markdown with custom styles avoiding the use of HTML, CSS, `UIWebViews` and that stuff. 
It support a lot of styles, including images, gifs, mentions, links, and more.

This library will only transform a `NSString` with markdown format to a `NSAttributedString` with styles. The styles can be provided by you or you can use the default ones. 
You can then render this `NSAttributedString` in a normal `UItextView` but some elements won't work (you can render an image link directly)

## Basic Example 
````objc
UITextView *myView = [UITextView new];
[self.view addSubview:myView];
NSString *markdown = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Example" ofType:@"md"] encoding:NSUTF8StringEncoding error:nil];

NSError *error = nil;
NSAttributedString *stylie = [MMMarkdown attributedStringWithMarkdown:markdown attributesDelegate:nil extensions:MMMarkdownExtensionsNone error:&error];
[myView setAttributedText:stylie];

````

There is also included a Markdownizer category to detect extra stuff in a text and transform it to markdown format before the conversion to `NSAttributedString`. It can detect:

- Dropbox images links to format `![]()`
- CloudApp images links to format `![]()`
- Inline images links to format `![]()`
- mentions (like @saky) to format `@[]()`
- youtube videos to format `@[]()`
- Emojis! from text to unicode. `:poop:` to :poop:
- [Redbooth](www.redbooth.com) links to format `@[]()`

usage is very simple:

````
NSString *myString = [...get your markdown text ...];
myString = [myString markdownizedString]; //easy!
````



## MMMardkdown
AttributedMarkdown is a fork of [MMMarkdown](https://github.com/mdiep/MMMarkdown)

MMMarkdown is an Objective-C static library for converting [Markdown][] to HTML. Unlike other Markdown libraries, MMMarkdown implements an actual parser. It is not a port of the original Perl implementation and does not use regular expressions to transform the input into HTML. MMMarkdown tries to be efficient and minimize memory usage.

[Markdown]: http://daringfireball.net/projects/markdown/


## License
AttributedMarkdown is available under the [MIT License][].

[MIT License]: http://opensource.org/licenses/mit-license.php
