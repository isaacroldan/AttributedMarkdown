//
//  RBMagicTextView.m
//  Redbooth
//
//  Created by Isaac Roldán Armengol on 28/6/14.
//  Copyright (c) 2014 teambox. All rights reserved.
//

#import "RBMagicTextView.h"
#import "VSAnimatedGIFResponseSerializer.h"
#import <AFNetworking.h>
#import <YLGIFImage.h>
#import <YLImageView.h>
#import <YTPlayerView.h>
#import <CommonCrypto/CommonCrypto.h>
#import <SDWebImage/SDImageCache.h>
#import "RBLayoutManager.h"


static int kImagePlaceholderHeight = 150;
static int kYoutubeVideoHeightRatio = 0.7;

@interface RBMagicTextView()

@property (nonatomic, strong) NSNumber *currentOffset;
@property (nonatomic, strong) NSNumber *previuosHeightOffset;
@property (nonatomic, strong) NSNumber *subviewsToBeRendered;
@property (nonatomic, strong) NSMutableAttributedString *attributedString;

@end


@implementation RBMagicTextView


#pragma mark - init methods

/**
 *  Initialize the TextView with our custom LayoutManager
 */
- (id)init
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] init];
    RBLayoutManager *textLayout = [[RBLayoutManager alloc] init];
    [textStorage addLayoutManager:textLayout];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    [textLayout addTextContainer:textContainer];
    self = [super initWithFrame:CGRectZero textContainer:textContainer];
    if (self) {
        
    }
    return self;
}

- (void)renderMarkdownString:(NSString*)markdown withLevel:(MMMarkdownLevel)markdownLevel
{
    NSAttributedString *attributedString = [MMMarkdown AttributedStringWithMarkdown:markdown baseURL:@"redbooth.com" markdownLevel:markdownLevel error:nil];
    [self renderAttributedString:attributedString];
}

- (void)renderAttributedString:(NSAttributedString*)attributedString
{
    [self resetTextView];
    [self setAttributedContent:attributedString];
}

- (void)resetTextView
{
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            [(UIImageView*)subview setImage:nil];
            [subview removeFromSuperview];
        }
        else if ([subview isKindOfClass:[YTPlayerView class]]) {
            [subview removeFromSuperview];
        }
    }
    self.imageViewArray = [@[] mutableCopy];
    self.currentOffset = @0;
    self.previuosHeightOffset = @0;
    self.textContainer.exclusionPaths = @[];
    self.scrollEnabled = NO;
    self.editable = NO;
    self.selectable = YES;
    self.dataDetectorTypes = UIDataDetectorTypeLink;
    self.attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    self.attributedText = self.attributedString;
    self.linkTextAttributes = @{NSForegroundColorAttributeName:ss_Color_Light_Blue};
}

/**
 *  Given an attributed string, populate the textView adding GIFs (if any) as subviews.
 */
- (void)setAttributedContent:(NSAttributedString*)stylie
{
    NSArray *attributedElementsArray = [self arrayOfElementsInAttributedString:stylie];
    
    //Add each item to the textView
    for (id elem in attributedElementsArray) {
        if ([elem isKindOfClass:[NSString class]]) {
            if ([elem hasPrefix:@"<YOUTUBE>"]) {
                [self addYoutubeVideoWithURL:elem];
            }
            else {
                [self addImageWithURL:elem]; //gifs!
            }
        }
        else {
            [self addAttributedString:elem];
        }
    }
    [self updateTextViewAfterAddingAllElements];
}

- (void)updateTextViewAfterAddingAllElements
{
    self.attributedText = self.attributedString;
    self.contentSize = CGSizeMake(self.frame.size.width, [self.currentOffset intValue]);
    if ([self.currentOffset intValue] != self.frameHeight) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frameWidth, [self.currentOffset intValue]);
    }
    [self updateTextViewHeight];
}

/**
 *  Split the attributed string separating the Images & Youtube embed videos from the rest of the string elements
 *  Images are inside the <IMAGE> tag. youtube videos inside <YOUTUBE>
 *  @return array with all the elements to add to the texView
 */
- (NSArray*)arrayOfElementsInAttributedString:(NSAttributedString*)attString
{
    NSString *regex = @"(<IMAGE>.+<IMAGE>)|(<YOUTUBE>.+<YOUTUBE>)";
    NSRange searchRange = NSMakeRange(0,attString.string.length);
    NSRange foundRange;
    NSMutableArray *arrayOfElements = [@[] mutableCopy];
    while (searchRange.location < attString.string.length) {
        searchRange.length = attString.string.length-searchRange.location;
        foundRange = [attString.string rangeOfString:regex options:NSRegularExpressionSearch|NSCaseInsensitiveSearch range:searchRange];
        if (foundRange.location != NSNotFound) {
            NSAttributedString *previousNonMatchingString = [attString attributedSubstringFromRange:NSMakeRange(searchRange.location, foundRange.location-searchRange.location)];
            NSString *matchingString = [attString.string substringWithRange:foundRange];
            matchingString = [matchingString stringByReplacingOccurrencesOfString:@"<IMAGE>" withString:@""];
            [arrayOfElements addObject:previousNonMatchingString];
            [arrayOfElements addObject:matchingString];
            self.subviewsToBeRendered = @(self.subviewsToBeRendered.intValue + 1);
            searchRange.location = foundRange.location+foundRange.length;
        }
        else {
            NSAttributedString *lastNonMatchingString = [attString attributedSubstringFromRange:searchRange];
            [arrayOfElements addObject:lastNonMatchingString];
            break;
        }
    }
    return arrayOfElements;
}


#pragma mark - Add New elements

/**
 *  Add an IMAGE element to the textView. It will be added as a subview.
 *  The frame occuped by the IMAGE is setted as a exclusion area in the textView so no text is rendered in the same place.
 *  The image is downloaded async and the method uses a placeholder while its downloading.
 *  The exclusion path is updated when the download is complete
 */
- (void)addImageWithURL:(NSString*)urlString
{
    //Only search for images in memory not in disk (much slower...). Review if we want to access cache in disk too.
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:urlString];
    YLImageView *imageView = [self imageViewWithCachedImage:cachedImage];
    [self addSubview:imageView];
    if (cachedImage) return;
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    BOOL isRedboothImage = [self parseRedboothAPIURL:urlString];
    RBMagicTextView *__weak weakSelf = self;
    if (!isRedboothImage) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        //When the downloaded image is a GIF, we use the VSAnimatedGIFResponseSerializer. It returns a YLGifImage ready to use low ram :)
        AFHTTPResponseSerializer *responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[[[RedboothApiClient sharedInstance] imageResponseSerializer],[VSAnimatedGIFResponseSerializer serializer]]];
        
        op.responseSerializer = responseSerializer;
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, UIImage *image) {
            [weakSelf processDownloadedImage:image inImageView:imageView];
            [[SDImageCache sharedImageCache] storeImage:image forKey:urlString];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [weakSelf processErrorDownloadingImage:error];
        }];
        [[NSOperationQueue mainQueue] addOperation:op];
    }
    else {
        [[RedboothApiClient sharedInstance] GET:urlString parameters:nil success:^(NSURLSessionDataTask *dataTask, id responseobject) {
            [weakSelf processDownloadedImage:(UIImage*)responseobject inImageView:imageView];
            [[SDImageCache sharedImageCache] storeImage:(UIImage*)responseobject forKey:urlString];
        } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
            [weakSelf processErrorDownloadingImage:error];
        }];
    }
}

- (YLImageView*)imageViewWithCachedImage:(UIImage*)cachedImage
{
    YLImageView *imageView = [[YLImageView alloc] initWithFrame:CGRectMake(5, [self.currentOffset intValue], self.frame.size.width-ss_Margin_2, kImagePlaceholderHeight)];
    if (cachedImage) {
        self.subviewsToBeRendered = @(self.subviewsToBeRendered.intValue - 1);
        [self updateImageView:imageView withImage:cachedImage];
    }
    else {
        [imageView setImage:[UIImage imageNamed:@"Horizontal-loader-dots-redbooth@2x.gif"]];
        [imageView setContentMode:UIViewContentModeCenter]; //This content mode is only for the placeholder
    }
    [imageView setClipsToBounds:YES];
    [self.imageViewArray addObject:imageView];
    [self addNewExclusionPathForImageView:imageView];
    self.currentOffset = @([self.currentOffset intValue] + imageView.frame.size.height);
    return imageView;
}

- (BOOL)parseRedboothAPIURL:(NSString*)urlString
{
    BOOL isRedbooth = [urlString hasPrefix:@"/api/"] || [urlString hasPrefix:@"/downloads/"];
    if (isRedbooth) {
        urlString = [@"https://redbooth.com" stringByAppendingString:urlString];
    }
    return isRedbooth;
}

- (void)processErrorDownloadingImage:(NSError*)error
{
    NSLog(@"Error: %@", error);
    self.subviewsToBeRendered = @(self.subviewsToBeRendered.intValue - 1);
    if ([self.subviewsToBeRendered intValue] == 0) {
        [self updateTextViewHeight];
    }
}

- (void)processDownloadedImage:(UIImage*)image inImageView:(UIImageView*)imageView
{
    int oldheight = imageView.frame.size.height;
    [self updateImageView:imageView withImage:image];
    [self updateExclusionPathForImageView:imageView];
    int offsetHeight = oldheight - imageView.frame.size.height;
    self.previuosHeightOffset = @([self.previuosHeightOffset intValue] + offsetHeight);
    NSLog(@"TEXTVIEW HEIGHT: %f",self.frame.size.height);
    self.subviewsToBeRendered = @(self.subviewsToBeRendered.intValue - 1);
    if ([self.subviewsToBeRendered intValue] == 0) {
        [self updateTextViewHeight];
    }
}

- (void)addYoutubeVideoWithURL:(NSString*)urlString
{
    urlString = [urlString stringByReplacingOccurrencesOfString:@"<YOUTUBE>" withString:@""];
    YTPlayerView *playerView = [[YTPlayerView alloc] initWithFrame:CGRectMake(0, [self.currentOffset intValue], self.frame.size.width, self.frame.size.width*kYoutubeVideoHeightRatio)];
    [playerView loadWithVideoId:urlString];
    [self.imageViewArray addObject:playerView];
    [self addNewExclusionPathForImageView:playerView];
    [self addSubview:playerView];
    self.currentOffset = @([self.currentOffset intValue] + playerView.frame.size.height);
}

/**
 *  For normal attributed strings, we just append them to the current attributedText of the textView
 *  We update the `currentOffset` variable, used to know the current position in the frame of the textView
 *  this position is used to add the IMAGES in the correct place (they are added as subviews!)
 *
 */
- (void)addAttributedString:(NSMutableAttributedString *)attString
{
    if (attString.length == 0) {
        return;
    }
    if ([self attributedStringIsOnlyEmptySpaces:attString]) {
        return;
    }
    CGSize size = [(NSMutableAttributedString*)attString boundingRectWithSize:CGSizeMake(self.frame.size.width-textViewLeftInset, 999) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:NULL].size;
    [self.attributedString appendAttributedString:attString];
    self.currentOffset = @([self.currentOffset intValue] + size.height + 10);
}

- (BOOL)attributedStringIsOnlyEmptySpaces:(NSAttributedString*)attString
{
    if (attString.length < 4) {
        NSString *trimmedString = [attString.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return trimmedString.length == 0;
    }
    return NO;
}

/**
 *  Add new exclusion path to the text view.
 *  We add a exclusion path for each GIF we want to show.
 */
- (void)addNewExclusionPathForImageView:(UIView*)view
{
    UIBezierPath * imgRect = [UIBezierPath bezierPathWithRect:CGRectMake(0, view.frame.origin.y, self.frame.size.width+100, view.frame.size.height)];
    NSMutableArray *exclusionPaths = [self.textContainer.exclusionPaths mutableCopy];
    if (!exclusionPaths) {
        exclusionPaths = [@[] mutableCopy];
    }
    [exclusionPaths addObject:imgRect];
    self.textContainer.exclusionPaths = exclusionPaths;
}


# pragma mark - update elements

- (void)updateTextViewHeight
{
    if ([self.previuosHeightOffset intValue] != 0) {
        [self setFrameHeight:self.frameHeight-[self.previuosHeightOffset intValue]];
    }
    [self.gifDelegate textViewHeightWasUpdatedWithHeight:self.frameHeight];
}

/**
 *  The exclusion paths are initialized to the frame of the placeholder
 *  Once the image is downloaded we need to update the exclusion path to the new frame
 */
- (void)updateExclusionPathForImageView:(UIImageView*)imageView
{
    if ([self.imageViewArray containsObject:imageView]) {
        int index = (int)[self.imageViewArray indexOfObject:imageView];
        NSMutableArray *exclusionPaths = [self.textContainer.exclusionPaths mutableCopy];
        UIBezierPath * imgRect = [UIBezierPath bezierPathWithRect:CGRectMake(0, imageView.frame.origin.y, self.frame.size.width, imageView.frame.size.height)];
        exclusionPaths[index] = imgRect;
        self.textContainer.exclusionPaths = exclusionPaths;
    }
}

/**
 *  We insert imageViews with placeholders while the Images are downloaded
 *  When the download is complete we need to update the image and the frame of the imageView.
 */
- (void)updateImageView:(UIImageView*)imageView withImage:(UIImage *)image
{
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    imageView.image = image;
    int width = image.size.width*image.scale < (self.frame.size.width-3) ? image.size.width*image.scale : (self.frame.size.width-3);
    [imageView setFrame:CGRectMake(3, imageView.frame.origin.y-[self.previuosHeightOffset intValue], self.frame.size.width-3, image.size.height*width/image.size.width)];
}



#pragma mark - lazy instantations

- (NSMutableArray*)imageViewArray
{
    if (!_imageViewArray) {
        _imageViewArray = [@[] mutableCopy];
    }
    return _imageViewArray;
}

@end
