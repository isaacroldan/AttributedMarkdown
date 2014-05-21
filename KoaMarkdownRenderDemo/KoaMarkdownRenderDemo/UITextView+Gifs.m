//
//  UITextView+Gifs.m
//  KoaMarkdownRenderDemo
//
//  Created by Isaac Roldan on 21/05/14.
//  Copyright (c) 2014 Isaac Roldan. All rights reserved.
//

#import "UITextView+Gifs.h"
#import <AFNetworking.h>
#import "VSAnimatedGIFResponseSerializer.h"
#import <objc/runtime.h>

@interface UITextView ()

@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, strong) NSNumber *currentOffset;
@property (nonatomic, strong) NSNumber *previuosHeightOffset;


@end

static char imageViewArrayKey;
static char currentOffsetKey;
static char previousHeightOffsetKey;


@implementation UITextView (Gifs)


/**
 *  Given an attributed string, populate the textView adding GIFs (if any) as subviews.
 */
- (void)setAttributedContent:(NSMutableAttributedString*)stylie
{
    NSArray *attArray = [self splitAttributedStringWithGIFs:stylie];
    
    //Initialize variables
    self.imageViewArray = [@[] mutableCopy];
    self.currentOffset = @0;
    self.previuosHeightOffset = @0;
    
    //Add each item to the textView
    for (id elem in attArray) {
        if ([elem isKindOfClass:[NSString class]]) {
            [self addGIFWithURL:elem]; //gifs!
        }
        else {
            [self addAttributedString:elem];
        }
    }
    self.contentSize = CGSizeMake(self.frame.size.width, [self.currentOffset intValue]);
}

/**
 *  Split the attributed string separating the GIFs from the rest of the elements
 *  GIFs must be as NSString between the tags <GIF>
 *  @return array with all the elements to add to the texView
 */
- (NSArray*)splitAttributedStringWithGIFs:(NSMutableAttributedString*)attString
{
    NSRange searchRange = NSMakeRange(0,attString.string.length);
    NSRange foundRange;
    NSMutableArray *attArray = [@[] mutableCopy];
    while (searchRange.location < attString.string.length) {
        searchRange.length = attString.string.length-searchRange.location;
        foundRange = [attString.string rangeOfString:@"<GIF>.+<GIF>" options:NSRegularExpressionSearch|NSCaseInsensitiveSearch range:searchRange];
        if (foundRange.location != NSNotFound) {
            [attArray addObject:[attString attributedSubstringFromRange:NSMakeRange(searchRange.location, foundRange.location-searchRange.location)]];
            NSString *gifURL = [attString.string substringWithRange:NSMakeRange(foundRange.location+5, foundRange.length-10)];
            [attArray addObject:gifURL];
            searchRange.location = foundRange.location+foundRange.length;
        } else {
            [attArray addObject:[attString attributedSubstringFromRange:searchRange]];
            break;
        }
    }
    return attArray;
}

/**
 *  Add a GIF element to the textView. It will be added as a subview.
 *  The frame occuped by the GIF is setted as a exclusion area in the textView so no text is rendered in the same place.
 *  The gif is downloaded async and the method uses a placeholder while its downloading.
 *  The exclusion path is updated when the download is complete
 */
- (void)addGIFWithURL:(NSString*)urlString
{
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder.gif"]];
    [imageView setFrame:CGRectMake(0, [self.currentOffset intValue], self.frame.size.width, 200)];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setClipsToBounds:YES];
    [self.imageViewArray addObject:imageView];
    [self addSubview:imageView];
   
    [self addNewExclusionPathForImageView:imageView];
    
    self.currentOffset = @([self.currentOffset intValue] + imageView.frame.size.height);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [VSAnimatedGIFResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, UIImage *image) {
        
        int oldheight = imageView.frame.size.height;
        [self updateImageView:imageView withAnimatedImage:image];
        [self updateExclusionPathForImageView:imageView];
        int offsetHeight = oldheight - imageView.frame.size.height;
        self.previuosHeightOffset = @([self.previuosHeightOffset intValue] + offsetHeight);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

/**
 *  Add new exclusion path to the text view.
 *  We add a exclusion path for each GIF we want to show.
 */
- (void)addNewExclusionPathForImageView:(UIImageView*)imageView
{
    UIBezierPath * imgRect = [UIBezierPath bezierPathWithRect:imageView.frame];
    NSMutableArray *exclusionPaths = [self.textContainer.exclusionPaths mutableCopy];
    if (!exclusionPaths) {
        exclusionPaths = [@[] mutableCopy];
    }
    [exclusionPaths addObject:imgRect];
    self.textContainer.exclusionPaths = exclusionPaths;
}

/**
 *  The exclusion paths are initialized to the frame of the placeholder
 *  Once the image is downloaded we need to update the exclusion path to the new frame
 */
- (void)updateExclusionPathForImageView:(UIImageView*)imageView
{
    int index = [self.imageViewArray indexOfObject:imageView];
    NSMutableArray *exclusionPaths = [self.textContainer.exclusionPaths mutableCopy];
    UIBezierPath * imgRect = [UIBezierPath bezierPathWithRect:CGRectMake(0, imageView.frame.origin.y, self.frame.size.width, imageView.frame.size.height)];
    exclusionPaths[index] = imgRect;
    self.textContainer.exclusionPaths = exclusionPaths;
}

/**
 *  We insert imageViews with placeholders while the GIFs are downloaded
 *  When the download is complete we need to update the image and the frame of the imageView.
 */
- (void)updateImageView:(UIImageView*)imageView withAnimatedImage:(UIImage *)image
{
    imageView.image = image;
    int width = image.size.width*image.scale < (self.frame.size.width-10) ? image.size.width*image.scale : (self.frame.size.width-10);
    [imageView setFrame:CGRectMake(0, imageView.frame.origin.y-[self.previuosHeightOffset intValue], self.frame.size.width-10, image.size.height*width/image.size.width)];
}

/**
 *  For normal attributed strings, we just append them to the current attributedText of the textView
 *  We update the `currentOffset` variable, used to know the current position in the frame of the textView
 *  this position is used to add the GIFs in the correct place (they are added as subviews!)
 *
 */
- (void)addAttributedString:(NSMutableAttributedString *)attString
{
    CGSize size = [(NSMutableAttributedString*)attString boundingRectWithSize:CGSizeMake(self.frame.size.width, 99999) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:NULL].size;
    NSMutableAttributedString *newAtt = [self.attributedText mutableCopy];
    [newAtt appendAttributedString:(NSMutableAttributedString*)attString];
    self.attributedText = newAtt;
    self.currentOffset = @([self.currentOffset intValue] + size.height + 10);
}


#pragma mark - Objects

- (void)setImageViewArray:(NSMutableArray *)imageViewArray
{
    objc_setAssociatedObject(self, &imageViewArrayKey, imageViewArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray*)imageViewArray
{
    return objc_getAssociatedObject(self, &imageViewArrayKey);
}

- (void)setCurrentOffset:(NSNumber *)currentOffset
{
    objc_setAssociatedObject(self, &currentOffsetKey, currentOffset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber*)currentOffset
{
    return objc_getAssociatedObject(self, &currentOffsetKey);
}

- (void)setPreviuosHeightOffset:(NSNumber *)previuosHeightOffset
{
    objc_setAssociatedObject(self, &previousHeightOffsetKey, previuosHeightOffset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber*)previuosHeightOffset
{
    return objc_getAssociatedObject(self, &previousHeightOffsetKey);
}

@end
