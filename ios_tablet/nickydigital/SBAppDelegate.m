//
//  SBAppDelegate.m
//  smilebooth
//
//  Created by Terrence Curran on 1/10/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//
#import <HockeySDK/HockeySDK.h>

#import "NDMainViewController.h"
#import "SBAppDelegate.h"
#import "NDConstants.h"

@interface SBAppDelegate(HockeyProtocols) <BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate> {}
@end

@implementation SBAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

	// Hockey App
	[[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:@"2259484855ddb380f84856dfaeaa43aa"
														 liveIdentifier:@"2259484855ddb380f84856dfaeaa43aa"
															   delegate:self];
	[[BITHockeyManager sharedHockeyManager] startManager];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [NDMainViewController singleton];

	//self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    //self.window.rootViewController = self.navigationController;
	
	self.window.rootViewController = self.viewController;

	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	
	// Set the application defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:kPrefServerUrlDefault forKey:kPrefServerUrlKey];
	[defaults registerDefaults:appDefaults];
	[defaults synchronize];
	

    [self.window makeKeyAndVisible];
    return YES;

}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
