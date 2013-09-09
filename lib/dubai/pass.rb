require 'digest/sha1'
require 'openssl'
require 'base64'
require 'json'
require 'zip'

module Dubai
  module Passbook
    WWDR_CERTIFICATE = <<-EOF
-----BEGIN CERTIFICATE-----
MIIEIzCCAwugAwIBAgIBGTANBgkqhkiG9w0BAQUFADBiMQswCQYDVQQGEwJVUzET
MBEGA1UEChMKQXBwbGUgSW5jLjEmMCQGA1UECxMdQXBwbGUgQ2VydGlmaWNhdGlv
biBBdXRob3JpdHkxFjAUBgNVBAMTDUFwcGxlIFJvb3QgQ0EwHhcNMDgwMjE0MTg1
NjM1WhcNMTYwMjE0MTg1NjM1WjCBljELMAkGA1UEBhMCVVMxEzARBgNVBAoMCkFw
cGxlIEluYy4xLDAqBgNVBAsMI0FwcGxlIFdvcmxkd2lkZSBEZXZlbG9wZXIgUmVs
YXRpb25zMUQwQgYDVQQDDDtBcHBsZSBXb3JsZHdpZGUgRGV2ZWxvcGVyIFJlbGF0
aW9ucyBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQAD
ggEPADCCAQoCggEBAMo4VKbLVqrIJDlI6Yzu7F+4fyaRvDRTes58Y4Bhd2RepQcj
tjn+UC0VVlhwLX7EbsFKhT4v8N6EGqFXya97GP9q+hUSSRUIGayq2yoy7ZZjaFIV
PYyK7L9rGJXgA6wBfZcFZ84OhZU3au0Jtq5nzVFkn8Zc0bxXbmc1gHY2pIeBbjiP
2CsVTnsl2Fq/ToPBjdKT1RpxtWCcnTNOVfkSWAyGuBYNweV3RY1QSLorLeSUheHo
xJ3GaKWwo/xnfnC6AllLd0KRObn1zeFM78A7SIym5SFd/Wpqu6cWNWDS5q3zRinJ
6MOL6XnAamFnFbLw/eVovGJfbs+Z3e8bY/6SZasCAwEAAaOBrjCBqzAOBgNVHQ8B
Af8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUiCcXCam2GGCL7Ou6
9kdZxVJUo7cwHwYDVR0jBBgwFoAUK9BpR5R2Cf70a40uQKb3R01/CF4wNgYDVR0f
BC8wLTAroCmgJ4YlaHR0cDovL3d3dy5hcHBsZS5jb20vYXBwbGVjYS9yb290LmNy
bDAQBgoqhkiG92NkBgIBBAIFADANBgkqhkiG9w0BAQUFAAOCAQEA2jIAlsVUlNM7
gjdmfS5o1cPGuMsmjEiQzxMkakaOY9Tw0BMG3djEwTcV8jMTOSYtzi5VQOMLA6/6
EsLnDSG41YDPrCgvzi2zTq+GGQTG6VDdTClHECP8bLsbmGtIieFbnd5G2zWFNe8+
0OJYSzj07XVaH1xwHVY5EuXhDRHkiSUGvdW0FY5e0FmXkOlLgeLfGK9EdB4ZoDpH
zJEdOusjWv6lLZf3e7vWh0ZChetSPSayY6i0scqP9Mzis8hH4L+aWYP62phTKoL1
fGUuldkzXfXtZcwxN8VaBOhr4eeIA0p1npsoy0pAiGVDdd3LOiUjxZ5X+C7O0qmS
XnMuLyV1FQ==
-----END CERTIFICATE-----
    EOF

    class << self
      attr_accessor :certificate, :password
    end

    class Pass
      attr_reader :pass, :assets

      TYPES = ['boarding-pass', 'coupon', 'event-ticket', 'store-card', 'generic']

      def initialize(directory)
        @assets = Dir[File.join(directory, '*')]
        @pass = File.read(@assets.delete(@assets.detect{|file| File.basename(file) == 'pass.json'}))
      end

      def manifest
        checksums = {}
        checksums['pass.json'] = Digest::SHA1.hexdigest(@pass)

        @assets.each do |file|
          checksums[File.basename(file)] = Digest::SHA1.file(file).hexdigest 
        end

        checksums.to_json
      end

      def pkpass
        Zip::OutputStream.write_buffer do |zip|
          zip.put_next_entry 'pass.json' and zip.write @pass
          zip.put_next_entry 'manifest.json' and zip.write manifest
          zip.put_next_entry 'signature' and zip.write signature(manifest)

          @assets.each do |file|
            zip.put_next_entry File.basename(file) and zip.print IO.read(file)
          end
        end
      end

      private

      def signature(manifest)
        pk7 = OpenSSL::PKCS7.sign(p12.certificate, p12.key, manifest, [wwdr], OpenSSL::PKCS7::BINARY | OpenSSL::PKCS7::DETACHED)
        data = OpenSSL::PKCS7.write_smime(pk7)

        start = %{filename=\"smime.p7s"\n\n}
        finish = "\n\n------"
        data = data[(data.index(start) + start.length)...(data.rindex(finish) + finish.length)]

        Base64.decode64(data)
      end

      def p12
        OpenSSL::PKCS12.new(File.read(Passbook.certificate), Passbook.password)
      end

      def wwdr
        OpenSSL::X509::Certificate.new(WWDR_CERTIFICATE)
      end
    end
  end
end
