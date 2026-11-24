# frozen_string_literal: true

require "ripper"
require "set"

module ForemApiSync
  # Lightweight, zero-Rails-boot extractor for Forem's API routes.
  #
  # Extracts the `namespace :api` block from `config/routes.rb` using Ruby's
  # Ripper lexer (so nested blocks and comments are handled accurately),
  # evaluates it alongside `config/routes/api.rb` using a minimal Rails routing
  # DSL emulator, and checks whether each routed controller#action actually
  # exists in `app/controllers/` or `app/controllers/concerns/`.
  class RouteExtractor
    Route = Struct.new(
      :method,
      :path,
      :controller,
      :action,
      :api_version,
      :env_constraint,
      :action_implemented,
      keyword_init: true
    ) do
      def key
        "#{method} #{path}"
      end

      def to_h
        {
          "key" => key,
          "method" => method,
          "path" => path,
          "controller" => controller,
          "action" => action,
          "api_version" => api_version,
          "env_constraint" => env_constraint,
          "action_implemented" => action_implemented
        }.compact
      end
    end

    # Minimal stand-in for Forem's ApiConstraints.new(version: 1, default: false)
    class ApiConstraintsStub
      attr_reader :version, :default

      def initialize(version: nil, default: false, **_rest)
        @version = version
        @default = default
      end
    end

    # Minimal stand-in for Forem's RailsEnvConstraint.new(allowed_envs: %w[test])
    class RailsEnvConstraintStub
      attr_reader :allowed_envs

      def initialize(allowed_envs: [], **_rest)
        @allowed_envs = Array(allowed_envs).map(&:to_s)
      end
    end

    class DSL
      ApiConstraints = ApiConstraintsStub
      RailsEnvConstraint = RailsEnvConstraintStub

      DEFAULT_COLLECTION_ACTIONS = %i[index create show update destroy].freeze
      DEFAULT_SINGULAR_ACTIONS = %i[show create update destroy].freeze

      attr_reader :routes

      def initialize(forem_dir:, routes_dir:)
        @forem_dir = forem_dir
        @routes_dir = routes_dir
        @routes = []
        @path_stack = []
        @module_stack = []
        @constraint_stack = []
        @env_stack = []
        @version_stack = []
        @resource_stack = []
      end

      def namespace(name, path: nil, module: nil, **_opts, &block)
        seg = (path || name).to_s
        mod = (binding.local_variable_get(:module) || name).to_s
        with_context(path: seg, mod: mod, &block)
      end

      def scope(*args, **opts, &block)
        path_arg = args.first.is_a?(String) || args.first.is_a?(Symbol) ? args.first.to_s : opts[:path]&.to_s
        mod = opts[:module]&.to_s
        constraints_obj = opts[:constraints]
        version = constraints_obj.is_a?(ApiConstraintsStub) ? "v#{constraints_obj.version}" : nil
        extra_constraints = constraints_obj.is_a?(Hash) ? constraints_obj : nil
        env = constraints_obj.is_a?(RailsEnvConstraintStub) ? constraints_obj.allowed_envs.join(",") : nil

        with_context(path: path_arg, mod: mod, version: version, constraints: extra_constraints, env: env, &block)
      end

      def constraints(*args, **opts, &block)
        obj = args.first
        env = obj.is_a?(RailsEnvConstraintStub) ? obj.allowed_envs.join(",") : nil
        hash_constraints = obj.is_a?(Hash) ? obj : (opts.empty? ? nil : opts)
        with_context(constraints: hash_constraints, env: env, &block)
      end

      def draw(name)
        file = File.join(@routes_dir, "#{name}.rb")
        raise "Missing drawn routes file: #{file}" unless File.exist?(file)

        instance_eval(File.read(file), file, 1)
      end

      def resources(name, only: nil, except: nil, controller: nil, to: nil, param: :id, path: nil, **opts, &block)
        actions = resolve_actions(DEFAULT_COLLECTION_ACTIONS, only: only, except: except)
        to_ctrl, to_action = to&.include?("#") ? to.split("#", 2) : [nil, nil]
        ctrl = (to_ctrl || controller || name).to_s
        seg = (path || name).to_s
        param_name = param.to_sym

        base_path = join_paths(@path_stack + [seg])
        member_path = join_paths(@path_stack + [seg, ":#{param_name}"])

        emit_route("GET", base_path, ctrl, to_action || "index") if actions.include?(:index)
        emit_route("POST", base_path, ctrl, to_action || "create") if actions.include?(:create)
        emit_route("GET", member_path, ctrl, to_action || "show") if actions.include?(:show)
        emit_route("PUT", member_path, ctrl, to_action || "update") if actions.include?(:update)
        emit_route("DELETE", member_path, ctrl, to_action || "destroy") if actions.include?(:destroy)

        return unless block

        nested_param = "#{singularize(name)}_#{param_name}"
        @resource_stack.push(
          singular: false,
          name: name.to_s,
          controller: ctrl,
          collection_path: seg,
          member_path: "#{seg}/:#{param_name}",
          nested_path: "#{seg}/:#{nested_param}"
        )
        # Inside a `resources :foo do ... end` block, child `resources` nest under
        # `/foo/:foo_id/...` while `member` uses `/foo/:id/...` and `collection` uses `/foo/...`.
        with_context(path: nil, &block)
      ensure
        @resource_stack.pop if block
      end

      def resource(name, only: nil, except: nil, controller: nil, path: nil, **_opts, &block)
        actions = resolve_actions(DEFAULT_SINGULAR_ACTIONS, only: only, except: except)
        ctrl = (controller || pluralize(name.to_s)).to_s
        seg = (path || name).to_s
        base_path = join_paths(@path_stack + [seg])

        emit_route("GET", base_path, ctrl, "show") if actions.include?(:show)
        emit_route("POST", base_path, ctrl, "create") if actions.include?(:create)
        emit_route("PUT", base_path, ctrl, "update") if actions.include?(:update)
        emit_route("DELETE", base_path, ctrl, "destroy") if actions.include?(:destroy)

        return unless block

        @resource_stack.push(
          singular: true,
          name: name.to_s,
          controller: ctrl,
          collection_path: seg,
          member_path: seg,
          nested_path: seg
        )
        with_context(path: nil, &block)
      ensure
        @resource_stack.pop if block
      end

      def collection(&block)
        res = @resource_stack.last
        with_context(path: res&.fetch(:collection_path), in_member_or_collection: true, &block)
      end

      def member(&block)
        res = @resource_stack.last
        with_context(path: res&.fetch(:member_path), in_member_or_collection: true, &block)
      end

      %w[get post put patch delete].each do |verb|
        define_method(verb) do |path, to: nil, action: nil, controller: nil, on: nil, constraints: nil, **_opts|
          res = @resource_stack.last
          prefix_segments = @path_stack.dup

          if on == :collection && res
            prefix_segments << res[:collection_path]
          elsif on == :member && res
            prefix_segments << res[:member_path]
          elsif !@in_member_or_collection && res && !path.to_s.start_with?("/")
            prefix_segments << res[:nested_path]
          end

          path_str = path.to_s
          ctrl, act = parse_target(path_str, to: to, action: action, controller: controller, resource: res)

          full_path = join_paths(prefix_segments + [path_str])
          merged_constraints = current_constraints.merge(constraints.is_a?(Hash) ? constraints : {})
          expand_path_variants(full_path, merged_constraints).each do |expanded|
            emit_route(verb.upcase, expanded, ctrl, act)
          end
        end
      end

      # Override resources when nested directly inside another resource block
      alias_method :_resources_base, :resources
      def resources(name, **opts, &block)
        if @resource_stack.any? && !@in_member_or_collection
          parent = @resource_stack.last
          with_context(path: parent[:nested_path]) do
            _resources_base(name, **opts, &block)
          end
        else
          _resources_base(name, **opts, &block)
        end
      end

      private

      def with_context(path: nil, mod: nil, version: nil, constraints: nil, env: nil, in_member_or_collection: nil)
        @path_stack.push(path) if path && !path.empty?
        @module_stack.push(mod) if mod && !mod.empty?
        @version_stack.push(version) if version
        @constraint_stack.push(constraints) if constraints
        @env_stack.push(env) if env
        prev_mc = @in_member_or_collection
        @in_member_or_collection = in_member_or_collection unless in_member_or_collection.nil?

        yield if block_given?
      ensure
        @in_member_or_collection = prev_mc
        @env_stack.pop if env
        @constraint_stack.pop if constraints
        @version_stack.pop if version
        @module_stack.pop if mod && !mod.empty?
        @path_stack.pop if path && !path.empty?
      end

      def current_constraints
        @constraint_stack.each_with_object({}) { |h, acc| acc.merge!(h) }
      end

      def resolve_actions(defaults, only:, except:)
        actions = only ? Array(only).map(&:to_sym) : defaults.dup
        actions -= Array(except).map(&:to_sym) if except
        actions
      end

      def parse_target(path_str, to:, action:, controller:, resource:)
        if to && to.include?("#")
          ctrl, act = to.split("#", 2)
          [ctrl, act]
        else
          act = (action || to || path_str.delete_prefix("/").split("/").last).to_s
          ctrl = (controller || resource&.fetch(:controller) || @module_stack.last).to_s
          # For namespace :followers { get :users }, Rails routes to followers#users
          if resource.nil? && controller.nil? && to.nil? && @path_stack.last
            ctrl = @path_stack.last
          end
          [ctrl, act]
        end
      end

      def emit_route(method, path, controller, action)
        full_controller = qualify_controller(controller)
        @routes << Route.new(
          method: method,
          path: path,
          controller: full_controller,
          action: action,
          api_version: @version_stack.last || "v0",
          env_constraint: @env_stack.last,
          action_implemented: nil
        )
      end

      def qualify_controller(controller)
        mods = @module_stack.dup
        # Avoid doubling when namespace :followers + get :users sets controller = "followers"
        mods.pop if mods.last == controller
        (mods + [controller]).reject(&:empty?).join("/")
      end

      def join_paths(segments)
        cleaned = segments.compact.map { |s| s.to_s.gsub(%r{\A/+|/+\z}, "") }.reject(&:empty?)
        "/#{cleaned.join("/")}"
      end

      # Expand simple Rails optional segments like `me(/:status)` with regex
      # alternation constraints, and constrained enum segments like `/:role`
      # when `role: /a|b|c/`.
      def expand_path_variants(path, constraints)
        variants = [path]

        # Handle optional segment like `/api/articles/me(/:status)`
        if path =~ /\(\/:([a-z_]+)\)/
          param = Regexp.last_match(1).to_sym
          base = path.sub(/\(\/:[a-z_]+\)/, "")
          regex = constraints[param] || constraints[param.to_s]
          if regex.is_a?(Regexp) && regex.source =~ /\A[a-z0-9_|]+\z/
            variants = [base] + regex.source.split("|").map { |val| path.sub(/\(\/:[a-z_]+\)/, "/#{val}") }
          else
            variants = [base, path.sub(/\(\/:([a-z_]+)\)/, "/:\\1")]
          end
        end

        # Expand pure-literal alternation constraints on named segments (e.g. role: /limited|spam|.../)
        constraints.each do |param, regex|
          next unless regex.is_a?(Regexp) && regex.source =~ /\A[a-z0-9_|]+\z/

          token = ":#{param}"
          next unless variants.any? { |v| v.include?(token) }

          values = regex.source.split("|")
          variants = variants.flat_map do |v|
            if v.include?(token)
              values.map { |val| v.sub(token, val) }
            else
              [v]
            end
          end
        end

        variants.uniq
      end

      def singularize(name)
        s = name.to_s
        return "#{s[0..-4]}y" if s.end_with?("ies")
        return s[0..-2] if s.end_with?("s")

        s
      end

      def pluralize(name)
        s = name.to_s
        return s if s.end_with?("s")

        "#{s}s"
      end
    end

    def initialize(forem_dir:)
      @forem_dir = File.expand_path(forem_dir)
    end

    def extract
      routes_rb = File.join(@forem_dir, "config/routes.rb")
      routes_dir = File.join(@forem_dir, "config/routes")
      raise "Missing Forem routes file: #{routes_rb}" unless File.exist?(routes_rb)

      api_block = extract_api_namespace_block(File.read(routes_rb))
      dsl = DSL.new(forem_dir: @forem_dir, routes_dir: routes_dir)
      dsl.instance_eval(api_block, routes_rb, 1)

      deduplicated = deduplicate_routes(dsl.routes)
      deduplicated.each do |route|
        route.action_implemented = action_implemented?(route.controller, route.action)
      end
      deduplicated.sort_by { |r| [r.path, r.method] }
    end

    # Extracts the top-level `namespace :api ... do ... end` block from routes.rb
    # using Ruby's Ripper lexer so nested blocks, strings, and comments are exact.
    def extract_api_namespace_block(source)
      tokens = Ripper.lex(source)
      lines = source.lines

      start_line = nil
      tokens.each_with_index do |tok, idx|
        next unless tok[1] == :on_ident && tok[2] == "namespace"

        # Look ahead past whitespace/parens for :api
        j = idx + 1
        j += 1 while j < tokens.length && %i[on_sp on_lparen].include?(tokens[j][1])
        if j + 1 < tokens.length && tokens[j][1] == :on_symbeg && tokens[j + 1][1] == :on_ident && tokens[j + 1][2] == "api"
          start_line = tok[0][0]
          break
        end
      end

      raise "Could not find `namespace :api` block in config/routes.rb" unless start_line

      depth = 0
      end_line = nil
      openers = Set.new(%w[do def class module begin case])
      line_start_openers = Set.new(%w[if unless while until for])

      tokens.each_with_index do |tok, idx|
        line_no = tok[0][0]
        next if line_no < start_line
        next unless tok[1] == :on_kw

        kw = tok[2]
        if openers.include?(kw)
          depth += 1
        elsif line_start_openers.include?(kw) && statement_opener?(tokens, idx)
          depth += 1
        elsif kw == "end"
          depth -= 1
          if depth == 0
            end_line = line_no
            break
          end
        end
      end

      raise "Unbalanced `namespace :api` block in config/routes.rb" unless end_line

      lines[(start_line - 1)..(end_line - 1)].join
    end

    private

    # Distinguishes block `if cond` from postfix modifier `foo if cond`.
    def statement_opener?(tokens, idx)
      j = idx - 1
      while j >= 0
        type = tokens[j][1]
        return true if %i[on_nl on_ignored_nl on_semicolon].include?(type)
        return false unless %i[on_sp on_comment].include?(type)

        j -= 1
      end
      true
    end

    # When both v1 and v0 define the same METHOD + PATH (via `draw :api`),
    # keep the v1 entry as canonical. V0-only routes (e.g. /api/events) are kept.
    def deduplicate_routes(routes)
      by_key = {}
      routes.each do |route|
        existing = by_key[route.key]
        if existing.nil? || (existing.api_version != "v1" && route.api_version == "v1")
          by_key[route.key] = route
        end
      end
      by_key.values
    end

    # Checks if `def <action>` exists in the controller or its included API concerns.
    def action_implemented?(controller, action)
      controller_file = File.join(@forem_dir, "app/controllers/#{controller}_controller.rb")
      return false unless File.exist?(controller_file)

      checked = Set.new
      queue = [controller_file]

      until queue.empty?
        file = queue.shift
        next if checked.include?(file) || !File.exist?(file)

        checked << file
        content = File.read(file)
        return true if content.match?(/^\s*def\s+#{Regexp.escape(action)}\b/)

        # Follow `include Api::FooController` -> app/controllers/concerns/api/foo_controller.rb
        content.scan(/^\s*include\s+([A-Z][A-Za-z0-9_:]*)/).flatten.each do |mod_name|
          rel = mod_name.split("::").map { |p| underscore(p) }.join("/")
          concern_file = File.join(@forem_dir, "app/controllers/concerns/#{rel}.rb")
          queue << concern_file if File.exist?(concern_file)
        end

        # Follow class inheritance within app/controllers/
        if content =~ /^\s*class\s+\S+\s+<\s+([A-Z][A-Za-z0-9_:]*)/
          parent = Regexp.last_match(1)
          parent_rel = parent.split("::").map { |p| underscore(p) }.join("/")
          [
            File.join(@forem_dir, "app/controllers/#{parent_rel}.rb"),
            File.join(File.dirname(file), "#{parent_rel}.rb")
          ].each do |candidate|
            queue << candidate if File.exist?(candidate)
          end
        end
      end

      false
    end

    def underscore(str)
      str.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
         .gsub(/([a-z\d])([A-Z])/, '\1_\2')
         .downcase
    end
  end
end
