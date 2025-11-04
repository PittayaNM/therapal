#  Therapal Test Case Plan

## 1. Scope

### Functional
- **Authentication**  
- **Registration**  
- **Therapy Booking**  
- **Payment**  
- **User Profile**  
- **Live Streaming**

### UI/UX
- Test **interface responsiveness** and **overall design consistency** across **iOS** and **Android**.

### Validation
- Verify **form input correctness**, including:
  - Email format
  - Password rules
  - Payment details validation

### Navigation
- Ensure **smooth screen transitions**, e.g.:
  - `Login → Home → Therapy Booking`

### Payment Flows
- Validate **successful processing** of payments for therapy sessions.

---

### Project Information
| Field | Details |
|--------|----------|
| **Project** | Therapal – Therapy Booking and Live Streaming Platform |
| **Purpose** | Define **manual test coverage** for major user journeys and key edge cases in the Therapal mobile app |
| **Audience** | QA Engineers, Developers, Product Owners |
| **Date** | 22 October 2025 |

---

## 2. Test Strategy

### Approach
- **Risk-based testing**: Prioritize high-impact features — *registration, therapy booking, payments, live streaming.*

### Levels
- **Component**
- **Integration**
- **System**

### Types
- **Functional Testing**
- **UI/UX Testing**
- **Validation Testing**
- **Regression Testing**

---

## 3. Test Environments & Data

| Category | Details |
|-----------|----------|
| **Environment (ENV)** | Staging backend with seeded test data |
| **Accounts** | Roles: User, Therapist, Admin |
| **Payment Cards (Sandbox)** | Visa and MasterCard test tokens |
| **Sample Therapist Names** | Dr. Ugo David, Dr. Maya Chan, Dr. Kevin Lee |

---

## 4. Entry and Exit Criteria

### Entry Criteria
- Environment ready  
- Data seeded  
- App installed on iOS and Android devices  

### Exit Criteria
- All **P0/P1** test cases pass  
- No **critical defects** remain open  
# TEST CASE TEMPLATE

| Project Name | Therapal |  | Test Case Author | Boss |
|---|---|---|---|---|
| Priority | Low |  | Test Case Reviewer | Thun |
| Description |  |  | Test Case Version | Name |
| Test Objective |  |  | Test Execution Date | 4/11/2025 |

---

## 1. LOGIN

| Test Case ID | Test Title | Test Steps | Input Data | Expected Results | Actual Results | Execution Status |
|---|---|---|---|---|---|---|
| TC_001 | Login with valid email and password | Enter valid email and password | email : test@gmail.com<br>password : Test123 | Log in success and navigate to home page | Log in success and navigate to home page | Pass |
| TC_002 | Login with missing Email | 1. Open the TheraPal Sign In page.<br><br>2. Leave the email field empty.<br><br>3. Enter a valid password  in the password field.<br><br>4. Click the Sign In button. | password : Test123 | Error login and missing email | Display error "please enter your email" | Pass |
| TC_003 | Login with missing password | 1. Open the login page.<br><br>2. Enter a valid email address in the email field.<br><br>3. Leave the password field empty.<br><br>4. Click the "Sign In" button. | email : test@gmail.com | The system should display an error message: <br>"Please enter your password." | Display error "please enter your password"  | Pass |
| TC_004 | Login with Invalid Email Format | 1. Open the TheraPal Sign In page.<br><br>2. Enter an invalid email format (e.g., userexample.com).<br><br>3. Enter a valid password (e.g., password123).<br><br>4. Click the Sign In button. | email : testtest | The system should display an error message: "Please enter a valid email address." | Display error "Invalid email format" | Pass |
| TC_005 | Show/Hide Password Button | 1. Enter an email and password into the input fields.<br><br>2. Click the Show Password button (usually an eye icon).<br><br>3. Verify that the password is displayed in plain text.<br><br>4. Click the button again to hide the password. | email : test@gmail.com<br>password : Test123 | The password should toggle between being shown and hidden each time the button is clicked. | The password field correctly toggles visibility | Pass |
| TC_006 | Password Too Short | 1.Open the login page.<br><br>2. Enter a valid email address in the email field.<br><br>3. Enter a password that is too short (e.g., less than 6 characters).<br><br>4. Click the Sign In button. | email : test@gmail.com<br>password : Test1 | The system should display an error message: "Password is too short. Minimum 6 characters required." | Display error "At least 6 characters" | Pass |
| TC_007 | Sign Up Link | 1. Open the TheraPal Sign In page.<br><br>2. Click on the Sign Up link. |  | The user should be redirected to the Sign Up page to create a new account. | User navigate to Sign Up page | Pass |
| TC_008 | Forgot Password Link | 1. Open the TheraPal Sign In page.<br><br>2. Click on the Forgot Password link. |  | The user should be redirected to the Forgot Password page where they can reset their password. | User navigate to Forgot Password  page |  |

---

## 2. REGISTER

| Test Case ID | Test Title | Test Steps | Input Data | Expected Results | Actual Results | Execution Status |
|---|---|---|---|---|---|---|
| REG_001 | Register with Valid Data | 1. Open the TheraPal Sign Up page.<br><br>2. Enter a valid name (e.g., John Doe).<br><br>3. Enter a valid date of birth (e.g., 01/01/1990).<br><br>4. Enter a valid email address (e.g., test@gmail.com).<br><br>5. Enter a valid phone number (e.g., 1234567890).<br><br>6. Enter a valid password (e.g., password123).<br><br>7. Confirm the password (e.g., password123).<br><br>8. Click the Sign Up button. | Name: John Doe<br><br>Date of Birth: 01/01/1990<br><br>Email: test@gmail.com<br><br>Phone Number: 1234567890<br><br>Password: test123<br><br>Password Confirmation: test123 | The system should create a new user account and redirect the user to the Home Page or login page. | The user was successfully registered and redirected to the Home Page. | Pass |
| REG_002 | Register with Missing Name | 1. Open the TheraPal Sign Up page.<br><br>2. Leave the name field empty.<br><br>3. Enter a valid date of birth.<br><br>4. Enter a valid email address.<br><br>5. Enter a valid phone number.<br><br>6. Enter a valid password.<br><br>7. Confirm the password.<br><br>8. Click the Sign Up button. | Name: (leave empty)<br><br>Date of Birth: 01/01/1990<br><br>Email: user@example.com<br><br>Phone Number: 1234567890<br><br>Password: test123<br><br>Password Confirmation: test123 | The system should display an error message: "Please enter your name." | Display error "Please enter your name" |  |
| REG_003 | Register with Invalid Email Format | 1. Open the TheraPal Sign Up page.<br><br>2. Enter a valid name.<br><br>3. Enter a date of birth.<br><br>4. Enter an invalid email address (e.g., userexample.com without @).<br><br>5. Enter a valid phone number.<br><br>6. Enter a valid password.<br><br>7. Confirm the password.<br><br>8. Click the Sign Up button. | Name: John Doe<br><br>Date of Birth: 01/01/1990<br><br>Email: test.com (invalid)<br><br>Phone Number: 1234567890<br><br>Password: test123<br><br>Password Confirmation: test123 | The system should display an error message: "Please enter a valid email address." | Display error "Please enter a valid email address." |  |
| REG_004 | Register with Mismatched Password and Confirmation | 1. Open the TheraPal Sign Up page.<br><br>2. Enter a valid name.<br><br>3. Enter a valid date of birth.<br><br>4. Enter a valid email address.<br><br>5. Enter a valid phone number.<br><br>6. Enter a password (e.g., password123).<br><br>7. Enter a password confirmation that does not match the original password (e.g., password321).<br><br>8. Click the Sign Up button. | Name: John Doe<br><br>Date of Birth: 01/01/1990<br><br>Email: test@gmail.com<br><br>Phone Number: 1234567890<br><br>Password: test123<br><br>Password Confirmation: test321 | The system should display an error message: "Passwords do not match." | Display error "Passwords do not match." |  |
| REG_005 | Register with Short Password | 1. Open the TheraPal Sign Up page.<br><br>2. Enter a valid name.<br><br>3. Enter a valid date of birth.<br><br>4. Enter a valid email address.<br><br>5. Enter a valid phone number.<br><br>6. Enter a password that is too short (e.g., 12345).<br><br>7. Confirm the password with the same short value.<br><br>8. Click the Sign Up button. | Name: John Doe<br><br>Date of Birth: 01/01/1990<br><br>Email: test@gmail.com<br><br>Phone Number: 1234567890<br><br>Password: 12345 (too short)<br><br>Password Confirmation: 12345 | The system should display an error message: "Password is too short. Minimum 6 characters required." | Display error "Password is too short. Minimum 6 characters required." |  |
| REG_006 | "Already have an account? Sign In" Link | 1. Open the TheraPal Sign Up page.<br><br>2. Click on the Sign In link. |  | The user should be redirected to the Sign In page. | User navigate to Sign In page |  |

---

## 3. FORGOT PASSWARD

| Test Case ID | Test Title | Test Steps | Input Data | Expected Results | Actual Results | Execution Status |
|---|---|---|---|---|---|---|
| FP-001 | Verify Forgot Password screen UI elements | 1. Launch the app<br>2. Navigate to 'Forgot Password'  |  | All UI elements are displayed: Phone number field, country code, 'Submit' button, app logo, and title 'Forgot Password'. |  |  |
| FP-002 | Verify entering valid phone  | 1. Navigate to Forgot Password<br>2. Enter a valid registered phone number | 876454321 | System sends OTP to registered phone number and navigates to Verify OTP screen. |  |  |
| FP-003 | Verify entering invalid phone number format | 1. Navigate to Forgot Password<br>2. Enter invalid phone number format<br>3. Tap 'Su | 12345 | System displays validation error message: 'Please enter a valid phone number.' |  |  |
| FP-004 | Verify OTP entry and validation | 1. On Verify OTP screen, enter correct OTP received | 987654 | System validates OTP successfully and navigates to Reset Password screen. |  |  |
| FP-005 | Verify invalid OTP entry | 1. On Verify OTP screen, enter incorrect OTP | 111111 | System displays error: 'Invalid OTP. Please try again.' |  |  |
| FP-006 | Verify OTP resend functionality | 1. On Verify OTP screen, wait for resend timer |  | System resends OTP successfully and updates timer. |  |  |
| FP-007 | Verify resetting password successfully | 1. On Reset Password screen, enter new password and confirm password<br>2. Tap 'Submit' | NewPassword123 / NewPassword123 | System resets password successfully and navigates to Login screen with success message. |  |  |
| FP-008 | Verify mismatch password validation | 1. On Reset Password screen, enter new password and confirm password<br>2. Tap 'Submit' | NewPassword123 / NewPassword321 | System shows error: 'Passwords do not match.' |  |  |
| FP-009 | Verify empty fields validation | 1. Leave all fields blank on any screen |  | System highlights required fields and shows appropriate validation messages. |  |  |

---

## 4. HOME

| Test Case ID | Test Title | Test Steps | Input Data | Expected Results | Actual Results | Execution Status |
|---|---|---|---|---|---|---|
| HME_001 | Verify Home Page Content After Login | 1. Log in with valid credentials (email and password).<br><br>2. Verify that the user is redirected to the Home Page.<br><br>3. Check that the user's profile picture is displayed at the top.<br><br>4. Verify the greeting message shows the correct username (e.g., "Hi, George").<br><br>5. Check that all the menu options are displayed : Lives,Appointment,Therapy ,Help,Subscription<br><br>6. Verify the Settings & Privacy link is present at the bottom of the screen. |  | The user should be logged in successfully.<br><br>The Home Page should load with the correct profile picture and username.<br><br>All menu options and the Settings & Privacy link should be visible. | The user was logged in successfully using the valid credentials (test@gmail.com and test123).<br><br>The Home Page loaded without issues, displaying the correct profile picture and the greeting message: "Hi, George" (assuming the logged-in user is George).<br><br>All menu options were visible and displayed correctly<br><br>The Settings & Privacy link was visible at the bottom of the page. |  |
| HME_002 | Navigation to "Lives" Section | 1. From the Home Page, click on the Lives button.<br><br>2. Verify that the app navigates to the Lives section. |  | The app should successfully navigate to the Lives section and display relevant content. | After clicking the Lives button from the Home Page, the app successfully navigated to the Lives section.<br><br>The Lives section loaded correctly, displaying the relevant content. |  |
| HME_003 | Navigation to "Appointment" Section | 1. On the Home Page, click the Appointment button.<br><br>2. Verify that the app navigates to the Appointment section. |  | The app should navigate to the Appointment section and display relevant information (e.g., scheduled appointments or booking options). | Clicking the Appointment button successfully navigated to the Appointment section. |  |
| HME_004 | Navigation to "Therapy" Section | 1. On the Home Page, click the Therapy button.<br><br>2. Verify that the app navigates to the Therapy section. |  | The app should navigate to the Therapy section, displaying therapy services, options, or related content. | Clicking the Therapy button successfully navigated to the Therapy section. |  |
| HME_005 | Navigation to "Help" Section | 1. On the Home Page, click the Help button.<br><br>2. Verify that the app navigates to the Help section. |  | The app should navigate to the Help section, providing assistance or FAQs. | Clicking the Help button successfully navigated to the Help section. |  |
| HME_006 | Navigation to "Subscription" Section | 1. From the Home Page, click on the Subscription button.<br><br>2. Verify that the app navigates to the Subscription section. |  | The app should successfully navigate to the Subscription section, showing subscription details or options. | After clicking the Subscription button from the Home Page, the app successfully navigated to the Subscription section.<br><br>The Subscription section loaded correctly, displaying the subscription details, options, or pricing . |  |
| HME_007 | "Settings & Privacy" Link | 1. On the Home Page, click the Settings & Privacy link at the bottom of the screen.<br><br>2. Verify that the app navigates to the Settings & Privacy section. |  | The app should navigate to the Settings & Privacy section, where users can manage settings related to privacy and preferences. |  | FAIL |

---

## 5. PROFILE

| Test Case ID | Test Title | Test Steps | Input Data | Expected Results | Actual Results | Execution Status |
|---|---|---|---|---|---|---|
| PRF_001 | Verify Profile Page Content | 1. After logging in, click on the Profile button from the Home Page.<br><br>2. Verify that the Profile Page opens successfully.<br><br>3. Verify that the profile picture (e.g., "George Josure" profile) is visible at the top.<br><br>4. Verify that the username ("George Josure") is correctly displayed.<br><br>5. Verify that the Personal Details section Name,Email,Contact,Date of birth.<br><br>6. Verify that the Contact Us section is displayed correctly with: Phone,Email<br><br>7. Verify that the Log Out button is visible at the bottom. |  | The Profile Page should load correctly with all profile details visible, including:<br>Profile picture,Personal details (Name, Email, Contact, Date of Birth),Contact Us information (Phone, Email)<br><br>Log Out button should be visible at the bottom of the page. | The profile picture, username, personal details, contact information, and the Log Out button were displayed correctly on the Profile Page. |  |
| PRF_002 | Profile Navigation | 1. On the Home Page, click the Profile button.<br><br>2. Verify that the user is redirected to the Profile Page.<br><br>3. Check that the Profile Page loads successfully and contains the correct information (e.g., name, email, contact details). |  | The app should successfully navigate to the Profile Page.<br><br>The Profile Page should load with correct information. | The app navigated successfully to the Profile Page and displayed the correct information. |  |
| PRF_003 | Profile Data Consistency | 1. On the Profile Page, edit the Personal Details (e.g., change the Email).<br><br>2. Save the changes and go back to the Profile Page.<br><br>3. Verify that the updated data (e.g., the new email) is correctly displayed on the profile. |  | The updated Personal Details (e.g., new email) should be displayed correctly on the Profile Page after the changes are saved. |  |  |
| PRF_004 | "Edit" Button for Personal Details | 1. On the Profile Page, click the Edit button next to the Personal Details section.<br><br>2. Verify that the user can edit the Personal Details fields (e.g., Name, Email, Contact).<br><br>3. Make changes to the Personal Details and save.<br><br>4. Verify that the changes are reflected on the Profile Page. |  | The user should be able to edit their Personal Details.<br><br>The changes made to the details should be saved and reflected immediately on the Profile Page. | The Edit button allowed the user to modify Personal Details and save them correctly. The changes were reflected immediately on the Profile Page. |  |
| PRF_005 | Verify "Settings & Privacy" Link | 1. On the Home Page or Profile Page, click on the Settings & Privacy link.<br><br>2. Verify that the user is redirected to the Settings & Privacy page. |  | The app should navigate to the Settings & Privacy page.<br><br>The user should see the settings options for privacy and other related preferences. | Clicking on Settings & Privacy successfully navigated to the appropriate page. |  |
| PRF_006 | "Log Out" Button | 1. On the Profile Page, click the Log Out button.<br><br>2. Verify that the user is logged out and redirected to the Login Page. |  | After clicking Log Out, the user should be logged out, and the app should redirect to the Login Page. | Clicking the Log Out button successfully logged the user out, and the app redirected to the Login Page. |  |

---

## 6. LIVES

| Test Case ID | Test Title | Test Steps | Input Data | Expected Results | Actual Results | Execution Status |
|---|---|---|---|---|---|---|
| LIV_001 | Verify Content in Lives Section | 1. After logging in, click on the Lives button in the Home Page.<br><br>2. Verify that the Lives Page loads successfully.<br><br>3.Check that the Lives Page is divided into the following sections:<br>Recommend, Sport, Meditation<br><br>4. Verify that each live session includes:<br>Session Title (e.g., "Dr. Ro Diaries").<br>Number of Likes and Views.<br>A thumbnail image or video preview.<br><br>5. Verify that all sections (Recommend, Sport, Meditation) are scrollable if there are more sessions than visible on the screen.<br><br>6. Verify that each live session thumbnail can be clicked to navigate to the live session's detailed page or playback. |  | The Lives Page should load correctly, displaying the Recommend, Sport, and Meditation sections.<br><br>Each section should display the session title, likes, views, and thumbnail.<br><br>The page should be scrollable if the number of sessions exceeds the visible area.<br><br>Each session should be clickable and should navigate to its corresponding session's detailed page or video. | The Lives Page failed to load correctly.<br><br>The Recommend, Sport, or Meditation sections were not displayed, or were partially missing.<br><br>One or more live sessions did not show the expected session title, likes, views, or thumbnail. | FAIL |
| LIV_002 | Live Session Detail Page | 1. On the Lives Page, click on one of the live session thumbnails (e.g., "Dr. Ro Diaries").<br><br>2. Verify that the app navigates to the Live Session Detail Page.<br><br>3. Verify that the session title, video, and other details are displayed on the detail page. |  | The app should navigate to the Live Session Detail Page of the selected session.<br><br>The detail page should display the session title, video player or content, likes, views, and any additional session details. | Clicking on the live session thumbnail  navigate to the Live Session Detail Page. | PASS |
| LIV_003 | Scroll Functionality in Lives Section | 1. On the Lives Page, scroll down the Recommend, Sport, and Meditation sections.<br><br>2. Verify that additional live sessions become visible as you scroll down.<br><br>3. Verify that no sections are cut off and all content is accessible. |  | The Lives Page should be scrollable, and additional sessions should load as you scroll down.<br><br>The page should display content for all sessions in Recommend, Sport, and Meditation sections without issues. | The Lives Page was not scrollable, and additional sessions did not load as I scrolled down. | FAIL |
| LIV_004 | Like/Follow Button on Live Sessions | 1. On the Lives Page, click the Like button on any live session (e.g., "Dr. Ro Diaries").<br><br>2. Verify that the Like button changes state (e.g., becomes filled or shows the updated count of likes).<br><br>3. Verify that the Like count updates accordingly .<br><br>4. Click the Like button again to unlike the session, and verify that the Like count decreases by 1. |  | The Like button should toggle between "liked" and "unliked" states.<br><br>The Like count should update correctly when clicked (increase by 1 for like, decrease by 1 for unlike). | Clicking the Like button did not change the button state or update the Like count. | FAIL |
| LIV_005 | "Live Out" Section Visibility | 1. On the Lives Page, verify that the "Live Out" section (if present) is visible.<br><br>2. Verify that the section contains live sessions that are currently unavailable or offline (if applicable). |  | The "Live Out" section should be visible if there are any live sessions that are no longer available or have ended.<br><br>The section should clearly indicate that these sessions are offline or unavailable. | The "Live Out" section was not visible on the Lives Page. | FAIL |

---

## 7. APPOINTMENT

| Test Case ID | Test Title | Test Steps | Input Data | Expected Results | Actual Results | Execution Status |
|---|---|---|---|---|---|---|
| APO_001 | Active "Join" Button on Appointment Page | 1. On the Appointment Page, verify that there are two "join" buttons:<br>1-on-1 therapy session on 30/9/2025 (enabled button).<br>Group therapy session on 1/10/2025 (disabled button).<br><br>2. Click the "join" button next to the 1-on-1 therapy session.<br><br>3. Verify that the app navigates to the corresponding Live Session Detail Page or session page.<br><br>4. Click the "join" button next to the Group therapy session.<br><br>5. Verify that the "join" button for Group therapy is disabled, and clicking it does not trigger any action. |  | Clicking the "join" button next to the 1-on-1 therapy session should successfully navigate the user to the Live Session Detail Page.<br><br>The "join" button next to the Group therapy session should be disabled, and clicking it should not trigger any navigation or action. | Clicking the "join" button next to the 1-on-1 therapy session  did not navigate to the Live Session Detail Page. | FAIL |
| APO_002 | Verify Appointment Page - Upcoming and Last Week Sessions | 1. The Upcoming section correctly displayed therapy sessions with:<br>Active "join" buttons for upcoming sessions like 1-on-1 therapy .<br>Correct session title, date, time, and doctor's name.<br><br>2. The Last Week section displayed past therapy sessions with:<br>Disabled "join" buttons for sessions such as Group therapy .<br><br>3. Clicking the "join" button for the active 1-on-1 therapy session  successfully navigated to the Live Session Detail Page.<br><br>4. Clicking the disabled "join" button for Group therapy  did not trigger any action, as expected. |  | The Upcoming section should list therapy sessions with the correct details:<br>Active sessions should display a green "join" button.<br><br>The Last Week section should list past therapy sessions:<br>Past sessions should have a disabled "join" button or should be non-interactive.<br><br>Clicking the "join" button for an active session should navigate to the Live Session Detail Page.<br><br>Clicking the "join" button for past sessions should do nothing or display a message indicating the session is unavailable. | The Upcoming section did not display some or all sessions, or the "join" buttons were missing | FAIL |
| APO_003 | Session Details in Appointment Page | 1. On the Appointment Page, click on the 1-on-1 therapy session scheduled for 30/9/2025.<br><br>2. Verify that the session details, including:<br>Date: 30/9/2025<br>Time: 11:00-13:00<br>Doctor's Name: Dr. Ugo David<br><br>3. Verify that the session information is displayed accurately, including any possible additional information like session status (active, completed, etc.).<br><br>4. Verify the presence of the "join" button if the session is upcoming and clickable. |  | The session details for the 1-on-1 therapy session on 30/9/2025 should be accurate, including:<br><br>The correct date and time.<br><br>The correct doctor's name.<br><br>The "join" button should be clickable for the upcoming session. | The session details for the 1-on-1 therapy session on 30/9/2025 were incorrect or missing.<br><br>Date, time, or doctor's name were not displayed, or incorrect.<br><br>The "join" button was missing or not functional. | FAIL |
| APO_004 | Disabled "Join" Button for Past Sessions | 1. On the Appointment Page, click on the 1-on-1 therapy session from 17/9/2025 in the Last Week section.<br><br>2. Verify that the "join" button is disabled for past sessions.<br><br>3. Verify that clicking the disabled "join" button does not trigger any action or navigation. |  | The "join" button for past sessions should be disabled, and clicking it should not trigger any navigation or action. | The "join" button for the 1-on-1 therapy session on 17/9/2025 was not disabled or became active when it should have been disabled. | FAIL |
