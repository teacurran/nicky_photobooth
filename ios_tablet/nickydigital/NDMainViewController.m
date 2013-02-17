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

- (void)viewDidLoad
{
    [super viewDidLoad];

	
	UIImage *bannerImage = [UIImage imageNamed:@"banner_default.png"];
	UIImageView* bannerView = [[UIImageView alloc] initWithImage:bannerImage];
	int bannerWidth = self.view.frame.size.height;
	int bannerHeight = (self.view.frame.size.height / bannerImage.size.width) * bannerImage.size.height;
	[bannerView setFrame:CGRectMake(0, 0, bannerWidth, bannerHeight)];
	[self.view addSubview:bannerView];
	
	
	photoGridController = [[NDPhotoGridViewController alloc] init];
	
	[self addChildViewController:photoGridController];
	
	UIView *photoGridContainer = [[UIView alloc] init];
	
	[photoGridContainer setFrame:CGRectMake(0, bannerHeight, self.view.frame.size.height, self.view.frame.size.width - bannerHeight)];
//	photoGridContainer.frame.size = self.view.frame.size; // CGRectMake(0, 0, self.window.frame.size, CGFloat height)
	[self.view addSubview:photoGridContainer];
	
	//set the frame for the photogrid
	CGFloat width = photoGridContainer.frame.size.width;
	CGFloat height = photoGridContainer.frame.size.height;
	NSLog(@"width:%d, height:%d", (int)width, (int)height);

	photoGridController.view.frame = CGRectMake(0, 0, width, height);

	[photoGridContainer addSubview:photoGridController.view];
	[photoGridController didMoveToParentViewController:self];
	
	
	//[self.view :photoGridController];
}


@end