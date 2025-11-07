# Testing Inventory - Controllers, Services & Models

## Controllers Inventory

### 1. **ErrorsController** ⭐ SIMPLE - Start here
- **Complejidad**: Muy Simple
- **Servicios**: Ninguno
- **Modelos**: Ninguno
- **Acciones**: not_found, internal_server_error
- **Prioridad**: 1 (Ideal para comenzar)

---

### 2. **AudioCaptchaController** ⭐ SIMPLE
- **Complejidad**: Simple
- **Servicios**: Ninguno (genera archivos de audio)
- **Modelos**: Ninguno
- **Acciones**: index (genera audio), speech (configuración TTS)
- **Dependencias**: Espeak
- **Prioridad**: 2

---

### 3. **ToolsController** ⭐ SIMPLE
- **Complejidad**: Simple
- **Servicios**: Ninguno
- **Modelos**: Election, User
- **Acciones**: user_elections (filtra elecciones por estado)
- **Prioridad**: 3

---

### 4. **ParticipationTeamsController** ⭐ SIMPLE-MEDIUM
- **Complejidad**: Simple-Media
- **Servicios**: Ninguno
- **Modelos**: ParticipationTeam, User
- **Acciones**: join, leave
- **Prioridad**: 4

---

### 5. **NoticeController** ⭐ MEDIUM
- **Complejidad**: Media
- **Servicios**: Ninguno
- **Modelos**: Notice, NoticeRegistrar, User
- **Acciones**: index, create
- **Autenticación**: Requerida
- **Prioridad**: 5

---

### 6. **OrdersController** ⭐ MEDIUM-COMPLEX
- **Complejidad**: Media-Alta
- **Servicios**: RedsysPaymentProcessor
- **Modelos**: Order, Collaboration
- **Acciones**: callback_redsys (procesa pagos)
- **Dependencias**: XML parsing, SOAP
- **Prioridad**: 6

---

### 7. **MilitantController** ⭐ MEDIUM-COMPLEX
- **Complejidad**: Media-Alta
- **Servicios**: UrlSignatureService
- **Modelos**: User
- **Acciones**: get_militant_info
- **Dependencias**: HMAC verification
- **Prioridad**: 7

---

### 8. **PageController** ⭐ COMPLEX
- **Complejidad**: Alta
- **Servicios**: UrlSignatureService
- **Modelos**: Page, User
- **Acciones**: Múltiples (show_form, privacy_policy, etc.)
- **Dependencias**: Forms iframe embedding
- **Prioridad**: 8

---

### 9. **CollaborationsController** ⭐ COMPLEX
- **Complejidad**: Alta
- **Servicios**: Ninguno (usa métodos de modelo)
- **Modelos**: Collaboration, Order, User
- **Acciones**: new, create, edit, modify, destroy, confirm, OK, KO, single
- **Lógica de negocio**: Frecuencias, pagos, órdenes
- **Prioridad**: 9

---

### 10. **VoteController** ⭐ VERY COMPLEX
- **Complejidad**: Muy Alta
- **Servicios**: CensusFileParser, PaperVoteService
- **Modelos**: Vote, Election, ElectionLocation, User
- **Acciones**: create, create_token, check, paper_vote, send_sms_check, election_votes_count
- **Validaciones**: Múltiples checks de autorización
- **Prioridad**: 10

---

### 11. **MicrocreditController** ⭐ VERY COMPLEX
- **Complejidad**: Muy Alta
- **Servicios**: LoanRenewalService
- **Modelos**: Microcredit, MicrocreditLoan, MicrocreditOption, User
- **Acciones**: index, new_loan, create_loan, renewal, loans_renewal, loans_renew, show_options
- **Lógica de negocio**: Renovaciones, préstamos, opciones
- **Prioridad**: 11

---

### 12. **UserVerificationsController** ⭐ VERY COMPLEX
- **Complejidad**: Muy Alta
- **Servicios**:
  - UserVerificationReportService
  - TownVerificationReportService
  - ExteriorVerificationReportService
- **Modelos**: UserVerification, User
- **Acciones**: new, create, report, report_town, report_exterior
- **Queries complejas**: Agregaciones SQL extensas
- **Prioridad**: 12

---

### 13. **ImpulsaController** ⭐ VERY COMPLEX
- **Complejidad**: Muy Alta
- **Servicios**: Ninguno
- **Modelos**: ImpulsaProject, ImpulsaEdition, ImpulsaEditionCategory, User
- **Acciones**: Wizard multi-step, upload files
- **Estado**: Máquina de estados compleja
- **Prioridad**: 13

---

### 14. **API::V1Controller & API::V2Controller** ⭐ COMPLEX
- **Complejidad**: Alta
- **Servicios**: Varios
- **Modelos**: Múltiples
- **Acciones**: API endpoints
- **Prioridad**: 14-15

---

### 15. **Devise Controllers** (Sessions, Registrations, Passwords, Confirmations, LegacyPassword)
- **Complejidad**: Media-Alta
- **Servicios**: Ninguno
- **Modelos**: User
- **Framework**: Devise
- **Prioridad**: 16-20

---

### 16. **OpenIdController** ⭐ VERY COMPLEX
- **Complejidad**: Muy Alta
- **Servicios**: Ninguno
- **Modelos**: User
- **Acciones**: OpenID authentication flow
- **Protocolo**: OpenID
- **Prioridad**: 21

---

### 17. **Otros**: BlogController, ProposalsController, SupportsController, SmsValidatorController
- **Complejidad**: Media
- **Prioridad**: 22-25

---

## Services Inventory

### 1. **UrlSignatureService**
- **Usado por**: MilitantController, PageController
- **Propósito**: Firma y verificación HMAC de URLs
- **Complejidad**: Media
- **Métodos**: sign_url, verify_signed_url, verify_militant_url

### 2. **RedsysPaymentProcessor**
- **Usado por**: OrdersController
- **Propósito**: Procesar callbacks de Redsys (SOAP/XML)
- **Complejidad**: Alta
- **Métodos**: process, parse_soap_callback

### 3. **UserVerificationReportService**
- **Usado por**: UserVerificationsController
- **Propósito**: Generar reportes por provincia/autonomía
- **Complejidad**: Muy Alta (queries SQL complejas)
- **Métodos**: generate

### 4. **TownVerificationReportService**
- **Usado por**: UserVerificationsController
- **Propósito**: Generar reportes por municipio
- **Complejidad**: Muy Alta
- **Métodos**: generate

### 5. **ExteriorVerificationReportService**
- **Usado por**: UserVerificationsController
- **Propósito**: Generar reportes de usuarios extranjeros
- **Complejidad**: Alta
- **Métodos**: generate

### 6. **CensusFileParser**
- **Usado por**: VoteController
- **Propósito**: Parsear archivos CSV de censo electoral
- **Complejidad**: Media
- **Métodos**: find_user_by_validation_token, find_user_by_document

### 7. **PaperVoteService**
- **Usado por**: VoteController
- **Propósito**: Manejar votos en papel y logging
- **Complejidad**: Media
- **Métodos**: log_vote_query, log_vote_registered, save_vote_for_user

### 8. **LoanRenewalService**
- **Usado por**: MicrocreditController
- **Propósito**: Manejar renovación de préstamos
- **Complejidad**: Alta
- **Métodos**: build_renewal

---

## Security & Quality Checklist

**APPLY TO EVERY CONTROLLER** - Issues discovered during AudioCaptchaController testing:

### 1. Input Validation (HIGH PRIORITY)
- [ ] **Nil/Empty Parameter Checks**: Validate all required parameters are present before processing
  - Return appropriate HTTP status (404, 422, etc.) when parameters are missing/invalid
  - Example: `unless captcha_value.present?; head :not_found; return; end`
- [ ] **Type Validation**: Ensure parameters are of expected type before use

### 2. Path Traversal Security (HIGH PRIORITY - SECURITY)
- [ ] **File Path Sanitization**: All user-provided inputs used in file paths MUST be sanitized
  - Use `File.basename()` to strip directory components
  - Never directly interpolate user input into file paths
  - Example: `"#{dir}/#{File.basename(params[:key])}.ext"`
- [ ] **Directory Traversal Prevention**: Verify files are created/accessed within expected directories
- [ ] **Test Coverage**: Include security tests for path traversal attempts

### 3. I18n Translation Handling (MEDIUM PRIORITY)
- [ ] **Fallback Values**: Always provide fallback for missing translations
  - Use `default:` parameter in `I18n.t()` calls
  - Example: `I18n.t("key.#{value}", default: value)`
- [ ] **Graceful Degradation**: Application should work even if translations are missing

### 4. Resource Cleanup (LOW PRIORITY)
- [ ] **Temporary File Management**: Implement cleanup for temporary files
  - Delete files after use or on a schedule
  - Prevent disk space exhaustion
  - Example: Cleanup files older than N hours/days
- [ ] **Error Handling**: Cleanup should not fail the main request
  - Use `rescue` blocks with logging
  - Continue processing even if cleanup fails

### 5. Additional Security Checks
- [ ] **SQL Injection**: Use parameterized queries, never string interpolation
- [ ] **XSS Prevention**: Sanitize user input displayed in views
- [ ] **CSRF Protection**: Verify CSRF tokens for state-changing actions
- [ ] **Mass Assignment**: Use strong parameters for all user input
- [ ] **Authorization**: Verify user has permission for the action

### 6. Test Coverage Requirements
- [ ] **Success Cases**: Happy path with valid data
- [ ] **Edge Cases**: Empty, nil, invalid, boundary values
- [ ] **Security Cases**: Path traversal, injection attempts, unauthorized access
- [ ] **Error Handling**: How does controller behave on errors?
- [ ] **Integration**: Test with mocked external dependencies

---

## Testing Strategy

### Phase 1: Simple Controllers (Foundation)
1. ✅ ErrorsController - **COMPLETED** (32 tests passing)
2. ✅ AudioCaptchaController - **COMPLETED** (24 tests passing, 4 issues fixed)
3. ⏭️ ToolsController
4. ⏭️ ParticipationTeamsController

### Phase 2: Medium Controllers
5. NoticeController
6. OrdersController
7. MilitantController

### Phase 3: Complex Controllers
8. PageController
9. CollaborationsController
10. VoteController

### Phase 4: Very Complex Controllers
11. MicrocreditController
12. UserVerificationsController
13. ImpulsaController

### Phase 5: API & Special Controllers
14. API Controllers
15. Devise Controllers
16. OpenIdController
17. Others

---

## Coverage Goals
- **Target**: 95% overall coverage
- **Controllers**: 95% line coverage
- **Services**: 100% line coverage (smaller, focused)
- **Models**: Evaluated separately

---

## Next Steps
1. ✅ Create this inventory
2. ⏭️ Start with ErrorsController (simplest)
3. ⏭️ Create RSpec configuration if needed
4. ⏭️ Create factories for required models
5. ⏭️ Write exhaustive tests for ErrorsController
6. ⏭️ Run tests and fix any issues
7. ⏭️ Repeat for each controller in priority order
