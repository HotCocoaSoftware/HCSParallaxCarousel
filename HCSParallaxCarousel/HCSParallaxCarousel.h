//
//  HCSParallaxCarousel.h
//  HCSParallaxCarousel
//
//  Created by Sahil Kapoor on 02/03/15.
//  Copyright (c) 2015 Hot Cocoa Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol HCSParallaxCarouselDelegate <NSObject>

- (NSUInteger)numberOfImagesAvailableForImageScroller:(UIView *)scroller;
- (id)imageScroller:(UIView *)scroller infoForItemAtIndex:(NSUInteger)index;

@optional

- (void)imageScroller:(UIView *)scroller didSelectImageAtIndex:(NSUInteger)index;
- (void)imageScroller:(UIView *)scroller didScrollToHeight:(CGFloat)height;
- (NSString *)reuseIdentifierForImageScroller:(UIView *)scroller index:(NSUInteger)index;
- (void)didChangeToPageAtIndex:(NSInteger)index;

@end

@interface HCSParallaxCarousel : UITableView

@property (nonatomic, strong) UIView *carouselView;
@property (nonatomic, weak) id<HCSParallaxCarouselDelegate> carouselDelegate;
@property (nonatomic, readonly) NSUInteger numberOfItems;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic) BOOL hidePageControl;

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style carouselHeight:(CGFloat)height;
- (void)reloadCarouselData;
- (void)scrollToImageAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;
- (void)registerCells;
- (Class)reusableCellClass;

- (void)setCarouselBackgroundColor:(UIColor *)backgroundColor;

@end
