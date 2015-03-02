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

static CGFloat const kParallaxViewHeight  = 200;

@interface HCSParallaxCarousel () <APParallaxViewDelegate ,UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *URLs;

@end

@implementation HCSParallaxCarousel

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    
    if (self) {
        [self initializeCarouselView];
    }
    
    return self;
}

- (void)initializeCarouselView {
    _carouselView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, kParallaxViewHeight)];
    [self setCarouselBackgroundColor:[UIColor blackColor]];
    [self setUpCollectionView];
    [self setUpPageControl];
    [self setUpParallaxView];
}

- (void)setUpParallaxView {
    [self addParallaxWithView:self.carouselView andHeight:kParallaxViewHeight];
    self.parallaxView.delegate = self;
}

@synthesize numberOfItems=_numberOfItems;

- (void)setUpCollectionView {
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
    [self.carouselView addSubview:_collectionView];
    [self.collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.carouselView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:0 metrics:nil views:@{@"collectionView":_collectionView}]];
    [self.carouselView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:0 metrics:nil views:@{@"collectionView":_collectionView}]];
    
    [self registerCells];
}

- (void)setUpPageControl {
    _pageControl = [[UIPageControl alloc] initWithFrame:(CGRect){kMargin, self.carouselView.height - kPageControlHeight, self.carouselView.width - 2 * kMargin, kPageControlHeight}];
    [self.carouselView addSubview:_pageControl];
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
    
    _pageControl.enabled = NO;
    _pageControl.hidden = YES;
}

- (void)registerCells {
    [self registerClass:[self reusableCellClass] forCellWithReuseIdentifier:NSStringFromClass([self reusableCellClass])];
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [_collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (Class)reusableCellClass {
    return [HCSImageScrollerCell class];
}

- (void)scrollToImageAtIndex:(NSUInteger)index animated:(BOOL)animated {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfItems];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [self reuseIdentifierForIndexPath:indexPath];
    HCSImageScrollerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell configureWithInfo:[self.carouselDelgate imageScroller:self infoForItemAtIndex:indexPath.item]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.carouselView.width, self.carouselView.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.carouselDelgate imageScroller:self didSelectImageAtIndex:indexPath.row];
}

- (NSString *)reuseIdentifierForIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(reuseIdentifierForImageScroller:index:)]) {
        return [self.carouselDelgate reuseIdentifierForImageScroller:self index:indexPath.item];
    } else {
        return NSStringFromClass([self reusableCellClass]);
    }
}

- (NSUInteger)numberOfItems {
    NSUInteger numberOfAvailableImages = [self.carouselDelgate numberOfImagesAvailableForImageScroller:self];
    
    if ([_pageControl sizeForNumberOfPages:numberOfAvailableImages].width < (self.width - 2 * kMargin)) {
        _numberOfItems = numberOfAvailableImages;
    } else {
        _numberOfItems = kMaxNumberOfImages;
    }
    
    return _numberOfItems;
}

- (void)reloadCarouselData {
    _pageControl.numberOfPages = [self numberOfItems];
    _pageControl.currentPage = 0;
    _pageControl.hidden = NO;
    
    [self.collectionView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = _collectionView.width;
    float fractionalPage = _collectionView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;
    
    if ([self.carouselDelgate respondsToSelector:@selector(didChangePageAtIndex:)]) {
        [self.carouselDelgate didChangePageAtIndex:_collectionView.contentOffset.x];
    }
}

#pragma mark - APParallaxViewDelegate

- (void)parallaxView:(APParallaxView *)view didChangeFrame:(CGRect)frame {
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Customize methods

- (void)setCarouselBackgroundColor:(UIColor *)backgroundColor {
    [self.carouselView setBackgroundColor:backgroundColor];
}

@end
