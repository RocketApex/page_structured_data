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
- `Page` emits current-page-only breadcrumb JSON-LD when no breadcrumb is passed by default. This is preserved for compatibility and can be disabled with `PageStructuredData.render_default_breadcrumb_json_ld = false`.
- `BlogPosting` and `NewsArticle` share article behavior through `PageStructuredData::PageTypes::Article`.
- JSON-LD methods currently return full `<script>` HTML strings, and the ERB partial marks the combined output as `html_safe`. A future safer API could expose hashes while keeping `json_ld` backward compatible.
- The gemspec requires Ruby `>= 2.7.0`, matching the Rails 7 baseline.
- The gemspec supports Rails 7.x and Rails 8.x. Keep CI coverage aligned before widening support further.

## Things To Do

1. Expand CI before widening Rails support beyond the currently tested Rails versions.
2. Keep release automation aligned with `docs/release.md` and RubyGems MFA requirements.

## Verification Commands

- `bundle exec rake test`
- `ruby -Ilib -e 'require "page_structured_data"; puts PageStructuredData::VERSION'`
