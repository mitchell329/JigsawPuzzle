//
//  GameSettingsController.h
//  JigsawPuzzle-OC
//
//  Created by Admin on 10/30/16.
//  Copyright © 2016 Mitchell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameSetting.h"
#import "ClassicGameViewController.h"

@interface ClassicGameSettingsController : UIViewController <UINavigationControllerDelegate,
UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet UIImageView* imageView;
@property (nonatomic) GameSetting* setting;

- (IBAction) pickImage:(id)sender;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic)NSArray *dataSourceArray;
@end
