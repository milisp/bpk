# bpk

## save time to install macos package.
> install bin packages just download one url.

> brew need to download too much and Compilation time is too long.

## Usage

```sh
bpk install pkg
```

## package files

```txt
pkgs/$pkg/
    info
    link.sh
    version
    url
```

### info

```txt
n: name
d: description
c: bin for check exists
p: prefix for folder to remove or link  # option
r: folder path for remove or link  # option
```

### url

url template `x86_64|https://github.com/ducaale/xh/releases/download/v#v/xh-v#v-x86_64-apple-darwin.tar.gz`

at lease one url template

```txt
all|$url
x86_64|$url
arm64|$url
```

### version or `x86_64_version` or `arm64_version`

```md
version|md5
3.12.2|f88981146d943b5517140fa96e96f153
```
