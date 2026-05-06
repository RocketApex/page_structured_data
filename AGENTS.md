# Agent Notes

This is a public RocketApex open source Rails engine gem that is used in production projects. Treat changes as compatibility-sensitive maintenance work with a high release-quality bar. Prefer additive changes, tests that document existing behavior, and small patches over broad rewrites.

Because this is a public gem and repository, changes should be polished before release: keep docs accurate, preserve backward compatibility unless a major version explicitly allows a break, add tests for user-visible behavior, and avoid shipping half-finished internals or generated clutter as part of feature work.

## Current Public API To Preserve

- `PageStructuredData.config { |config| ... }`
- `PageStructuredData.base_app_name`
- `PageStructuredData::Page.new(title:, description:, image:, extra_title:, breadcrumb:, page_type:)`
- `PageStructuredData::Breadcrumbs.new(hierarchy:)`
- `PageStructuredData::PageTypes::BlogPosting.new(...)`
- `PageStructuredData::PageTypes::NewsArticle.new(...)`
- Rendering `page_structured_data/meta_tags` with locals `page:` and optional `default_image_url:`

## Findings

- The gem is intentionally small: `Page` composes title/meta data, `Breadcrumbs` builds breadcrumb JSON-LD, page types build article JSON-LD, and `_meta_tags.html.erb` renders the final tags.
- Test coverage was very thin. Baseline tests now document current title composition and JSON-LD behavior.
- The dummy app previously used `config.autoload_lib`, which is Rails 7.1-only, while the lockfile resolves Rails 7.0.8. This has been changed to explicit `autoload_paths` and `eager_load_paths`.
- `require "page_structured_data"` previously failed before Rails was loaded. The engine now requires the Rails pieces it depends on.
- `Page` currently creates an empty `Breadcrumbs` object when no breadcrumb is passed, so `json_lds` emits breadcrumb JSON-LD for every page. This may be surprising, but it is existing behavior and should not be changed in a patch release.
- `BlogPosting` and `NewsArticle` are almost identical except for schema type. Refactor only after behavior is covered by tests.
- JSON-LD methods currently return full `<script>` HTML strings, and the ERB partial marks the combined output as `html_safe`. A future safer API could expose hashes while keeping `json_ld` backward compatible.
- The gemspec says Ruby `>= 2.3.0`, but Rails `>= 7.0.0` implies a newer practical Ruby baseline. Aligning this is a compatibility-facing decision.

## Things To Do

1. Add escaping tests for HTML and JSON-LD output from `app/views/page_structured_data/_meta_tags.html.erb`.
2. Add tests for HTML escaping and JSON escaping, especially for user-provided titles, descriptions, image URLs, breadcrumb titles, and article data.
3. Add tests around default image fallback behavior.
4. Add tests for pages with both breadcrumbs and page types to lock down multiple JSON-LD script output.
5. Consider extracting shared article schema behavior for `BlogPosting` and `NewsArticle` after tests are in place.
6. Consider adding `to_h` or `schema_hash` methods to schema objects as an additive API. Keep `json_ld` returning the current script HTML for compatibility.
7. Decide whether default breadcrumb JSON-LD should remain the default forever, become configurable, or change only in a future major release.
8. Review gemspec Ruby/Rails support and document the supported matrix in `README.md`.
9. Add CI for the intended Ruby and Rails versions.
10. Trim unused generated Rails engine files only if doing so does not affect packaged files or downstream apps.

## Verification Commands

- `bundle exec rake test`
- `ruby -Ilib -e 'require "page_structured_data"; puts PageStructuredData::VERSION'`
