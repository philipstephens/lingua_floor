## Session access flow

This flow chart captures the current app behavior for login, scheduled-session selection, role routing, and logout.

```mermaid
flowchart TD
    A[Open LinguaFloor] --> B[Load auth session]
    B --> C[Load scheduled session catalog]
    C --> D{Authenticated user exists?}
    D -- No --> E[Enter display name]
    E --> F[Select scheduled session / time period]
    F --> G{Choose role}
    G -- Host --> H[Login as host for selected session]
    G -- Participant --> I[Login as participant for selected session]
    H --> J[Open Host Dashboard]
    I --> K[Open Participant Room]
    J --> L[Edit event setup for selected session]
    K --> M[Use participant transcript / hand-raise tools]
    L --> N[Session updates persist to catalog]
    M --> N
    D -- Yes --> O[Prefill display name and selected session]
    O --> G
    J --> P[Logout]
    K --> P
    P --> Q[Clear auth session]
    Q --> R[Return to join screen]
```

### Notes

- One LinguaFloor app now supports multiple scheduled sessions under the same shared floor.
- Login is tied to both a role and the selected scheduled session.
- Each user has one active transcript language preference at a time.
- Transcript translations are cached once per distinct target language and shared with all users on that language.
- Logout returns the user to the join screen and clears the in-memory auth session.

