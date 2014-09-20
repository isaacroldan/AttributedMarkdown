//
//  RBLayoutManager.m
//  Redbooth
//
//  Created by Isaac Roldán Armengol on 5/7/14.
//  Copyright (c) 2014 teambox. All rights reserved.
//

#import "RBLayoutManager.h"
#import "MMElement.h"

@implementation RBLayoutManager

static const CGFloat mentionHeight = 17;
static const CGFloat borderRadius = 2.0;

/**
 *  Defines how the background rect of a NSAttributedString is going to be drawn and filled.
 *  An attributed String has background when it has the attribute NSBackgroundColorAttributeName
 *  In this implementation, backgrounds are drawn with rounded corners.
 *
 */
- (void)fillBackgroundRectArray:(const CGRect *)rectArray count:(NSUInteger)rectCount forCharacterRange:(NSRange)charRange color:(UIColor *)color
{
    NSDictionary *attributesForCharsInRect = [self.textStorage attributesAtIndex:charRange.location effectiveRange:NULL];
    MMElementType type = [attributesForCharsInRect[@"ElementType"] intValue];
    
    if (type == MMElementTypeMention) {
        [self drawMentionsBackgroundArray:rectArray count:rectCount forCharacterRange:charRange color:color];
        return;
    }
    else if (type == MMElementTypeBlockquote) {
        [self drawBlockquoteBackgroundArray:rectArray count:rectCount forCharacterRange:charRange color:color];
        return;
    }
    else if (type == MMElementTypeCodeBlock) {
        [self drawCodeBlockBackgroundArray:rectArray count:rectCount forCharacterRange:charRange color:color];
        return;
    }
    else if (type == MMElementTypeCodeSpan) {
        [self drawCodeSpanBackgroundArray:rectArray count:rectCount forCharacterRange:charRange color:color];
        return;
    }
}

/**
 *  Draw and Fill Code Span objects background: `code line`
 */
- (void)drawCodeSpanBackgroundArray:(const CGRect *)rectArray count:(NSUInteger)rectCount forCharacterRange:(NSRange)charRange color:(UIColor *)color
{
    CGMutablePathRef path = CGPathCreateMutable();
    NSDictionary *attributesForCharsInRect = [self.textStorage attributesAtIndex:charRange.location effectiveRange:NULL];
    
    if (rectCount == 1 || (rectCount == 2 && (CGRectGetMaxX(rectArray[1]) < CGRectGetMinX(rectArray[0]))))
    {
        // 1 rect or 2 rects without edges in contact
        CGPathAddRoundedRect(path, NULL, rectArray[0], borderRadius, borderRadius);
        if (rectCount == 2)
            CGPathAddRoundedRect(path, NULL, rectArray[1], borderRadius, borderRadius);
    }
    else
    {
        // 2 or 3 rects
        NSUInteger lastRect = rectCount - 1;
        
        CGFloat minx0 = CGRectGetMinX(rectArray[0]), midx0 = CGRectGetMidX(rectArray[0]), maxx0 = CGRectGetMaxX(rectArray[0]);
        CGFloat miny0 = CGRectGetMinY(rectArray[0]), midy0 = CGRectGetMidY(rectArray[0]), maxy0 = CGRectGetMaxY(rectArray[0]);
        CGFloat minx1 = CGRectGetMinX(rectArray[lastRect])-4, midx1 = CGRectGetMidX(rectArray[lastRect]), maxx1 = CGRectGetMaxX(rectArray[lastRect]);
        CGFloat miny1 = CGRectGetMinY(rectArray[lastRect]), midy1 = CGRectGetMidY(rectArray[lastRect]), maxy1 = CGRectGetMaxY(rectArray[lastRect]);
        
        CGPathMoveToPoint(path, NULL, minx0, midy0);
        CGPathAddArcToPoint(path, NULL, minx0, miny0, midx0, miny0, 2);
        CGPathAddArcToPoint(path, NULL, maxx0, miny0, maxx0, midy0, 2);
        CGPathAddArcToPoint(path, NULL, maxx0, miny1, (maxx1+(maxx0-maxx1)/2), miny1, 2);
        CGPathAddArcToPoint(path, NULL, maxx1, miny1, maxx1, midy1, 2);
        CGPathAddArcToPoint(path, NULL, maxx1, maxy1, midx1, maxy1, 2);
        CGPathAddArcToPoint(path, NULL, minx1, maxy1, minx1, midy1, 2);
        CGPathAddArcToPoint(path, NULL, minx1, maxy0, minx0/2, maxy0, 2);
        CGPathAddArcToPoint(path, NULL, minx0, maxy0, minx0, midy0, 2);
        CGPathCloseSubpath(path);
    }

    CGPathCloseSubpath(path);
    
    [color set]; // set fill and stroke color
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineWidth(ctx, 1);
    UIColor *strokeColor = (UIColor*)attributesForCharsInRect[@"BackgroundBorderColor"];
    CGContextSetStrokeColorWithColor(ctx, strokeColor.CGColor);;
    CGContextAddPath(ctx, path);
    CGPathRelease(path);
    CGContextDrawPath(ctx, kCGPathFillStroke);
}

/**
 *  Draw and Fill Code Block objects background:  ````
 *                                                code block
 *                                                ````
 */
- (void)drawCodeBlockBackgroundArray:(const CGRect *)rectArray count:(NSUInteger)rectCount forCharacterRange:(NSRange)charRange color:(UIColor *)color
{
    NSTextContainer *textContainer = self.textContainers[0];
    NSDictionary *attributesForCharsInRect = [self.textStorage attributesAtIndex:charRange.location effectiveRange:NULL];
    UIColor *strokeColor = (UIColor*)attributesForCharsInRect[@"BackgroundBorderColor"];

    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat minx = 5;
    CGFloat maxx = textContainer.size.width-minx;
    CGFloat miny = rectArray[0].origin.y;
    CGFloat maxy = (rectArray[rectCount-1].origin.y + rectArray[rectCount-1].size.height)+14;
    CGPathAddRect(path, NULL, CGRectMake(minx, miny, maxx-minx, maxy-miny));
    CGPathCloseSubpath(path);
    
    CGMutablePathRef borderPath = CGPathCreateMutable();
    CGPathMoveToPoint(borderPath, NULL, minx, miny+1);
    CGPathAddLineToPoint(borderPath, NULL, maxx, miny+1);
    CGPathMoveToPoint(borderPath, NULL, minx, maxy);
    CGPathAddLineToPoint(borderPath, NULL, maxx, maxy);
    CGPathCloseSubpath(borderPath);
    
    [color set]; // set fill color

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, strokeColor.CGColor);
    
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx, kCGPathFill);
    CGContextSetLineWidth(ctx, 0.9); //it is 0.9 and not 1.0 because iOS rounds 1.0 to 1.5 (i don't know why). 0.9 is rounded to 1.0 by the system.
    CGContextAddPath(ctx, borderPath);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    CGPathRelease(path);
    CGPathRelease(borderPath);
}

/**
 *  Draw and Fill Blockquote objects background:    > quote line
 */
- (void)drawBlockquoteBackgroundArray:(const CGRect *)rectArray count:(NSUInteger)rectCount forCharacterRange:(NSRange)charRange color:(UIColor *)color
{
    CGMutablePathRef path = CGPathCreateMutable();
    NSDictionary *attributesForCharsInRect = [self.textStorage attributesAtIndex:charRange.location effectiveRange:NULL];

    for (int i = 0; i<rectCount; i++) {
        CGRect rect = rectArray[i];
        CGPathMoveToPoint(path, NULL, 8, rect.origin.y-2);
        CGPathAddLineToPoint(path, NULL, 8, rect.origin.y + rect.size.height+2);
    }
    CGPathCloseSubpath(path);
    
    [color set]; // set fill and stroke color
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    CGContextSetLineWidth(ctx, 3.5);
    UIColor *strokeColor = (UIColor*)attributesForCharsInRect[@"BackgroundBorderColor"];
    CGContextSetStrokeColorWithColor(ctx, strokeColor.CGColor);
    CGContextAddPath(ctx, path);
    CGPathRelease(path);
    CGContextDrawPath(ctx, kCGPathStroke);
}

/**
 *  Draw and Fill Mention objects background:  @mention
 *  Used too in the background of Internal Links objects.
 */
- (void)drawMentionsBackgroundArray:(const CGRect *)rectArray count:(NSUInteger)rectCount forCharacterRange:(NSRange)charRange color:(UIColor *)color
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    for (int i = 0; i<rectCount; i++) {
        CGRect rect = rectArray[i];
        rect.origin.y = rect.origin.y + 1;
        rect.origin.x = rect.origin.x + 0.5;
        rect.size.height = mentionHeight;
        if (rect.size.width > 0) {
            rect.size.width = rect.size.width - 1;
        }
        
        CGPathAddRoundedRect(path, NULL, rect, borderRadius, borderRadius);
    }
    
    CGPathCloseSubpath(path);
    
    [color set]; // set fill and stroke color
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineWidth(ctx, 1);
    CGContextAddPath(ctx, path);
    CGPathRelease(path);
    CGContextDrawPath(ctx, kCGPathFillStroke);
}

@end


