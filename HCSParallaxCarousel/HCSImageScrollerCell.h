//
//  HCSImageScrollerCell.h
//  HCSParallaxCarousel
//
//  Created by Sahil Kapoor on 02/03/15.
//  Copyright (c) 2015 Hot Cocoa Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DACircularProgressView.h"

@interface HCSImageScrollerCell : UICollectionViewCell

@property (nonatomic, strong) DACircularProgressView *progressView;
@property (nonatomic, strong) UIImageView *imageView;

- (void)setUpGradient;
- (void)configureWithInfo:(id)info;
- (void)setImageURL:(NSURL *)URL;

+ (NSString *)reuseIdentifier;
- (void)setImageWithReq:(NSURLRequest *)primaryRequest
        fallBackRequest:(NSURLRequest *)fallBackRequest;

@end
