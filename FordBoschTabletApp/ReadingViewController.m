//
//  ReadingViewController.m
//  FordBoschTabletApp
//
//  Created by Ted Kim on 11/19/13.
//  Copyright (c) 2013 Johan Ismael. All rights reserved.
//

#import "ReadingViewController.h"

@interface ReadingViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *containingView;
@property (nonatomic) NSUInteger lastPage;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSLayoutManager *textLayout;
@property (strong, nonatomic) NSTextStorage *textStorage;

@end

@implementation ReadingViewController

#define READER_PAGES_INCREMENT (4)  // Start with this many pages

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(20,20,self.containingView.bounds.size.width-20,self.containingView.bounds.size.height-20)];
        _scrollView.delegate = self;
        _scrollView.contentSize  = CGSizeMake((self.containingView.bounds.size.width-20)*READER_PAGES_INCREMENT,self.containingView.bounds.size.height-20);
        _scrollView.pagingEnabled = YES;
        [self.containingView addSubview:_scrollView];
    }
    return _scrollView;
}

- (NSLayoutManager *)textLayout
{
    if (!_textLayout) {
        // SET THE BOOK PATH HERE
        NSString *stringPath = [[NSBundle mainBundle] pathForResource:@"The Honour of the Knights" ofType:@"txt"];
        NSString *txtContent = [[NSString alloc] initWithContentsOfFile:stringPath encoding:NSUTF8StringEncoding error:nil];
        
        // CONFIGURE FONT STYLES HERE
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 7; // <--- magic line spacing here!
        NSDictionary *attrsDictionary = @{ NSFontAttributeName: [UIFont fontWithName:@"Palatino" size:20],
                                           NSParagraphStyleAttributeName: paragraphStyle};
        
        NSAttributedString *textString =  [[NSAttributedString alloc] initWithString:txtContent attributes:attrsDictionary];
        self.textStorage = [[NSTextStorage alloc] initWithAttributedString:textString];
        _textLayout = [[NSLayoutManager alloc] init];
        // Add layout manager to text storage object
        [self.textStorage addLayoutManager:_textLayout];
    }
    return _textLayout;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.lastPage = 0;
    while (self.lastPage < READER_PAGES_INCREMENT) {
        [self addPages];
    }
}

- (void)addPages
{
    // Create a text container
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.scrollView.frame.size];
    // Add text container to text layout manager
    [self.textLayout addTextContainer:textContainer];
    // Instantiate UITextView object using the text container
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width*self.lastPage,0,self.scrollView.frame.size.width,self.scrollView.frame.size.height) textContainer:textContainer];
    textView.userInteractionEnabled = NO;
    // Give the container an identifier tag
    [textView setTag:self.lastPage];
    
    // Add text view to the scroll view
    [self.scrollView addSubview:textView];
    self.lastPage++;
}

// Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    if (page == self.lastPage - 1) {
        // We're at the last page!
        self.scrollView.contentSize  = CGSizeMake((self.containingView.bounds.size.width-20)*(self.lastPage + 1),self.containingView.bounds.size.height-20);
        [self addPages];
    }
    
}

@end
