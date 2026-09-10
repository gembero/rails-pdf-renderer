# RailsPdfRenderer

## Ruby support

This gem only supports Ruby versions that are still supported by the Ruby core
team. When a Ruby version reaches end-of-life it is dropped from the CI matrix
and `required_ruby_version` is raised in the next release, which may happen in a
minor version bump.

The currently supported versions are Ruby 3.3, 3.4 and 4.0.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rails-pdf-renderer

## Usage

Render the current controller action as a PDF:

```ruby
class InvoicesController < ApplicationController
  def show
    render pdf: "invoice-#{@invoice.number}"
  end
end
```

Or get the PDF back as a string:

```ruby
pdf = ApplicationController.renderer.render_to_string(pdf: true, template: "invoices/show")
```

### `inline:` vs `html:`

These two options look similar and are **not** interchangeable:

| Option    | Content                           | Processed by                               |
| --------- | --------------------------------- | ------------------------------------------ |
| `inline:` | An **ERB template** source string | ActionView - `<%= %>` is evaluated as Ruby |
| `html:`   | **Finished HTML**                 | Nothing - sent to the PDF service verbatim |

Use `html:` whenever the HTML has already been rendered - ViewComponent output, a
`render_to_string` from elsewhere, a stored email body, or any content influenced by user
input:

```ruby
html = InvoiceComponent.new(invoice: @invoice).render_in(view_context)
ApplicationController.renderer.render_to_string(pdf: true, html: html)
```

> **Security:** passing already-rendered HTML to `inline:` makes ActionView compile it as an
> ERB template, so any `<%= ... %>` in the content executes as Ruby on your server. Always use
> `html:` for content you did not author as a template.

`html:` is sent as-is, so `layout:`, `locals:`, `assigns:`, `formats:` and `handlers:` are
ignored, and passing both `html:` and `inline:` raises `ArgumentError`.

If you need a non-ERB *template* language for `inline:`, pass `type:` - it is forwarded to
ActionView's handler lookup, e.g. `type: :raw` or `type: :haml`.

### Options

| Option | Description |
| ------ | ----------- |
| `pdf:` | Filename without the `.pdf` extension, when using `render` |
| `html:` | Finished HTML, sent to the PDF service verbatim |
| `inline:` | ERB template source |
| `template:`, `layout:`, `locals:`, `assigns:`, `formats:`, `handlers:`, `file:`, `type:` | Standard ActionView rendering options |
| `show_as_html:` | Render the HTML in the browser instead of a PDF, for debugging |
| `status:` | HTTP status for the response |
| `disposition:` | `"inline"` (default) or `"attachment"` |
| `save_to_file:` | Also write the PDF to this path |
| `save_only:` | Write the PDF to `save_to_file:` without sending a response |
| `orientation:`, `pageSize:`, `zoom:`, `height:`, `width:`, `margin:`, `footerTemplate:` | Forwarded to the PDF service |

### Configuration

```ruby
RailsPdfRenderer.configure do |config|
  config.url = "https://your-pdf-service.example.com/render"
  config.auth_key = Rails.application.credentials.pdf_service_key
  config.default_options = {margin: {top: "10mm", bottom: "10mm", left: "0mm", right: "0mm"}}
end
```

## Development

The local Ruby version is managed with [mise](https://mise.jdx.dev) and pinned in
`.tool-versions`. Install it once with `mise install`, and run every command through mise so it
uses the pinned Ruby rather than the system one:

    $ mise install
    $ mise exec -- bin/setup

If you have mise activated in your shell (`mise activate`), the `mise exec --` prefix is
unnecessary — the pinned Ruby is already on your `PATH`. The examples below spell it out so
they work either way.

Run the tests with `mise exec -- rake spec`, or `mise exec -- bundle exec rake` for the full
gate (rspec + standardrb) that CI runs. You can also run `mise exec -- bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `mise exec -- bundle exec rake install`.

Development happens on Ruby 4.0 even though the gem supports 3.3 and up; CI is what covers
the rest of the matrix.

## Releasing new gems
1. Update version.rb
2. Run `mise exec -- bundle exec rake release` to release a new gem

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/erikaxel/rails-pdf-renderer.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

Initial inspiration and code was influenced by [wicked_pdf](https://github.com/mileszs/wicked_pdf/)