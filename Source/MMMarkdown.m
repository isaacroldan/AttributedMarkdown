//
//  MMMarkdown.m
//  MMMarkdown
//
//  Copyright (c) 2012 Matt Diephouse.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "MMMarkdown.h"


#import "MMParser.h"
#import "MMGenerator.h"

@implementation MMMarkdown

#pragma mark - Public Methods

+ (NSAttributedString *)attributedStringWithMarkdown:(NSString *)string error:(__autoreleasing NSError **)error
{
    return [self attributedStringWithMarkdown:string extensions:MMMarkdownExtensionsNone fromSelector:_cmd error:error attributedDelegate:nil];
}

+ (NSAttributedString *)attributedStringWithMarkdown:(NSString *)string extensions:(MMMarkdownExtensions)extensions error:(NSError *__autoreleasing *)error
{
    return [self attributedStringWithMarkdown:string extensions:extensions fromSelector:_cmd error:error attributedDelegate:nil];
}

+ (NSAttributedString *)attributedStringWithMarkdown:(NSString *)string attributesDelegate:(id)delegate extensions:(MMMarkdownExtensions)extensions error:(NSError *__autoreleasing *)error
{
    return [self attributedStringWithMarkdown:string extensions:extensions fromSelector:_cmd error:error attributedDelegate:nil];
}

#pragma mark - Private Methods

+ (NSAttributedString *)attributedStringWithMarkdown:(NSString *)string
                                          extensions:(MMMarkdownExtensions)extensions
                                        fromSelector:(SEL)selector
                                               error:(__autoreleasing NSError **)error
                                  attributedDelegate:(id<AttributedStringStylesGeneratorDelegate>)delegate
{
    if (string == nil || string.length == 0)
    {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    MMParser    *parser    = [[MMParser alloc] initWithExtensions:extensions];
    MMGenerator *generator = [MMGenerator new];
    generator.delegate = delegate;
    
    MMDocument *document = [parser parseMarkdown:string error:error];
    if (!document)
        return nil;
    
    return [generator generateAttributedString:document];
}


@end
