# cookbook-sentry-cookbook

Installs the [Sentry](https://docs.sentry.io/) error-logging software and all other required dependencies.

## Supported Platforms

Only tested to work in Ubuntu 14.04

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['cookbook-sentry']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### cookbook-sentry::default

Include `cookbook-sentry` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cookbook-sentry::default]"
  ]
}
```

## License and Authors

Author:: Earth U (<iskitingbords @ gmail.com>)
