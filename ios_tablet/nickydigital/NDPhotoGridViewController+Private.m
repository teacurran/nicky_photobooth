//
//  BDViewController+Private.m
//  BDDynamicGridViewDemo
//
//  Created by Nor Oh on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NDPhotoGridViewController+Private.h"

#import "UIImageView+AFNetworking.h"
#import "AFJSONRequestOperation.h"
#import "NDConstants.h"
#import "Photo.h"

@implementation NDPhotoGridViewController (Private)

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
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		Boolean itemsChanged = false;

		NSLock *arrayLock = [self getItemLock];
		[arrayLock lock];

		for(id jsonImage in JSON)
		{
			NSString *filename = [jsonImage valueForKeyPath:@"filename"];
			NSNumber *fileId = [jsonImage valueForKeyPath:@"id"];
	
			Boolean found = false;
			for (id photo in _items) {
				if ([filename isEqualToString:[photo filename]]) {
					found = true;
					break;
				}
			}

			if (!found) {
				NSLog(@"adding photo: %@", filename);

				UIImageView *imageView = [[UIImageView alloc] init];
				imageView.clipsToBounds = YES;
				
				[imageView setImageWithURL:[
								NSURL URLWithString:[
										NSString stringWithFormat:@"%@/%@/%@",
													 [defaults stringForKey:kPrefServerUrlKey],
													 @"api/photo/300",
													 filename]
								]
						placeholderImage:[UIImage imageNamed:@"placeholder_landscape.png"]
				 ];

				imageView.frame = CGRectMake(0, 0, 300, 200);

				Photo *photo = [[Photo alloc] init];
				[photo setFilename:filename];
				[photo setFileId:fileId];
				[photo setThumbView:imageView];
				
				[_items addObject:photo];
				itemsChanged = true;
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
			
			/*
			if (bufferPlaceholders > 0) {
				for (int i=0; i<bufferPlaceholders; i++) {
					UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder_landscape.png"]];
					imageView.clipsToBounds = YES;
					
					//imageView.frame = CGRectMake(0, 0, 200, 150);
					
					Photo *photo = [[Photo alloc] init];
					[photo setFilename:Nil];
					[photo setFileId:0];
					[photo setThumbView:imageView];
					
					[_items insertObject:photo atIndex:0];
					itemsChanged = true;
				}
			}
			*/
			
			
			
			
			
			[self reloadData];
		}
		[arrayLock unlock];

	} failure:nil];
	
	[operation start];
	
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
