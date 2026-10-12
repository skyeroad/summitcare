# Book corrections from building the companion code

Each entry below is a change the manuscript should make. Every one was found by
building `summitcare-api` or the SummitCare iOS sources from the book's listings.
Where a Rails test could show the problem, it was run against the book's version
first and failed, then passed with the correction. "Find" is an exact, unique
snippet from the manuscript when the entry was written; "Replace with" is the
minimal fix.

Fifteen corrections, in manuscript order. Corrections 1-14 have been applied to the manuscript (correction 13 only in part; correction 15 covers the rest).

---

## 1. 06-chapter-6.md (Shared Building Blocks, Patient model; matches Solution 7)

**Find**

```ruby
  phi_attributes :first_name, :last_name, :date_of_birth, :phone,
                 :address_line1, :city, :state, :postal_code
  phi_attributes :mrn, :email, deterministic: true
```

**Replace with**

```ruby
  attribute :date_of_birth, :date # stored as encrypted text
  phi_attributes :first_name, :last_name, :date_of_birth, :phone,
                 :address_line1, :city, :state, :postal_code
  phi_attributes :mrn, deterministic: true
  phi_attributes :email, deterministic: true, downcase: true
```

**Why:** Chapter 6's model doesn't match Solution 7's: without `attribute :date_of_birth, :date`, the date comes back as a String, and without `downcase: true`, email lookups are case-sensitive.

---

## 2. 11-category-a.md, Solution 1 (WebAuthn test)

**Find**

```ruby
require "test_helper"

class WebauthnCredentialTest < ActiveSupport::TestCase
```

**Replace with**

```ruby
require "test_helper"
require "webauthn/fake_client"

class WebauthnCredentialTest < ActiveSupport::TestCase
```

**Why:** `require "webauthn"` doesn't load `FakeClient`, so the test fails with `uninitialized constant WebAuthn::FakeClient` (webauthn 3.4).

---

## 3. 11-category-a.md, Solution 1 (PasskeyRegistrationsController)

**Find**

```ruby
    credential = WebAuthn::Credential.from_create(params.require(:credential).permit!.to_h)
```

**Replace with**

```ruby
    credential = WebAuthn::Credential.from_create(params.require(:credential).permit(
      :type, :id, :rawId, :authenticatorAttachment, clientExtensionResults: {},
      response: [:clientDataJSON, :attestationObject, { transports: [] }]).to_h)
```

**Why:** Brakeman reports `permit!` as a Mass Assignment warning, so the Solution 33 `security.yml` job, which fails on any warning, fails on the book's own code.

---

## 4. 11-category-a.md, Solution 4 (ApplicationController)

**Find**

```ruby
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index
```

**Replace with**

```ruby
  after_action :verify_authorized, unless: -> { action_name == "index" }
  after_action :verify_policy_scoped, if: -> { action_name == "index" }
```

**Why:** Rails 7.1+ sets `raise_on_missing_callback_actions = true` in development and test, so every controller without an `index` action (BreakGlassGrants, Documents, TokenRefreshes...) raises `AbstractController::ActionNotFound`, and the Solution 6 and 9 tests get 404s.

---

## 5. 11-category-a.md, Solution 5 (SummitCareApp)

**Find**

```swift
    @State private var session = SessionManager()
```

**Replace with**

```swift
    private var session: SessionManager { model.sessionManager } // AppModel owns it (Solution 30)
```

**Why:** Solution 30's `AppModel.handle(_:)` signs out `sessionManager`, so `AppModel` must own the one `SessionManager` the views observe; a second instance made by the App would never see the sign-out (AppModel declares `let sessionManager = SessionManager(...)`).

---

## 6. 11-category-a.md, Solution 5 (Proving It, server test)

**Find**

```ruby
    get api_v1_patients_path, headers: { "Authorization" => "Bearer #{tokens[:access_token]}" }
```

**Replace with**

```ruby
    post api_v1_token_refresh_path, params: { refresh_token: tokens[:refresh_token], device_id: "dev-1" }, as: :json
```

**Why:** The access token lives 15 minutes, the same as the idle timeout, so after `travel 16.minutes` `find_by_access_token` returns nil, nothing is revoked, and `revoked_reason` is nil; the refresh path (`refreshable?`) is where the idle revocation happens.

---

## 7. 12-category-b.md, Solution 7 (Proving It)

**Find**

```ruby
    patient = Patient.create!(mrn: "SC-100231", first_name: "Avery",
```

**Replace with**

```ruby
    patient = Patient.create!(mrn: "SC-109999", first_name: "Avery",
```

**Why:** SC-100231 is the `patients(:avery)` fixture, and Solution 16 adds a unique index on `mrn`, so the test raises `PG::UniqueViolation`.

---

## 8. 12-category-b.md, Solution 9 (production.rb excerpt)

**Find**

```ruby
# config/environments/production.rb
config.active_storage.service = :amazon
config.active_storage.service_urls_expire_in = 1.minute
config.active_storage.draw_routes = false
```

**Replace with**

```ruby
# config/environments/production.rb
config.active_storage.service = :amazon
config.active_storage.draw_routes = false

# config/application.rb (every environment, so tests see it)
config.active_storage.service_urls_expire_in = 1.minute
```

**Why:** `DocumentsController#show` reads `Rails.configuration.active_storage.service_urls_expire_in`, which is nil outside production, so the Solution 9 test raises `NoMethodError: undefined method 'from_now' for nil`.

---

## 9. 13-category-c.md, Solution 13 (What You Need)

**Find**

```
- `config.active_record.schema_format = :sql`, so triggers and grants survive into `db/structure.sql`.
```

**Replace with**

```
- `config.active_record.schema_format = :sql`, so the triggers survive into `db/structure.sql`. Grants don't (Rails runs `pg_dump --no-privileges`), so create roles and apply grants in your setup and deploy scripts.
```

**Why:** The generated `db/structure.sql` contains the triggers but no `GRANT` or `REVOKE` statements.

---

## 10. 13-category-c.md, Solution 13 (Proving It)

**Find**

```
`db/structure.sql` showing the triggers and grants,
```

**Replace with**

```
`db/structure.sql` showing the triggers, the output of `\dp audit_events` from the production database showing the grants,
```

**Why:** Same cause as correction 9: `structure.sql` can't show grants.

---

## 11. 13-category-c.md, Solution 16 (whodunnit)

**Find**

```ruby
def user_for_paper_trail = Current.user&.id
```

**Replace with**

```ruby
def user_for_paper_trail = -> { Current.user&.id } # read when the version is saved
```

**Why:** `ApplicationController`'s `before_action` runs before `Api::V1::BaseController` authenticates, so `Current.user` is still nil and every API edit records `whodunnit` nil; PaperTrail 17 accepts a proc and calls it at save time.

---

## 12. 13-category-c.md, Solution 17 (Proving It)

**Find**

```ruby
class AccessAnomalyScanJobTest < ActiveJob::TestCase
```

**Replace with**

```ruby
class AccessAnomalyScanJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper # for assert_enqueued_emails
```

**Why:** `ActiveJob::TestCase` doesn't include `assert_enqueued_emails`, so the test fails with `NoMethodError`.

---

## 13. 15-category-e.md, Solution 23 (config/vendors.yml)

**Find**

```yaml
    sdks: { gems: [aws-sdk-s3, aws-sdk-kms, aws-sdk-bedrockruntime, aws-sdk-sns] }
```

**Replace with**

```yaml
    sdks: { gems: [aws-sdk-s3, aws-sdk-kms, aws-sdk-bedrockruntime, aws-sdk-sns, aws-sdk-rds] }
```

**And find**

```yaml
local_libraries:   # code that makes no network calls of its own
  gems: [pundit, rotp, rqrcode, webauthn, lograge, paper_trail, faraday]
```

**Replace with**

```yaml
  regional_hie:
    name: Regional Health Information Exchange
    purpose: FHIR R4 queries over mutual TLS (Solution 27)
    receives_phi: true
    baa_signed_on: 2026-04-01
    hosts: ["fhir.regional-hie.example"]
    data_categories: [demographics, clinical]
    review_by: 2027-04-01
local_libraries:   # code that makes no network calls of its own
  gems: [pundit, rotp, rqrcode, webauthn, lograge, paper_trail, faraday, prawn, blind_index]
```

**Why:** Solution 27's `FhirClient` calls `HttpClient.for(:regional_hie, ...)`, which raises `VendorRegistry::UnknownVendor` without the entry, and `bin/check_vendor_sdks` fails on the `aws-sdk-rds` (Solution 28), `prawn` (Solution 18), and `blind_index` (Solution 7) gems the book adds.

---

## 14. 15-category-e.md, Solution 23 (bin/check_vendor_sdks)

**Find**

```ruby
# bin/check_vendor_sdks
require "bundler"
```

**Replace with**

```ruby
# bin/check_vendor_sdks
require "bundler"
require "date"
```

**Why:** `permitted_classes: [Date]` refers to `Date`, but neither `bundler`, `json` nor `yaml` loads it, so the script exits with `uninitialized constant Date (NameError)` before checking anything.

---

## 15. 15-category-e.md, Solution 23 (config/vendors.yml, rest of correction 13)

Correction 13 has two parts. The `aws-sdk-rds` part is in the manuscript; the
`regional_hie` vendor and the two new `local_libraries` gems are not.

**Where:** in "#### 1. Write the registry", the `config/vendors.yml` listing,
immediately after the `sentry:` entry (which ends `review_by: 2027-03-01`) and
before the closing `swift_packages: []` line. If the listing gets rewrapped,
look for the line starting `local_libraries:` and the `gems: [pundit, ...]`
line under it.

**Find**

```yaml
local_libraries:   # code that makes no network calls of its own
  gems: [pundit, rotp, rqrcode, webauthn, lograge, paper_trail, faraday]
```

**Replace with**

```yaml
  regional_hie:
    name: Regional Health Information Exchange
    purpose: FHIR R4 queries over mutual TLS (Solution 27)
    receives_phi: true
    baa_signed_on: 2026-04-01
    hosts: ["fhir.regional-hie.example"]
    data_categories: [demographics, clinical]
    review_by: 2027-04-01
local_libraries:   # code that makes no network calls of its own
  gems: [pundit, rotp, rqrcode, webauthn, lograge, paper_trail, faraday,
         prawn, blind_index]
```

**Why:** Solution 27's `FhirClient` calls `HttpClient.for(:regional_hie, ...)`, and the manuscript itself says the guard refuses the call unless `regional_hie` has a BAA on file, but no entry exists, so `VendorRegistry` raises `UnknownVendor`. Separately, `bin/check_vendor_sdks` fails on the `prawn` (Solution 18) and `blind_index` (Solution 7) gems the book adds. The entry is indented two spaces so it nests under `vendors:`.
