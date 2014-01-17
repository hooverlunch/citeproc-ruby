module CiteProc
  module Ruby
    module Formats

      class Html < Format

        @defaults = {
          :css_only  => false,
          :italic    => 'i',      # em
          :bold      => 'b',      # strong
          :container => 'span',   # inner container
          :display   => 'div'     # display container
        }

        class << self
          attr_reader :defaults
        end

        attr_reader :config

        def initialize(config = nil)
          if config.nil?
            @config = Html.defaults.dup
          else
            @config = Html.defaults.merge(config)
          end
        end

        def css_only?
          config[:css_only]
        end

        def apply_font_style
          if options[:'font-style'] == 'italic' && !css_only?
            output.replace content_tag(config[:italic], output)
          else
            css[:'font-style'] = options[:'font-style']
          end
        end

        def apply_font_variant
          css['font-variant'] = options[:'font-variant']
        end

        def apply_font_weight
          if options[:'font-weight'] == 'bold' && !css_only?
            output.replace content_tag(config[:bold], output)
          else
            css[:'font-weight'] = options[:'font-weight']
          end
        end

        def apply_text_decoration
          css[:'text-decoration'] = options[:'text-decoration']
        end

        def apply_vertical_align
          css[:'vertical-align'] = options[:'vertical-align']
        end

        def apply_display
          output.replace(
            content_tag(config[:display], output, :display => options[:display])
          )
        end

        def apply_prefix
          output.prepend(CSL.encode_xml_text(options[:prefix]))
        end

        def apply_suffix
          output.concat(CSL.encode_xml_text(options[:suffix]))
        end

        def apply_quotes
          output.replace locale.quote(output, true)
        end

        protected

        def css
          @css ||= {}
        end

        def finalize_content!
          super
          output.replace content_tag(config[:container], output, css) if @css
        end

        def setup!
          # TODO find a better solution for this (strip tags?)
          # For now make sure not to double encode entities
          # by matching spaces before or after.

          output.gsub! /[&<]\s/, '& ' => '&amp; ', '< ' => '&lt; '
          output.gsub! /\s>/, ' &gt;'
        end

        def cleanup!
          @css = nil
          super
        end

        private

        def content_tag(name, content, options = nil)
          "<#{name}#{style(options)}>#{content}</#{name}>"
        end

        def style(options)
          return unless options && !options.empty?
          " style=#{options.map { |*kv| kv.join(': ') }.join('; ').inspect}"
        end

      end

    end
  end
end