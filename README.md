# PageStructuredData
Use this gem to churn out meta tags for your rails webpages. This also renders meta tags for the following:
1. Page `<title>` tag with proper hyphenation when used with breadcrumbs
2. Basic `<meta>` tags
2. Twitter meta tags
3. Open graph meta tags
4. Google Schema JSON-LD `<script>` tags

## Installation
Add this line to your application's Gemfile:

```ruby
gem "page_structured_data"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install page_structured_data
```

## Usage

### Layouts

Add the following in your layout to include the basic meta tags by default

```erbruby
<%= render 'page_structured_data/meta_tags', page: @page_meta, 
    default_image_url: image_url('<path_to_default_image>') %>
```

Note: This doesn't include csrf or any other security or viewport related meta tags.

### Views

In your views, please define the `@page_meta` as follows

```ruby
<% @page_meta = PageStructuredData::Page.new(title: 'Home', extra_title: "Official Page",
        description: 'Welcome to my Page') %>
```

The instance variable will be used in the layout to create proper meta tags. Most attributes are self explanatory. `extra_title` is used to append to the title. 

### Config

Configure the application wide settings as follows:

```erbruby
# config/initializers/page_structured_data.rb
Rails.application.config.after_initialize do
  PageStructuredData.config do |config|
    config.base_app_name = 'AwesomestApp' # or use any application constant as this is called after_initialize
  end
end
```

### Breadcrumbs

Create a list of breadcrumbs like this:

```erbruby
<% breadcrumb = PageStructuredData::Breadcrumbs.new(hierarchy: [{ title: 'Resources', href: resources_url }, { title: 'Articles', href: resources_articles_url }]) %>
```

And include it in the `Page.new` as:

```erbruby
<% @page_meta = PageStructuredData::Page.new(title: 'Home', extra_title: "Official Page",
        description: 'Welcome to my Page', breadcrumb: breadcrumb) %>
```

This will create a JSON+LD breadcrumbs similar to [Breadcrumbs](https://developers.google.com/search/docs/appearance/structured-data/breadcrumb)

### PageTypes

Currently this gem supports the following page types:

* [BlogPosting](https://schema.org/BlogPosting)
* [NewsArticle](https://schema.org/NewsArticle)

To use these, it is similar to breadcrumbs: include them in `Page.new` and it the json+ld will be automatically included.

```erbruby
<% article_page_type = PageStructuredData::PageTypes::BlogPosting.new(headline: @article.title, published_at: @article.published_at,
        updated_at: @article.updated_at, authors: [name: @article.authors.first.name, url: @article.authors.first.website],
        images: [main_app.url_for(@article.cover_image.variant(:standard))]) %>
<% @page_meta = PageStructuredData::Page.new(title: 'Home', extra_title: "Official Page",
                                             description: 'Welcome to my Page', page_type: article_page_type) %>
```

Just replace BlogPosting class with the other type for other page types.

## Contributing
Please raise a PR to be validated and merged.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
