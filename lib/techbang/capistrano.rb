require "techbang/capistrano/version"

module Techbang
  module Capistrano
    def self.load_into(configuration)
      configuration.load do

        # Overrides deploy:assets:precompile task of Capistrano
        #
        # It was originally taken from:
        # https://github.com/AF83/capistrano-af83/blob/master/lib/capistrano/af83/deploy/assets.rb
        #
        set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb config/environments)

        namespace :deploy do
          namespace :assets do

            desc <<-DESC
              Run the asset precompilation rake task. You can specify the full path \
              to the rake executable by setting the rake variable. You can also \
              specify additional environment variables to pass to rake via the \
              asset_env variable. The defaults are:

                set :rake,      "rake"
                set :rails_env, "production"
                set :asset_env, "RAILS_GROUPS=assets"
                set :assets_dependencies, fetch(:assets_dependencies) + %w(config/locales/js)
            DESC
            task :precompile, :roles => lambda { assets_role }, :except => { :no_release => true } do
              from = source.next_revision(current_revision)
              if capture("cd #{latest_release} && #{source.local.diff(from)} -- #{assets_dependencies.join ' '} | wc -l").to_i > 0
                run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile:primary}
              else
                logger.info "Skipping asset pre-compilation because there were no asset changes"
              end

              #
              # The following was taken from Capistrano.
              #

              if capture("ls -1 #{shared_path.shellescape}/#{shared_assets_prefix}/manifest* | wc -l").to_i > 1
                raise "More than one asset manifest file was found in '#{shared_path.shellescape}/#{shared_assets_prefix}'.  If you are upgrading a Rails 3 application to Rails 4, follow these instructions: http://github.com/capistrano/capistrano/wiki/Upgrading-to-Rails-4#asset-pipeline"
              end

              # Sync manifest filenames across servers if our manifest has a random filename
              if shared_manifest_path =~ /manifest-.+\./
                run <<-CMD.compact
                  [ -e #{shared_manifest_path.shellescape} ] || mv -- #{shared_path.shellescape}/#{shared_assets_prefix}/manifest* #{shared_manifest_path.shellescape}
                CMD
              end

              # Copy manifest to release root (for clean_expired task)
              run <<-CMD.compact
                cp -- #{shared_manifest_path.shellescape} #{current_release.to_s.shellescape}/assets_manifest#{File.extname(shared_manifest_path)}
              CMD
            end

          end
        end

      end
    end
  end
end

if Capistrano::Configuration.instance
  Techbang::Capistrano.load_into(Capistrano::Configuration.instance)
end
