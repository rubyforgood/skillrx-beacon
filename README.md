# SkillRx Beacon

SkillRx Beacon is a Ruby on Rails API application that manages content synchronisation for edge devices (Beacons) deployed in low-resource medical settings. It replaces the existing Azure-based distribution system with direct device-to-CMS communication.

Beacons are physical devices deployed in healthcare facilities globally that broadcast local Wi-Fi networks, allowing healthcare workers to access training materials via their phones without internet connectivity. This application handles device registration, content assignment, and sync orchestration.

# Ruby for Good

SkillRx Beacon is one of many projects initiated and run by Ruby for Good. You can find out more about Ruby for Good at https://rubyforgood.org.

# Welcome Contributors!

[Contribution guidelines for this project](CONTRIBUTING.md)

# Install & Setup

Clone the codebase
```
git clone git@github.com:rubyforgood/skillrx-beacon.git
```

Run the setup script to prepare the DB and assets
```sh
bin/setup
```

To run the app locally, use:
```
bin/dev
```

# Running specs

```sh
# Default: Run all spec files
$ bundle exec rspec

# Run all spec files in a single directory
$ bundle exec rspec spec/models

# Run a single spec file
$ bundle exec rspec spec/requests/api/v1/devices_spec.rb

# See all options for running specs
$ bundle exec rspec --help
```

# Testing

This project uses:
* `rspec` for testing
* `shoulda-matchers` for expectations
* `factory_bot` for making records

To run tests, simply use `bin/rspec`.
