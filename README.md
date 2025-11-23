# Rails JS Logger

Bridge JavaScript console output to Rails logs for unified debugging.

## Why?

*LLM-friendly debugging.* AI coding assistants like Claude Code can read your Rails server logs but cannot access browser developer tools. When JavaScript errors occur, your AI assistant sees nothing—the errors are trapped in the browser console. This gem bridges that gap by forwarding all `console.log`, `console.error`, and uncaught exceptions to your Rails logs where AI assistants can read and help debug them.

*Unified logging.* Stop switching between browser console and server logs. See JavaScript errors alongside your Rails logs in one place.

*Zero frontend dependencies.* Works with any JavaScript setup—importmaps, esbuild, webpack, or plain script tags. No npm packages required.

## Installation

Add to your Gemfile:

```ruby
gem "rails_js_logger"
```

Run the installer:

```sh
rails generate rails_js_logger:install
```

The installer automatically:
- Creates `config/initializers/rails_js_logger.rb`
- Mounts the engine in `config/routes.rb`
- Adds JavaScript to importmap (if using importmap-rails)

## Usage

JavaScript console methods are automatically forwarded to Rails logs:

```javascript
console.log("User clicked checkout", { cart_id: 123 });
console.error("Payment failed", error);
```

Appears in Rails logs as:

```
[JS] User clicked checkout {"cart_id":123}
[JS] Payment failed TypeError: Cannot read property...
```

Uncaught errors and unhandled promise rejections are also captured.

## Configuration

```ruby
# config/initializers/rails_js_logger.rb
RailsJsLogger.enabled = true
RailsJsLogger.log_level = :debug        # :debug, :info, :warn, :error
RailsJsLogger.tag = "JS"
RailsJsLogger.sample_rate = 1.0         # 0.0 to 1.0
RailsJsLogger.max_payload_size = 100_000
RailsJsLogger.logger = Rails.logger
```

## JavaScript Options

```javascript
window.RailsJsLogger.init({
  endpoint: "/rails_js_logger/logs",
  batchSize: 10,
  flushInterval: 5000
});
```

## License

MIT
