//
//  KoaViewController.m
//  KoaMarkdownRenderDemo
//
//  Created by Isaac Roldanon 16/05/14.
//  Copyright (c) 2014 Isaac Roldan. All rights reserved.
//

#import "KoaViewController.h"
#import "MMMarkdown.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "YLGIFImage.h"
#import "YLImageView.h"
#import "VSAnimatedGIFResponseSerializer.h"
#import "UITextView+Gifs.h"

@interface KoaViewController ()


@end

@implementation KoaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITextView *myView = [UITextView new];
    [myView setEditable:NO];
    [myView setSelectable:YES];
    
    myView.frame = CGRectMake(50, 20, 320-50, self.view.frame.size.height-20);
    myView.backgroundColor = [UIColor whiteColor];
    [myView setLinkTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.13 green:0.65 blue:0.72 alpha:1]}];
    [self.view addSubview:myView];
    NSString *markdown = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Example" ofType:@"md"]  encoding:NSUTF8StringEncoding error:nil];

    NSError *error = nil;
    NSMutableAttributedString *stylie = [MMMarkdown HTMLStringWithMarkdown:markdown baseURL:@"redbooth.com" error:&error];
    
    [myView setAttributedContent:stylie];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
