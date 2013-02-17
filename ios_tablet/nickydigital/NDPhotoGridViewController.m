//
//  NDPhotoGridControllerViewController.m
//  nickydigital
//
//  Created by Terrence Curran on 2/10/13.
//  Copyright (c) 2013 Terrence Curran. All rights reserved.
//

#import "NDPhotoGridViewController.h"
#import "NDPhotoGridViewController+Private.h"
#import "BDRowInfo.h"
#import "UAModalPanel.h"
#import "NDPhotoDetailModalPanel.h"

@interface NDPhotoGridViewController ()

@end

@implementation NDPhotoGridViewController

UAModalPanel *detailPanel;

- (void)viewDidLoad
{

    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.delegate = self;
    
    self.onLongPress = ^(UIView* view, NSInteger viewIndex){
        NSLog(@"Long press on %@, at %d", view, viewIndex);
    };
    
    self.onDoubleTap = ^(UIView* view, NSInteger viewIndex){
        NSLog(@"Double tap on %@, at %d", view, viewIndex);
    };
	
	__weak NDPhotoGridViewController *blockSelf = self;
	self.onSingleTap = ^(UIView* view, NSInteger viewIndex) {

		// create the detail panel the first time we load.
		if (detailPanel == nil) {
			detailPanel = [[NDPhotoDetailModalPanel alloc] initWithFrame:blockSelf.view.bounds title:@"test"];
			//[detailPanel hide];
			detailPanel.shouldBounce = NO;
		}
		
        NSLog(@"Single tap on %@, at %d", view, viewIndex);

		//		NDPhotoGridViewController *strongSelf = blockSelf;
		//		detailPanel.frame = CGRectMake(0, 0, strongSelf.view.frame.size.width, strongSelf.view.frame.size.height);

		[blockSelf.view addSubview:detailPanel];

		//[self.view addSubview:detailPanel];
		//[detailPanel showFromPoint:[view center]];
		[detailPanel show];
		//NDPhotoGridViewController *strongSelf = blockSelf;

		//[modalPanel showFromPoint:[sender center]];
	};

	
    //[self _demoAsyncDataLoading];

	[NSTimer scheduledTimerWithTimeInterval:2.0
									 target:self
								   selector:@selector(loadPhotos)
								   userInfo:nil
									repeats:YES];


}

- (void)animateReload
{
    _items = [NSArray new];
    [self _demoAsyncDataLoading];
}

- (NSUInteger)numberOfViews
{
    return _items.count;
}

-(NSUInteger)maximumViewsPerCell
{
    return 5;
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
			numOfViews = 4;
		} else if (row < 4) {
			numOfViews = 5;
		} else {
			numOfViews = 10;
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
    UIImageView * imageView = [_items objectAtIndex:index];
    return imageView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    //Call super when overriding this method, in order to benefit from auto layout.
    [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    return YES;
}

- (CGFloat)rowHeightForRowInfo:(BDRowInfo *)rowInfo
{
	
	int photo_width = self.view.frame.size.width / rowInfo.viewsPerCell;
	
	int row_height = 3 * photo_width / 4;
	
	return row_height;
	
	
//	if (rowInfo.order < 2) {
//		return 200;
//	} else if (rowInfo.order < 4) {
//		return 100;
//	} else {
//		return 50;
//	}
	
	
	
    //    if (rowInfo.viewsPerCell == 1) {
    //        return 125  + (arc4random() % 55);
    //    }else {
    //        return 100;
    //    }
//    return 200 + (arc4random() % 125);
}

@end
