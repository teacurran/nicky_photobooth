//
//  SBAppDelegate.h
//  smilebooth
//
//  Created by Terrence Curran on 1/10/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NDPhotoGridViewController;

@interface SBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NDPhotoGridViewController *viewController;

@end
