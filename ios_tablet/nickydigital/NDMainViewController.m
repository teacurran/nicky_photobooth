//
//  NDRoot.m
//  nickydigital
//
//  Created by Terrence Curran on 2/17/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIView+LayerEffects.h"
#import "UIImageView+AFNetworking.h"
#import "AFJSONRequestOperation.h"

#import "NDConstants.h"
#import "NDMainViewController.h"

#import "NDPhotoGridViewController.h"
#import "NDPhotoGridViewController+Private.h"

@implementation NDMainViewController

@synthesize serviceLoginView;
@synthesize buttonLogOut;
@synthesize labelLoggedOut;
@synthesize labelAccountMessage;

NDPhotoGridViewController *photoGridController;

UIImage *bannerImage;
UIImageView *bannerView;
UIView *photoGridContainer;

NSString *userEmailAddress;
NSString *userFacebookToken;
NSString *userFacebookUser;

UIColor *brandColor = nil;
bool _loggedIn = false;

Event *_event = nil;

int serviceLoginViewHeight = 100;

+ (id)singleton {
    static NDMainViewController *singletonController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonController = [[self alloc] init];
    });
    return singletonController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	int windowWidth = CGRectGetWidth(self.view.bounds);
	int windowHeight = CGRectGetHeight(self.view.bounds);
	
	bannerImage = [UIImage imageNamed:@"banner_default.png"];
	bannerView = [[UIImageView alloc] initWithImage:bannerImage];

	int bannerHeight = (windowWidth / bannerImage.size.width) * bannerImage.size.height;
	[bannerView setFrame:CGRectMake(0, 0, windowWidth, bannerHeight)];
	[self.view addSubview:bannerView];
	
	// create the photo grid controller
	photoGridController = [[NDPhotoGridViewController alloc] init];
	[self addChildViewController:photoGridController];
	
	// add the photo grid container
	photoGridContainer = [[UIView alloc] init];
	[photoGridContainer setFrame:CGRectMake(0, bannerHeight, windowWidth, windowHeight - bannerHeight)];
	[self.view addSubview:photoGridContainer];
	
	//set the frame for the photogrid
	CGFloat width = photoGridContainer.frame.size.width;
	CGFloat height = photoGridContainer.frame.size.height;
	NSLog(@"width:%d, height:%d", windowWidth, windowHeight);

	photoGridController.view.frame = CGRectMake(0, 0, width, height);

	// move the controller into the container.
	[photoGridContainer addSubview:photoGridController.view];
	[photoGridController didMoveToParentViewController:self];
	

	[[NSBundle mainBundle] loadNibNamed:@"LoggedInView" owner:self options:nil];

	[serviceLoginView setFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), serviceLoginViewHeight)];

	// Add a border above the serviceLoginView.
	CALayer *serviceLoginBorder = [CALayer layer];
	serviceLoginBorder.frame = CGRectMake(0, 0, serviceLoginView.frame.size.width, 3.0f);
	serviceLoginBorder.backgroundColor = [UIColor redColor].CGColor;
	[serviceLoginView.layer addSublayer:serviceLoginBorder];
	
	buttonLogOut.borderColor = [UIColor redColor];

	[buttonLogOut useWhiteLabel: YES];
	buttonLogOut.tintColor = [UIColor redColor];
	[buttonLogOut setShadow:[UIColor blackColor] opacity:0.8 offset:CGSizeMake(0, 1) blurRadius: 4];
    [buttonLogOut setGradientType:kUIGlossyButtonGradientTypeLinearSmoothExtreme];
	
	labelLoggedOut.hidden = true;
	
	
	[self.view addSubview:serviceLoginView];
	

	//[photoGridContainer setFrame:CGRectMake(0, bannerHeight, windowWidth, windowHeight - bannerHeight - serviceLoginViewHeight)];
	 
	//[self.view :photoGridController];
	
	[NSTimer scheduledTimerWithTimeInterval:10.0
									 target:self
								   selector:@selector(loadEvent)
								   userInfo:nil
									repeats:YES];
}

-(void) loadEvent
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSURL *photoListUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",  [defaults stringForKey:kPrefServerUrlKey], @"/api/event"]];
	NSURLRequest *request = [NSURLRequest requestWithURL:photoListUrl];
	

	// {
	// id: 1,
	// code: "citi",
	// banner: "/event/citi.jpg",
	// name: "NickyDigital Citi",
	// album_name: "NickyDigital Citi Album",
	// short_share: "Short Share #text",
	// long_share: "This is long share text."
	// }
	
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

		NSString *eventId = [JSON objectForKey:@"id"];
		int eventIdInt = [eventId intValue];
		
		Event *event = [self event];
		if (eventIdInt != event.eventId) {
			event.code = [JSON objectForKey:@"code"];
			event.banner = [JSON objectForKey:@"banner"];
			event.name = [JSON objectForKey:@"name"];
			event.album = [JSON objectForKey:@"album_name"];
			event.shortShare = [JSON objectForKey:@"short_share"];
			event.longShare = [JSON objectForKey:@"long_share"];
		}
	} failure:nil];

	[operation start];

}
										 
-(void)displayLoggedIn {

	[UIView animateWithDuration:1
                     animations:^{
						 [serviceLoginView setFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - serviceLoginViewHeight, CGRectGetWidth(self.view.bounds), serviceLoginViewHeight)];
                     } completion:^(BOOL finished) {
					 }
	 ];
	
}

-(void)hideLoggedIn {
	
	[UIView animateWithDuration:1
                     animations:^{
						 [serviceLoginView setFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), serviceLoginViewHeight)];
                     } completion:^(BOOL finished) {
					 }
	 ];
	
}

-(void)logInWithMessage:(NSString*)message {
	
	labelAccountMessage.text = message;
	_loggedIn = true;
	
	[self displayLoggedIn];
}

- (IBAction)btnLogoutClick:(id)sender {
	_loggedIn = false;
	[self hideLoggedIn];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	NSLog(@"FRAME:%f", CGRectGetWidth(self.view.bounds));

	int windowWidth = CGRectGetWidth(self.view.bounds);
	int windowHeight = CGRectGetHeight(self.view.bounds);

	int bannerHeight = (windowWidth / bannerImage.size.width) * bannerImage.size.height;
	[bannerView setFrame:CGRectMake(0, 0, windowWidth, bannerHeight)];

	[photoGridContainer setFrame:CGRectMake(0, bannerHeight, windowWidth, windowHeight - bannerHeight)];

	
	//set the frame for the photogrid
	CGFloat width = photoGridContainer.frame.size.width;
	CGFloat height = photoGridContainer.frame.size.height;
	NSLog(@"width:%d, height:%d", windowWidth, windowHeight);
	
	photoGridController.view.frame = CGRectMake(0, 0, width, height);

	
}

- (UIColor*)brandColor
{
	if (!brandColor) {
		brandColor = UIColorFromRGB(0xFB0986);
	}
	return brandColor;
}

- (bool)loggedIn
{
	return _loggedIn;
}

- (Event*)event
{
	if (!_event) {
		_event = [[Event alloc] init];
		_event.code = @"default";
	}
	return _event;
}
										 

@end
