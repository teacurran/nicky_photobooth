//
//  NDPhotoGridControllerViewController.m
//  nickydigital
//
//  Created by Terrence Curran on 2/10/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import "NDPhotoGridViewController.h"
#import "NDConstants.h"
#import "NDPhotoDetailViewController.h"

#import "BDRowInfo.h"
#import "UAModalPanel.h"
#import "Photo.h"
#import "AFJSONRequestOperation.h"
#import "NDMainViewController.h"
#import "UIImageView+AFNetworking.h"

@interface NDPhotoGridViewController ()

@end

@implementation NDPhotoGridViewController

NDPhotoDetailViewController *detailViewController;

NDMainViewController *_mainViewController;

UIRefreshControl *refreshControl;

NSMutableArray * _items;
NSMutableDictionary * _itemsLoading;

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

    
	refreshControl = [[UIRefreshControl alloc] init];
	refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
	[refreshControl addTarget:self
	action:@selector(refreshPhotos:)
	forControlEvents:UIControlEventValueChanged];
	
	[self.tableView addSubview:refreshControl];
	
	
	
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

NSLock *itemLock;

-(NSLock*) getItemLock {
	if (itemLock == Nil) {
		itemLock = [[NSLock alloc] init];
	}
	return itemLock;
}

-(void) loadPhotos
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSURL *photoListUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",  [defaults stringForKey:kPrefServerUrlKey], @"/api/photos"]];
	NSURLRequest *request = [NSURLRequest requestWithURL:photoListUrl];
	
	if (_items == nil) {
		_items = [NSMutableArray array];
	}
	if (_itemsLoading == nil) {
		_itemsLoading = [[NSMutableDictionary alloc] initWithCapacity:10];
	}
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		Boolean itemsChanged = false;
		
		NSLock *arrayLock = [self getItemLock];
		[arrayLock lock];
		
		for(id jsonImage in JSON)
		{
			NSString *filename = [jsonImage valueForKeyPath:@"filename"];
			
			Boolean found = false;
			for (id photo in _items) {
				if ([filename isEqualToString:[photo filename]]) {
					found = true;
					break;
				}
			}
			for (id key in _itemsLoading) {
				Photo *photo = [_itemsLoading objectForKey:key];
				if ([filename isEqualToString:[photo filename]]) {
					found = true;
					break;
				}
			}
			
			if (!found) {
				NSLog(@"adding photo: %@", filename);
				
				UIImageView *imageView = [[UIImageView alloc] init];
				imageView.clipsToBounds = YES;
				

				NSURL *imageUrl = [NSURL URLWithString:[
									 NSString stringWithFormat:@"%@/%@/%@",
									 [defaults stringForKey:kPrefServerUrlKey],
									 @"api/photo/300",
									 filename]
								   ];
				NSMutableURLRequest *imageRequest = [NSMutableURLRequest requestWithURL:imageUrl];
				//imageRequest.cachePolicy = NSURLRequestReloadIgnoringCacheData;
				imageRequest.timeoutInterval = 300.0;
				
				[imageView setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
					
					Photo *photo = [_itemsLoading objectForKey:request];
					if (photo != nil) {
						
						photo.thumbView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
						photo.thumbView.image = image;

						[_items addObject:photo];
						[_itemsLoading removeObjectForKey:request];
						[self reloadPhotos];
					}
					
				} failure:nil];
				
				
				Photo *photo = [[Photo alloc] init];
				[photo setFilename:filename];
				[photo setThumbView:imageView];
				
				[_itemsLoading setObject:photo forKey:imageRequest];

				//itemsChanged = true;

				//_items = [_items arrayByAddingObject:photo];
				//				        [self performSelector:@selector(animateUpdate:)
				//				                   withObject:[NSArray arrayWithObjects:imageView, imageView.image, nil]
				//				                   afterDelay:0.2 + (arc4random()%3) + (arc4random() %10 * 0.1)];
				
			}
		}
		
		// look for items to delete
		NSMutableArray *itemsToDelete = [NSMutableArray array];
		for (id photo in _items) {
			Boolean found = false;
			for(id jsonImage in JSON)
			{
				NSString *filename = [jsonImage valueForKeyPath:@"filename"];
				if ([filename isEqualToString:[photo filename]]) {
					found = true;
					break;
				}
			}
			
			if (!found) {
				[itemsToDelete addObject:photo];
				itemsChanged = true;
			}
		}
		for (id photo in itemsToDelete) {
			[_items removeObject:photo];
		}
		
		if (itemsChanged) {
			[self reloadPhotos];
		}
		[self reloadPhotos];
		[arrayLock unlock];
		
	} failure:nil];
	
	[operation start];
	
}

- (void) reloadPhotos {
	// put in some placeholders if we don't have enough images to fill out a row.
	int bufferPlaceholders = 0;
	int photoCount = _items.count;
	
	if (photoCount < 3) {
		
		bufferPlaceholders = 3 - photoCount;
		
	} else if (photoCount > 3 && photoCount < 6) {
		
		bufferPlaceholders = 6 - photoCount;
		
	} else if (photoCount > 6 && photoCount < 12) {
		
		bufferPlaceholders = 12 - photoCount;
		
	} else if (photoCount > 12 && photoCount < 18) {
		
		bufferPlaceholders = 18 - photoCount;
		
	} else if (photoCount > 18 && photoCount < 24) {
		
		bufferPlaceholders = 24 - photoCount;
		
	} else if (photoCount > 24 && photoCount < 30) {
		
		bufferPlaceholders = 30 - photoCount;
		
	} else if (photoCount > 30) {
		
		bufferPlaceholders = 12 - ((photoCount - 30) % 12);
		
	}
	
	NSLog(@"inserting placeholders:%d", bufferPlaceholders);
	_placeholderCount = bufferPlaceholders;

	[self reloadData];
}

-(void)refreshPhotos:(UIRefreshControl *)refresh {
	NSLock *arrayLock = [self getItemLock];
	[arrayLock lock];
	_items = nil;

	//[UIImageView clearAFImageCache];
	[arrayLock unlock];
	
	[self reloadData];
	
	[self loadPhotos];
	
	[refreshControl endRefreshing];
}

- (void) animateUpdate:(NSArray*)objects
{
    UIImageView *imageView = [objects objectAtIndex:0];
    UIImage* image = [objects objectAtIndex:1];
    [UIView animateWithDuration:0.5
                     animations:^{
                         imageView.alpha = 0.f;
                     } completion:^(BOOL finished) {
                         imageView.image = image;
                         [UIView animateWithDuration:0.2
                                          animations:^{
                                              imageView.alpha = 1;
                                          } completion:^(BOOL finished) {
                                              NSArray *visibleRowInfos =  [self visibleRowInfos];
                                              for (BDRowInfo *rowInfo in visibleRowInfos) {
                                                  [self updateLayoutWithRow:rowInfo animiated:YES];
                                              }
                                          }];
                     }];
}


@end
