//
//  HCSParallaxCarousel.h
//  HCSParallaxCarousel
//
//  Created by Sahil Kapoor on 02/03/15.
//  Copyright (c) 2015 Hot Cocoa Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol HCSParallaxCarousel <NSObject>

- (NSUInteger)numberOfImagesAvailableForImageScroller:(UIView *)scroller;
- (id)imageScroller:(UIView *)scroller infoForItemAtIndex:(NSUInteger)index;
- (void)imageScroller:(UIView *)scroller didSelectImageAtIndex:(NSUInteger)index;

@optional

- (NSString *)reuseIdentifierForImageScroller:(UIView *)scroller index:(NSUInteger)index;
- (void)didChangePageAtIndex:(CGFloat)newOffsetX;

@end

@interface HCSParallaxCarousel : UITableView

@property (nonatomic, strong) UIView *carouselView;
@property (nonatomic, weak) id<HCSParallaxCarousel> carouselDelgate;
@property (nonatomic, readonly) NSUInteger numberOfItems;
@property (nonatomic, strong) UIPageControl *pageControl;

- (void)reloadCarouselData;
- (void)scrollToImageAtIndex:(NSUInteger)index animated:(BOOL)animated;

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerCells;
- (Class)reusableCellClass;

- (void)setCarouselBackgroundColor:(UIColor *)backgroundColor;

@end
