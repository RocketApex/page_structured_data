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
    assert_select 'meta[name="twitter:card"][content="summary_large_image"]'
    assert_select 'meta[name="twitter:title"][content="Home"]'
    assert_select 'meta[name="twitter:description"][content="Welcome to the site"]'
    assert_select 'meta[name="twitter:image"][content="https://example.com/home.png"]'
  end

  test "renders full metadata tags in stable head order" do
    page = PageStructuredData::Page.new(
      title: "Home",
      description: "Welcome to the site",
      image: "https://example.com/home.png",
      canonical_url: "https://example.com/home"
    )

    render partial: "page_structured_data/meta_tags", locals: { page: page }

    assert_fragments_in_order(
      "<title>Home</title>",
      '<link rel="canonical" href="https://example.com/home">',
      '<meta name="title" content="Home">',
      '<meta name="description" content="Welcome to the site">',
      '<meta name="image" content="https://example.com/home.png">',
      '<meta property="og:title" content="Home">',
      '<meta property="og:description" content="Welcome to the site">',
      '<meta property="og:image" content="https://example.com/home.png">',
      '<meta name="twitter:card" content="summary_large_image">',
      '<meta name="twitter:title" content="Home">',
      '<meta name="twitter:description" content="Welcome to the site">',
      '<meta name="twitter:image" content="https://example.com/home.png">'
    )
  end

  test "uses default image when page image is absent" do
    page = PageStructuredData::Page.new(title: "Home")

    render partial: "page_structured_data/meta_tags",
           locals: { page: page, default_image_url: "https://example.com/default.png" }

    assert_select 'meta[name="image"][content="https://example.com/default.png"]'
    assert_select 'meta[property="og:image"][content="https://example.com/default.png"]'
    assert_select 'meta[name="twitter:image"][content="https://example.com/default.png"]'
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
    assert_select 'meta[name="twitter:image"][content="https://example.com/fallback.png"]'
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

  test "renders multiple json ld scripts after social metadata" do
    organization = PageStructuredData::PageTypes::Organization.new(
      name: "RocketApex",
      url: "https://rocketapex.com"
    )
    website = PageStructuredData::PageTypes::WebSite.new(
      name: "RocketApex",
      url: "https://rocketapex.com",
      publisher: organization
    )
    page = PageStructuredData::Page.new(
      title: "Home",
      description: "Open source projects from RocketApex",
      image: "https://rocketapex.com/logo.png",
      page_types: [organization, website]
    )

    render partial: "page_structured_data/meta_tags", locals: { page: page }

    json_ld_scripts = css_select('script[type="application/ld+json"]')
    assert_equal 3, json_ld_scripts.size
    assert_equal ["BreadcrumbList", "Organization", "WebSite"], json_ld_scripts.map { |script| JSON.parse(script.text)["@type"] }
    assert rendered.index('<meta name="twitter:image" content="https://rocketapex.com/logo.png">') < rendered.index('<script type="application/ld+json">')
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
    assert_select 'meta[name="description"]', count: 0
    assert_select 'meta[name="image"]', count: 0
    assert_select 'meta[property="og:description"]', count: 0
    assert_select 'meta[property="og:image"]', count: 0
    assert_select 'meta[name="twitter:card"][content="summary_large_image"]'
    assert_select 'meta[name="twitter:description"]', count: 0
    assert_select 'meta[name="twitter:image"]', count: 0
    assert_select 'script[type="application/ld+json"]', count: 0
  end

  test "omits blank description and image tags" do
    page = PageStructuredData::Page.new(title: "Home")

    render partial: "page_structured_data/meta_tags", locals: { page: page }

    assert_select 'meta[name="title"][content="Home"]'
    assert_select 'meta[property="og:title"][content="Home"]'
    assert_select 'meta[name="twitter:title"][content="Home"]'
    assert_select 'meta[name="description"]', count: 0
    assert_select 'meta[name="image"]', count: 0
    assert_select 'meta[property="og:description"]', count: 0
    assert_select 'meta[property="og:image"]', count: 0
    assert_select 'meta[name="twitter:description"]', count: 0
    assert_select 'meta[name="twitter:image"]', count: 0
    refute_includes rendered, 'content=""'
  end

  private

  def assert_fragments_in_order(*fragments)
    previous_index = -1

    fragments.each do |fragment|
      current_index = rendered.index(fragment)
      assert current_index, "Expected rendered output to include #{fragment.inspect}"
      assert current_index > previous_index, "Expected #{fragment.inspect} to render after the previous fragment"
      previous_index = current_index
    end
  end
end
