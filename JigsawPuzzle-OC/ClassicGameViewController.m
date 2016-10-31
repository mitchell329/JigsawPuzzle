//
//  ClassicGameViewController.m
//  JigsawPuzzle-OC
//
//  Created by Shuai Yuan on 26/10/16.
//  Copyright © 2016 Mitchell. All rights reserved.
//

#import "ClassicGameViewController.h"
#import <UIKit/UIKit.h>

@interface ClassicGameViewController ()
{
    //UIImage *selectedImage;
    CGFloat imageSize;
    CGFloat tileSize;
    NSMutableArray *tilesOuterArray;
    NSMutableArray *originalPositionOuterArray;
    NSMutableArray *currentPositionOuterArray;
    CGRect emptyTile;
    CGPoint emptyTilePosition;
    int grid;
    int steps;
    int ruffleSteps;
}
@end

@implementation ClassicGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    grid = self.settings.getDifficultLevel + 3;
    ruffleSteps = pow(3, grid);
    //ruffleSteps = 6;
    steps = 0;
    _stepsLabel.text = [@(steps) stringValue];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self generateTiles:self.settings.getImage intoGrid:grid];
    self.thumbImageView.image = self.settings.getImage;
    [self ruffleTiles];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIImageView *)cropImage : (UIImage *)image atPosition: (CGPoint)position
{
    CGRect cropRect = CGRectMake(position.x * (tileSize + 1), position.y * (tileSize + 1), tileSize, tileSize);
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    UIImageView *croppedImageView = [[UIImageView alloc] initWithImage:croppedImage];
    croppedImageView.frame = cropRect;
    
    return croppedImageView;
}

-(void)generateTiles : (UIImage *)image intoGrid:(int)number
{
    imageSize = _imageGridView.frame.size.height;
    tileSize = imageSize / number - 1;
    tilesOuterArray = [NSMutableArray arrayWithCapacity:number];
    originalPositionOuterArray = [NSMutableArray arrayWithCapacity:number];
    currentPositionOuterArray = [NSMutableArray arrayWithCapacity:number];
    
    UIGraphicsBeginImageContext(CGSizeMake(imageSize, imageSize));
    [image drawInRect:CGRectMake(0, 0, imageSize, imageSize)];
    UIImage *newSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    for (int i = 0; i < grid; i++) {
        NSMutableArray *originalPositionInnerArray = [NSMutableArray arrayWithCapacity:number];
        NSMutableArray *currentPositionInnerArray = [NSMutableArray arrayWithCapacity:number];
        NSMutableArray *tilesInnerArray = [NSMutableArray arrayWithCapacity:number];
        
        for (int j = 0; j < grid; j++) {
            UIImageView *tile = [self cropImage:newSizeImage atPosition:CGPointMake(i, j)];
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTile:)];
            singleTap.numberOfTapsRequired = 1;
            [tile setUserInteractionEnabled:YES];
            [tile addGestureRecognizer:singleTap];
            
            [tilesInnerArray addObject:tile];
            [originalPositionInnerArray addObject:[NSValue valueWithCGPoint:CGPointMake(i, j)]];
            [currentPositionInnerArray addObject:[NSValue valueWithCGPoint:CGPointMake(i, j)]];
            
            if (!(i == grid - 1 && j == grid - 1)) {
                [_imageGridView addSubview:tile];
            }
        }
        
        [tilesOuterArray addObject:tilesInnerArray];
        [originalPositionOuterArray addObject:originalPositionInnerArray];
        [currentPositionOuterArray addObject:currentPositionInnerArray];
    }
    
    emptyTile = CGRectMake((grid - 1) * (tileSize + 1), (grid - 1) * (tileSize + 1), tileSize, tileSize);
    emptyTilePosition = CGPointMake(grid - 1, grid - 1);
}

- (void) ruffleTiles
{
    int i, j;
    int k = 0;
    while (k < ruffleSteps) {
        CGPoint randomPosition = [self getRandomPosition];
        i = (int)randomPosition.y;
        j = (int)randomPosition.x;
        
        if ((i == emptyTilePosition.y - 1 && j == emptyTilePosition.x - 1) ||
            (i == emptyTilePosition.y - 1 && j == emptyTilePosition.x + 1) ||
            (i == emptyTilePosition.y + 1 && j == emptyTilePosition.x - 1) ||
            (i == emptyTilePosition.y + 1 && j == emptyTilePosition.x + 1) ||
            (i == emptyTilePosition.y && j == emptyTilePosition.x)) {
            continue;
        }
        
        UIView *randomTile = tilesOuterArray[j][i];
        
        //update tiles array
        tilesOuterArray[i][j] = tilesOuterArray[(int)emptyTilePosition.y][(int)emptyTilePosition.x];
        tilesOuterArray[(int)emptyTilePosition.y][(int)emptyTilePosition.x] = randomTile;
                                                
        
        
        //update current tile position
        CGPoint tempPosition = [currentPositionOuterArray[i][j] CGPointValue];
        
        NSLog(@"temp position: %d, %d", (int)tempPosition.x, (int)tempPosition.y);
        
        //currentPositionOuterArray[i][j] = currentPositionOuterArray[(int)emptyTilePosition.y][(int)emptyTilePosition.x];
        //currentPositionOuterArray[(int)emptyTilePosition.y][(int)emptyTilePosition.x] = [NSValue valueWithCGPoint:tempPosition];
        
        currentPositionOuterArray[i][j] = [NSValue valueWithCGPoint:CGPointMake(emptyTilePosition.x, emptyTilePosition.y)];
        currentPositionOuterArray[(int)emptyTilePosition.x][(int)emptyTilePosition.y] = [NSValue valueWithCGPoint:tempPosition];
        
        //swap current tile with empty tile in the view
        CGRect tempRect = randomTile.frame;
        randomTile.frame = emptyTile;
        emptyTile = tempRect;
        
        //update empty tile position
        emptyTilePosition = CGPointMake(i, j);
        
        k++;
    }
}

- (CGPoint) getRandomPosition
{
    int x, y;
    if (emptyTilePosition.x == 0) {
        x = arc4random() % 2;
    }
    else if (emptyTilePosition.x == grid - 1) {
        x = (emptyTilePosition.x - 1) + arc4random() % 2;
    }
    else {
        x = (emptyTilePosition.x - 1) + arc4random() % 3;
    }
    
    if (emptyTilePosition.y == 0) {
        y = arc4random() % 2;
    }
    else if (emptyTilePosition.y == grid - 1) {
        y = (emptyTilePosition.y - 1) + arc4random() % 2;
    }
    else {
        y = (emptyTilePosition.y - 1) + arc4random() % 3;
    }
    
    NSLog(@"random position: %d, %d", x, y);
    
    return CGPointMake(x, y);
}

- (void)tapTile : (UITapGestureRecognizer *)sender
{
    UIView *tappedTile = sender.view;
    CGPoint tappedPosition = tappedTile.frame.origin;
    CGPoint location = [sender locationInView:[sender.view superview]];
    int indexOuter = location.y / tileSize;
    int indexInner = location.x / tileSize;
    
    //for debugging only
    CGPoint p = [currentPositionOuterArray[indexOuter][indexInner] CGPointValue];
    NSLog(@"current position: %d, %d", (int)p.x, (int)p.y);
    
    CGPoint tempPoint = [currentPositionOuterArray[indexOuter][indexInner] CGPointValue];
    
    if ([self isWithinEmptyTile:CGPointMake(location.x - tileSize, location.y)]) {
        tappedTile.frame = CGRectMake(tappedPosition.x - (tileSize + 1), tappedPosition.y, tileSize, tileSize);
        
        //currentPositionOuterArray[indexOuter][indexInner] = currentPositionOuterArray[indexOuter][indexInner - 1];
        //currentPositionOuterArray[indexOuter][indexInner - 1] = [NSValue valueWithCGPoint:tempPoint];
        
        currentPositionOuterArray[indexOuter][indexInner] = [NSValue valueWithCGPoint:CGPointMake(indexOuter, indexInner - 1)];
        currentPositionOuterArray[indexOuter][indexInner - 1] = [NSValue valueWithCGPoint:tempPoint];
    }
    if ([self isWithinEmptyTile:CGPointMake(location.x + tileSize, location.y)]) {
        tappedTile.frame = CGRectMake(tappedPosition.x + (tileSize + 1), tappedPosition.y, tileSize, tileSize);
        
        //currentPositionOuterArray[indexOuter][indexInner] = currentPositionOuterArray[indexOuter][indexInner + 1];
        //currentPositionOuterArray[indexOuter][indexInner + 1] = [NSValue valueWithCGPoint:tempPoint];
        
        currentPositionOuterArray[indexOuter][indexInner] = [NSValue valueWithCGPoint:CGPointMake(indexOuter, indexInner + 1)];
        currentPositionOuterArray[indexOuter][indexInner + 1] = [NSValue valueWithCGPoint:tempPoint];
    }
    if ([self isWithinEmptyTile:CGPointMake(location.x, location.y - tileSize)]) {
        tappedTile.frame = CGRectMake(tappedPosition.x, tappedPosition.y - (tileSize + 1), tileSize, tileSize);
        
        //currentPositionOuterArray[indexOuter][indexInner] = currentPositionOuterArray[indexOuter - 1][indexInner];
        //currentPositionOuterArray[indexOuter - 1][indexInner] = [NSValue valueWithCGPoint:tempPoint];
        
        currentPositionOuterArray[indexOuter][indexInner] = [NSValue valueWithCGPoint:CGPointMake(indexOuter - 1, indexInner)];
        currentPositionOuterArray[indexOuter - 1][indexInner] = [NSValue valueWithCGPoint:tempPoint];
    }
    if ([self isWithinEmptyTile:CGPointMake(location.x, location.y + tileSize)]) {
        tappedTile.frame = CGRectMake(tappedPosition.x, tappedPosition.y + (tileSize + 1), tileSize, tileSize);
        
        //currentPositionOuterArray[indexOuter][indexInner] = currentPositionOuterArray[indexOuter + 1][indexInner];
        //currentPositionOuterArray[indexOuter + 1][indexInner] = [NSValue valueWithCGPoint:tempPoint];
        
        currentPositionOuterArray[indexOuter][indexInner] = [NSValue valueWithCGPoint:CGPointMake(indexOuter + 1, indexInner)];
        currentPositionOuterArray[indexOuter + 1][indexInner] = [NSValue valueWithCGPoint:tempPoint];
    }
    
    emptyTile = CGRectMake(tappedPosition.x, tappedPosition.y, tileSize, tileSize);
    _stepsLabel.text = [@(++steps) stringValue];
    
    //for debugging only
    p = [currentPositionOuterArray[indexOuter][indexInner] CGPointValue];
    NSLog(@"new position: %d, %d", (int)p.x, (int)p.y);
    
    if ([self isWin]) {
        [self popupAlert:@"You Win!"];
    }
}

- (BOOL) isWithinEmptyTile : (CGPoint)point
{
    if (point.x > emptyTile.origin.x && point.x < (emptyTile.origin.x + tileSize) && point.y > emptyTile.origin.y && point.y < (emptyTile.origin.y + tileSize)) {
        return true;
    }
    else return false;
}

- (void) swapPosition: (CGPoint)current with: (CGPoint)new
{
    CGPoint tempPoint = current;
    current = new;
    new = tempPoint;
}

- (BOOL) isWin
{
    for (int i = 0; i < grid; i++) {
        for (int j = 0; j < grid; j++) {
            if (!(i == grid - 1 && j == grid - 1)) {
                CGPoint originalPosition = [originalPositionOuterArray[i][j] CGPointValue];
                CGPoint currentPosition = [currentPositionOuterArray[i][j] CGPointValue];
                //NSLog(@"original position: %d, %d, current position: %d, %d", (int)originalPosition.x, (int)originalPosition.y, (int)currentPosition.x, (int)currentPosition.y);
                if (!CGPointEqualToPoint(originalPosition, currentPosition)) {
                    return false;
                }
            }
            
        }
    }
    return true;
}

- (void)displayOriginalImage : (UIImage *)image
{
    imageSize = _imageGridView.frame.size.height;
    UIGraphicsBeginImageContext(CGSizeMake(imageSize, imageSize));
    [image drawInRect:CGRectMake(0, 0, imageSize, imageSize)];
    UIImage *newSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView * completeImageView = [[UIImageView alloc] initWithImage:newSizeImage];
    [_imageGridView addSubview:completeImageView];
}

- (void)popupAlert: (NSString*)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
