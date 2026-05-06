require "test_helper"

class MetaTagsPartialTest < ActionView::TestCase
  test "renders page title and meta tags" do
    page = PageStructuredData::Page.new(
      title: "Home",
      description: "Welcome to the site",
      image: "https://example.com/home.png"
    )

    render partial: "page_structured_data/meta_tags", locals: { page: page }

    assert_select "title", text: "Home"
    assert_select 'meta[name="title"][content="Home"]'
    assert_select 'meta[name="description"][content="Welcome to the site"]'
    assert_select 'meta[name="image"][content="https://example.com/home.png"]'
    assert_select 'meta[property="og:title"][content="Home"]'
    assert_select 'meta[property="og:description"][content="Welcome to the site"]'
    assert_select 'meta[property="og:image"][content="https://example.com/home.png"]'
    assert_select 'meta[property="twitter:card"][content="summary_large_image"]'
    assert_select 'meta[property="twitter:title"][content="Home"]'
    assert_select 'meta[property="twitter:description"][content="Welcome to the site"]'
    assert_select 'meta[property="twitter:image"][content="https://example.com/home.png"]'
  end

  test "uses default image when page image is absent" do
    page = PageStructuredData::Page.new(title: "Home")

    render partial: "page_structured_data/meta_tags",
           locals: { page: page, default_image_url: "https://example.com/default.png" }

    assert_select 'meta[name="image"][content="https://example.com/default.png"]'
    assert_select 'meta[property="og:image"][content="https://example.com/default.png"]'
    assert_select 'meta[property="twitter:image"][content="https://example.com/default.png"]'
  end

  test "uses page fallback image before default image local" do
    page = PageStructuredData::Page.new(
      title: "Home",
      fallback_image: "https://example.com/fallback.png"
    )

    render partial: "page_structured_data/meta_tags",
           locals: { page: page, default_image_url: "https://example.com/default.png" }

    assert_select 'meta[name="image"][content="https://example.com/fallback.png"]'
    assert_select 'meta[property="og:image"][content="https://example.com/fallback.png"]'
    assert_select 'meta[property="twitter:image"][content="https://example.com/fallback.png"]'
  end

  test "renders canonical url" do
    page = PageStructuredData::Page.new(
      title: "Home",
      canonical_url: "https://example.com/home"
    )

    render partial: "page_structured_data/meta_tags", locals: { page: page }

    assert_select 'link[rel="canonical"][href="https://example.com/home"]'
  end

  test "renders json ld scripts" do
    page_type = PageStructuredData::PageTypes::NewsArticle.new(
      headline: "Launch Notes",
      published_at: Time.zone.parse("2026-05-01 10:00:00 UTC"),
      updated_at: Time.zone.parse("2026-05-02 10:00:00 UTC")
    )
    page = PageStructuredData::Page.new(title: "Launch Notes", page_type: page_type)

    render partial: "page_structured_data/meta_tags", locals: { page: page }

    json_ld_scripts = css_select('script[type="application/ld+json"]')
    assert_equal 2, json_ld_scripts.size
    assert_equal "BreadcrumbList", JSON.parse(json_ld_scripts.first.text)["@type"]
    assert_equal "NewsArticle", JSON.parse(json_ld_scripts[1].text)["@type"]
  end

  test "escapes html-sensitive values in rendered tags" do
    page = PageStructuredData::Page.new(
      title: 'Home "quoted" & <tag>',
      description: 'Description "quoted" & <tag>',
      image: 'https://example.com/image.png?name="quoted"&tag=<tag>'
    )

    render partial: "page_structured_data/meta_tags", locals: { page: page }

    assert_select "title", text: 'Home "quoted" & <tag>'
    assert_includes rendered, "Home &quot;quoted&quot; &amp; &lt;tag&gt;"
    assert_includes rendered, 'content="Description &quot;quoted&quot; &amp; &lt;tag&gt;"'
    assert_includes rendered, 'content="https://example.com/image.png?name=&quot;quoted&quot;&amp;tag=&lt;tag&gt;"'
  end

  test "renders safely when page is absent" do
    render partial: "page_structured_data/meta_tags", locals: { page: nil }

    assert_select "title", text: ""
    assert_select 'meta[name="title"]'
    assert_select 'meta[name="description"]'
    assert_select 'meta[name="image"]'
    assert_select 'meta[property="twitter:card"][content="summary_large_image"]'
    assert_select 'script[type="application/ld+json"]', count: 0
  end
end
