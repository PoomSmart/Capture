#import <UIKit/UIKit.h>
#import <Preferences/PSSpecifier.h>
#import <Cephei/HBListController.h>
#import <Cephei/HBAppearanceSettings.h>
#import <Social/Social.h>
#import "Header.h"
#define REGISTER_PREF
#import "Identifiers.h"
#import "../PS.h"
#import "../PSPrefs.x"

DeclarePrefsTools()

BOOL experimental()
{
	return YES;
	//return [[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/org.thebigboss.capture"];
}
#define CRACK !experimental()

NSString *normalized(NSString *self)
{
	if (!CRACK)
		return self;
	if (self == nil)
		return @"";
	NSMutableString *reversedStr;
	int len = self.length;
	reversedStr = [NSMutableString stringWithCapacity:len];
	while (len > 0)
		[reversedStr appendString:[NSString stringWithFormat:@"%C", [self characterAtIndex:--len]]];
	return reversedStr;
}

#import <PreferencesUI/PSUIPrefsRootController.h>

@implementation PSUIPrefsRootController (Hack)

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

@end

@interface CaptureGuideViewController : UIViewController
@end

@implementation CaptureGuideViewController

- (id)init
{
	if (self == [super init]) {
		UITextView *guide = [[[UITextView alloc] initWithFrame:CGRectZero] autorelease];
		guide.text = @"The quick brown fox jumps over the lazy dog";
		guide.font = [UIFont systemFontOfSize:18];
		guide.editable = NO;
		self.view = guide;
		self.navigationItem.title = @"Guide";
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:0 target:self action:@selector(dismissGuide)] autorelease];
	}
	return self;
}

- (void)dismissGuide
{
	[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

@interface CapturePreferenceController : HBListController
@end

@implementation CapturePreferenceController

+ (nullable NSString *)hb_specifierPlist
{
	return @"Capture";
}

- (NSArray *)specifiers
{
	NSArray *specs = [super specifiers];
	if (!CRACK)
		return specs;
	NSMutableArray <PSSpecifier *> *mspecs = [specs mutableCopy];
	[mspecs[0] setProperty:@"**Crack my DRM and I will give you a free copy**" forKey:@"footerText"];
	[mspecs[0] setProperty:@1 forKey:@"footerAlignment"];
	[mspecs[2] setProperty:@"Automatically inject DRM checking at runtime" forKey:@"footerText"];
	[mspecs[4] setProperty:@"Enable DRM without any prompt" forKey:@"footerText"];
	[mspecs[6] setProperty:@"I find it fun" forKey:@"footerText"];
	specs = mspecs.copy;
	[mspecs release];
	return specs;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navigationItem.title = !CRACK ? tweakName : @"#TeamPirated";
}

- (void)loadView
{
	[super loadView];
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
	UILabel *tweakLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, 320, 50)];
	tweakLabel.text = !CRACK ? tweakName : @"Crapture";
	tweakLabel.textColor = UIColor.systemBlueColor;
	tweakLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:50.0];
	tweakLabel.textAlignment = 1;
	tweakLabel.autoresizingMask = 0x12;
	[headerView addSubview:tweakLabel];
	[tweakLabel release];
	UILabel *dev = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, 320, 14)];
	dev.text = !CRACK ? @"By PoomSmart" : @"PoomSmart hates you";
	dev.alpha = 0.8;
	dev.font = [UIFont systemFontOfSize:14.0];
	dev.textAlignment = 1;
	dev.autoresizingMask = 0xa;
	[headerView addSubview:dev];
	[dev release];
	if (CRACK) {
		UILabel *p1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 15)];
		p1.text = @"Pirated?";
		p1.textColor = UIColor.systemRedColor;
		p1.font = [UIFont systemFontOfSize:12.0];
		[headerView addSubview:p1];
		[p1 release];
		UILabel *p2 = [[UILabel alloc] initWithFrame:CGRectMake(280, 36, 80, 15)];
		p2.text = @"¯\\_(ツ)_/¯";
		p2.textColor = UIColor.systemRedColor;
		p2.font = [UIFont boldSystemFontOfSize:12.0];
		[headerView addSubview:p2];
		[p2 release];
		UILabel *p3 = [[UILabel alloc] initWithFrame:CGRectMake(45, 45, 80, 15)];
		p3.text = @"¯\\_(ツ)_/¯";
		p3.textColor = UIColor.systemRedColor;
		p3.font = [UIFont boldSystemFontOfSize:12.0];
		[headerView addSubview:p3];
		[p3 release];
		UILabel *p4 = [[UILabel alloc] initWithFrame:CGRectMake(240, 62, 80, 15)];
		p4.text = @"¯\\_(ツ)_/¯";
		p4.textColor = UIColor.systemRedColor;
		p4.font = [UIFont boldSystemFontOfSize:12.0];
		[headerView addSubview:p4];
		[p4 release];
	}	
	self.table.tableHeaderView = headerView;
	[headerView release];
}

- (instancetype)init
{
	if (self == [super init]) {
		HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
		appearanceSettings.tintColor = UIColor.systemBlueColor;
		appearanceSettings.tableViewCellTextColor = UIColor.systemBlueColor;
		self.hb_appearanceSettings = appearanceSettings;
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:(!CRACK ? @"💙" : @"💔") style:UIBarButtonItemStylePlain target:self action:@selector(love)] autorelease];
	}
	return self;
}

- (void)love
{
	SLComposeViewController *twitter = [[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter] retain];
	twitter.initialText = !CRACK ? @"#Capture by @PoomSmart is really awesome!" : @"#Capture by @PoomSmart is really awesome, even more if I didn't pirate it.";
	[self.realNavigationController presentViewController:twitter animated:YES completion:nil];
	[twitter release];
}

- (void)showGuideView
{
	CaptureGuideViewController *guide = [[[CaptureGuideViewController alloc] init] autorelease];
	UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:guide] autorelease];
	nav.modalPresentationStyle = 2;
	[self.navigationController presentViewController:nav animated:YES completion:nil];
}

@end

@interface CaptureWordsManagerController : PSViewController <UITableViewDelegate, UITableViewDataSource> {
	UIColor *_originalTintColor;
}
@end

@implementation CaptureWordsManagerController

- (NSString *)title
{
	return normalized(@"Phrases");
}

- (id)init
{
	if (self == [super init])
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:normalized(@"Reset") style:UIBarButtonItemStylePlain target:self action:@selector(reset)] autorelease];
	return self;
}

- (void)viewWillAppear:(BOOL)arg1
{
	[super viewWillAppear:arg1];
	if ([UIWindow instancesRespondToSelector:@selector(tintColor)]) {
		UIWindow *window = UIApplication.sharedApplication.windows[0];
		if (self->_originalTintColor == nil)
			self->_originalTintColor = [window.tintColor retain];
		window.tintColor = !CRACK ? UIColor.systemOrangeColor : UIColor.systemRedColor;
	}
}

- (void)viewDidDisappear:(BOOL)arg1
{
	if (self.navigationController == nil && self->_originalTintColor != nil)
		UIApplication.sharedApplication.windows[0].tintColor = self->_originalTintColor;
	[super viewDidDisappear:arg1];
}

- (void)reset
{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:tweakName message:@"Reset to default?" preferredStyle:UIAlertControllerStyleAlert];
	[alertController _addActionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		setObjectForKey(PtakePhoto, photoKey);
		setObjectForKey(Pburst, burstKey);
		setObjectForKey(PstopBurst, burstStopKey);
		setObjectForKey(PcaptureVideo, videoKey);
		setObjectForKey(Pstop, stopKey);
		DoPostNotification();
		[self.tableView reloadData];
	}];
	[alertController _addActionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL];
	[self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (UITableView *)tableView
{
    return (UITableView *)self.view;
}

- (void)loadView
{
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	tableView.dataSource = self;
	tableView.delegate = self;
	tableView.autoresizingMask = 0x12;
	self.view = tableView;
	[tableView release];
}

/*- (void)viewDidLoad
{
	[super viewDidLoad];
	self.tableView.allowsSelectionDuringEditing = NO;
	self.tableView.editing = YES;
}*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 5;
}

- (NSArray *)categories
{
	return @[photoKey, burstKey, burstStopKey, videoKey, stopKey];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *str = nil;
	switch (section) {
		case 0: str = @"Take Photo"; break;
		case 1: str = @"Take Burst"; break;
		case 2: str = @"Stop Burst"; break;
		case 3: str = @"Capture Video"; break;
		case 4: str = @"Stop Listening";
	}
	return normalized(str);
}

- (NSString *)categoryForKey:(NSInteger)section
{
	return self.categories[section];
}

- (NSArray *)phrasesForSection:(NSInteger)section
{
	NSArray *defaults = nil;
	switch (section) {
		case 0: defaults = PtakePhoto; break;
		case 1: defaults = Pburst; break;
		case 2: defaults = PstopBurst; break;
		case 3: defaults = PcaptureVideo; break;
		case 4: defaults = Pstop; break;
	}
	return (NSArray *)objectForKey([self categoryForKey:section], defaults);
}

- (NSArray *)phrasesForCategory:(NSIndexPath *)indexPath
{
	return [self phrasesForSection:indexPath.section];
}

- (NSString *)phraseForIndexPath:(NSIndexPath *)indexPath
{
	return [self phrasesForSection:indexPath.section][indexPath.row];
}

- (void)addPhrase:(NSString *)phrase forIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *mutableCategory = [self phrasesForCategory:indexPath].mutableCopy;
	[mutableCategory addObject:phrase];
	setObjectForKey(mutableCategory.copy, [self categoryForKey:indexPath.section]);
	[mutableCategory release];
	DoPostNotification();
	[self.tableView reloadData];
}

- (void)setPhrase:(NSString *)newPhrase forIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *mutableCategory = [self phrasesForCategory:indexPath].mutableCopy;
	NSUInteger phraseIndex = [mutableCategory indexOfObject:[self phraseForIndexPath:indexPath]];
	if (phraseIndex != NSNotFound) {
		[mutableCategory replaceObjectAtIndex:phraseIndex withObject:newPhrase];
		setObjectForKey(mutableCategory.copy, [self categoryForKey:indexPath.section]);
	}
	[mutableCategory release];
	DoPostNotification();
	[self.tableView reloadData];
}

- (void)removePhrase:(NSString *)phrase forIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *mutableCategory = [self phrasesForCategory:indexPath].mutableCopy;
	[mutableCategory removeObject:phrase];
	setObjectForKey(mutableCategory.copy, [self categoryForKey:indexPath.section]);
	[mutableCategory release];
	DoPostNotification();
	[self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[self phrasesForSection:section] count] + 1;
}

- (BOOL)isOfLastIndex:(NSIndexPath *)indexPath
{
	return indexPath.row == [self tableView:self.tableView numberOfRowsInSection:indexPath.section] - 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellName;
	UITableViewCell *cell;
	if ([self isOfLastIndex:indexPath]) {
		cellName = [NSString stringWithFormat:@"edit%ld-%ld", (long)indexPath.section, (long)indexPath.row];
		cell = [tableView dequeueReusableCellWithIdentifier:cellName] ?: [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName] autorelease];
		cell.textLabel.text = !CRACK ? @"Add" : @"อิอิ";
		cell.textLabel.textColor = UIColor.whiteColor;
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		cell.contentView.backgroundColor = UIColor.systemYellowColor;
		return cell;
	}
	cellName = [NSString stringWithFormat:@"cell%ld-%ld", (long)indexPath.section, (long)indexPath.row];
	cell = [tableView dequeueReusableCellWithIdentifier:cellName] ?: [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName] autorelease];
	cell.textLabel.text = !CRACK ? [self phraseForIndexPath:indexPath] : [NSString stringWithFormat:@"%@ ¯\\_(ツ)_/¯", normalized([self phraseForIndexPath:indexPath])];
	cell.textLabel.textColor = UIColor.orangeColor;
	return cell;
}

- (NSString *)normalizedString:(NSString *)string
{
	return [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
}

- (void)textFieldDidChange:(UITextField *)sender
{
	UIAlertController *alertController = (UIAlertController *)self.navigationController.presentedViewController;
	if (alertController) {
		UITextField *textField = alertController.textFields.firstObject;
		UIAlertAction *okAction = alertController.actions.firstObject;
		okAction.enabled = [self normalizedString:textField.text].length > 0;
	}
}

- (void)presentNormalAlertWithMessage:(NSString *)message
{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:tweakName message:message preferredStyle:UIAlertControllerStyleAlert];
	[self.navigationController presentViewController:alertController animated:YES completion:nil];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[alertController dismissViewControllerAnimated:YES completion:nil];
	});
}

- (void)presentAlertWithDefaultText:(NSString *)text indexPath:(NSIndexPath *)indexPath
{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:tweakName message:@"Enter phrase" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
		[textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
		textField.clearsOnBeginEditing = NO;
		textField.text = text;
	}];
	BOOL isAddButton = [self isOfLastIndex:indexPath];
	[alertController _addActionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		UITextField *textField = alertController.textFields.firstObject;
		NSString *phrase = [self normalizedString:textField.text];
		NSArray *phrasesForCategory = [self phrasesForCategory:indexPath];
		BOOL duplicate = [phrasesForCategory containsObject:phrase];
		BOOL shouldShowAlert = duplicate;
		BOOL isSelf = NO;
		if (!isAddButton) {
			isSelf = YES;
			BOOL isSame = [[self phraseForIndexPath:indexPath] isEqualToString:phrase];
			shouldShowAlert &= !isSame;
		}
		if (shouldShowAlert) {
			[self presentNormalAlertWithMessage:@"Duplicate words, not adding nor replacing"];
			return;
		}
		if (!isSelf)
			[self addPhrase:phrase forIndexPath:indexPath];
		else
			[self setPhrase:phrase forIndexPath:indexPath];
		
	}];
	if (!isAddButton) {
		[alertController _addActionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[self removePhrase:[self phraseForIndexPath:indexPath] forIndexPath:indexPath];
		}];
	}
	[alertController _addActionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL];
	[self.navigationController presentViewController:alertController animated:YES completion:nil];
	[self textFieldDidChange:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if ([self isOfLastIndex:indexPath])
		[self presentAlertWithDefaultText:@"" indexPath:indexPath];
	else
		[self presentAlertWithDefaultText:[self phraseForIndexPath:indexPath] indexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return ![self isOfLastIndex:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView setEditing:NO animated:YES];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:(!CRACK ? @"Delete" : @"¯\\_(ツ)_/¯") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
		[tableView setEditing:NO animated:YES];
		[self removePhrase:[self phraseForIndexPath:indexPath] forIndexPath:indexPath];
	}];
	return @[deleteAction];
}

@end