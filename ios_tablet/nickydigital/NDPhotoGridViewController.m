//
//  NDPhotoGridControllerViewController.m
//  nickydigital
//
//  Created by Terrence Curran on 2/10/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import "NDPhotoGridViewController.h"
#import "NDPhotoGridViewController+Private.h"
#import "NDConstants.h"
#import "NDPhotoDetailViewController.h"

#import "BDRowInfo.h"
#import "UAModalPanel.h"
#import "Photo.h"
#import "UIImageView+AFNetworking.h"
#import "AFJSONRequestOperation.h"
#import "NDMainViewController.h"

@interface NDPhotoGridViewController ()

@end

@implementation NDPhotoGridViewController

NDPhotoDetailViewController *detailViewController;

NDMainViewController *_mainViewController;

- (void)viewDidLoad
{

    [super viewDidLoad];

	_placeholders = [NSMutableArray array];
	for(int i=0; i<[self maximumViewsPerCell]; i++) {
		UIImageView *placeholderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder_landscape.png"]];
		placeholderView.frame = CGRectMake(0, 0, 300, 200);
		placeholderView.clipsToBounds = YES;
		[_placeholders addObject:placeholderView];
	}
    
	//self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

//	[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"banner_default.png"] forBarMetrics:UIBarMetricsDefault];

	//self.navigationController.navigationBar.frame = CGRectMake(0, 0, 1536, 150);

	//return [self initWithCGImage:[[UIImage imageWithData:[NSData dataWithContentsOfFile:path]] CGImage] scale:2.0 orientation:UIImageOrientationUp];


	//UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.navigationController.navigationBar.frame];
	//imageView.contentMode = UIViewContentModeLeft;
	//imageView.image = [[UIImage imageNamed:@"banner_default.png"] CGImage;

	//imageView.image.scale = 1;

	//[self.navigationController.navigationBar insertSubview:imageView atIndex:0];



	//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: reloadButton, nil];


	//[[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];

    self.delegate = self;
    
    self.onLongPress = ^(UIView* view, NSInteger viewIndex){
        NSLog(@"Long press on %@, at %d", view, viewIndex);
    };
    
    self.onDoubleTap = ^(UIView* view, NSInteger viewIndex){
        NSLog(@"Double tap on %@, at %d", view, viewIndex);
    };
	
	__weak NDPhotoGridViewController *blockSelf = self;
	//__weak NSArray *blockItems = _items;
	self.onSingleTap = ^(UIView* view, NSInteger viewIndex) {

		// create the detail panel the first time we load.
		if (detailViewController == nil) {
			detailViewController = [[NDPhotoDetailViewController alloc] init];
		}
		
        NSLog(@"Single tap on %@, at %d", view, viewIndex);

		//		NDPhotoGridViewController *strongSelf = blockSelf;
		//detailPanel.detailPanel. = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50);


		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

		if (viewIndex < _items.count) {
			Photo *photo = [_items objectAtIndex:(_items.count - viewIndex - 1) ];

			if (photo.detailView == nil) {
				UIImageView *imageView = [[UIImageView alloc] init];
				imageView.clipsToBounds = YES;
				
				NSURL *url = [NSURL URLWithString:[
											NSString stringWithFormat:@"%@/%@/%@",
												   [defaults stringForKey:kPrefServerUrlKey],
												   @"api/photo/640",
												   photo.filename]
				];

				NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
				[request setHTTPShouldHandleCookies:NO];
				[request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

				[imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
					
					photo.detailView.image = image;
					[detailViewController setPhoto:photo withView:photo.detailView];
					
				} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
					
				}];
				//[imageView setImageWithURL:url
				//			placeholderImage:photo.thumbView.image
				//	];

				photo.detailView = imageView;
				[detailViewController setPhoto:photo withView:photo.detailView];

				//imageView.frame = CGRectMake(0, 0, 300, 200);
				
			} else {
				[detailViewController setPhoto:photo withView:photo.detailView];
			}
			
			//UIImageView * imageView = photo.thumbView;
			
			[blockSelf.view addSubview:detailViewController.view];

			//[self.view addSubview:detailPanel];
			//[detailPanel.detailPanel showFromPoint:CGPointMake([view center].x, [view center].y - 300)];
			[detailViewController.detailPanel show];
			[detailViewController updateShareButtons];
			
		}
		
		//NDPhotoGridViewController *strongSelf = blockSelf;

		//[modalPanel showFromPoint:[sender center]];
	};
	
	[self setBackgroundColor:[UIColor whiteColor]];
	[self setBorderWidth:kGridBorderWidth];

	
    //[self _demoAsyncDataLoading];

	[NSTimer scheduledTimerWithTimeInterval:2.0
									 target:self
								   selector:@selector(loadPhotos)
								   userInfo:nil
									repeats:YES];


}

- (NSUInteger)numberOfViews
{
    return _items.count + _placeholderCount;
}

/* Won't be used because we are using a custom layout */
-(NSUInteger)maximumViewsPerCell
{
    return 12;
}

- (NSArray*) customLayout
{
	//rearrange views on the table by recalculating row infos
	NSArray *_rowInfos = [NSArray new];
	NSUInteger accumNumOfViews = 0;
	BDRowInfo * ri;
	NSUInteger kMaxViewsPerCell = self.delegate.maximumViewsPerCell;
	NSAssert(kMaxViewsPerCell>0, @"Maximum number of views per cell must be greater than zero");
	NSUInteger kMinViewsPerCell = 1;
	
	if ([self.delegate respondsToSelector:@selector(minimumViewsPerCell)]) {
		kMinViewsPerCell = self.delegate.minimumViewsPerCell==0?1:self.delegate.minimumViewsPerCell;
	}
	
	NSAssert(kMinViewsPerCell <= kMaxViewsPerCell, @"Minimum number of views per row cannot be greater than maximum number of views per row.");
	
	int row=0;
	while (accumNumOfViews < self.delegate.numberOfViews) {
		NSUInteger numOfViews = 0;
		if (row < 2) {
			numOfViews = 3;
		} else if (row < 6) {
			numOfViews = 6;
		} else {
			numOfViews = 12;
		}
		
		numOfViews = (accumNumOfViews+numOfViews <= self.delegate.numberOfViews)?numOfViews:(self.delegate.numberOfViews-accumNumOfViews);

		ri = [BDRowInfo new];
		ri.order = _rowInfos.count;
		ri.accumulatedViews = accumNumOfViews;
		ri.viewsPerCell = numOfViews;
		accumNumOfViews = accumNumOfViews + numOfViews;
		_rowInfos = [_rowInfos arrayByAddingObject:ri];

		row++;
	}
	ri.isLastCell = YES;
	NSAssert(accumNumOfViews == self.delegate.numberOfViews, @"wrong accum %u ", ri.accumulatedViews);

	return _rowInfos;
}

- (UIView *)viewAtIndex:(NSUInteger)index rowInfo:(BDRowInfo *)rowInfo
{
	if (index < _items.count) {
		Photo *photo = [_items objectAtIndex:(_items.count - index - 1) ];
		
		UIImageView * imageView = photo.thumbView;
		return imageView;
	}

	return [_placeholders objectAtIndex:(index - _items.count)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    //Call super when overriding this method, in order to benefit from auto layout.
    [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    return YES;
}

- (CGFloat)rowHeightForRowInfo:(BDRowInfo *)rowInfo
{
	int photo_width = (self.view.frame.size.width - (rowInfo.viewsPerCell * kGridBorderWidth) - kGridBorderWidth) / rowInfo.viewsPerCell;
	
	int row_height = 2 * photo_width / 3;
	
	return row_height;
}

- (NDMainViewController*) mainViewController
{
	if (!_mainViewController) {
		_mainViewController = [NDMainViewController singleton];
	}
	return _mainViewController;
}

@end
