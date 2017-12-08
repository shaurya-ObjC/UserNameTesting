//
//  DescriptionLabelTableViewCell.m
//  ZippSlip
//
//  Created by Abhishek Neb on 8/21/15.
//  Copyright (c) 2015 Quovantis. All rights reserved.
//

#import "DescriptionLabelTableViewCell.h"
#import "NSString+Calculations.h"

@implementation DescriptionLabelTableViewCell


- (void)customInitWithQuestionInformation:(QuestionInformation *)question {
    
    _cellQuestion = question;
    
    self.cellIdentifierName = question.questionIdentifier;
    self.cellType = question.type;
    
    CGFloat labelHeight = 0.0f;
    if (question.questionText) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@""];
        
        UIColor *highlightedColor = [UIColor colorWithRed:255/255.f green:136/255.f blue:83/255.f alpha:1.0f];
        NSAttributedString *questionText = [[NSAttributedString alloc] initWithString: question.questionText? question.questionText :@"" attributes:@{NSForegroundColorAttributeName:self.descriptionLabel.textColor , NSFontAttributeName:self.descriptionLabel.font}];
        [string appendAttributedString:questionText];
        
        if (question.isMandatory) {
            NSAttributedString *astreiskSign = [[NSAttributedString alloc] initWithString:@" *" attributes:@{NSForegroundColorAttributeName:highlightedColor, NSFontAttributeName:self.descriptionLabel.font}];
            [string appendAttributedString:astreiskSign];
        }
        self.descriptionLabel.attributedText = [[NSAttributedString alloc] initWithAttributedString:string];
        
        CGSize cellSize = self.bounds.size;
        cellSize.height -= self.descriptionLabel.bounds.size.height;
        
        CGSize labelSize = [[self.descriptionLabel.attributedText string] usedSizeForMaxWidth:self.descriptionLabel.bounds.size.width withFont:self.descriptionLabel.font];
        labelHeight = labelSize.height;
        
        cellSize.height += labelHeight;
        self.cellHeight = cellSize.height;
    } else {
        self.descriptionLabel.hidden = YES;
    }
    
    self.isDisabled = question.isDisabled;
    self.userInteractionEnabled = !self.isDisabled;

}
//                DescriptionLabelTableViewCell *desciptionCell = [tableView dequeueReusableCellWithIdentifier:KDescriptionLabelFormCellIdentifierName];
//                desciptionCell.descriptionLabel.text = currentFormInformation.formDescription;
//
//
//                CGSize cellSize = desciptionCell.bounds.size;
//                cellSize.height -= desciptionCell.descriptionLabel.bounds.size.height;
//                CGSize labelSize = [desciptionCell.descriptionLabel.text usedSizeForMaxWidth:desciptionCell.descriptionLabel.bounds.size.width withFont:desciptionCell.descriptionLabel.font];
//                cellSize.height += labelSize.height;
//
//                desciptionCell.cellIdentifierName = KDescriptionLabelFormCellIdentifierName;
//                desciptionCell.cellHeight = cellSize.height;
//
//                return desciptionCell;
@end
