# PageStructuredData

[![Gem Version](https://badge.fury.io/rb/page_structured_data.svg)](https://rubygems.org/gems/page_structured_data)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](MIT-LICENSE)

PageStructuredData is a small Rails engine for rendering page-level SEO and social sharing metadata from one page object.

It helps Rails applications render:

- A `<title>` tag
- Basic `title`, `description`, and `image` meta tags
- Open Graph tags
- Twitter card tags
- Google-compatible JSON-LD structured data
- Breadcrumb structured data
- Article structured data for `BlogPosting` and `NewsArticle`
- Organization structured data

## Requirements

- Rails 7.x or 8.x
- Ruby 2.7 or newer

Rails 7.0 requires Ruby 2.7 or newer, so this gem follows that same baseline. Rails 8 requires Ruby 3.2 or newer, so Rails 8 applications must use a Ruby version supported by Rails 8.

## Installation

Add the gem to your application's Gemfile:

```ruby
gem "page_structured_data"
```

Then install it:

```bash
bundle install
```

## Configuration

Configure application-wide defaults in an initializer:

```ruby
# config/initializers/page_structured_data.rb
Rails.application.config.after_initialize do
  PageStructuredData.config do |config|
    config.base_app_name = "AwesomestApp"
    config.render_default_breadcrumb_json_ld = true
  end
end
```

`base_app_name` is appended to generated page titles.

`render_default_breadcrumb_json_ld` controls whether pages without an explicit breadcrumb render current-page-only breadcrumb JSON-LD. It defaults to `true` for backward compatibility. Set it to `false` if you only want breadcrumb JSON-LD when a `PageStructuredData::Breadcrumbs` object is passed to the page.

For example:

```ruby
PageStructuredData.base_app_name = "AwesomestApp"

page = PageStructuredData::Page.new(
  title: "Pricing",
  extra_title: "Plans",
  description: "Simple pricing for AwesomestApp"
)

page.page_title
# => "Pricing - Plans - AwesomestApp"
```

## Rendering Meta Tags

Render the bundled partial from your application layout:

```erb
<%= render "page_structured_data/meta_tags",
           page: @page_meta,
           default_image_url: image_url("social/default.png") %>
```

`default_image_url` is optional. It is used when the page object does not provide an image.

This partial is only responsible for SEO, social sharing, and structured-data tags. Keep your normal Rails layout tags, such as CSRF, CSP, viewport, and favicon tags, in your application layout.

## Basic Page Metadata

Set `@page_meta` in the controller or view before the layout renders:

```ruby
@page_meta = PageStructuredData::Page.new(
  title: "Home",
  extra_title: "Official Page",
  description: "Welcome to my page",
  image: image_url("social/home.png")
)
```

The generated title is built from:

1. `title`
2. `extra_title`, when present
3. breadcrumb titles, when present
4. `PageStructuredData.base_app_name`, when present

The parts are joined with `" - "`.

## Breadcrumbs

Create breadcrumbs with a hierarchy of page titles and URLs:

```ruby
breadcrumbs = PageStructuredData::Breadcrumbs.new(
  hierarchy: [
    { title: "Resources", href: resources_url },
    { title: "Articles", href: resources_articles_url }
  ]
)
```

Pass the breadcrumbs into the page object:

```ruby
@page_meta = PageStructuredData::Page.new(
  title: "How to Structure Metadata",
  description: "A guide to page metadata and structured data",
  breadcrumb: breadcrumbs
)
```

This renders `BreadcrumbList` JSON-LD similar to Google's breadcrumb structured data format.

Current compatibility note: when no breadcrumb object is passed, `PageStructuredData::Page` renders current-page-only breadcrumb JSON-LD by default. To opt out, set `config.render_default_breadcrumb_json_ld = false`.

## Article Page Types

PageStructuredData includes page types for:

- [`BlogPosting`](https://schema.org/BlogPosting)
- [`NewsArticle`](https://schema.org/NewsArticle)
- [`Organization`](https://schema.org/Organization)

Use a page type when the current page represents an article:

```ruby
article_page_type = PageStructuredData::PageTypes::BlogPosting.new(
  headline: @article.title,
  published_at: @article.published_at,
  updated_at: @article.updated_at,
  authors: [
    {
      name: @article.authors.first.name,
      url: @article.authors.first.website
    }
  ],
  images: [
    main_app.url_for(@article.cover_image.variant(:standard))
  ]
)

@page_meta = PageStructuredData::Page.new(
  title: @article.title,
  description: @article.summary,
  image: main_app.url_for(@article.cover_image.variant(:standard)),
  breadcrumb: breadcrumbs,
  page_type: article_page_type
)
```

For news pages, use `PageStructuredData::PageTypes::NewsArticle` with the same arguments.

Use `Organization` when the current page represents an organization:

```ruby
organization_page_type = PageStructuredData::PageTypes::Organization.new(
  name: "RocketApex",
  url: "https://rocketapex.com",
  logo: "https://rocketapex.com/logo.png",
  same_as: ["https://github.com/RocketApex"],
  parent_organization: {
    name: "Parent Org",
    url: "https://parent.example"
  }
)

@page_meta = PageStructuredData::Page.new(
  title: "About RocketApex",
  description: "Open source projects from RocketApex",
  page_type: organization_page_type
)
```

## API Reference

### `PageStructuredData::Page`

```ruby
PageStructuredData::Page.new(
  title:,
  description: nil,
  image: nil,
  extra_title: "",
  breadcrumb: nil,
  page_type: nil
)
```

Important methods:

- `page_title`: returns the composed page title.
- `json_lds`: returns the JSON-LD script tags for breadcrumbs and page type data.

### `PageStructuredData::Breadcrumbs`

```ruby
PageStructuredData::Breadcrumbs.new(
  hierarchy: [
    { title: "Resources", href: "https://example.com/resources" }
  ]
)
```

Important methods:

- `titles`: returns breadcrumb titles.
- `to_h(current_page_title:)`: returns a structured hash for `BreadcrumbList` JSON-LD.
- `json_ld(current_page_title:)`: returns a `BreadcrumbList` JSON-LD script tag.

### Article Page Types

```ruby
PageStructuredData::PageTypes::BlogPosting.new(
  headline:,
  published_at:,
  updated_at:,
  images: [],
  authors: []
)
```

```ruby
PageStructuredData::PageTypes::NewsArticle.new(
  headline:,
  published_at:,
  updated_at:,
  images: [],
  authors: []
)
```

`authors` should be an array of hashes with `:name` and `:url` keys.

Important methods:

- `to_h`: returns a structured hash for article JSON-LD.
- `json_ld`: returns an article JSON-LD script tag.

### Organization Page Type

```ruby
PageStructuredData::PageTypes::Organization.new(
  name:,
  url:,
  logo: nil,
  same_as: [],
  parent_organization: nil
)
```

`parent_organization` should be a hash with `:name` and `:url` keys.

Important methods:

- `json_ld`: returns an organization JSON-LD script tag.

## Development

Run the test suite:

```bash
bundle exec rake test
```

Verify the gem can be required:

```bash
ruby -Ilib -e 'require "page_structured_data"; puts PageStructuredData::VERSION'
```

## Compatibility Policy

This gem is used in production applications. Changes should preserve existing public APIs and rendered output unless a breaking change is intentionally released in a major version.

Prefer additive APIs and tests that document current behavior before refactoring internals.

## Contributing

Bug reports and pull requests are welcome on GitHub.

When contributing, please include tests for user-visible behavior and keep changes focused. For compatibility-sensitive behavior, describe the expected impact in the pull request.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
