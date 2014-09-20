//
//  MMMarkdownStyleSheet.h
//  Redbooth
//
//  Created by Isaac Roldan on 10/07/14.
//  Copyright (c) 2014 Redbooth. All rights reserved.
//

//Font names
#define mm_FontType_Normal          @"OpenSans"
#define mm_FontType_Bold            @"OpenSans-Bold"
#define mm_FontType_Light           @"OpenSans-Light"
#define mm_FontType_SemiBold        @"OpenSans-Semibold"
#define mm_FontType_Italic          @"OpenSans-Italic"
#define mm_FontType_BoldItalic      @"OpenSans-BoldItalic"
#define mm_FontType_Monospace       @"CourierNewPSMT"

// UIFonts
#define mm_Font_mainFont            [UIFont fontWithName:mm_FontType_Normal size:13]
#define mm_Font_Semibold_Big        [UIFont fontWithName:mm_FontType_SemiBold size:20]
#define mm_Font_Semibold_Medium     [UIFont fontWithName:mm_FontType_SemiBold size:16]
#define mm_Font_Semibold_Normal     [UIFont fontWithName:mm_FontType_SemiBold size:13]
#define mm_Font_Italic_Normal       [UIFont fontWithName:mm_FontType_Italic size:13]
#define mm_Font_Bold_Normal         [UIFont fontWithName:mm_FontType_Bold size:13]
#define mm_Font_BoldItalic_Normal   [UIFont fontWithName:mm_FontType_BoldItalic size:13]
#define mm_Font_Monospace_Normal    [UIFont fontWithName:mm_FontType_Monospace size:12]

// UIColors
#define mm_Color_Paragraph      [UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:1]
#define mm_Color_DarkGrey51     [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1]
#define mm_Color_DarkGrey69     [UIColor colorWithRed:69/255.0f green:69/255.0f blue:69/255.0f alpha:1]
#define mm_Color_LightGrey230   [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1]
#define mm_Color_LightGrey238   [UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1]
#define mm_Color_LightGrey250   [UIColor colorWithRed:250/255.0f green:250/255.0f blue:250/255.0f alpha:1.0f]
#define mm_Color_BlueMention_Foreground [UIColor colorWithRed:23/255.0f green:103/255.0f blue:115/255.0f alpha:1.0f]
#define mm_Color_BlueMention_Background [UIColor colorWithRed:211/255.0f green:236/255.0f blue:240/255.0f alpha:1.0f]
#define mm_Color_BlueLink       [UIColor colorWithRed:0.13 green:0.65 blue:0.72 alpha:1]

#define mm_Color_White          [UIColor whiteColor]



// Baselines
#define mm_Baseline_Offset_Big  @15
#define mm_Baseline_Offset_Medium @10
