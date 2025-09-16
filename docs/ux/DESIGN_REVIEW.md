# Design Review Checklist

## Visual Design
- [ ] **Color Consistency**: Primary (Gold #FFD700) and secondary colors used consistently
- [ ] **Typography Hierarchy**: Clear distinction between headings, body, and labels
- [ ] **Spacing Consistency**: Using defined spacing tokens (4px base grid)
- [ ] **Border Radius**: Consistent use of radius tokens (xs, sm, md, lg, xl)
- [ ] **Shadows**: Appropriate elevation for cards and modals

## Accessibility (A11y)
- [ ] **Color Contrast (WCAG AA)**: 
  - [ ] Normal text: 4.5:1 contrast ratio
  - [ ] Large text: 3:1 contrast ratio
  - [ ] Gold on black: ✓ (Passes with 15.3:1)
  - [ ] Black on gold: ✓ (Passes with 15.3:1)
- [ ] **Focus States**: Visible focus indicators for all interactive elements
- [ ] **Touch Targets**: Minimum 48x48px for all clickable elements
- [ ] **Screen Reader**: Semantic HTML and proper ARIA labels
- [ ] **Keyboard Navigation**: All features accessible via keyboard

## Theme Support
- [ ] **Light Mode**: All components look good on white background
- [ ] **Dark Mode**: All components look good on dark background
- [ ] **Theme Switching**: Smooth transition between themes
- [ ] **Salon Overrides**: Custom colors apply correctly

## Responsive Design
- [ ] **Mobile (< 600px)**: Single column, optimized for touch
- [ ] **Tablet (600-1024px)**: 2-column layouts where appropriate
- [ ] **Desktop (≥ 1024px)**: 3-column layouts, navigation rail
- [ ] **Text Scaling**: Supports up to 1.3x text scale
- [ ] **Landscape Orientation**: Layouts adapt properly

## Component Consistency
- [ ] **Buttons**: All variants (primary, secondary, ghost) styled consistently
- [ ] **Cards**: Consistent padding, shadows, and border radius
- [ ] **Forms**: Consistent input styling and validation states
- [ ] **Empty States**: Present for all list/search views
- [ ] **Loading States**: Skeletons or spinners for all async operations
- [ ] **Error States**: Consistent error messaging (banners, toasts)

## Performance & UX
- [ ] **Loading Indicators**: Present for operations > 300ms
- [ ] **Error Handling**: User-friendly error messages
- [ ] **Success Feedback**: Clear confirmation for user actions
- [ ] **Animation**: Smooth, purposeful animations (not excessive)
- [ ] **Offline State**: Clear messaging when offline

## PWA Requirements
- [ ] **Manifest**: Complete with all required fields
- [ ] **Icons**: All sizes present (72px to 512px)
- [ ] **Maskable Icons**: Safe zone respected
- [ ] **Theme Color**: Matches brand (#FFD700)
- [ ] **Splash Screen**: Branded loading experience
- [ ] **Offline Page**: Fallback when offline

## Platform Specific
- [ ] **iOS**: 
  - [ ] Status bar style appropriate
  - [ ] Safe area insets respected
  - [ ] Apple touch icon present
- [ ] **Android**:
  - [ ] Material Design guidelines followed
  - [ ] System navigation respected
- [ ] **Web**:
  - [ ] Responsive to all viewport sizes
  - [ ] Browser compatibility (Chrome, Safari, Firefox, Edge)

## Internationalization (i18n)
- [ ] **RTL Support**: Layout mirrors correctly for RTL languages
- [ ] **Text Expansion**: UI handles 30% text expansion
- [ ] **Date/Time Formats**: Localized appropriately
- [ ] **Currency**: Formatted per locale

## Content Guidelines
- [ ] **Microcopy**: Clear, concise, and helpful
- [ ] **Error Messages**: Actionable and user-friendly
- [ ] **Empty States**: Helpful guidance for users
- [ ] **Loading Messages**: Informative progress indicators

## Testing Checklist
- [ ] **Device Testing**:
  - [ ] iPhone (various sizes)
  - [ ] Android phones (various sizes)
  - [ ] iPad
  - [ ] Android tablets
  - [ ] Desktop browsers
- [ ] **Accessibility Testing**:
  - [ ] Screen reader (VoiceOver/TalkBack)
  - [ ] Keyboard navigation
  - [ ] High contrast mode
  - [ ] Text scaling (up to 200%)
- [ ] **Theme Testing**:
  - [ ] System theme changes
  - [ ] Manual theme toggle
  - [ ] Salon overrides

## Final Review
- [ ] **Brand Consistency**: Follows SalonManager brand guidelines
- [ ] **User Flow**: Intuitive navigation and task completion
- [ ] **Visual Polish**: No rough edges or inconsistencies
- [ ] **Performance**: Smooth scrolling and interactions
- [ ] **Documentation**: Design decisions documented

---

## Review Sign-off

**Reviewer**: _________________  
**Date**: _________________  
**Version**: _________________

### Notes:
_Add any specific notes or exceptions here_