Pod::Spec.new do |s|
  s.name     = 'Godzippa'
  s.version  = '2.1.1'
  s.license  = 'MIT'
  s.summary  = 'GZip Compression / Decompression Category for NSData and NSFileManager.'
  s.homepage = 'https://github.com/mattt/Godzippa'
  s.social_media_url = 'https://twitter.com/mattt'
  s.author   = { 'Mattt' => 'mattt@me.com' }
  s.source   = { git: 'https://github.com/mattt/Godzippa.git',
                 tag: s.version }
  s.source_files = 'Sources/*.{h,m}'
  s.requires_arc = true

  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'

  s.library = 'z'
end
