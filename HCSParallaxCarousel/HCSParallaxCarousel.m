//
//  HCSParallaxCarousel.m
//  HCSParallaxCarousel
//
//  Created by Sahil Kapoor on 02/03/15.
//  Copyright (c) 2015 Hot Cocoa Software. All rights reserved.
//

#import "HCSParallaxCarousel.h"
#import "UIScrollView+APParallaxHeader.h"
#import "HCSImageScrollerCell.h"
#import "FrameAccessor.h"

static CGFloat const kPageControlHeight = 30;
static CGFloat const kMargin = 10.f;
static NSUInteger const kMaxNumberOfImages = 18;

@interface HCSParallaxCarousel () <APParallaxViewDelegate ,UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *URLs;
@property (nonatomic) CGFloat scrollViewTouchLocation;
@property (nonatomic) CGFloat carouselHeight;

@end

@implementation HCSParallaxCarousel

@synthesize numberOfItems=_numberOfItems;

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style carouselHeight:(CGFloat)height {
    self = [super initWithFrame:frame style:style];
    
    if (self) {
        _carouselHeight = height > kPageControlHeight ? height : kPageControlHeight;
        [self initializeCarouselView];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    return [self initWithFrame:frame style:style carouselHeight:200];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame style:UITableViewStylePlain];
}

- (void)initializeCarouselView {
    [self setCarouselBackgroundColor:[UIColor blackColor]];
    [self setUpCollectionView];
    [self setUpPageControl];
    [self setUpParallaxView];
}

#pragma mark - Carousel Set Up

- (void)setUpParallaxView {
    [self addParallaxWithView:self.carouselView andHeight:self.carouselHeight];
    self.parallaxView.delegate = self;
}

- (void)setUpCollectionView {
    [self.carouselView addSubview:self.collectionView];
    [self.collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.carouselView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:nil views:@{@"collectionView":self.collectionView}]];
    [self.carouselView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:0 metrics:nil views:@{@"collectionView":self.collectionView}]];
    
    [self registerCells];
}

- (void)setUpPageControl {
    [self.carouselView addSubview:self.pageControl];
    [self.pageControl setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.carouselView addConstraint:[NSLayoutConstraint constraintWithItem:self.pageControl
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.carouselView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1
                                                                   constant:0]];
    [self.carouselView addConstraint:[NSLayoutConstraint constraintWithItem:self.pageControl
                                                                  attribute:NSLayoutAttributeBottomMargin
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.carouselView
                                                                  attribute:NSLayoutAttributeBottomMargin
                                                                 multiplier:1
                                                                   constant:0]];
    
    self.pageControl.enabled = NO;
    self.pageControl.hidden = YES;
}

#pragma mark - Custom Cell

- (void)registerCells {
    [self registerClass:[self reusableCellClass] forCellWithReuseIdentifier:NSStringFromClass([self reusableCellClass])];
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (Class)reusableCellClass {
    return [HCSImageScrollerCell class];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfItems];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [self reuseIdentifierForIndexPath:indexPath];
    HCSImageScrollerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell configureWithInfo:[self.carouselDelegate imageScroller:self.carouselView infoForItemAtIndex:indexPath.item]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.carouselView.width, self.carouselView.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.carouselDelegate respondsToSelector:@selector(imageScroller:didSelectImageAtIndex:)]) {
        [self.carouselDelegate imageScroller:self.carouselView didSelectImageAtIndex:indexPath.row];
    }
}

#pragma mark - Setter

- (void)setHidePageControl:(BOOL)hidePageControl {
    self.pageControl.hidden = hidePageControl;
}

#pragma mark - Other Methods

- (NSString *)reuseIdentifierForIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(reuseIdentifierForImageScroller:index:)]) {
        return [self.carouselDelegate reuseIdentifierForImageScroller:self index:indexPath.item];
    } else {
        return NSStringFromClass([self reusableCellClass]);
    }
}

- (void)scrollToImageAtIndex:(NSUInteger)index animated:(BOOL)animated {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
}

- (NSUInteger)numberOfItems {
    NSUInteger numberOfAvailableImages = [self.carouselDelegate numberOfImagesAvailableForImageScroller:self];
    
    if ([self.pageControl sizeForNumberOfPages:numberOfAvailableImages].width < (self.width - 2 * kMargin)) {
        _numberOfItems = numberOfAvailableImages;
    } else {
        _numberOfItems = kMaxNumberOfImages;
    }
    
    return _numberOfItems;
}

- (void)reloadCarouselData {
    self.pageControl.numberOfPages = [self numberOfItems];
    self.pageControl.currentPage = 0;
    self.pageControl.hidden = NO;
    
    [self.collectionView reloadData];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.collectionView.width;
    float fractionalPage = self.collectionView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    
    if ([self.carouselDelegate respondsToSelector:@selector(didChangeToPageAtIndex:)]) {
        if (self.pageControl.currentPage != page) {
            [self.carouselDelegate didChangeToPageAtIndex:page];
        }
    }
    self.pageControl.currentPage = page;
}

#pragma mark - APParallaxViewDelegate

- (void)parallaxView:(APParallaxView *)view didChangeFrame:(CGRect)frame {
    if (frame.size.height < 200) {
        return;
    }
    [self.collectionView.collectionViewLayout invalidateLayout];
    if ([self.carouselDelegate respondsToSelector:@selector(imageScroller:didScrollToHeight:)] && self.scrollViewTouchLocation < self.carouselHeight) {
        [self.carouselDelegate imageScroller:self.carouselView didScrollToHeight:frame.size.height];
    }
}

#pragma mark - Customize Methods

- (void)setCarouselBackgroundColor:(UIColor *)backgroundColor {
    [self.carouselView setBackgroundColor:backgroundColor];
}

#pragma mark - Lazy Initializers

- (UIView *)carouselView {
    if (!_carouselView) {
        _carouselView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.carouselHeight)];
    }
    
    return _carouselView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        CGRect frame = CGRectMake(kMargin, self.carouselView.height - kPageControlHeight, self.carouselView.width - 2 * kMargin, kPageControlHeight);
        _pageControl = [[UIPageControl alloc] initWithFrame:frame];
    }
    
    return _pageControl;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = self.carouselView.bounds.size;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        
        CGRect frame = self.carouselView.bounds;
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [_collectionView setContentOffset:CGPointZero animated:NO];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
    }

    return _collectionView;
}

@end
