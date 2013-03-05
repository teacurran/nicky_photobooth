//
//  NDConstants.h
//  smilebooth
//
//  Created by Terrence Curran on 1/14/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//RGB color macro with alpha
#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

@interface NDConstants : NSObject

extern NSString* const kSMileBoothAuthUrl;

extern NSString *const kFacebookAppId;
extern NSString *const kFacebookSecret;
extern NSString *const kFacebookRedirect;
extern NSString *const kFacebookScope;
extern NSString *const kFacebookOauth;

extern NSString *const kTwitterConsumerKey;
extern NSString *const kTwitterConsumerSecret;

extern int const kGridBorderWidth;

extern NSString *const kPrefServerUrlKey;
extern NSString *const kPrefServerUrlDefault;


@end
