# PURR-PUBS

This document describes the process for getting a working hub up and running
with the Clojure based API and ClojureScript based SPA application.


Purpose: 

This procedure will result in a working version of the system that can be
easily ran locally and developed in whatever way you wish. I am not proposing
this as "THE" way that we should do it going forward, but it is a way to get
the system up and running.

## Procedure

1. Create a top level directory

```
mkdir purr
cd purr
mkdir -p data/mysql
mkdir -p data/srv
```

2. Clone all the repos

```sh
#
# Code Repos:
git clone git@github.com:hubzero/hzn-pubs-spa.git
git clone git@github.com:hubzero/hzn-pubs-api.git
git clone git@gitlab.hubzero.org:jbg/hzn-session-auth.git
git clone git@gitlab.hubzero.org:jbg/com_pubs.git
git clone git@github.com:hubzero/hubzero-cms.git
#
# Docker Stuff
git clone git@gitlab.hubzero.org:jbg/hzcms-docker.git
```

3. Ensure Configuration 

**DO THIS ONLY ONCE**

```sh
vim hzcms-docker/app/config/database.php
# Make sure 'host' is referring to the named MySQL instance in docker-compose
```

4. Build the SPA

This will build it once, if you're developing, run the build however
you want for the workflow of your choosing, just make sure directories
are aligned.

```sh
cd hzn-pubs-spa
lein shadow compile hzn
```

5. Bring the system up

```
docker-compose up
```

6. Alter some SQL

**DO THIS ONLY ONCE**

```sql
ALTER TABLE `jos_publication_versions` ADD COLUMN `popupURL` TEXT DEFAULT NULL AFTER `release_notes`;

UPDATE `jos_extensions`
SET `extension_id` = '1469',`name` = 'Projects - Publications',`type` = 'plugin',`element` = 'publications',`folder` = 'projects',`client_id` = '0',`enabled` = '1',`access` = '1',`protected` = '1',`manifest_cache` = '',`params` = '{\"display_limit\":\"50\",\"updatable_areas\":\"\",\"image_types\":\"jpg, jpeg, gif, png\",\"video_types\":\"avi, mpeg, mov, mpg, wmv, rm, mp4\",\"googleview\":\"0\",\"restricted\":\"\",\"new_pubs\":\"1\"}',`custom_data` = '',`system_data` = '',`checked_out` = '1000',`checked_out_time` = '2020-09-16 14:54:44',`ordering` = '8',`state` = '0',`modified` = '2020-09-16 15:00:01',`modified_by` = '1000'
WHERE `extension_id` = '1469';
```

7. Run Composer for the CMS

**DO THIS ONLY ONCE**

PHP-FPM Run Composer:

```sh
docker-compose exec php-fpm bash
# In the container:
cd public/core
php bin/composer install
```

Debian Container, Install Java/Libs:

```sh
docker-compose exec debian bash
# See the script for what it does, it's in the `hzn-pubs-api` repo.
bin/init.sh
```

8. How to Access

Credentials: `hzcms-docker/hubzero.secrets`

Create a Project:

https://localhost/projects

Create a new publication from that project. You should be able to use
the UI, but this link will/should also work:

https://localhost/pubs/#/prjs/1