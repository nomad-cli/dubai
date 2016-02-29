require 'digest/sha1'
require 'openssl'
require 'base64'
require 'json'
require 'zip'

module Dubai
  module Passbook
    WWDR_CERTIFICATE = <<-EOF
-----BEGIN CERTIFICATE-----
MIIEIjCCAwqgAwIBAgIIAd68xDltoBAwDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UE
BhMCVVMxEzARBgNVBAoTCkFwcGxlIEluYy4xJjAkBgNVBAsTHUFwcGxlIENlcnRp
ZmljYXRpb24gQXV0aG9yaXR5MRYwFAYDVQQDEw1BcHBsZSBSb290IENBMB4XDTEz
MDIwNzIxNDg0N1oXDTIzMDIwNzIxNDg0N1owgZYxCzAJBgNVBAYTAlVTMRMwEQYD
VQQKDApBcHBsZSBJbmMuMSwwKgYDVQQLDCNBcHBsZSBXb3JsZHdpZGUgRGV2ZWxv
cGVyIFJlbGF0aW9uczFEMEIGA1UEAww7QXBwbGUgV29ybGR3aWRlIERldmVsb3Bl
ciBSZWxhdGlvbnMgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwggEiMA0GCSqGSIb3
DQEBAQUAA4IBDwAwggEKAoIBAQDKOFSmy1aqyCQ5SOmM7uxfuH8mkbw0U3rOfGOA
YXdkXqUHI7Y5/lAtFVZYcC1+xG7BSoU+L/DehBqhV8mvexj/avoVEkkVCBmsqtsq
Mu2WY2hSFT2Miuy/axiV4AOsAX2XBWfODoWVN2rtCbauZ81RZJ/GXNG8V25nNYB2
NqSHgW44j9grFU57Jdhav06DwY3Sk9UacbVgnJ0zTlX5ElgMhrgWDcHld0WNUEi6
Ky3klIXh6MSdxmilsKP8Z35wugJZS3dCkTm59c3hTO/AO0iMpuUhXf1qarunFjVg
0uat80YpyejDi+l5wGphZxWy8P3laLxiX27Pmd3vG2P+kmWrAgMBAAGjgaYwgaMw
HQYDVR0OBBYEFIgnFwmpthhgi+zruvZHWcVSVKO3MA8GA1UdEwEB/wQFMAMBAf8w
HwYDVR0jBBgwFoAUK9BpR5R2Cf70a40uQKb3R01/CF4wLgYDVR0fBCcwJTAjoCGg
H4YdaHR0cDovL2NybC5hcHBsZS5jb20vcm9vdC5jcmwwDgYDVR0PAQH/BAQDAgGG
MBAGCiqGSIb3Y2QGAgEEAgUAMA0GCSqGSIb3DQEBBQUAA4IBAQBPz+9Zviz1smwv
j+4ThzLoBTWobot9yWkMudkXvHcs1Gfi/ZptOllc34MBvbKuKmFysa/Nw0Uwj6OD
Dc4dR7Txk4qjdJukw5hyhzs+r0ULklS5MruQGFNrCk4QttkdUGwhgAqJTleMa1s8
Pab93vcNIx0LSiaHP7qRkkykGRIZbVf1eliHe2iK5IaMSuviSRSqpd1VAKmuu0sw
ruGgsbwpgOYJd+W+NKIByn/c4grmO7i77LpilfMFY0GCzQ87HUyVpNur+cmV6U/k
TecmmYHpvPm0KdIBembhLoz2IYrF+Hjhga6/05Cdqa3zr/04GpZnMBxRpVzscYqC
tGwPDBUf
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
