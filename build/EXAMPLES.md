# Build Examples

## TDD Loop

Task: implement `User#admin?` from `role`.

1. Write the failing spec in `spec/models/user_spec.rb`.
2. Run it and confirm the expected `NoMethodError`.
3. Implement the smallest method:

```ruby
def admin?
  role == "admin"
end
```

4. Rerun the focused spec and then the relevant broader suite.

## Bug Fix Loop

Task: fix a 500 when Search receives `q: nil`.

1. Add a reproduction spec with `q: nil`.
2. Run it and confirm the failure points at `SearchService`.
3. Normalize the query with a focused guard such as `query.to_s.strip`.
4. Rerun the focused spec and all search-related specs.
