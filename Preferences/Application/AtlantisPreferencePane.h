

@protocol AtlantisPreferencePane

- (NSString *) preferencePaneName;
- (NSImage *) preferencePaneImage;
- (NSView *) preferencePaneView;

- (void) preferencePaneCommit;

@end

