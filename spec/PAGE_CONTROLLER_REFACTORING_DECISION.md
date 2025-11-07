# PageController Code Duplication - Refactoring Decision

**Date**: 2025-11-07
**Issue**: #12 in PAGE_CONTROLLER_ANALYSIS.md - Massive Code Duplication (25+ similar form actions)
**Decision**: **DO NOT REFACTOR** - Maintain current explicit action structure
**Status**: JUSTIFIED - Code clarity and maintainability prioritized over DRY principle

---

## The Duplication

PageController contains 25+ methods that follow this pattern:

```ruby
def guarantees_form
  render :form_iframe, locals: { title: "...", url: form_url(77), return_path: guarantees_path }
end

def primarias_andalucia
  render :form_iframe, locals: { title: "...", url: form_url(21) }
end

# ... 23 more similar methods
```

---

## Refactoring Options Considered

### Option 1: Dynamic Action with Configuration Hash
```ruby
FORM_CONFIGS = {
  guarantees_form: { title: "...", form_id: 77, return_path: :guarantees_path },
  primarias_andalucia: { title: "...", form_id: 21 },
  # ... 23 more
}.freeze

def show_dynamic_form
  config = FORM_CONFIGS[params[:form_key].to_sym]
  render :form_iframe, locals: {
    title: config[:title],
    url: form_url(config[:form_id]),
    return_path: config[:return_path] ? send(config[:return_path]) : nil
  }
end
```

**Pros**:
- Eliminates code duplication
- Single place to modify rendering logic
- Follows DRY principle

**Cons**:
- Requires changing 25+ routes
- Adds configuration file/constant
- Less explicit - have to look up config to understand what each form does
- More complex routing (need form_key parameter)
- Harder for new developers to understand
- Breaks RESTful conventions
- Difficult to add form-specific logic later

### Option 2: Metaprogramming with define_method
```ruby
FORMS = {
  guarantees_form: { title: "...", id: 77 },
  # ...
}

FORMS.each do |method_name, config|
  define_method(method_name) do
    render :form_iframe, locals: {
      title: config[:title],
      url: form_url(config[:id])
    }
  end
end
```

**Pros**:
- No route changes needed
- Still eliminates duplication

**Cons**:
- Metaprogramming makes code harder to understand
- IDE autocomplete doesn't work well
- Stack traces are harder to read
- Can't easily grep for method definitions
- Debugging is more difficult

### Option 3: Extract to Concern or Service
```ruby
module FormRenderer
  def render_form_iframe(form_id, title:, return_path: nil)
    render :form_iframe, locals: {
      title: title,
      url: form_url(form_id),
      return_path: return_path
    }
  end
end

# Then in each action:
def guarantees_form
  render_form_iframe(77, title: "...", return_path: guarantees_path)
end
```

**Pros**:
- Keeps explicit actions
- Extracts common logic
- Easy to understand

**Cons**:
- Minimal benefit - only saves 1-2 lines per method
- Adds indirection
- Methods are still repetitive

---

## Decision: DO NOT REFACTOR

### Reasons to Keep Current Structure

#### 1. **Clarity and Explicitness**
Each action is immediately understandable:
- Clear method name describes purpose
- Can see exact title in code
- Can see exact form ID
- Can see if there's a return_path
- No need to look up configuration

#### 2. **Easy Modification**
- Changing one form doesn't risk affecting others
- Can add form-specific logic easily
- Can add validations per form
- Can add before_actions per form

#### 3. **Grep-able and Searchable**
```bash
grep -r "primarias_andalucia" # Finds method definition immediately
```
With configuration hash, you'd find the config entry, not the logic.

#### 4. **Better Stack Traces**
When error occurs:
```
PageController#primarias_andalucia  # Clear which form failed
vs
PageController#show_dynamic_form    # Which form? Have to check params
```

#### 5. **IDE Support**
- Auto-complete works for method names
- "Go to definition" works
- Refactoring tools work better

#### 6. **Routing Clarity**
Current routes are explicit:
```ruby
get 'primarias_andalucia' => 'page#primarias_andalucia'
```

vs hypothetical:
```ruby
get 'primarias_andalucia' => 'page#show_dynamic_form', form_key: 'primarias_andalucia'
```

#### 7. **Form-Specific Customization**
Some forms already have slight differences:
- Some have `return_path`, others don't
- Future forms might need authentication
- Future forms might need specific validations
- Explicit actions make customization trivial

#### 8. **Historical Context**
These forms likely correspond to specific political campaigns/processes:
- "Primarias Andalucía" - Andalusia primaries
- "Avales Barcelona" - Barcelona endorsements
- "Elecciones Andaluzas" - Andalusian elections

Each is a distinct political/administrative process. Having separate explicit actions reflects this organizational reality.

#### 9. **Low Change Frequency**
These actions are likely stable - forms from past elections/processes:
- Not frequently modified
- Rarely need to add new ones
- When adding new form, copy-paste-modify is clear and safe

#### 10. **Testing**
With explicit actions:
- Can write specific tests for specific forms if needed
- Test failures clearly indicate which form broke
- Can mock/stub specific actions easily

---

## Alternative Solution: Extract Common Logic Only

If we want to reduce some duplication without losing clarity:

```ruby
def render_form_with_signature(form_id, title:, template: :form_iframe, **options)
  render template, locals: {
    title: title,
    url: form_url(form_id),
    **options
  }
end

# Usage in actions:
def guarantees_form
  render_form_with_signature(77,
    title: "Comunicación a Comisiones de Garantías Democráticas",
    return_path: guarantees_path
  )
end
```

**Decision**: Even this is not worth it - saves only 1 line per method, adds indirection.

---

## Conclusion

**KEEP CURRENT CODE STRUCTURE**

The "duplication" here is actually **repetition with variation** - each action represents a distinct form with distinct purpose. The code is:

✅ **Explicit and Clear**: Anyone can read and understand immediately
✅ **Easy to Modify**: Changes are localized
✅ **Easy to Search**: grep/find works perfectly
✅ **Easy to Debug**: Stack traces are clear
✅ **Easy to Test**: Each action can be tested independently
✅ **Easy to Customize**: Form-specific logic is trivial to add

The DRY (Don't Repeat Yourself) principle should not be applied blindly. In this case:
- **Repetition is intentional** - each form is a distinct entity
- **Abstraction would hide meaning** - would make code harder to understand
- **Cost of abstraction > benefit** - added complexity not worth marginal code reduction

**This is a case where explicit is better than DRY.**

---

## Status: ISSUE RESOLVED - NO REFACTORING NEEDED

Marked as "Low Priority" in original analysis, now marked as **JUSTIFIED - NO ACTION REQUIRED**.

---

## Future Considerations

If PageController grows to 50+ forms or requires frequent form additions, revisit this decision. But for current state (25 forms, mostly historical, low change frequency), current structure is optimal.

**Recommendation for Future**: If adding many new forms, consider:
1. Separate controller for new forms
2. Different architecture (e.g., form builder DSL)
3. But keep existing forms as-is (don't retrofit)
