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

// This value is used to estimate the length of the HTML output. The length of the markdown document
// is multplied by it to create an NSMutableString with an initial capacity.
//static const Float64 kHTMLDocumentLengthMultiplier = 1.25;



static NSString * __HTMLEscapedString(NSString *aString)
{
    NSMutableString *result = [aString mutableCopy];
    
    [result replaceOccurrencesOfString:@"&"
                            withString:@"&amp;"
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"\""
                            withString:@"&quot;"
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, result.length)];
    
    return result;
}

static NSString *__obfuscatedEmailAddress(NSString *anAddress)
{
    NSMutableString *result = [NSMutableString new];
    
    NSString *(^decimal)(unichar c) = ^(unichar c){ return [NSString stringWithFormat:@"&#%d;", c];  };
    NSString *(^hex)(unichar c)     = ^(unichar c){ return [NSString stringWithFormat:@"&#x%x;", c]; };
    NSString *(^raw)(unichar c)     = ^(unichar c){ return [NSString stringWithCharacters:&c length:1]; };
    NSArray *encoders = [NSArray arrayWithObjects:decimal, hex, raw, nil];
    
    for (NSUInteger idx=0; idx<anAddress.length; idx++)
    {
        unichar character = [anAddress characterAtIndex:idx];
        NSString *(^encoder)(unichar c);
        if (character == '@')
        {
            // Make sure that the @ gets encoded
            encoder = [encoders objectAtIndex:arc4random_uniform(2)];
        }
        else
        {
            int r = arc4random_uniform(100);
            encoder = [encoders objectAtIndex:(r >= 90) ? 2 : (r >= 45) ? 1 : 0];
        }
        [result appendString:encoder(character)];
    }
    
    return result;
}

@interface MMGenerator ()
- (void)_generateHTMLForElement:(MMElement *)anElement
                      inDocument:(MMDocument *)aDocument
                            HTML:(NSMutableAttributedString *)theHTML
                        location:(NSUInteger *)aLocation
                     stylesArray:(NSMutableArray *)stylesArray;
@end

@implementation MMGenerator

//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

- (NSMutableAttributedString *)generateHTML:(MMDocument *)aDocument
{
    NSUInteger  location = 0;
    NSMutableAttributedString *HTML = [[NSMutableAttributedString alloc] init];
    for (MMElement *element in aDocument.elements) {
        if (element.type == MMElementTypeHTML) {
            [HTML appendAttributedString:[[NSAttributedString alloc] initWithString:[aDocument.markdown substringWithRange:element.range]]];
        }
        else {
            [self _generateHTMLForElement:element
                               inDocument:aDocument
                                     HTML:HTML
                                 location:&location
                               stylesArray:[@[@(element.type)] mutableCopy]];
        }
    }
    
    return HTML;
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

- (void)_generateHTMLForElement:(MMElement *)anElement
                     inDocument:(MMDocument *)aDocument
                           HTML:(NSMutableAttributedString *)theHTML
                       location:(NSUInteger *)aLocation
                    stylesArray:(NSMutableArray *)stylesArray;
{
    NSString *markdown = aDocument.markdown;
    NSString *startOfList = [markdown substringWithRange:NSMakeRange(anElement.range.location, 2)];
    
    NSAttributedString *startTag =  [MMAttributesHelper startStringForElement:anElement listType:startOfList];// __HTMLStartTagForElement(anElement, startOfList);
    NSString *endTag   = [MMAttributesHelper endStringForElement:anElement];// __HTMLEndTagForElement(anElement);

    NSLog(@"%@",stylesArray);
    if (startTag)
        [theHTML appendAttributedString:startTag];
    
    for (MMElement *child in anElement.children) {
        int start = (int)theHTML.length;
        int end = (int)child.range.length;

        if (child.type == MMElementTypeNone) {
            NSString *markdown = aDocument.markdown;
            if (child.range.length == 0) {
                [theHTML appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            }
            else {
                [theHTML appendAttributedString:[[NSAttributedString alloc] initWithString:[markdown substringWithRange:child.range]]];
                [theHTML addAttributes:[MMAttributesHelper attributesDictionaryForElement:anElement nestedStyles:stylesArray] range:NSMakeRange(start, end)]; //__stringAttributesForElement(anElement, stylesArray)
                NSLog(@"%@",[markdown substringWithRange:child.range]);
            }
        }
        else if (child.type == MMElementTypeHTML) {
            [theHTML appendAttributedString:[[NSAttributedString alloc] initWithString:[aDocument.markdown substringWithRange:child.range]]];
            [theHTML addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"OpenSans" size:20] range:NSMakeRange(start, end)];
        }
        else {
            [stylesArray addObject:@(child.type)];
            [self _generateHTMLForElement:child
                               inDocument:aDocument
                                     HTML:theHTML
                                 location:aLocation
                               stylesArray:[stylesArray mutableCopy]];
        }
    }

    if (endTag)
        [theHTML appendAttributedString:[[NSAttributedString alloc] initWithString:endTag]];
}


@end
