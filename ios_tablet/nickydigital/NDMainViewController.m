//
//  NDRoot.m
//  nickydigital
//
//  Created by Terrence Curran on 2/17/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import "NDMainViewController.h"

#import "NDPhotoGridViewController.h"
#import "NDPhotoGridViewController+Private.h"

@implementation NDMainViewController

NDPhotoGridViewController *photoGridController;

UIImage *bannerImage;
UIImageView *bannerView;
UIView *photoGridContainer;
UIView *serviceLoginView;

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
	
	
	serviceLoginView = [[UIView alloc] init];
	serviceLoginView.backgroundColor = [UIColor redColor];
	[serviceLoginView setFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), serviceLoginViewHeight)];
	[self.view addSubview:serviceLoginView];
	
	[self displayLoggedIn];

	//[photoGridContainer setFrame:CGRectMake(0, bannerHeight, windowWidth, windowHeight - bannerHeight - serviceLoginViewHeight)];
	 
	//[self.view :photoGridController];
}

-(void)displayLoggedIn {

	[UIView animateWithDuration:1
                     animations:^{
						 [serviceLoginView setFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - serviceLoginViewHeight, CGRectGetWidth(self.view.bounds), serviceLoginViewHeight)];
                     } completion:^(BOOL finished) {
					 }
	 ];

	
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


@end
