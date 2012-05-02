# EnotisPluggableAuth

This gem provides pluggable auth functionality between PSC and eNOTIS.

## Building

This gem is intended to be built into a gemjar for deployment into a PSC instance. In order to build the gem, go to the root of this project and run the following commands:

`gem build enotis_pluggable_auth.gemspec`
`buildr package`

The first command builds the gem. The second command builds the gemjar, and places inside the `target/` folder.

## Modifying

If you want to modify how the gem talks to eNOTIS, modify the `lib/enotis_pluggable_auth.rb` file, and the corresponding tests in `spec/enotis_pluggable_auth_spec.rb`

