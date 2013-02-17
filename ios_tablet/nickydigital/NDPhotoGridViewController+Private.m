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

#define kNumberOfPhotos 40
@implementation NDPhotoGridViewController (Private)

-(void)buildBarButtons
{
    UIBarButtonItem * reloadButton = [[UIBarButtonItem alloc] initWithTitle:@"Lay it!"
                                                                      style:UIBarButtonItemStylePlain 
                                                                     target:self 
                                                                     action:@selector(animateReload)];

    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: reloadButton, nil];

}

-(NSArray*)_imagesFromBundle
{   
    NSArray *images = [NSArray array];
    NSBundle *bundle = [NSBundle mainBundle];
    for (int i=0; i< kNumberOfPhotos; i++) {
        NSString *path = [bundle pathForResource:[NSString stringWithFormat:@"%d", i + 1] ofType:@"jpg"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image) {
            images = [images arrayByAddingObject:image];
        }
    }
    return images;
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

				UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder.png"]];
				imageView.clipsToBounds = YES;
				
				[imageView setImageWithURL:[
								NSURL URLWithString:[
										NSString stringWithFormat:@"%@/%@/%@",  [defaults stringForKey:kPrefServerUrlKey], @"api/photo/200", filename]
								]
						placeholderImage:[UIImage imageNamed:@"placeholder.png"]
				 ];

				imageView.frame = CGRectMake(0, 0, 200, 150);

				Photo *photo = [[Photo alloc] init];
				[photo setFilename:filename];
				[photo setFileId:fileId];
				[photo setThumbView:imageView];
				
				[_items addObject:photo];
				itemsChanged = true;
				//_items = [_items arrayByAddingObject:photo];

			}
		}

		// look for items to delete
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
				[_items removeObject:photo];
				itemsChanged = true;
			}
		}
		if (itemsChanged) {
			[self reloadData];
		}

	} failure:nil];
	
	[operation start];
	
}

- (void)_demoAsyncDataLoading
{
    _items = [NSArray array];
    //load the placeholder image

//    for (int i=0; i < kNumberOfPhotos; i++) {
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder.png"]];
//        imageView.frame = CGRectMake(0, 0, 44, 44);
//        imageView.clipsToBounds = YES;
//        _items = [_items arrayByAddingObject:imageView];
//    }

    NSArray *images = [self _imagesFromBundle];
    for (int i = 0; i < images.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder.png"]];
        imageView.clipsToBounds = YES;

        UIImage *image = [images objectAtIndex:i];
        imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
		imageView.image = image;
		
        _items = [_items arrayByAddingObject:imageView];
		
//        [self performSelector:@selector(animateUpdate:)
//                   withObject:[NSArray arrayWithObjects:imageView, image, nil]];
//                   afterDelay:0.2 + (arc4random()%3) + (arc4random() %10 * 0.1)];
    }

    [self reloadData];
	
//	NSArray *visibleRowInfos =  [self visibleRowInfos];
//	for (BDRowInfo *rowInfo in visibleRowInfos) {
//		[self updateLayoutWithRow:rowInfo animiated:NO];
//	}

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
