//
//  GameSettingsController.m
//  JigsawPuzzle-OC
//
//  Created by Admin on 10/30/16.
//  Copyright © 2016 Mitchell. All rights reserved.
//

#import "ClassicGameSettingsController.h"

@interface ClassicGameSettingsController ()

@end

@implementation ClassicGameSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.setting = [[GameSetting alloc] initGame:0];
    // Do any additional setup after loading the view.
    _dataSourceArray = @[@"Easy", @"Medium", @"Hard"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) pickImage:(id)sender{
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]
                                                 init];
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker
         didFinishPickingImage:(UIImage *)image
                   editingInfo:(NSDictionary *)editingInfo
{
    self.imageView.image = image;
    [self.setting setImage:image];
    [self dismissViewControllerAnimated:NO completion:nil];
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"startGame" ]){
        ClassicGameViewController *controller = (ClassicGameViewController *) segue.destinationViewController;
        controller.settings = self.setting;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (NSInteger)numberOfComponentsInPickerView: (UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component

{
    return  _dataSourceArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _dataSourceArray[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *resultString = _dataSourceArray[row];
    [self.setting setDifficultLevel: (int)row];
    NSLog(@"%@", resultString);
}




@end
