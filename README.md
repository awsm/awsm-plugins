# awsm plugins

Install AWSM plugins simply!

[![asciicast](https://asciinema.org/a/47xobdkrq5rszonqh4auih5q2.png)](https://asciinema.org/a/47xobdkrq5rszonqh4auih5q2)

## Bootstrap Install AWSM plugins
Plugins live in ~/.awsm/plugins as a collection of folders (typically git repositories). To install `awsm-plugins` and use it to install other plugins, run the following:

```
brew install jq
mkdir -p ~/.awsm/plugins
git clone git@github.com:awsm/awsm-plugins.git ~/.awsm/plugins
```

#### List
```
awsm plugins list
```

#### Install

```
awsm plugins install awsm-lambda
```

