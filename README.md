# Flarum Docker image [UNMAINTAINED]

[Flarum](http://flarum.org/) is an open source forum web application written in PHP ([Laravel](http://laravel.com)) and JavaScript ([Mithril](https://lhorie.github.io/mithril/)).

This is a Docker image for the development version of Flarum, which can be used as is to try out the application, or which can be adapted to contribute to Flarum.


## Preparation

Once you run the image, the Flarum application will be made available at [http://flarum.dev](http://flarum.dev), which means that `flarum.dev` needs to point to the IP address that the container is published at.

Assuming that the container is published at the IP address 127.0.0.1 (i.e. `localhost`, see the note below for more information on IP addresses), then you need to add this line to your hosts file (`/etc/hosts` on Linux and OS X, `%SystemRoot%\System32\drivers\etc\hosts` on Windows):

	127.0.0.1 flarum.dev   

**Note** — To configure and/or find out the IP address of a VM-hosted Docker installation, see [https://docs.docker.com/installation/windows/](https://docs.docker.com/installation/windows/) (Windows) and [https://docs.docker.com/installation/mac/](https://docs.docker.com/installation/mac/) (OS X) for guidance if using Boot2Docker. If you're using [Vagrant](https://www.vagrantup.com/), you'll need to set up port forwarding (see [https://docs.vagrantup.com/v2/networking/forwarded_ports.html](https://docs.vagrantup.com/v2/networking/forwarded_ports.html).

*TMI — The [front end's URL is hardcoded](https://github.com/flarum/core/blob/825b4082defbcaa53bfce3d4d284ec317a9e014e/js/admin/src/initializers/boot.js#L16) as `http://flarum.dev` and the [back end's URL is hardcoded](https://github.com/flarum/core/blob/825b4082defbcaa53bfce3d4d284ec317a9e014e/src/Core/Seeders/ConfigTableSeeder.php#L16) as `http://flarum.dev/api`. Forcing the front and the back end to have the same hardcoded hostname requires an extra step to make the hostname resolvable, but it is an easy way to comply with the [same-origin policy](http://en.wikipedia.org/wiki/Same-origin_policy) in a development environment.*

## Usage

Run with:

	docker run -p 80:80 sebp/flarum

Alternatively, if you're using Docker Compose, use an entry such as this one in your `docker-compose.yml` file:

	flarum:
	  image: sebp/flarum
	  ports:
	    - "80:80"

and run with:

	docker-compose up flarum

## Build notes

To make the image consistently rebuildable by Docker (and thus avoid [issues when major things change in the source code](https://github.com/spujadas/flarum-docker/issues/1)), the build process checks out a [specific commit of the flarum/flarum source code](https://github.com/flarum/flarum/commit/d5229bd3d0c060bb95a93b974538cdb204802739) rather than the latest commit.

Two additional workarounds are needed to make that version work:

- As it stands, the flarum/flarum repository uses a [specific commit of the flarum/core repository](https://github.com/flarum/core/tree/825b4082defbcaa53bfce3d4d284ec317a9e014e) as a submodule... but this commit has a major bug (preventing posts from being displayed) that was [corrected in a later commit](https://github.com/flarum/core/commit/e5f2355d179dcb2c141dd58c797377fdbb5c30b6), so the build process checks out a [later (and working) commit of flarum/core](https://github.com/flarum/core/commit/aae3e989c4940671e73095478d4ab9f2939e28e8).
- The build process can't complete due to a missing `extensions_enabled` entry in the `config` table of the `flarum` database ([attempting to fetch it](https://github.com/flarum/core/blob/825b4082defbcaa53bfce3d4d284ec317a9e014e/src/Support/Extensions/ExtensionsServiceProvider.php#L19) leads to a [`foreach (NULL as $extension)` situation](https://github.com/flarum/core/blob/825b4082defbcaa53bfce3d4d284ec317a9e014e/src/Support/Extensions/ExtensionsServiceProvider.php#L22) which [doesn't end well and is a known open issue at the time of writing](https://github.com/flarum/core/issues/76)). The build process therefore 'manually' inserts the missing entry in the database (an alternative workaround that doesn't involve fiddling with the database is to add `'extensions_enabled => '[]'` to the `$config` array in flarum/core's [`/src/Core/Seeders/ConfigTableSeeder.php`](https://github.com/flarum/core/blob/825b4082defbcaa53bfce3d4d284ec317a9e014e/src/Core/Seeders/ConfigTableSeeder.php)).

## About

Written by [Sébastien Pujadas](http://pujadas.net), released under the [MIT license](http://opensource.org/licenses/MIT).
