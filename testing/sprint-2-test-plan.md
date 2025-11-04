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
