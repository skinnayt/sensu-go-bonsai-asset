#!/usr/bin/env ruby

require 'json'
require 'yaml'
require 'optparse'
require 'uri'

#build_filters = {
#'alpine:amd64': [
#    "entity.system.os == 'linux'",
#    "entity.system.arch == 'amd64'",
#    "entity.system.platform_family == 'alpine'",
#    "parseInt(entity.system.platform_version.split('.')[0]) > 3",
#  ],
#'alpine:arm64': [
#    "entity.system.os == 'linux'",
#    "entity.system.arch == 'arm64'",
#    "entity.system.platform_family == 'alpine'",
#    "parseInt(entity.system.platform_version.split('.')[0]) > 3",
#  ],
#'alpine3.8:amd64': [
#    "entity.system.os == 'linux'",
#    "entity.system.arch == 'amd64'",
#    "entity.system.platform_family == 'alpine'",
#  ],
#'alpine3.8:arm64': [
#    "entity.system.os == 'linux'",
#    "entity.system.arch == 'arm64'",
#    "entity.system.platform_family == 'alpine'",
#  ],
#'almalinux9:amd64': [
#    "entity.system.os == 'linux'",
#    "entity.system.arch == 'amd64'",
#    "entity.system.platform == 'almalinux'",
#    "entity.system.platform_family == 'rhel'",
#    "entity.system.platform_version.split('.')[0] > '9'",
#  ],
#'almalinux9:arm64': [
#    "entity.system.os == 'linux'",
#    "entity.system.arch == 'arm64'",
#    "entity.system.platform == 'almalinux'",
#    "entity.system.platform_family == 'rhel'",
#    "entity.system.platform_version.split('.')[0] > '9'",
#  ],
#'amzn2:amd64': [
#    "entity.system.os == 'linux'",
#    "entity.system.arch == 'amd64'",
#    "entity.system.platform_family == 'rhel'",
#    "parseInt(entity.system.platform_version.split('.')[0]) > 8",
#  ],
#'amzn2:arm64': [
#    "entity.system.os == 'linux'",
#    "entity.system.arch == 'arm64'",
#    "entity.system.platform_family == 'rhel'",
#    "parseInt(entity.system.platform_version.split('.')[0]) > 8",
#  ],
#'centos8:amd64': [
#    "entity.system.os == 'linux'",
#    "entity.system.arch == 'amd64'",
#    "entity.system.platform_family == 'rhel'",
#    "parseInt(entity.system.platform_version.split('.')[0]) > 8",
#  ],
#'centos8:arm64': [
#    "entity.system.os == 'linux'",
#    "entity.system.arch == 'arm64'",
#    "entity.system.platform_family == 'rhel'",
#    "parseInt(entity.system.platform_version.split('.')[0]) > 8",
#  ],
#'debian10:amd64': [
#    "entity.system.os == 'linux'",
#    "entity.system.arch == 'amd64'",
#    "entity.system.platform_family == 'debian'",
#    "entity.system.platform_version.split('.')[0] > '10'",
#  ],
#'debian10:arm64': [
#    "entity.system.os == 'linux'",
#    "entity.system.arch == 'arm64'",
#    "entity.system.platform_family == 'debian'",
#    "entity.system.platform_version.split('.')[0] > '10'",
#  ],
#'debian11:amd64': [
#    "entity.system.os == 'linux'",
#    "entity.system.arch == 'amd64'",
#    "entity.system.platform_family == 'debian'",
#    "entity.system.platform_version.split('.')[0] > '11'",
#  ],
#'debian11:arm64': [
#    "entity.system.os == 'linux'",
#    "entity.system.arch == 'arm64'",
#    "entity.system.platform_family == 'debian'",
#    "entity.system.platform_version.split('.')[0] > '11'",
#  ],
#'debian12:amd64': [
#    "entity.system.os == 'linux'",
#    "entity.system.arch == 'amd64'",
#    "entity.system.platform_family == 'debian'",
#    "entity.system.platform_version.split('.')[0] > '12'",
#  ],
#'debian12:arm64': [
#    "entity.system.os == 'linux'",
#    "entity.system.arch == 'arm64'",
#    "entity.system.platform_family == 'debian'",
#    "entity.system.platform_version.split('.')[0] > '12'",
#  ],
#'gentoo2.15:amd64': [
#    "entity.system.os == 'linux'",
#    "entity.system.arch == 'amd64'",
#    "entity.system.platform == 'gentoo'",
#    "entity.system.platform_version == '2.15'",
#  ],
#'gentoo2.15:arm64': [
#    "entity.system.os == 'linux'",
#    "entity.system.arch == 'arm64'",
#    "entity.system.platform == 'gentoo'",
#    "entity.system.platform_version == '2.15'",
#  ],
#}

build_filters = {
  'alpine': [
    "entity.system.os == 'linux'",
    "entity.system.platform_family == 'alpine'",
    "parseInt(entity.system.platform_version.split('.')[0]) == 3",
  ],
  'alpine3.8': [
    "entity.system.os == 'linux'",
    "entity.system.platform_family == 'alpine'",
  ],
  'alpine3.16': [
    "entity.system.os == 'linux'",
    "entity.system.platform_family == 'alpine'",
    "parseInt(entity.system.platform_version.split('.')[0]) == 3",
    "parseInt(entity.system.platform_version.split('.')[1]) == 16",
  ],
  'almalinux9': [
    "entity.system.os == 'linux'",
    "entity.system.platform == 'almalinux'",
    "entity.system.platform_family == 'rhel'",
    "entity.system.platform_version.split('.')[0] == '9'",
  ],
  'amzn2': [
    "entity.system.os == 'linux'",
    "entity.system.platform == 'amazon'",
    "entity.system.platform_family == 'rhel'",
    "parseInt(entity.system.platform_version.split('.')[0]) == 2",
  ],
  'centos8': [
    "entity.system.os == 'linux'",
    "entity.system.platform_family == 'rhel'",
    "parseInt(entity.system.platform_version.split('.')[0]) == 8",
  ],
  'debian10': [
    "entity.system.os == 'linux'",
    "entity.system.platform_family == 'debian'",
    "entity.system.platform_version.split('.')[0] == '10'",
  ],
  'debian11': [
    "entity.system.os == 'linux'",
    "entity.system.platform_family == 'debian'",
    "entity.system.platform_version.split('.')[0] == '11'",
  ],
  'debian12': [
    "entity.system.os == 'linux'",
    "entity.system.platform_family == 'debian'",
    "entity.system.platform_version.split('.')[0] == '12'",
  ],
  'gentoo2.15': [
    "entity.system.os == 'linux'",
    "entity.system.platform == 'gentoo'",
    "entity.system.platform_version == '2.15'",
  ],
  'gentoo2.17': [
    "entity.system.os == 'linux'",
    "entity.system.platform == 'gentoo'",
    "entity.system.platform_version == '2.17'",
  ],
}

options = {
  base_url: '',
  dist_dir: 'dist',

  platforms: [],

  plugin_name: '',
  plugin_namespace: '',
  plugin_version: '',
  asset_name: '',

  json: false,
  yaml: false,
}

OptionParser.new do |opt|
  opt.on('-n NAME', '--name NAME', 'Plugin Name') do |v|
    options[:plugin_name] = v
  end

  opt.on('-a ASSET_NAME', '--asset-name ASSET_NAME', 'Plugin name for asset') do |v|
    options[:asset_name] = v
  end

  opt.on('-N NAMESPACE', '--namespace NAMESPACE', 'Plugin Namespace') do |v|
    options[:plugin_namespace] = v
  end

  opt.on('-V VERSION', '--version VERSION', 'Plugin Version') do |v|
    options[:plugin_version] = v
  end

  opt.on('-p PLATFORM PLATFORM', '--platforms PLATFORM PLATFORM', Array, 'Platforms') do |v|
    options[:platforms] |= [*v]
  end

  opt.on('-r RUBY', '--ruby-version RUBY', 'Ruby Version') do |v|
    options[:ruby_version] = v
  end

  opt.on('-u URL', '--url URL', 'Base URL') do |v|
    options[:base_url] = v
  end

  opt.on('-y', '--yaml', 'Output data in YAML') do |v|
    options[:yaml] = true
  end

  opt.on('-j', '--json', 'Output data in JSON') do |v|
    options[:json] = true
  end
end.parse!

if options[:asset_name] == ''
  options[:asset_name] = options[:plugin_name]
end

plugins = {}
platform_arch = {}

options[:platforms].each do |plat|
  unless platform_arch.key?(plat.to_sym)
    platform_arch[plat.to_sym] = []
  end
end

Dir[File.join(options[:dist_dir], '*')].select { |f| File.file?(f) && File.basename(f).match(/\.gz$/) }.each do |plugin|
  mat = /^#{options[:plugin_name]}_#{options[:plugin_version]}_ruby-3.2.0_(?<platform>[a-z0-9.]+)_(?<osname>[a-z]+)_(?<arch>[a-z0-9]+)$/.match(File.basename(plugin, '.tar.gz'))
  if mat.nil?
    puts "#{plugin} did not match"
  else
    plat = mat[:platform].to_sym
    arch = mat[:arch].to_sym
    unless platform_arch.key? plat
      platform_arch[plat] = []
    end
    unless platform_arch[plat].include? arch.to_s
      platform_arch[plat] << arch.to_s
    end
    options[:platforms] << mat[:platform] unless options[:platforms].include? mat[:platform]
    unless plugins.key? plat
      plugins[plat] = {}
    end
    plugins[plat][arch] = File.basename(plugin)
  end
end

shas = {}
File.readlines(File.join(options[:dist_dir], "#{options[:plugin_name]}_#{options[:plugin_version]}_sha512-checksums.txt")).each do |x|
  sha_file = x.split(' ', 2)
  shas[File.basename(sha_file[1]).strip] = sha_file[0]
end

asset_def = {
  type: 'Asset',
  api_version: 'core/v2',
  metadata: {
    name: "#{options[:plugin_namespace]}/#{options[:asset_name]}",
    namespace: 'default',
    annotations: {
      'io.sensu.bonsai.name': options[:plugin_name],
      'io.sensu.bonsai.namespace': options[:plugin_namespace],
      'io.sensu.bonsai.version': options[:plugin_version],
    },
  },
  builds: [],
}

options[:platforms].each do |platform|
  plat = platform.to_sym
  platform_arch[plat].each do |arch|
    asset_url = URI.parse(options[:base_url])
    asset_url.path = File.join(asset_url.path, plugins[plat][arch.to_sym])
    build = {
      filters: [],
      url: asset_url.to_s,
      sha512: shas[plugins[plat][arch.to_sym]],
    }
    build[:filters] = build_filters[platform.to_sym].dup
    build[:filters] << "entity.system.arch == 'ARCH'".sub!(/ARCH/, arch.to_s)
    asset_def[:builds] << build
  end
end

asset_yaml = asset_def.dup
#asset_yaml[:type] = 'Asset'
#asset_yaml[:api_version] = 'core/v2'
asset_yaml[:spec] = {
  builds: asset_yaml.delete(:builds),
}

asset_json = asset_def.dup

File.open(File.join(options[:dist_dir], "asset-#{options[:plugin_name]}_#{options[:plugin_version]}.yaml"), 'w') do |yfh|
  yfh.write(JSON.parse(asset_yaml.to_json).to_yaml)
end

File.open(File.join(options[:dist_dir], "asset-#{options[:plugin_name]}_#{options[:plugin_version]}.json"), 'w') do |jfh|
  jfh.write(asset_json.to_json)
end
