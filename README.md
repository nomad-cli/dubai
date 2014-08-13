![Dubai](https://raw.github.com/nomad/nomad.github.io/assets/dubai-banner.png)

[Passbook](http://www.apple.com/ios/whats-new/#passbook) is an iOS 6 feature that manages boarding passes, movie tickets, retail coupons, & loyalty cards. Using the [PassKit API](https://developer.apple.com/library/prerelease/ios/#documentation/UserExperience/Reference/PassKit_Framework/_index.html), developers can register web services to automatically update content on the pass, such as gate changes on a boarding pass, or adding credit to a loyalty card.

Dubai makes it easy to generate `.pkpass` from a script or the command line, allowing you to rapidly iterate on the design and content of your passes, or generate one-offs on the fly.

Pairs nicely with [Rack::Passbook](https://github.com/mattt/rack-passbook).

> Dubai is named for [Dubai, UAE](http://en.wikipedia.org/wiki/Dubai), a center of commerce and trade (and as [Dave Rupert was all-too-eager to point out](https://twitter.com/davatron5000/status/304321180259721216), an unfortunate pun on "Do Buy!").
> It's part of a series of world-class command-line utilities for iOS development, which includes [Cupertino](https://github.com/mattt/cupertino) (Apple Dev Center management), [Shenzhen](https://github.com/mattt/shenzhen) (Building & Distribution), [Houston](https://github.com/mattt/houston) (Push Notifications), and [Venice](https://github.com/mattt/venice) (In-App Purchase Receipt Verification).

## Installation

    $ gem install dubai

## Usage

```ruby
require 'dubai'

Dubai::Passbook.certificate, Dubai::Passbook.password = "/path/to/certificate.p12", "..."

# Example.pass is a directory with files "pass.json", "icon.png" & "icon@2x.png"
File.open("Example.pkpass", 'w') do |f|
  f.write Dubai::Passbook::Pass.new("Example.pass").pkpass.string
end
```

## Comand Line Interface

Dubai also comes with the `pk` binary, which provides a convenient way to generate and preview passes

    $ pk generate Example.pass -T boarding-pass

Dubai comes with templates for all of the different Passbook layouts:

- `boarding-pass`
- `coupon`
- `event-ticket`
- `store-card`
- `generic`

Build a `.pkpass` file (which can previewed with a drag-and-drop onto the iOS Simulator):

    $ pk build Example.pass -c /path/to/certificate.p12

...or serve them from a webserver (which can be previewed by visiting the address on a device or the simulator):

    $ pk serve Example.pass -c /path/to/certificate.p12
    $ open http://localhost:4567/pass.pkpass

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- m@mattt.me

## License

Dubai is available under the MIT license. See the LICENSE file for more info.
