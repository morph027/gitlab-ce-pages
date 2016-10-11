# GitLab CE Pages [![Build Status](https://travis-ci.org/YuMS/gitlab-ce-pages.svg?branch=master)](https://travis-ci.org/YuMS/gitlab-ce-pages) [![GitHub tag](https://img.shields.io/github/tag/yums/gitlab-ce-pages.svg?maxAge=2592000)]()

This is an unofficial **GitLab Pages** implementation for **GitLab CE (GitLab Community Edition)**, denoted as **GCP**.

Official **GitLab Pages** is only for GiLab EE, as discussed [here](https://gitlab.com/gitlab-org/gitlab-ce/issues/3085) and [here](https://news.ycombinator.com/item?id=10923747).

Actually, there's already [a project](https://github.com/Glavin001/GitLab-Pages) aiming at the same goal as this one. *Luckily*, I found it after my finishing the initial version of this project.

## What can this project do?

This project is almost compatible with official **GitLab Pages**, which means you can directly use [these GitLab Pages examples](https://gitlab.com/groups/pages) and summon **GCP** to handle the rest (if configured correctly of course). If one day, you switched to **GitLab EE** or **GitLab.com**, or Pages is included into **GitLab CE**,  the immigration would be seamless.

Currently, following features are supported:
 * Pages per project with compatible page generation DSL in `.gitlab-ci.yml` (official doc [here](http://docs.gitlab.com/ee/pages/README.html#project-pages))
 * CNAME support

## Usage

The only ~~supported~~ encouraged way to run **GCP** is with [Docker](https://www.docker.com/).

#### Prerequisite
 * **[GitLab CE 8.4+](https://gitlab.com/)**: GCP cooperates with GitLab rather than `^((?!GitLab).)*$` nor `GitLab (8\.[0-3]\..*|[0-7]\..*|[0-7]|8\.3)`

 * **[GitLab CI](https://about.gitlab.com/gitlab-ci/)**: build is essential for everything. If you haven't enabled GitLab CI, you can take this chance to start trying it. It's totally awesome. Here's the [doc](http://doc.gitlab.com/ce/ci/).

#### Further deploying steps
 * Create an peeking account (I'll name it **page**) for **GCP**. This has to be done in order to retrieve artifacts in private projects. Actually, you can also use an privileged (admin) account to peek at those private projects.
 * Go to **Profile Settings** -> **Account** and copy **Private Token**. This will later be used when running Docker.
 * Get Docker image

 ```
  docker pull yums/gitlab-ce-pages:1.2.2
 ```
 
 * Run Docker container with

 ```
  docker run --name gitlab-ce-pages -d --restart=always \
      --env 'PAGE_PRIVATE_TOKEN=private_token_of_peeking_account' \
      --env 'GITLAB_URL=http://gitlab.example.com/' \
      --env 'PROJECT_ROOT=public' \
      --volume /srv/gitlab-ce-pages/public:/home/pages/public/ \
      -p 80:80 \
      yums/gitlab-ce-pages:1.2.2
 ```
 
 * Tell your GitLab users the URL of your **GCP** server. They will use it as **webhook URL**. Note that this URL is the one which can actually access your running Docker instance's exposed port.
 * If you want, import some of [these examples](https://gitlab.com/groups/pages) into your own GitLab, as public projects. This will help your users to start building their own pages quickly by just forking them.

#### Enable for project (I expect you, the reader, to retell the following bullet points to your GitLab users, in your own way):
 * Add peeking (I named it **page**, remember?) account as your project members and grant **Reporter** privilege. If an privileged account is used as peeking account, this step is optional.
 * Set **Webhook** in **Project Settings** -> **Webhooks**, tick only **Build event** and fill in **URL** provided by administrator.
 * Write `.gitlab-ci.yml` like demonstrated in [these examples](https://gitlab.com/groups/pages). Or if your administrator has already imported some of them into GitLab, fork one.
 * Wait for build to complete and check your page under `{GITLAB_CE_PAGE_URL}/{WORKSPACE}/{PROJECT_NAME}`.

#### DNS configuration

Changed in **1.2.2**! No need to manually edit text files.

You can provide a generic internal domain for pages (even provide a fake internal ```gitlab.io```) for all subdomains. Just let your existing DNS server forward all requests for ```gitlab.io``` to your **GCP** server and it will resolve to ```PUBLIC_IP``` for all local pages and further forward all unknown pages to upstream DNS servers (:exclamation: Do not build loops by again forwarding to the server which was asking **GCP**).

Like official ```gitlab.io```, the project name will be used as domain for the resulting page.

You need to run your container with ```--cap-add=NET_ADMIN``` for dnsmasq, expose udp port 53 and add another environment variable called ```PUBLIC_IP```, which is the ip address of your docker host:

 ```
  docker run --name gitlab-ce-pages -d --restart=always \
      --env 'PAGE_PRIVATE_TOKEN=private_token_of_peeking_account' \
      --env 'GITLAB_URL=http://gitlab.example.com/' \
      --env 'PROJECT_ROOT=public' \
      --env 'PUBLIC_IP=x.x.x.x' \
      --volume /srv/gitlab-ce-pages/public:/home/pages/public/ \
      --cap-add=NET_ADMIN \
      -p 80:80 \
      -p 53:53/udp
      yums/gitlab-ce-pages:1.2.2
 ```

## Upgrading
You can easily upgrade your GCP in following steps:

 * pull latest image

 ```
  docker pull yums/gitlab-ce-pages:1.2.2
 ```
 
 * remove running image

 ```
  docker rm -f gitlab-ce-pages
 ```
 
 * start service with new image
 
 ```
  docker run --name gitlab-ce-pages -d --restart=always \
      --env 'PAGE_PRIVATE_TOKEN=private_token_of_peeking_account' \
      --env 'GITLAB_URL=http://gitlab.example.com/' \
      --env 'PROJECT_ROOT=public' \
      --volume /srv/gitlab-ce-pages/public:/home/pages/public/ \
      -p 80:80 \
      yums/gitlab-ce-pages:1.2.2
 ```

## Environment variables
* **PAGE_PRIVATE_TOKEN**: private token of peeking account
* **GITLAB_URL**: GitLab CE URL
* **RELATIVE_URL**: relative URL of **GCP**, with this you can deploy **GCP** under existing domains with some proxy forwarding. This variable should looks like `pages`, without prefix or trailing splashes.
* **PROJECT_ROOT**: root directory of decompressed artifacts file. If set, files inside of **PROJECT_ROOT** directory will be taken out. This variable should looks like `public`, without prefix or trailing splashes. Note that in GitLab's official examples, artifacts are put inside `public` folder and then packed into artifacts.
* **PUBLIC_IP**: ip address of your Docker host to act as DNS server for internal gitlab pages domain.


## Sample `docker-compose.yml`

This is a sample `docker-compose.yml` file for you if you want to use docker-compose. It behaves similarly to the command line version.

    gitlab-ce-pages:
      restart: always
      image: yums/gitlab-ce-pages:1.2.2
      environment:
        - PAGE_PRIVATE_TOKEN=private_token_of_peeking_account
        - GITLAB_URL=http://gitlab.example.com/
        - PROJECT_ROOT=public
      volumes:
        - ./public:/home/pages/public
      ports:
        - "80:80"
        - "53:53/udp"
