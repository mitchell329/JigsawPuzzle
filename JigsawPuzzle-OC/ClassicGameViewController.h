//
//  ClassicGameViewController.h
//  JigsawPuzzle-OC
//
//  Created by Shuai Yuan on 26/10/16.
//  Copyright © 2016 Mitchell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameSetting.h"

@interface ClassicGameViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UIView *imageGridView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageGridViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageGridViewLeadingConstraint;

@property (nonatomic) GameSetting *settings;

@end
