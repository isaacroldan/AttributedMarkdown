//
//  MMGenerator.m
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

#import "MMGenerator.h"
#import "MMDocument.h"
#import "MMElement.h"
#import "MMAttributesHelper.h"


@interface MMGenerator ()
- (void) _generateAttributedStringForElement:(MMElement *)anElement
                                  inDocument:(MMDocument *)aDocument
                            attributedString:(NSMutableAttributedString *)theHTML
                                    location:(NSUInteger *)aLocation
                              nestedElements:(NSMutableArray*)nestedElements;
@end

@implementation MMGenerator


#pragma mark - Public Methods

- (NSAttributedString *)generateAttributedString:(MMDocument *)aDocument
{
    NSUInteger  location = 0;
    NSMutableAttributedString *theAttributedString = [[NSMutableAttributedString alloc] init];
    
    for (MMElement *element in aDocument.elements) {
        if (element.type == MMElementTypeHTML) {
            [theAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[aDocument.markdown substringWithRange:element.range]]];
        }
        else {
            [self _generateAttributedStringForElement:element
                                           inDocument:aDocument
                                     attributedString:theAttributedString
                                             location:&location
                                       nestedElements:nil];
        }
    }
    
    return [theAttributedString copy];
}


#pragma mark - Private Methods

- (void)_generateAttributedStringForElement:(MMElement *)anElement
                                 inDocument:(MMDocument *)aDocument
                           attributedString:(NSMutableAttributedString *)theAttributedString
                                   location:(NSUInteger *)aLocation
                             nestedElements:(NSMutableArray *)nestedElements;

{
    NSString *markdown = aDocument.markdown;
    
    NSString *startOfList;
    if (markdown.length>1 && markdown.length-anElement.range.location>=2) {
        startOfList = [markdown substringWithRange:NSMakeRange(anElement.range.location, 2)];
    }
    
    NSAttributedString *startTag;
    NSAttributedString *endTag;
        if (self.delegate) {
        startTag = [self.delegate startStringForElement:anElement listType:startOfList nestedStyles:nestedElements];
        endTag   = [self.delegate endStringForElement:anElement nestedStyles:nestedElements];
    }
    else {
        startTag = [MMAttributesHelper startStringForElement:anElement listType:startOfList nestedStyles:nestedElements];
        endTag   = [MMAttributesHelper endStringForElement:anElement nestedStyles:nestedElements];
    }
    
    if (startTag) [theAttributedString appendAttributedString:startTag];
    
    for (MMElement *child in anElement.children)
    {
        int start = (int)theAttributedString.length;
        int end = (int)child.range.length;
        if (child.type == MMElementTypeNone)
        {
            NSString *markdown = aDocument.markdown;
            if (child.range.length == 0)
            {
                [theAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            }
            else
            {
                [theAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[markdown substringWithRange:child.range]]];
                if (self.delegate) {
                    [theAttributedString addAttributes:[self.delegate attributesDictionaryForElement:anElement nestedStyles:nestedElements] range:NSMakeRange(start, end)];
                }
                else {
                    [theAttributedString addAttributes:[MMAttributesHelper attributesDictionaryForElement:anElement nestedStyles:nestedElements] range:NSMakeRange(start, end)];
                }
            }
        }
        else if (child.type == MMElementTypeHTML)
        {
            [theAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[aDocument.markdown substringWithRange:child.range]]];
            [theAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"OpenSans" size:20] range:NSMakeRange(start, end)];
        }
        else
        {
            [nestedElements addObject:@(child.type)];
            [self _generateAttributedStringForElement:child
                                           inDocument:aDocument
                                     attributedString:theAttributedString
                                             location:aLocation
                                       nestedElements:[nestedElements mutableCopy]];
        }
    }
    
    if (endTag) [theAttributedString appendAttributedString:endTag];
}


@end
