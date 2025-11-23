(function() {
  "use strict";

  var RailsJsLogger = {
    endpoint: "/rails_js_logger/logs",
    batchSize: 10,
    flushInterval: 5000,
    maxQueueSize: 1000,
    queue: [],
    original: {},

    init: function(options) {
      options = options || {};
      if (options.endpoint) this.endpoint = options.endpoint;
      if (options.batchSize) this.batchSize = options.batchSize;
      if (options.flushInterval) this.flushInterval = options.flushInterval;

      this.intercept();
      this.setupFlush();
      this.setupErrorHandler();
    },

    intercept: function() {
      var self = this;
      ["log", "info", "warn", "error", "debug"].forEach(function(method) {
        self.original[method] = console[method];
        console[method] = function() {
          self.original[method].apply(console, arguments);
          self.enqueue(method, Array.prototype.slice.call(arguments));
        };
      });
    },

    enqueue: function(level, args) {
      if (this.queue.length >= this.maxQueueSize) {
        this.queue.shift();  // Drop oldest entry
      }

      var message = args.map(function(arg) {
        if (typeof arg === "object") {
          try { return JSON.stringify(arg); } catch (e) { return String(arg); }
        }
        return String(arg);
      }).join(" ");

      this.queue.push({ level: level, message: message });
      if (this.queue.length >= this.batchSize) this.flush();
    },

    setupFlush: function() {
      var self = this;
      setInterval(function() { self.flush(); }, this.flushInterval);
      window.addEventListener("beforeunload", function() { self.flush(); });
    },

    flush: function() {
      if (this.queue.length === 0) return;

      var logs = this.queue.splice(0, this.queue.length);
      var csrf = document.querySelector("meta[name='csrf-token']");

      fetch(this.endpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrf ? csrf.content : ""
        },
        body: JSON.stringify({ logs: logs }),
        keepalive: true
      }).catch(function() {});
    },

    setupErrorHandler: function() {
      var self = this;

      window.addEventListener("error", function(e) {
        self.enqueue("error", [
          "Uncaught:",
          e.message,
          "at",
          e.filename + ":" + e.lineno + ":" + e.colno
        ]);
      });

      window.addEventListener("unhandledrejection", function(e) {
        self.enqueue("error", ["Unhandled rejection:", e.reason]);
      });
    }
  };

  if (typeof document !== "undefined") {
    document.addEventListener("DOMContentLoaded", function() {
      RailsJsLogger.init();
    });
  }

  window.RailsJsLogger = RailsJsLogger;
})();
