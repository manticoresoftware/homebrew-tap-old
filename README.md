[![manticoresearch](https://manticoresearch.com/wp-content/uploads/2018/03/manticoresearch.png)](https://manticoresearch.com) <img src="https://brew.sh/assets/img/homebrew-256x256.png" height="100">

# The Manticore Search Homebrew Tap

This is a custom [Homebrew](https://brew.sh)  tap for Manticore Search. 

Manticore Search is also available in the official [homebrew-core](https://github.com/Homebrew/homebrew-core) channel.

Please note that this tap compile Manticore and don't use bottle. It will install  dependencies required for compiling.

## Setup

To add the custom tap:

```
$ brew tap manticoresoftware/tap
```

## Installing Formulae

```
$ brew install manticoresearch
```

To start as service:

```
$ brew services start manticoresearch
```

The configuration is located at ``/usr/local/etc/manticore/sphinx.conf``

Additional dependencies for indexing are ``mysql@5.7``, ``libpq`` and ``unixodbc``.

Please note that the replication feature is not available on MacOS.

## Additional Information

This tap was created using the Homebrew documentation on [How to Create and Maintain a tap](https://github.com/Homebrew/brew/blob/master/docs/How-to-Create-and-Maintain-a-Tap.md).

You can find additional information in the [Homebrew project README](https://github.com/Homebrew/brew#homebrew).
