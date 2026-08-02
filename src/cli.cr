require "option_parser"
require "kemal"
require "./banner"

# XSSMaze parses its own command line instead of letting Kemal do it, so the
# help screen, the error wording and the extra flags are ours. Kemal is then
# run with `args: nil` and simply reads the config we filled in here.
module Xssmaze::CLI
  class Options
    property? banner : Bool = true
    property? quiet : Bool = false
  end

  def self.parse!(args : Array(String) = ARGV) : Options
    options = Options.new

    # Colour has to settle before anything is rendered, including `--help`,
    # so this one flag is read ahead of the parse.
    UI.color = false if args.includes?("--no-color")

    ssl_enabled = false
    key_file = ""
    cert_file = ""
    config = Kemal.config

    parser = OptionParser.new do |opts|
      opts.on("-b HOST", "--bind HOST", "") { |host| config.host_binding = host }
      opts.on("-p PORT", "--port PORT", "") { |port| config.port = parse_port(port) }
      opts.on("-s", "--ssl", "") { ssl_enabled = true }
      opts.on("--ssl-key-file FILE", "") { |file| key_file = file }
      opts.on("--ssl-cert-file FILE", "") { |file| cert_file = file }
      opts.on("-q", "--quiet", "") { options.quiet = true }
      opts.on("--no-banner", "") { options.banner = false }
      opts.on("--no-color", "") { UI.color = false }
      opts.on("-v", "--version", "") { Banner.version(STDOUT); exit 0 }
      opts.on("-h", "--help", "") { Banner.help(STDOUT); exit 0 }

      opts.invalid_option { |flag| Banner.fail("unknown option #{flag}") }
      opts.missing_option { |flag| Banner.fail("#{flag} needs a value") }
      # Runs before OptionParser's own invalid-option pass, so leftovers that
      # look like flags are reported as flags.
      opts.unknown_args do |rest|
        if extra = rest.first?
          Banner.fail(extra.starts_with?('-') ? "unknown option #{extra}" : "unexpected argument #{extra}")
        end
      end
    end

    parser.parse(args)
    configure_ssl(ssl_enabled, key_file, cert_file)
    options
  end

  private def self.parse_port(value : String) : Int32
    port = value.to_i?
    Banner.fail("port must be a number between 1 and 65535, got #{value}") unless port && (1..65535).includes?(port)
    port
  end

  private def self.configure_ssl(enabled : Bool, key_file : String, cert_file : String) : Nil
    return unless enabled

    {% if !flag?(:without_openssl) %}
      Banner.fail("--ssl needs --ssl-key-file FILE") if key_file.empty?
      Banner.fail("--ssl needs --ssl-cert-file FILE") if cert_file.empty?

      ssl = Kemal::SSL.new
      ssl.key_file = key_file
      ssl.cert_file = cert_file
      Kemal.config.ssl = ssl.context
    {% else %}
      Banner.fail("this build has SSL support compiled out")
    {% end %}
  end
end
