//
//  TexfieldFormCell.m
//  ZippSlip
//
//  Created by Abhishek Neb on 8/11/15.
//  Copyright (c) 2015 Quovantis. All rights reserved.
//

#import "TexfieldFormCell.h"
#import "Helpers.h"
#import "DataManager.h"
#import "NSDate+Utils.h"
#import "NSObject+Blocks.h"
#import "UserInformation.h"
#import "OptionInformation.h"
#import "ActionSheetPicker.h"
#import "ActionSheetPicker.h"
#import "UserInformation.h"
#import "UITextField+Helpers.h"
#import "QuestionInformation.h"
#import "DynamicFieldQuestions.h"
#import "NSString+Calculations.h"
#import "AnsweredOptionsInformation.h"
#import "CompositeQuestionInformation.h"

@interface TexfieldFormCell ()
{
    BOOL    isDynamicValueExists;
    NSArray *pickerTitleRootArray;
    NSArray *pickerTitleNamesRootArray;
    NSInteger selectedTitlePickerIndex;
    
    NSArray *pickerStatesRootArray;
    NSArray *pickerStatesNamesRootArray;
    NSInteger selectedStatePickerIndex;
    
    NSArray *pickerDirectionsRootArray;
    NSArray *pickerDirectionsNamesRootArray;
    NSInteger selectedDirectionPickerIndex;
    
    NSArray *pickerOtherRootArray;
    NSArray *pickerOtherNamesRootArray;
    NSInteger selectedOtherPickerIndex;
    
    NSString *questionId;
    ActionSheetStringPicker *myCustomPicker;
    AnsweredOptionsInformation *curentAnsweredOptionsInformation;
}
@end
@implementation TexfieldFormCell

// Address type Keys
static NSString *const kStreetNumberFormKey     = @"StreetNumber";
static NSString *const kStreetAddressFormKey    = @"StreetAddress";
static NSString *const kStreetTypeFormKey       = @"StreetType";
static NSString *const kStreetDirectionFormKey  = @"StreetDirection";
static NSString *const kApartmentFormKey        = @"Apartment";
static NSString *const kZipFormKey              = @"Zip";
static NSString *const kCityFormKey             = @"City";
static NSString *const kStateFormKey            = @"State";

static NSString *const kTitleIdFormKey          = @"TitleId";
static NSString *const kTitleNameFormKey        = @"TitleName";

#pragma mark - Custom Init
#pragma mark -

- (void)resetToDefaultValues {
    _formTextField.text = nil, questionId = nil, curentAnsweredOptionsInformation = nil;
    pickerOtherRootArray = nil, pickerOtherNamesRootArray = nil, pickerTitleRootArray = nil, pickerTitleNamesRootArray = nil, pickerStatesRootArray = nil, pickerStatesNamesRootArray = nil, pickerDirectionsRootArray = nil, pickerDirectionsNamesRootArray = nil;
    isDynamicValueExists = NO;
    
    _formTextField.rightView = nil;
    _formTextField.leftView = nil;
    _formTextField.inputView  = nil;
}

- (void)customInitWithQuestionInformation:(id )question {
    [self resetToDefaultValues];
    [_formTextField removeCustomBorderFromViewEdge:UIRectEdgeBottom];
    
    _cellQuestion = question;
    
    _heightGapConstraint.constant = 0.0f;
    
    _titleTextFieldLabel.hidden = NO;
    
    
    NSString *headingText = nil;
    
    if ([question isKindOfClass:[QuestionInformation class]]) {
        QuestionInformation *currentQuestion  = question;
        if ([currentQuestion.answeredOptionsInformation count]) {
            curentAnsweredOptionsInformation = currentQuestion.answeredOptionsInformation[0];
        }
        questionId = currentQuestion.questionId;
        self.formTextField.placeholder = currentQuestion.questionText;
        self.cellIdentifierName = currentQuestion.questionIdentifier;
        self.cellType = currentQuestion.type;
        headingText = currentQuestion.questionText;
        self.isDisabled = currentQuestion.isDisabled;
    } else if ([question isKindOfClass:[CompositeQuestionInformation class]]) {
        CompositeQuestionInformation *currentQuestion  = question;
        questionId = currentQuestion.compositeId;
        curentAnsweredOptionsInformation = currentQuestion.answeredOptionInfo;
        self.formTextField.placeholder = currentQuestion.text;
        self.cellIdentifierName = currentQuestion.questionIdentifier;
        self.cellType = currentQuestion.type;
        headingText = currentQuestion.headingQuestionLabelText;
        self.isDisabled = currentQuestion.isDisabled;
    }
    
    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    [Helpers setDynamicString:headingText inLabel:_titleTextFieldLabel withRequired:self.cellQuestion.isMandatory ForCellSize:_titleTextFieldLabel.bounds.size];
    CGFloat height = [Helpers heightWithWidth:[UIScreen mainScreen].bounds.size.width -16 andFont:_titleTextFieldLabel.font string:[NSString stringWithFormat:@"%@   ",headingText]];
    height =     ceilf(height/17);
    self.cellHeight = height*17.f +size.height;
    
    
    [self setTextFieldFormTypeAccordingToQuestionText];
    [self showDefaultAnswerForAnyQuestion];
    self.userInteractionEnabled = !self.isDisabled;
    
    if (self.isDisabled) {
        if ([self.formTextField.placeholder isEqualToString: NSLocalizedString(@"Type Here",nil)] || [self.formTextField.placeholder isEqualToString: NSLocalizedString(@"Please Select",nil)]){
            self.formTextField.placeholder =  nil;
        }
    }
    
    __weak __typeof(self)weakSelf = self;
    [self performBlock:^{
        [weakSelf.formTextField addCustomPropertiesForFormTextField];
        _formTextField.leftView = nil;
        _formTextField.rightView.userInteractionEnabled = NO;
    } afterDelay:0.3f];
}

- (void)setTextFieldFormTypeAccordingToQuestionText {
    switch (self.cellType) {
        case QuestionTypeName:
        case  QuestionTypeAddress:
            [self setTextFieldFromTypeAccordingToCellType];
            break;
            
        case QuestionTypeMediumSingleSelectDropDown:
        case QuestionTypeLargeSingleSelectDropDown:
        case QuestionTypeSmallSingleSelectDropDown:
            // Add input view of text fields.
            self.textFieldType = TexfieldFormTypePicker;
            [_formTextField addPaddingWithLeftImage:nil andRightImage:[UIImage imageNamed:kDropDownIconImage]];
            self.formTextField.placeholder = NSLocalizedString(@"Please Select",nil);
            break;
            
        case QuestionTypeDate:
            self.textFieldType = TexfieldFormTypeDateofBirth;
            self.formTextField.keyboardType = UIKeyboardTypeDefault;
            [_formTextField addPaddingWithLeftImage:nil andRightImage:[UIImage imageNamed:kCalendarIconImage]];
            break;
            
        case QuestionTypeNumeric:
            self.textFieldType = TexfieldFormTypeNumber;
            self.formTextField.keyboardType = UIKeyboardTypeNumberPad;
            self.formTextField.placeholder = NSLocalizedString(@"Type Here",nil);
            break;
            
        case QuestionTypePhoneNumber:
            self.textFieldType = TexfieldFormTypePhoneNumber;
            self.formTextField.keyboardType = UIKeyboardTypeNumberPad;
            self.formTextField.placeholder = NSLocalizedString(@"Type Here",nil);
            break;
            
        case QuestionTypeSmallText:
        case QuestionTypeLargeText:
        case QuestionTypeMediumText:
        case QuestionTypeWorkFlowLabel:
        case QuestionTypeBigText:
        {
            self.textFieldType = TexfieldFormTypeDefault;
            self.formTextField.keyboardType = UIKeyboardTypeDefault;
            self.formTextField.placeholder = NSLocalizedString(@"Type Here",nil);
        }
            break;
            
        case QuestionTypeEmail:
            self.textFieldType = TexfieldFormTypeEmail;
            self.formTextField.keyboardType = UIKeyboardTypeEmailAddress;
            self.formTextField.placeholder = NSLocalizedString(@"Type Here",nil);

            break;
            
        default:
            break;
    }
}

- (void)setTextFieldFromTypeAccordingToCellType {
    
    if ([_formTextField.placeholder isEqualToString:kStreetNumberFormKey]) {
        self.textFieldType = TexfieldFormTypeDefault;
        self.formTextField.keyboardType = UIKeyboardTypeDefault;
        
    } else if ([_formTextField.placeholder isEqualToString:kStreetAddressFormKey]) {
        self.textFieldType = TexfieldFormTypeDefault;
        self.formTextField.keyboardType = UIKeyboardTypeDefault;
        
    } else if ([_formTextField.placeholder isEqualToString:kStreetTypeFormKey]) {
        self.textFieldType = TexfieldFormTypeDefault;
        self.formTextField.keyboardType = UIKeyboardTypeDefault;
        
    } else if ([_formTextField.placeholder isEqualToString:kStreetDirectionFormKey]) {
        self.textFieldType = TexfieldFormTypePicker;
        [_formTextField addPaddingWithLeftImage:nil andRightImage:[UIImage imageNamed:kDropDownIconImage]];
        
    } else if ([_formTextField.placeholder isEqualToString:kApartmentFormKey]) {
        self.formTextField.keyboardType = UIKeyboardTypeDefault;
        self.textFieldType = TexfieldFormTypeDefault;
        
    } else if ([_formTextField.placeholder isEqualToString:kZipFormKey]) {
        self.formTextField.keyboardType = UIKeyboardTypeNumberPad;
        self.textFieldType = TexfieldFormTypeZippCode;
        
    } else if ([_formTextField.placeholder isEqualToString:kCityFormKey]) {
        self.textFieldType = TexfieldFormTypeDefault;
        self.formTextField.keyboardType = UIKeyboardTypeDefault;
        
    } else if ([_formTextField.placeholder isEqualToString:kStateFormKey]) {
        self.textFieldType = TexfieldFormTypePicker;
        [_formTextField addPaddingWithLeftImage:nil andRightImage:[UIImage imageNamed:kDropDownIconImage]];
        
    } else if ([_formTextField.placeholder isEqualToString:kFirstNameFormCellKey]) {
        self.textFieldType = TexfieldFormTypeDefault;
        self.formTextField.keyboardType = UIKeyboardTypeDefault;
        
    } else if ([_formTextField.placeholder isEqualToString:kLastNameFormCellKey]) {
        self.textFieldType = TexfieldFormTypeDefault;
        self.formTextField.keyboardType = UIKeyboardTypeDefault;
        
    } else if ([_formTextField.placeholder isEqualToString:kTitleNameFormCellKey]) {
        self.textFieldType = TexfieldFormTypePicker;
        [_formTextField addPaddingWithLeftImage:nil andRightImage:[UIImage imageNamed:kDropDownIconImage]];
        
    } else if ([_formTextField.placeholder isEqualToString:kMiddleNameFormCellKey]) {
        self.textFieldType = TexfieldFormTypeDefault;
        self.formTextField.keyboardType = UIKeyboardTypeDefault;
    }
}

- (void)showDefaultAnswerForAnyQuestion  {
    if (self.textFieldType ==  TexfieldFormTypePicker) {
        if ((self.cellType == QuestionTypeMediumSingleSelectDropDown) || (self.cellType == QuestionTypeSmallSingleSelectDropDown) || (self.cellType == QuestionTypeLargeSingleSelectDropDown)) {
            [self setDefaultAnswerForOtherPicker];
        }  else if ([_formTextField.placeholder isEqualToString:kStreetDirectionFormKey]) {
            [self setDefaultAnswerForDirections];
        }else if ([_formTextField.placeholder isEqualToString:kStateFormKey]) {
            [self setDefaultAnswerForStates];
        }else if ([_formTextField.placeholder isEqualToString:kTitleNameFormCellKey]) {
            [self setDefaultAnswerForPickerTitle];
        }
    }  else {
        // Normal Text Field
        if (curentAnsweredOptionsInformation) {
            NSString *optionText = curentAnsweredOptionsInformation.optionText;
            if (self.textFieldType == TexfieldFormTypePhoneNumber) {
                _formTextField.text = [Helpers getStringFromPhoneNumberString:optionText];
                if ([[UserInformation instance] isDataForUnitedStates]) {
                    _formTextField.text = [Helpers convertNumberStringIntoPhoneNumberFormatString:_formTextField.text];
                }
            } else {
                _formTextField.text = optionText;
            }
        } else if (self.cellQuestion.answerDynamicFieldId){
            NSString *answerString = [DynamicFieldQuestions getDynamicAnswerStringFromAnswer:self.cellQuestion.answerDynamicFieldId forActivity:self.cellActivityDetailsInformation];
            if (answerString) {
                _formTextField.text = answerString;
                [self replyWithAnswerForOptionText:answerString andAlsoCallChangeInputView:NO];
            }
        }
    }
    
}

#pragma mark - TextField Delegate
#pragma mark -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.textFieldType ==  TexfieldFormTypePicker) {
        if ((self.cellType == QuestionTypeMediumSingleSelectDropDown) || (self.cellType == QuestionTypeSmallSingleSelectDropDown) || (self.cellType == QuestionTypeLargeSingleSelectDropDown)) {
            [self setPickerViewForOtherTextField];
            return NO;
        }
    } else if (self.textFieldType ==  TexfieldFormTypeDateofBirth) {
        [self setDatePickerForTextField];
        return NO;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    
    // Prevent invalid character input, if keyboard is numberpad
    if (textField.keyboardType == UIKeyboardTypeNumberPad)
    {
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
        {
            return NO;
        }
    }
    
    if (self.textFieldType == TexfieldFormTypePhoneNumber) {
        
        NSString *filterString = [[UserInformation instance] isDataForUnitedStates]?@"(###) ###-####": @"##########";
        [Helpers addFilter:filterString InTextField:textField shouldChangeCharactersInRange:range replacementString:string];
        return NO;
    }
    
 
    return YES;
}



- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if ((self.textFieldType == TexfieldFormTypePicker) || (self.textFieldType == TexfieldFormTypePicker)) {
        // Do Nothing
    } else {
        // Normal Text Field
        if (self.textFieldType == TexfieldFormTypePhoneNumber) {
            [self replyWithAnswerForOptionText:[Helpers getStringFromPhoneNumberString:textField.text] andAlsoCallChangeInputView:YES];
        } else {
            [self replyWithAnswerForOptionText:textField.text andAlsoCallChangeInputView:YES];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Pickers
#pragma mark -
#pragma mark Title
- (void)setPickerForTitle {
    [self customInitForPickerTitle];
    
    [ActionSheetStringPicker showPickerWithTitle:NSLocalizedString(@"Select Title",nil) rows:pickerTitleNamesRootArray initialSelection:selectedTitlePickerIndex  doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        selectedTitlePickerIndex = selectedIndex;
        _formTextField.text = [NSString stringWithFormat:@"%@",selectedValue];
        NSDictionary *selectedDictionary = pickerTitleRootArray[selectedIndex];
        [self replyWithAnswerForOptionText:[selectedDictionary objectForKey:kTitleNameFormCellKey] andAlsoCallChangeInputView:YES];
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:self];

}

- (void)setDefaultAnswerForPickerTitle {
    
    if (curentAnsweredOptionsInformation) {
        [self customInitForPickerTitle];
        NSString *optionText =  curentAnsweredOptionsInformation.optionText;
        NSInteger count = 0;
        for (NSDictionary *titleDict in pickerTitleRootArray) {
            NSString *titleId = [titleDict objectForKey:kTitleIdFormKey];
            if ([titleId isEqualToString:optionText]) {
                _formTextField.text = [NSString stringWithFormat:@"%@",[titleDict objectForKey:kTitleNameFormKey]];
                selectedTitlePickerIndex = count;
                break;
            }
            count++;
        }
    }
}

- (void)customInitForPickerTitle {
    if (!pickerTitleRootArray || !pickerTitleNamesRootArray) {
        pickerTitleRootArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kTitleNameFormCellKey ofType:kPlistFormKey]];        
        NSString *cultureId = [[UserInformation instance] isDataForUnitedStates] ? @"1" : @"3";
        NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:[pickerTitleRootArray count]];
        for (NSDictionary *titleDict in pickerTitleRootArray) {
            if ([[titleDict objectForKey:@"CultureId"] isEqualToString:cultureId]) {
                [titles insertObject:[titleDict objectForKey:kTitleNameFormKey] atIndex:[titles count]];
            }
        }
        pickerTitleNamesRootArray = [NSMutableArray arrayWithArray:titles];
    }
}

#pragma mark States
- (void)setPickerForStates {
    
    [self customInitForStatesPicker];
    
    [ActionSheetStringPicker showPickerWithTitle:NSLocalizedString(@"Select State",nil) rows:pickerStatesNamesRootArray initialSelection:selectedStatePickerIndex  doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        _formTextField.text = [NSString stringWithFormat:@"%@",selectedValue];
        NSDictionary *selectedDictionary = pickerStatesRootArray[selectedIndex];
        selectedStatePickerIndex = selectedIndex;
        [self replyWithAnswerForOptionText:[selectedDictionary objectForKey:kStateIdFormKey] andAlsoCallChangeInputView:YES];

    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:self];
    
}

- (void)setDefaultAnswerForStates {
    if (curentAnsweredOptionsInformation) {
        [self customInitForStatesPicker];
        NSString *optionText =  curentAnsweredOptionsInformation.optionText;
        NSInteger count = 0;
        for (NSDictionary *stateDict in pickerStatesRootArray) {
            NSString *stateId = [stateDict objectForKey:kStateIdFormKey];
            if ([stateId isEqualToString:optionText]) {
                _formTextField.text = [NSString stringWithFormat:@"%@",[stateDict objectForKey:kStateNameFormKey]];
                selectedStatePickerIndex = count;
                break;
            }
            count++;
        }
    }
}

- (void)customInitForStatesPicker {
    if (!pickerStatesRootArray || !pickerStatesNamesRootArray) {
        UserInformation *userInfo = [UserInformation instance];
        pickerStatesRootArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:userInfo.countryId ofType:kPlistFormKey]];
        pickerStatesRootArray = [Helpers insertPleaseSelectAtFirstIndexofOptions:pickerStatesRootArray havingDynamicValue:YES];
        NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:[pickerStatesRootArray count]];
        for (NSDictionary *titleDict in pickerStatesRootArray) {
            [titles insertObject:[titleDict objectForKey:kStateNameFormKey] atIndex:[titles count]];
        }
        pickerStatesNamesRootArray = [NSMutableArray arrayWithArray:titles];
    }
}

#pragma mark Directions
- (void)setPickerForDirections {
    
    [self customInitForDirectionPicker];
    
    [ActionSheetStringPicker showPickerWithTitle:NSLocalizedString(@"Select Direction",nil) rows:pickerDirectionsNamesRootArray initialSelection:selectedDirectionPickerIndex  doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        
        _formTextField.text = [NSString stringWithFormat:@"%@",selectedValue];
        NSDictionary *selectedDictionary = pickerDirectionsRootArray[selectedIndex];
        selectedDirectionPickerIndex = selectedIndex;
        [self replyWithAnswerForOptionText:[selectedDictionary objectForKey:kDirectionIdFormKey] andAlsoCallChangeInputView:YES];
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:self];

}

- (void)setDefaultAnswerForDirections {
    if (curentAnsweredOptionsInformation) {
        [self customInitForDirectionPicker];
        NSString *optionText =  curentAnsweredOptionsInformation.optionText;
        NSInteger count = 0;
        for (NSDictionary *directionDict in pickerDirectionsRootArray) {
            NSString *directionId = [directionDict objectForKey:kDirectionIdFormKey];
            if ([directionId isEqualToString:optionText]) {
                _formTextField.text = [NSString stringWithFormat:@"%@",[directionDict objectForKey:kNameFormKey]];
                selectedDirectionPickerIndex = count;
                break;
            }
            count++;
        }
    }
}

- (void)customInitForDirectionPicker {
    if (!pickerDirectionsRootArray || !pickerDirectionsNamesRootArray) {
        pickerDirectionsRootArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kStreetDirectionFormKey ofType:kPlistFormKey]];
        pickerDirectionsRootArray = [Helpers insertPleaseSelectAtFirstIndexofOptions:pickerDirectionsRootArray havingDynamicValue:YES];
        NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:[pickerDirectionsRootArray count]];
        for (NSDictionary *titleDict in pickerDirectionsRootArray) {
            [titles insertObject:[titleDict objectForKey:kNameFormKey] atIndex:[titles count]];
        }
        pickerDirectionsNamesRootArray = [NSMutableArray arrayWithArray:titles];
    }
}

#pragma mark Other Picker
- (void)setPickerViewForOtherTextField {
    
    [self customInitForOtherPicker];

    [ActionSheetStringPicker showPickerWithTitle:self.cellQuestion.questionText rows:pickerOtherNamesRootArray initialSelection:selectedOtherPickerIndex  doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        
        if (selectedIndex < [pickerOtherRootArray count]) {
            NSString *currentSelectedValue = nil;
            
            if (isDynamicValueExists) {
                NSDictionary *dictionary = pickerOtherRootArray[selectedIndex];
                selectedOtherPickerIndex = selectedIndex;
                currentSelectedValue = [dictionary objectForKey:kIdWeb];
            } else {
                OptionInformation *selectedOptionInfo = pickerOtherRootArray[selectedIndex];
                selectedOtherPickerIndex = selectedIndex;
                currentSelectedValue = selectedOptionInfo.optionId;
            }

            if ([currentSelectedValue isEqualToString:@"-1"])
            {
                _formTextField.text = nil;
                currentSelectedValue = nil;
            }
            else
            {
                _formTextField.text = [NSString stringWithFormat:@"%@",selectedValue];
            }

            [self replyWithAnswerForOptionText:currentSelectedValue andAlsoCallChangeInputView:YES];
        }
        
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:self];

}

- (void)setDefaultAnswerForOtherPicker {
    if (curentAnsweredOptionsInformation) {
        if ([_cellQuestion isKindOfClass:[CompositeQuestionInformation class]]) {
            return;
        }

        [self customInitForOtherPicker];
        if (isDynamicValueExists) {
            //
            NSString *optionText =  curentAnsweredOptionsInformation.optionText;
            NSInteger count = 0;
            for (NSDictionary *valuesDict in pickerOtherRootArray) {
                if ([[valuesDict objectForKey:kIdWeb] isEqualToString:optionText]) {
                    _formTextField.text = [NSString stringWithFormat:@"%@",[valuesDict objectForKey:@"Value"]];
                    selectedOtherPickerIndex = count;
                    [self replyWithAnswerForOptionText:[valuesDict objectForKey:kIdWeb] andAlsoCallChangeInputView:NO];
                    break;
                }
                count++;
            }

        } else {
            NSString *optionText =  curentAnsweredOptionsInformation.optionText;
            if (self.cellQuestion.isDisabled && [optionText isEqualToString: @"-1"]) {
                return;
            }
            NSInteger count = 0;
            for (OptionInformation *optInfo in pickerOtherRootArray) {
                if ([optInfo.optionId isEqualToString:optionText]) {
                    _formTextField.text = [NSString stringWithFormat:@"%@",optInfo.optionText];
                    selectedOtherPickerIndex = count;
                    break;
                }
                count++;
            }
        }
    } else if (self.cellQuestion.answerDynamicFieldId){
        NSString *answerString = [DynamicFieldQuestions getDynamicAnswerStringFromAnswer:self.cellQuestion.answerDynamicFieldId forActivity:self.cellActivityDetailsInformation];
        if (answerString) {
            [self customInitForOtherPicker];
            NSInteger count = 0;
            for (NSDictionary *valuesDict in pickerOtherRootArray) {
                if ([[valuesDict objectForKey:@"Value"] isEqualToString:answerString]) {
                    _formTextField.text = [NSString stringWithFormat:@"%@",[valuesDict objectForKey:@"Value"]];
                    selectedOtherPickerIndex = count;
                    [self replyWithAnswerForOptionText:[valuesDict objectForKey:kIdWeb] andAlsoCallChangeInputView:NO];
                    break;
                }
                count++;
            }
        }
    } 
}

- (void)customInitForOtherPicker {
    if (!pickerOtherRootArray || !pickerOtherNamesRootArray) {
        pickerOtherRootArray = _cellQuestion.optionsArray;
        if (![pickerOtherRootArray count]) {
            isDynamicValueExists = YES;

            NSString *answerDynamicFieldId = [NSString stringWithFormat:@"%@",self.cellQuestion.answerDynamicFieldId];
            pickerOtherRootArray = [NSArray arrayWithArray:[DynamicFieldQuestions getDynamicOptionsFromAnswer:answerDynamicFieldId forActivity:self.cellActivityDetailsInformation]];
            pickerOtherRootArray = [Helpers insertPleaseSelectAtFirstIndexofOptions:pickerOtherRootArray havingDynamicValue:YES];
            
            NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:[pickerOtherRootArray count]];
            for (NSDictionary *dictionary in pickerOtherRootArray) {
                [titles insertObject:[dictionary objectForKey:@"Value"] atIndex:[titles count]];
            }
            pickerOtherNamesRootArray = [NSMutableArray arrayWithArray:titles];
            
        } else {
            isDynamicValueExists = NO;
            pickerOtherRootArray = [Helpers insertPleaseSelectAtFirstIndexofOptions:pickerOtherRootArray havingDynamicValue:NO];
            NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:[pickerOtherRootArray count]];
            for (OptionInformation *optInfo in pickerOtherRootArray) {
                [titles insertObject:optInfo.optionText atIndex:[titles count]];
            }
            pickerOtherNamesRootArray = [NSMutableArray arrayWithArray:titles];
        }
        
        
//        pickerDirectionsRootArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kStreetDirectionFormKey ofType:kPlistFormKey]];
//        NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:[pickerDirectionsRootArray count]];
//        for (NSDictionary *titleDict in pickerDirectionsRootArray) {
//            [titles insertObject:[titleDict objectForKey:kNameFormKey] atIndex:[titles count]];
//        }
//        pickerDirectionsNamesRootArray = [NSMutableArray arrayWithArray:titles];
        
        
    }
}



#pragma mark DatePicker
//OptionText = "8/20/2015"
- (void)setDatePickerForTextField  {
    NSDate *currentDate = [NSDate date];
    if (curentAnsweredOptionsInformation) {
        NSString *dateString = curentAnsweredOptionsInformation.optionText;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:[[UserInformation instance] formatForDate]];
        currentDate = [dateFormatter dateFromString:dateString];
    }
    
    NSCalendar *calendar    = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    //            NSDate *minDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    
    [ActionSheetDatePicker showPickerWithTitle:_formTextField.placeholder datePickerMode:UIDatePickerModeDate selectedDate:maxDate minimumDate:nil maximumDate:nil doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        _formTextField.text = [NSString stringWithFormat:@"%@",[(NSDate *)selectedDate getDateAccordingToDateFormat:[[UserInformation instance] formatForDate]]];
        // Normal Text Field
        [self replyWithAnswerForOptionText:_formTextField.text andAlsoCallChangeInputView:YES];

    } cancelBlock:^(ActionSheetDatePicker *picker) {
        
    } origin:self];
    
}

#pragma mark - Answers Calling Delegates
#pragma mark -
- (void)replyWithAnswerForOptionText:(NSString *)replyText andAlsoCallChangeInputView:(BOOL)isInputChanged {
    AnsweredOptionsInformation *answerdOption = [[AnsweredOptionsInformation alloc] init];
    if (curentAnsweredOptionsInformation) {
        answerdOption =  curentAnsweredOptionsInformation;
    }
    answerdOption.optionText = replyText;
    answerdOption.questionId = questionId;
    
    if ([self.cellQuestion isKindOfClass:[QuestionInformation class]]) {
        _cellQuestion.answeredOptionsInformation = [NSMutableArray arrayWithArray:@[answerdOption]];
    } else if ([self.cellQuestion isKindOfClass:[CompositeQuestionInformation class]]) {
        CompositeQuestionInformation *currentCompositeInformation = (CompositeQuestionInformation *)self.cellQuestion;
        currentCompositeInformation.answeredOptionInfo = answerdOption;
        _cellQuestion = (id)currentCompositeInformation;
    }
    
    if (isInputChanged && [self.delegate respondsToSelector:@selector(changeInInputViewForCell:withObject:)]) {
        [self.delegate changeInInputViewForCell:self withObject:answerdOption];
    }
    
    if (self.textFieldType == TexfieldFormTypePicker) {
        [self addOrRemoveChildQuestionsIfExists];
    }
}

- (void)addOrRemoveChildQuestionsIfExists {
    if (![_cellQuestion.childQuestions count]) {
        return;
    }
    
    NSMutableArray *addChildQuestions = [[NSMutableArray alloc] init];
    NSMutableArray *removeChildQuestions = [[NSMutableArray alloc] init];
    
    for (id childQuestion in _cellQuestion.childQuestions) {
        NSString *childQuestionMandatoryOptionId = @"0";
        
        if ([childQuestion isKindOfClass:[QuestionInformation class]]) {
            QuestionInformation *subChildMainQuestion = (QuestionInformation *)childQuestion;
            childQuestionMandatoryOptionId = subChildMainQuestion.mandatoryParentOptionId;
        } else if ([childQuestion isKindOfClass:[CompositeQuestionInformation class]]) {
            CompositeQuestionInformation *subChildCompositeQuestion = (CompositeQuestionInformation *)childQuestion;
            childQuestionMandatoryOptionId = subChildCompositeQuestion.mandatoryParentOptionId;
        } else if ([childQuestion isKindOfClass:[NSDictionary class]]) {
            QuestionInformation *subChildMainQuestion = [[QuestionInformation alloc] initWithJSON:childQuestion];
            childQuestionMandatoryOptionId = subChildMainQuestion.mandatoryParentOptionId;
        }
        
        AnsweredOptionsInformation *answerdOption =  _cellQuestion.answeredOptionsInformation[0];
        
        if ([childQuestionMandatoryOptionId integerValue]) {
            if ([answerdOption.optionText isEqualToString:childQuestionMandatoryOptionId]) {
                [addChildQuestions addObject:childQuestion];
            }else {
                [removeChildQuestions addObject:childQuestion];
            }
        }
        
    }
    
    if ([removeChildQuestions count]) {
        if ([self.delegate respondsToSelector:@selector(removeChildQuestionsBelowCurrentCell:withQuestions:)]) {
            [self.delegate removeChildQuestionsBelowCurrentCell:self withQuestions:removeChildQuestions];
        }
    }
    
    if ([addChildQuestions count]) {
        if ([self.delegate respondsToSelector:@selector(addChildQuestionsBelowCurrentCell:withQuestions:)]) {
            [self.delegate addChildQuestionsBelowCurrentCell:self withQuestions:addChildQuestions];
        }
    }
    
}


@end
